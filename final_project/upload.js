const admin = require('firebase-admin');
const fs = require('fs');

// Initialize Firebase Admin SDK
admin.initializeApp({
  credential: admin.credential.cert(require('./serviceAccountKey.json'))
});

const db = admin.firestore();

// Read and parse the holidays.json file (array of holidays)
const holidays = JSON.parse(fs.readFileSync('holidays.json', 'utf8'));

async function uploadToFirestore() {
  const collectionRef = db.collection('publicHolidays');

  for (const holiday of holidays) {
    const { name, date } = holiday;

    // Convert date string to Firestore Timestamp
    const parsedDate = new Date(date);

    await collectionRef.add({
      name,
      date: parsedDate
    });

    console.log(`Uploaded: ${name} (${parsedDate.toISOString()})`);
  }

  console.log('✅ All holidays uploaded');
}

uploadToFirestore().catch(console.error);
