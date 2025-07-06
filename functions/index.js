const { onSchedule } = require("firebase-functions/v2/scheduler");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const { initializeApp } = require("firebase-admin/app");

initializeApp();

exports.dailyPenaltyUpdater = onSchedule("every 24 hours", async (event) => {
  const db = getFirestore();
  const now = new Date();

  const snapshot = await db.collection('penalties')
    .where('isPaid', '==', false)
    .get();

  const batch = db.batch();

  snapshot.forEach(doc => {
    const data = doc.data();
    const timestamp = data.timestamp?.toDate();
    if (!timestamp) return;

    const daysElapsed = Math.floor((now - timestamp) / (1000 * 60 * 60 * 24));
    let penaltyAmount = 0;

    if (daysElapsed > 5) {
      penaltyAmount = (daysElapsed - 5) * 2;
    }

    batch.update(doc.ref, { penaltyAmount });
  });

  await batch.commit();
  console.log("✅ Daily penalties updated");
});
