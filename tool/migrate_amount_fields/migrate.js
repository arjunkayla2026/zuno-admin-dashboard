'use strict';

const fs = require('node:fs');
const path = require('node:path');
const { applicationDefault, initializeApp } = require('firebase-admin/app');
const { FieldValue, getFirestore } = require('firebase-admin/firestore');

const PROJECT_ID = 'suno-staging-aaa4d';
const apply = process.argv.includes('--apply');
const dropOld = process.argv.includes('--drop-old');

const CREDIT_TYPES = new Set(['credit', 'adminCredit']);
const DEBIT_TYPES = new Set(['debit', 'adminDebit']);
const COMPLETED_STATUSES = new Set(['success', 'completed']);
const OLD_TRANSACTION_FIELDS = [
  'amount',
  'amountInPaise',
  'creditAmount',
  'extraAmount',
  'totalAmount',
  'adminCreditedAmount',
  'adminDebitedAmount',
];
const OLD_WALLET_FIELDS = ['rechargeExtra', 'topUp'];
const NEW_WALLET_FIELD = 'rechargeAmount';

const firstNumber = (...values) =>
  values.find((value) => typeof value === 'number' && Number.isFinite(value));
const round2 = (value) => Math.round(value * 100) / 100;
const hasAny = (data, keys) => keys.some((key) => key in data);
const oldFieldsOf = (data, keys) =>
  Object.fromEntries(keys.filter((key) => key in data).map((key) => [key, data[key]]));

function transactionAmounts(data) {
  const paise =
    typeof data.amountInPaise === 'number' ? data.amountInPaise / 100 : undefined;
  const isCredit = CREDIT_TYPES.has(data.type);
  const isDebit = DEBIT_TYPES.has(data.type);
  const source = isCredit
    ? firstNumber(data.adminCreditedAmount, data.totalAmount, data.amount)
    : isDebit
      ? firstNumber(data.adminDebitedAmount, data.totalAmount, data.amount)
      : firstNumber(data.totalAmount, paise, data.amount, data.rechargeAmount);
  const amount = round2(source ?? 0);
  const isCompleted = COMPLETED_STATUSES.has(data.status);

  return {
    missingAmount: source === undefined,
    fields: {
      rechargeAmount: isCredit || isDebit ? 0 : amount,
      adminCreditAmount: isCredit ? amount : 0,
      adminDebitAmount: isDebit ? amount : 0,
      amountFromOffer:
        isCredit || isDebit ? 0 : round2(firstNumber(data.extraAmount) ?? 0),
      receivedTotalAmount: isCompleted && !isDebit ? amount : 0,
    },
  };
}

function transactionChange(data) {
  const { fields, missingAmount } = transactionAmounts(data);
  const update = {};
  for (const [key, value] of Object.entries(fields)) {
    if (!(key in data)) update[key] = value;
  }
  if (dropOld) {
    for (const key of OLD_TRANSACTION_FIELDS) {
      if (key in data) update[key] = FieldValue.delete();
    }
  }
  return {
    update,
    backup: oldFieldsOf(data, OLD_TRANSACTION_FIELDS),
    warning: missingAmount ? 'no amount found, using 0' : null,
  };
}

function packageChange(data) {
  const update = {};
  if (!('rechargeAmount' in data) && 'payableAmount' in data) {
    update.rechargeAmount = data.payableAmount;
  }
  if (dropOld && 'payableAmount' in data) {
    update.payableAmount = FieldValue.delete();
  }
  return { update, backup: oldFieldsOf(data, ['payableAmount']), warning: null };
}

function userChange(data) {
  const sources = data.walletSources;
  if (sources === null || typeof sources !== 'object') {
    return { update: {}, backup: {}, warning: null };
  }

  const update = {};
  if (!(NEW_WALLET_FIELD in sources) && hasAny(sources, OLD_WALLET_FIELDS)) {
    update[`walletSources.${NEW_WALLET_FIELD}`] =
      firstNumber(sources.rechargeExtra) ?? 0;
  }
  if (dropOld) {
    for (const key of OLD_WALLET_FIELDS) {
      if (key in sources) update[`walletSources.${key}`] = FieldValue.delete();
    }
  }
  return {
    update,
    backup: oldFieldsOf(sources, OLD_WALLET_FIELDS),
    warning: null,
  };
}

const COLLECTIONS = [
  ['packages', packageChange],
  ['users', userChange],
  ['transactions', transactionChange],
];

function describe(update) {
  return Object.entries(update)
    .map(([key, value]) =>
      value instanceof FieldValue ? `-${key}` : `${key}=${JSON.stringify(value)}`,
    )
    .join(', ');
}

async function main() {
  initializeApp({ credential: applicationDefault(), projectId: PROJECT_ID });
  const firestore = getFirestore();
  const mode = apply ? 'APPLY' : 'dry run, pass --apply to write';
  console.log(`${PROJECT_ID}: ${mode}${dropOld ? ', removing old fields' : ''}`);

  const changes = [];
  for (const [collection, changeFor] of COLLECTIONS) {
    const snapshot = await firestore.collection(collection).get();
    let changed = 0;
    for (const document of snapshot.docs) {
      const { update, backup, warning } = changeFor(document.data());
      if (Object.keys(update).length === 0) continue;
      changed += 1;
      changes.push({ collection, ref: document.ref, update, backup });
      console.log(`${collection}/${document.id}: ${describe(update)}`);
      if (warning) console.warn(`  WARNING ${collection}/${document.id}: ${warning}`);
    }
    console.log(`${collection}: ${changed} of ${snapshot.size} document(s) to change\n`);
  }

  if (!apply || changes.length === 0) return;

  const backupFile = path.resolve(`backup-${Date.now()}.json`);
  fs.writeFileSync(
    backupFile,
    JSON.stringify(
      changes.map(({ collection, ref, backup }) => ({
        collection,
        id: ref.id,
        oldFields: backup,
      })),
      null,
      2,
    ),
  );
  console.log(`Old values saved to ${backupFile}`);

  const writer = firestore.bulkWriter();
  for (const { ref, update } of changes) writer.update(ref, update);
  await writer.close();
  console.log(`Updated ${changes.length} document(s).`);
}

main().catch((error) => {
  console.error(error.message);
  process.exitCode = 1;
});
