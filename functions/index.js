const { onSchedule } = require("firebase-functions/v2/scheduler");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const { initializeApp } = require("firebase-admin/app");

initializeApp();

exports.dailyPenaltyUpdater = onSchedule("every 24 hours", async (event) => {
  const db = getFirestore();
  const now = new Date();

  const snapshot = await db.collection('lending_requests')
    .where('isPaid', '==', false)
    .get();

  const batch = db.batch();

  for (const doc of snapshot.docs) {
    const data = doc.data();
    const timestamp = data.timestamp?.toDate();
    if (!timestamp) continue;

    const daysElapsed = Math.floor((now - timestamp) / (1000 * 60 * 60 * 24));
    const existingAmount = data.penaltyAmount || 0;

    // 🧠 New logic: Add 2 only if more than 5 days have passed
    if (daysElapsed > 5) {
      const updatedAmount = existingAmount + 2;
      batch.update(doc.ref, { penaltyAmount: updatedAmount });

      // Send alert if penalty is starting (was 0 yesterday)
      if (existingAmount === 0) {
        console.log(`📢 Creating alert for user ${data.userId}, penalty started.`);

        await db.collection('alerts').add({
          userId: data.userId,
          message: `📕 Your penalty has started for a book. Return it soon to avoid extra charges.`,
          timestamp: FieldValue.serverTimestamp(),
          isRead: false,
        });
      }
    }
  }

  await batch.commit();
  console.log("✅ Incremental penalties updated & alerts sent.");
});
