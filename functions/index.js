const admin = require("firebase-admin");
const functions = require("firebase-functions");
admin.initializeApp();

const db = admin.firestore();

exports.saveFcmToken = functions.https.onRequest(async (req, res) => {
  if (req.method !== "POST") {
    return res.status(405).send("Method Not Allowed");
  }

  const {userId, token} = req.body;
  if (!userId || !token) {
    return res.status(400).send("Missing userId or token");
  }

  try {
    await db.collection("fcmTokens").doc(userId).set({token});
    return res.status(200).send("Token saved successfully");
  } catch (error) {
    console.error("Error saving token:", error);
    return res.status(500).send("Internal Server Error");
  }
});
