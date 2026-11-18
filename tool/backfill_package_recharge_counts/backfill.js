'use strict';

const PROJECT_ID = 'suno-staging-aaa4d';
const PACKAGES = 'packages';
const TRANSACTIONS = 'transactions';
const COUNT_FIELD = 'totalRechargeCount';

async function main() {
  const { applicationDefault, initializeApp } = require('firebase-admin/app');
  const { getFirestore } = require('firebase-admin/firestore');

  const shouldWrite = process.argv.includes('--write');
  initializeApp({ credential: applicationDefault(), projectId: PROJECT_ID });
  const db = getFirestore();
  const stats = { packages: 0, updated: 0, unchanged: 0 };

  console.log(`Project: ${PROJECT_ID}. Mode: ${shouldWrite ? 'WRITE' : 'dry run'}.`);

  const packages = await db.collection(PACKAGES).select().get();
  stats.packages = packages.size;

  for (const { ref } of packages.docs) {
    const recharges = db
      .collection(TRANSACTIONS)
      .where('packageId', '==', ref.id)
      .where('type', '==', 'recharge')
      .where('status', '==', 'success')
      .select();
    const outcome = await db.runTransaction(async (tx) => {
      const pack = await tx.get(ref);
      if (!pack.exists) return null;
      const count = (await tx.get(recharges)).size;
      const stored = pack.get(COUNT_FIELD);
      if (stored === count) return { count, stored, changed: false };
      if (shouldWrite) tx.update(ref, { [COUNT_FIELD]: count });
      return { count, stored, changed: true };
    });
    if (!outcome || !outcome.changed) {
      stats.unchanged += 1;
      continue;
    }
    stats.updated += 1;
    console.log(`${ref.id}: ${COUNT_FIELD} ${outcome.stored ?? '(missing)'} -> ${outcome.count}`);
  }

  console.log(stats);
  if (!shouldWrite) console.log('Nothing was written. Re-run with --write to apply.');
}

main().catch((error) => {
  console.error(error.message);
  process.exitCode = 1;
});
