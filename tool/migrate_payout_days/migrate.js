'use strict';

const fs = require('node:fs');
const path = require('node:path');
const { applicationDefault, initializeApp } = require('firebase-admin/app');
const {
  FieldValue,
  Timestamp,
  getFirestore,
} = require('firebase-admin/firestore');

const PROJECT_ID = 'suno-staging-aaa4d';
const PAYOUTS = 'hostPayouts';
const USERS = 'users';
const BANK_ACCOUNTS = 'bankAccounts';
const BANK_APPROVED = 'approved';
const PAISE_PER_RUPEE = 100;
const apply = process.argv.includes('--apply');

const numberOf = (value) =>
  typeof value === 'number' && Number.isFinite(value) ? value : null;

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

const isOldPending = (data) =>
  data.status === 'pending' && data.pendingAt === undefined;

const sumBy = (records, keep) => {
  const totals = new Map();
  for (const { data } of records) {
    if (!keep(data) || typeof data.hostId !== 'string') continue;
    const amount = numberOf(data.totalAmount) || 0;
    totals.set(data.hostId, (totals.get(data.hostId) || 0) + amount);
  }
  return totals;
};

const callEarningsOf = (details) => {
  const current = numberOf(details.totalCallEarnings);
  if (current !== null) return current;
  const paise = numberOf(details.lifetimeEarningsPaise);
  if (paise !== null) return paise / PAISE_PER_RUPEE;
  const legacy = details.hostEarings && numberOf(
    details.hostEarings.totalCallsEarnings,
  );
  return legacy === null || legacy === undefined ? 0 : legacy;
};

const hostUpdatesOf = (host, {
  unpaid,
  withdrawn,
  clearedPayoutIds,
  bankReady,
}) => {
  const details = host.data().hostDetails || {};
  const updates = {
    'hostDetails.totalCallEarnings': callEarningsOf(details),
    'hostDetails.availableBalance': unpaid,
    'hostDetails.totalWithdrawn': withdrawn,
    'hostDetails.bankReady': bankReady,
  };
  ['revenuePaise', 'lifetimeEarningsPaise', 'hostEarings'].forEach((field) => {
    if (details[field] !== undefined) {
      updates[`hostDetails.${field}`] = FieldValue.delete();
    }
  });
  if (clearedPayoutIds.has(details.pendingPayoutId)) {
    updates['hostDetails.pendingPayoutId'] = FieldValue.delete();
  }
  const stats = details.todayStats;
  if (stats && typeof stats === 'object' && stats.earningsPaise !== undefined) {
    if (numberOf(stats.earnings) === null) {
      updates['hostDetails.todayStats.earnings'] =
        (numberOf(stats.earningsPaise) || 0) / PAISE_PER_RUPEE;
    }
    updates['hostDetails.todayStats.earningsPaise'] = FieldValue.delete();
  }
  return updates;
};

async function main() {
  initializeApp({ credential: applicationDefault(), projectId: PROJECT_ID });
  const firestore = getFirestore();
  console.log(
    `${PROJECT_ID}: ${apply ? 'APPLY' : 'dry run, pass --apply to write'}`,
  );

  const [payoutSnapshot, hostSnapshot, bankSnapshot] = await Promise.all([
    firestore.collection(PAYOUTS).get(),
    firestore.collection(USERS).where('role', '==', 'host').get(),
    firestore.collection(BANK_ACCOUNTS).get(),
  ]);
  const readyHostIds = new Set(bankSnapshot.docs
      .filter((bank) => bank.get('bankAccountStatus') === BANK_APPROVED)
      .map((bank) => bank.id));
  const payouts = payoutSnapshot.docs.map((doc) => ({
    id: doc.id,
    ref: doc.ref,
    data: doc.data(),
  }));
  const cleared = payouts.filter(({ data }) => isOldPending(data));
  const kept = payouts.filter(({ data }) => !isOldPending(data));
  const clearedPayoutIds = new Set(cleared.map(({ id }) => id));
  const unpaidByHost = sumBy(
    kept,
    (data) => ['open', 'pending', 'failed'].includes(data.status),
  );
  const withdrawnByHost = sumBy(kept, (data) => data.status === 'success');

  for (const { id, data } of cleared) {
    console.log(`delete ${PAYOUTS}/${id}: host=${data.hostId} ` +
      `totalAmount=${data.totalAmount}`);
  }
  const hostUpdates = hostSnapshot.docs.map((host) => ({
    host,
    updates: hostUpdatesOf(host, {
      unpaid: unpaidByHost.get(host.id) || 0,
      withdrawn: withdrawnByHost.get(host.id) || 0,
      clearedPayoutIds,
      bankReady: readyHostIds.has(host.id),
    }),
  }));
  const openUpdates = kept
      .filter(({ data }) => data.status === 'open')
      .map(({ id, ref, data }) => ({
        id,
        ref,
        current: data.bankReady,
        bankReady: readyHostIds.has(data.hostId),
      }))
      .filter(({ current, bankReady }) => current !== bankReady);
  for (const { id, bankReady } of openUpdates) {
    console.log(`update ${PAYOUTS}/${id}: bankReady=${bankReady}`);
  }
  for (const { host, updates } of hostUpdates) {
    const summary = Object.entries(updates)
        .map(([field, value]) =>
          `${field.replace('hostDetails.', '')}=${
            value instanceof FieldValue ? 'delete' : value}`)
        .join(' ');
    console.log(`update ${USERS}/${host.id}: ${summary}`);
  }
  console.log(`${cleared.length} old pending payout(s) to delete, ` +
    `${openUpdates.length} open payout(s) and ` +
    `${hostUpdates.length} host(s) to update`);

  if (!apply) return;

  const backupFile = path.resolve(`backup-payout-days-${Date.now()}.json`);
  fs.writeFileSync(backupFile, JSON.stringify({
    hostPayouts: cleared.map(({ id, data }) => ({
      id,
      data: serializable(data),
    })),
    hosts: hostSnapshot.docs.map((host) => ({
      id: host.id,
      hostDetails: serializable(host.data().hostDetails || {}),
    })),
  }, null, 2));
  console.log(`Backup saved to ${backupFile}`);

  const writer = firestore.bulkWriter();
  for (const { ref } of cleared) writer.delete(ref);
  for (const { host, updates } of hostUpdates) writer.update(host.ref, updates);
  for (const { ref, bankReady } of openUpdates) {
    writer.update(ref, { bankReady });
  }
  await writer.close();
  console.log(`Deleted ${cleared.length} payout(s) and updated ` +
    `${openUpdates.length} open payout(s) and ${hostUpdates.length} host(s).`);
}

main().catch((error) => {
  console.error(error.message);
  process.exitCode = 1;
});
