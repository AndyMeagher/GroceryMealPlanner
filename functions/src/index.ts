import { logger } from "firebase-functions";
import {
  onDocumentCreated,
  onDocumentUpdated,
} from "firebase-functions/v2/firestore";
import { getFirestore } from "firebase-admin/firestore";
import { initializeApp } from "firebase-admin/app";

initializeApp();

const db = getFirestore();
const CACHE_COLLECTION = "groceryItemCategoryCache";

export const getItemCategory = onDocumentCreated(
  "households/{householdId}/groceries/{itemId}",
  async (event) => {
    const eventData = event.data;
    const name = eventData?.data().name.trim().toLowerCase();
    const apiKey = process.env.SPOONACULAR_API_KEY;

    if (!name || !eventData) {
      logger.error("Undefined Name or Event Data");
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
