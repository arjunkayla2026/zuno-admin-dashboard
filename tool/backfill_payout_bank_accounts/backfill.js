'use strict';

const PROJECT_ID = 'suno-staging-aaa4d';
const PAYOUTS = 'hostPayouts';
const BANK_ACCOUNTS = 'bankAccounts';
const BANK_FIELD = 'bankAccount';
const AWAITING_PAYMENT = ['pending', 'failed'];

const snapshotOf = (bank) =>
  bank.exists && bank.get('bankAccountStatus') === 'approved'
    ? {
        accountHolderName: bank.get('accountHolderName') || null,
        branchName: bank.get('branchName') || null,
        accountNo: bank.get('accountNo') || null,
        ifscCode: bank.get('ifscCode') || null,
        panNumber: bank.get('panNumber') || null,
      }
    : null;

async function main() {
  const { applicationDefault, initializeApp } = require('firebase-admin/app');
  const { getFirestore } = require('firebase-admin/firestore');

  const shouldWrite = process.argv.includes('--write');
  initializeApp({ credential: applicationDefault(), projectId: PROJECT_ID });
  const db = getFirestore();
  const stats = { payouts: 0, withCopy: 0, filled: 0, noApprovedAccount: 0, skipped: 0 };

  console.log(`Project: ${PROJECT_ID}. Mode: ${shouldWrite ? 'WRITE' : 'dry run'}.`);

  const payouts = await db.collection(PAYOUTS).where('status', 'in', AWAITING_PAYMENT).get();
  stats.payouts = payouts.size;

  for (const document of payouts.docs) {
    if (document.data()[BANK_FIELD] !== undefined) {
      stats.withCopy += 1;
      continue;
    }
    const hostId = document.get('hostId');
    if (typeof hostId !== 'string' || hostId.length === 0) {
      stats.skipped += 1;
      console.log(`${document.id}: skipped, no hostId`);
      continue;
    }
    const outcome = await db.runTransaction(async (tx) => {
      const [payout, bank] = await Promise.all([
        tx.get(document.ref),
        tx.get(db.collection(BANK_ACCOUNTS).doc(hostId)),
      ]);
      if (!payout.exists || !AWAITING_PAYMENT.includes(payout.get('status'))) return null;
      if (payout.data()[BANK_FIELD] !== undefined) return null;
      const snapshot = snapshotOf(bank);
      if (shouldWrite) tx.update(document.ref, { [BANK_FIELD]: snapshot });
      return { snapshot };
    });
    if (!outcome) {
      stats.skipped += 1;
      continue;
    }
    if (outcome.snapshot) {
      stats.filled += 1;
      console.log(`${document.id}: copy bank account ending ${String(outcome.snapshot.accountNo || '').slice(-4)}`);
    } else {
      stats.noApprovedAccount += 1;
      console.log(`${document.id}: no approved bank account, store null`);
    }
  }

  console.log(stats);
  if (!shouldWrite) console.log('Nothing was written. Re-run with --write to apply.');
}

main().catch((error) => {
  console.error(error.message);
  process.exitCode = 1;
});
