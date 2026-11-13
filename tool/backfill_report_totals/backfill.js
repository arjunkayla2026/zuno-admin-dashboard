'use strict';

const PROJECT_ID = 'suno-staging-aaa4d';
const REPORTS = 'reports';
const REPORTED_USERS = 'reportedUsers';
const PAGE_SIZE = 300;

async function reportedIds(db) {
  const ids = new Set();
  let scanned = 0;
  let last = null;
  for (;;) {
    let query = db
      .collection(REPORTS)
      .orderBy('__name__')
      .select('reported')
      .limit(PAGE_SIZE);
    if (last) query = query.startAfter(last);
    const snapshot = await query.get();
    for (const document of snapshot.docs) {
      scanned += 1;
      const reported = document.get('reported');
      if (typeof reported === 'string' && reported.trim()) ids.add(reported);
    }
    if (snapshot.size < PAGE_SIZE) return { ids: [...ids], scanned };
    last = snapshot.docs[snapshot.size - 1];
  }
}

function totalOf(snapshot) {
  let lastReportedAt = null;
  for (const document of snapshot.docs) {
    const reportedAt = document.get('reportedAt');
    if (
      reportedAt &&
      typeof reportedAt.toMillis === 'function' &&
      (!lastReportedAt || reportedAt.toMillis() > lastReportedAt.toMillis())
    ) {
      lastReportedAt = reportedAt;
    }
  }
  return { totalReceivedCount: snapshot.size, lastReportedAt };
}

async function main() {
  const { applicationDefault, initializeApp } = require('firebase-admin/app');
  const { getFirestore } = require('firebase-admin/firestore');

  const shouldWrite = process.argv.includes('--write');
  initializeApp({ credential: applicationDefault(), projectId: PROJECT_ID });
  const db = getFirestore();
  const stats = { reports: 0, people: 0, created: 0, alreadyCounted: 0 };

  console.log(`Project: ${PROJECT_ID}. Mode: ${shouldWrite ? 'WRITE' : 'dry run'}.`);

  const { ids, scanned } = await reportedIds(db);
  stats.reports = scanned;
  stats.people = ids.length;

  for (const id of ids) {
    const totalRef = db.collection(REPORTED_USERS).doc(id);
    const reportsOfPerson = db.collection(REPORTS).where('reported', '==', id);
    const outcome = await db.runTransaction(async (tx) => {
      const existing = await tx.get(totalRef);
      if (existing.exists) return null;
      const total = totalOf(await tx.get(reportsOfPerson));
      if (shouldWrite) tx.create(totalRef, total);
      return total;
    });
    if (!outcome) {
      stats.alreadyCounted += 1;
      continue;
    }
    stats.created += 1;
    console.log(`${id}: totalReceivedCount=${outcome.totalReceivedCount}`);
  }

  console.log(stats);
  if (!shouldWrite) console.log('Nothing was written. Re-run with --write to apply.');
}

if (require.main === module) {
  main().catch((error) => {
    console.error(error.message);
    process.exitCode = 1;
  });
}

module.exports = { totalOf };
