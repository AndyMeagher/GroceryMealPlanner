import { onRequest } from "firebase-functions/v2/https";
import { logger } from "firebase-functions";
import { getFirestore } from "firebase-admin/firestore";
import { initializeApp } from "firebase-admin/app";

initializeApp();

const db = getFirestore();
const CACHE_COLLECTION = "groceryItemCategoryCache";

export const getItemCategory = onRequest(async (req, res) => {
  const name = (req.query.name as string).trim().toLowerCase();
  const apiKey = process.env.SPOONACULAR_API_KEY;

  if (!name) {
    res.status(400).send({ error: "Missing name parameter" });
    return;
  }

  const cacheKey = name;
  const cacheRef = db.collection(CACHE_COLLECTION).doc(cacheKey);

  // 1. Check cache
  const cached = await cacheRef.get();
  if (cached.exists) {
    logger.info(`Cache hit: ${cacheKey}`);
    res.send({ aisle: cached.data()!.aisle });
    return;
  }

  // 2. Cache miss — call Spoonacular
  logger.info(`Cache miss: ${cacheKey}`);

  const response = await fetch(
    `https://api.spoonacular.com/food/ingredients/search?query=${encodeURIComponent(name)}&number=1&metaInformation=true&apiKey=${apiKey}`,
  );
  const data = await response.json();
  const aisle = data.results?.[0]?.aisle || "Unknown";
  res.set("Connection", "close");

  if (aisle !== "Unknown") {
    cacheRef
      .set({ aisle })
      .catch((err) => logger.error("Cache write failed", err));
  }

  res.send({ aisle });
});
