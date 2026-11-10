'use strict';

const PROJECT_ID = 'suno-staging-aaa4d';
const FIELD = 'searchKeywords';
const MIN_LENGTH = 2;
const MAX_LENGTH = 24;
const PAGE_SIZE = 300;

function normalizeText(value) {
  return value.trim().toLowerCase().replace(/\s+/g, ' ');
}

function prefixes(value) {
  const result = [];
  const longest = Math.min(value.length, MAX_LENGTH);
  for (let length = MIN_LENGTH; length <= longest; length += 1) {
    result.push(value.slice(0, length));
  }
  return result;
}

function compareCodeUnits(a, b) {
  return a < b ? -1 : a > b ? 1 : 0;
}

function build(texts, phones) {
  const keywords = new Set();
  for (const text of texts) {
    if (typeof text !== 'string') continue;
    const normalized = normalizeText(text);
    if (!normalized) continue;
    prefixes(normalized).forEach((keyword) => keywords.add(keyword));
    for (const word of normalized.split(' ')) {
      prefixes(word).forEach((keyword) => keywords.add(keyword));
    }
  }
  for (const phone of phones) {
    if (typeof phone !== 'string') continue;
    prefixes(phone.replace(/\D/g, '')).forEach((keyword) => keywords.add(keyword));
  }
  return [...keywords].sort(compareCodeUnits);
}

function userTexts(user) {
  const details =
    user.hostDetails && typeof user.hostDetails === 'object' ? user.hostDetails : {};
  return [
    user.name,
    user.userName,
    user.userID,
    details.userName,
    details.fullName,
    details.district,
    details.state,
  ];
}

function userPhones(user) {
  const { phoneNumber, countryCode } = user;
  return typeof phoneNumber === 'string' && typeof countryCode === 'string'
    ? [phoneNumber, `${countryCode}${phoneNumber}`]
    : [phoneNumber];
}

function forUser(user) {
  return build(userTexts(user), userPhones(user));
}

function forBankAccount(account, user) {
  return build(
    [account.accountHolderName, ...(user ? userTexts(user) : [])],
    user ? userPhones(user) : [],
  );
}

function isSame(current, next) {
  return (
    Array.isArray(current) &&
    current.length === next.length &&
    current.every((value, index) => value === next[index])
  );
}

async function forEachDocument(db, collection, visit) {
  let last = null;
  for (;;) {
    let query = db.collection(collection).orderBy('__name__').limit(PAGE_SIZE);
    if (last) query = query.startAfter(last);
    const snapshot = await query.get();
    for (const document of snapshot.docs) await visit(document);
    if (snapshot.size < PAGE_SIZE) return;
    last = snapshot.docs[snapshot.size - 1];
  }
}

async function main() {
  const { applicationDefault, initializeApp } = require('firebase-admin/app');
  const { getFirestore } = require('firebase-admin/firestore');

  const shouldWrite = process.argv.includes('--write');
  initializeApp({ credential: applicationDefault(), projectId: PROJECT_ID });
  const db = getFirestore();
  const writer = shouldWrite ? db.bulkWriter() : null;
  const stats = {
    users: 0,
    usersChanged: 0,
    accounts: 0,
    accountsChanged: 0,
    missingUpdatedAt: 0,
  };

  console.log(`Project: ${PROJECT_ID}. Mode: ${shouldWrite ? 'WRITE' : 'dry run'}.`);

  const apply = (document, keywords) => {
    if (writer) writer.update(document.ref, { [FIELD]: keywords });
  };

  await forEachDocument(db, 'users', async (document) => {
    const data = document.data();
    const keywords = forUser(data);
    stats.users += 1;
    if (!data.updatedAt) stats.missingUpdatedAt += 1;
    if (isSame(data[FIELD], keywords)) return;
    stats.usersChanged += 1;
    apply(document, keywords);
  });

  await forEachDocument(db, 'bankAccounts', async (document) => {
    const data = document.data();
    const user = await db.collection('users').doc(document.id).get();
    const keywords = forBankAccount(data, user.exists ? user.data() : null);
    stats.accounts += 1;
    if (!data.updatedAt) stats.missingUpdatedAt += 1;
    if (isSame(data[FIELD], keywords)) return;
    stats.accountsChanged += 1;
    apply(document, keywords);
  });

  if (writer) await writer.close();
  console.log(stats);
  if (!shouldWrite) console.log('Nothing was written. Re-run with --write to apply.');
}

if (require.main === module) {
  main().catch((error) => {
    console.error(error.message);
    process.exitCode = 1;
  });
}

module.exports = { build, forUser, forBankAccount };
