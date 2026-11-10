'use strict';

const { applicationDefault, initializeApp } = require('firebase-admin/app');
const { FieldValue, getFirestore } = require('firebase-admin/firestore');

const PROJECT_ID = 'suno-staging-aaa4d';
const COLLECTION = 'packages';
const COINS_PER_RUPEE = 15;
const STATUSES = ['active', 'inactive'];
const ALLOWED_FIELDS = new Set([
  'coins',
  'createdAt',
  'updatedAt',
  'offerPercentage',
  'offerTag',
  'packageStatus',
  'rechargeAmount',
  'receivableAmount',
  'isGstEnabled',
]);

const apply = process.argv.includes('--apply');

const round2 = (value) => Math.round(value * 100) / 100;
const toNumber = (value) =>
  typeof value === 'number' && Number.isFinite(value) ? value : null;
const toText = (value) => (typeof value === 'string' ? value.trim() : '');

function percentFrom(text) {
  const match = /(\d+(?:\.\d+)?)\s*%/.exec(text);
  return match ? Number(match[1]) : null;
}

function migrate(data) {
  const receivable = round2(toNumber(data.receivableAmount) ?? 0);
  const gstAmount = toNumber(data.gst_amount);
  const payable = round2(
    toNumber(data.rechargeAmount) ??
      toNumber(data.payableAmount) ??
      receivable + (gstAmount ?? 0),
  );
  const legacyOffer = toText(data.offer);
  const offerTag = toText(data.offerTag) || legacyOffer;
  const offerPercentage = round2(
    toNumber(data.offerPercentage) ?? percentFrom(legacyOffer) ?? 0,
  );
  const isGstEnabled =
    typeof data.isGstEnabled === 'boolean'
      ? data.isGstEnabled
      : typeof data.gstEnabled === 'boolean'
        ? data.gstEnabled
        : payable > receivable;

  const update = {
    coins: Math.round(
      toNumber(data.coins) ?? receivable * COINS_PER_RUPEE,
    ),
    rechargeAmount: payable,
    receivableAmount: receivable,
    offerTag,
    offerPercentage,
    packageStatus: STATUSES.includes(data.packageStatus)
      ? data.packageStatus
      : 'active',
    isGstEnabled,
    updatedAt: FieldValue.serverTimestamp(),
  };
  if (!data.createdAt) update.createdAt = FieldValue.serverTimestamp();

  const removed = Object.keys(data).filter((key) => !ALLOWED_FIELDS.has(key));
  for (const key of removed) update[key] = FieldValue.delete();

  return { update, removed };
}

function describe(update) {
  const shown = {};
  for (const [key, value] of Object.entries(update)) {
    shown[key] = value instanceof FieldValue ? `<${value.constructor.name}>` : value;
  }
  return shown;
}

async function main() {
  initializeApp({ credential: applicationDefault(), projectId: PROJECT_ID });
  const firestore = getFirestore();
  const snapshot = await firestore.collection(COLLECTION).get();
  console.log(
    `${snapshot.size} document(s) in ${PROJECT_ID}/${COLLECTION}` +
      (apply ? ' — applying changes' : ' — dry run, pass --apply to write'),
  );

  const batch = firestore.batch();
  for (const document of snapshot.docs) {
    const before = document.data();
    const { update, removed } = migrate(before);
    console.log(`\n${document.id}`);
    console.log('  before :', JSON.stringify(before));
    console.log('  update :', JSON.stringify(describe(update)));
    if (removed.length) console.log('  removes:', removed.join(', '));
    batch.update(document.ref, update);
  }

  if (apply && !snapshot.empty) {
    await batch.commit();
    console.log(`\nUpdated ${snapshot.size} document(s).`);
  }
}

main().catch((error) => {
  console.error(error.message);
  process.exitCode = 1;
});
