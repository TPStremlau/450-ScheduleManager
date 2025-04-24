const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

/**
 * Cloud Function to notify users of upcoming events via FCM.
 */
exports.scheduledEventNotifier = onSchedule(
  {
    schedule: "every 1 minutes",
    timeZone: "America/New_York"
  },
  async () => {
    console.log("✅ Running scheduledEventNotifier");

    const now = admin.firestore.Timestamp.now();
    const snapshot = await db.collection("events")
      .where("notifyAt", "<=", now)
      .where("notificationsEnabled", "==", true)
      .where("notificationSent", "!=", true)
      .get();

    console.log(`📦 Matched event docs: ${snapshot.size}`);
    snapshot.docs.forEach(doc => {
      const data = doc.data();
      console.log(`📝 Event: ${doc.id} - notifyAt: ${data.notifyAt?.toDate()} - notificationsEnabled: ${data.notificationsEnabled} - notificationSent: ${data.notificationSent}`);
    });

    const tasks = snapshot.docs.map(async (doc) => {
      const data = doc.data();

      const userDoc = await db.collection("users").doc(data.createdBy).get();
      const userData = userDoc.data();
      const token = userData?.fcmToken;

      if (!token) {
        console.log(`⚠️ No token for user ${data.createdBy}`);
        return;
      }

      const message = {
        token: token,
        notification: {
          title: `Upcoming: ${data.eventName}`,
          body: "Your event is starting soon.",
        },
        data: {
          eventId: doc.id,
        },
      };

      try {
        console.log(`➡️ Attempting to send notification to: ${token}`);
        const response = await admin.messaging().send(message);
        console.log(`✅ Notification sent: ${response}`);
        await doc.ref.update({ notificationSent: true });
      } catch (error) {
        console.error(`❌ Failed to send notification: ${error}`);
      }
    });

    await Promise.all(tasks);
    return null;
  }
);
