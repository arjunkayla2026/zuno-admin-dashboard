'use strict';

const fs = require('node:fs');
const path = require('node:path');
const { applicationDefault, initializeApp } = require('firebase-admin/app');
const { Timestamp, getFirestore } = require('firebase-admin/firestore');

const PROJECT_ID = 'suno-staging-aaa4d';
const COLLECTION = 'transactions';
const apply = process.argv.includes('--apply');

const serializable = (value) => {
  if (value instanceof Timestamp) return value.toDate().toISOString();
  if (Array.isArray(value)) return value.map(serializable);
  if (value !== null && typeof value === 'object') {
    return Object.fromEntries(
      Object.entries(value).map(([key, item]) => [key, serializable(item)]),
    );
  }
  return value;
};

async function main() {
  initializeApp({ credential: applicationDefault(), projectId: PROJECT_ID });
  const firestore = getFirestore();
  const mode = apply ? 'APPLY' : 'dry run, pass --apply to delete';
  console.log(`${PROJECT_ID}/${COLLECTION}: ${mode}`);

  const snapshot = await firestore.collection(COLLECTION).get();
  for (const document of snapshot.docs) {
    const { type, status, userId } = document.data();
    console.log(`${document.id}: type=${type} status=${status} userId=${userId}`);
  }
  console.log(`${snapshot.size} document(s) found`);

  if (!apply || snapshot.empty) return;

  const backupFile = path.resolve(`backup-${COLLECTION}-${Date.now()}.json`);
  fs.writeFileSync(
    backupFile,
    JSON.stringify(
      snapshot.docs.map((document) => ({
        id: document.id,
        data: serializable(document.data()),
      })),
      null,
      2,
    ),
  );
  console.log(`Backup saved to ${backupFile}`);

  const writer = firestore.bulkWriter();
  for (const document of snapshot.docs) writer.delete(document.ref);
  await writer.close();
  console.log(`Deleted ${snapshot.size} document(s).`);
}

main().catch((error) => {
  console.error(error.message);
  process.exitCode = 1;
});
