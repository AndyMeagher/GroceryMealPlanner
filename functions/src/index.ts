import { logger } from "firebase-functions";
import {
  onDocumentCreated,
  onDocumentUpdated,
} from "firebase-functions/v2/firestore";
import { getFirestore } from "firebase-admin/firestore";
import { initializeApp } from "firebase-admin/app";
import { onCall } from "firebase-functions/https";
import Anthropic from "@anthropic-ai/sdk";
import * as cheerio from "cheerio";
import { HttpsError } from "firebase-functions/https";

initializeApp();

const db = getFirestore();
const CACHE_COLLECTION = "groceryItemCategoryCache";

export const getItemCategory = onDocumentCreated(
  "households/{householdId}/groceries/{itemId}",
  async (event) => {
    const eventData = event.data;
    const name = eventData?.data().name.trim().toLowerCase();
    const category = eventData?.data().category;
    const apiKey = process.env.SPOONACULAR_API_KEY;

    if (!name || !eventData) {
      logger.error("Undefined Name or Event Data");
      return;
    }

    if (category === "Costco") {
      logger.info(`Skipping categorization for Costco item: ${name}`);
      return;
    }

    const cacheKey = name;
    const cacheRef = db.collection(CACHE_COLLECTION).doc(cacheKey);

    // 1. Check cache
    const cached = await cacheRef.get();
    if (cached.exists) {
      logger.info(`Cache hit: ${cacheKey}`);
      await eventData.ref.update({ category: cached.data()!.aisle });
      return;
    }

    // 2. Cache miss — call Spoonacular
    logger.info(`Cache miss: ${cacheKey}`);

    const response = await fetch(
      `https://api.spoonacular.com/food/ingredients/search?query=${encodeURIComponent(name)}&number=1&metaInformation=true&apiKey=${apiKey}`,
    );
    const data = await response.json();
    const aisle = data.results?.[0]?.aisle || "Unknown";

    if (aisle !== "Unknown") {
      cacheRef
        .set({ aisle })
        .catch((err) => logger.error("Cache write failed", err));
    }

    await eventData.ref.update({ category: aisle });
  },
);

export const updateItemCategoryCache = onDocumentUpdated(
  "households/{householdId}/groceries/{itemId}",
  async (event) => {
    const before = event.data!.before.data();
    const after = event.data!.after.data();

    if (before.category === after.category) return;

    const cacheKey = after.name.trim().toLowerCase();
    const cacheRef = db.collection(CACHE_COLLECTION).doc(cacheKey);

    cacheRef
      .set({ aisle: after.category })
      .catch((err) => logger.error("Cache write failed", err));
  },
);

export const importRecipeFromUrl = onCall(
  { secrets: ["AIKEY"] },
  async (request) => {
    const { url } = request.data;
    const anthropic = new Anthropic({
      apiKey: process.env.AIKEY,
    });

    const response = await fetch(url, {
      headers: { "User-Agent": "Mozilla/5.0" },
    });

    const html = await response.text();

    // strip it down
    const $ = cheerio.load(html);
    $("nav, header, footer, script, style, iframe").remove();

    // try specific recipe container first
    const recipeContent = $("#recipe").next();

    var cleaned;
    if (recipeContent.length) {
      cleaned = recipeContent.text().replace(/\s+/g, " ").trim();
    } else {
      // fall back to main content
      const main = $(
        "main, article, [class*='recipe'], [class*='content']",
      ).first();
      cleaned = main.length ? main.text() : $("body").text();
      cleaned = cleaned.replace(/\s+/g, " ").trim();
    }

    if (cleaned.length == 0) {
      throw new HttpsError("not-found", "No recipe found at this URL");
    }

    const anthropicResponse = await anthropic.messages.create({
      model: "claude-sonnet-4-6",
      max_tokens: 1024,
      messages: [
        {
          role: "user",
          content: `You are a recipe extraction assistant. Extract the recipe from the following text and return it as a JSON object with exactly this shape:

            {
              "name": "string",
              "instructions": "string",
              "ingredients": [
                { "name": "string", "quantity": "string" }
              ]
            }

            Rules:
            - Return only the JSON object, no explanation, no markdown, no code blocks
            - Instructions should be a single string with each step separated by a newline
            - If you cannot find a recipe in the text, return { "error": "no recipe found" }
            - quantity must always be a string, never a number. Write "2 pieces" not 2
            
            Text:
            ${cleaned}`,
        },
      ],
    });

    const text =
      anthropicResponse.content[0].type === "text"
        ? anthropicResponse.content[0].text
        : "";

    try {
      const recipe = JSON.parse(text);
      return { recipe: recipe };
    } catch (e) {
      throw new HttpsError("internal", "Failed to parse recipe from this URL");
    }
  },
);

export const createNewRecipeFromIngredients = onCall(
  { secrets: ["AIKEY"] },
  async (request) => {
    //const { ingredients } = request.data;
    // const anthropic = new Anthropic({
    //   apiKey: process.env.AIKEY,
    // });
    // ask ai to create a recipe
    return { success: true };
  },
);
