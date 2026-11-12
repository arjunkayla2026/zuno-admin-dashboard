'use strict';

const { applicationDefault, initializeApp } = require('firebase-admin/app');
const { FieldValue, getFirestore } = require('firebase-admin/firestore');

const PROJECT_ID = 'suno-staging-aaa4d';
const COLLECTION = 'settings';
const DOCUMENT = 'app';

const platformVersion = () => ({
  minimumVersion: '1.0.0',
  currentVersion: '1.0.0',
  minimumBuildNumber: 1,
  currentBuildNumber: 1,
  forceUpdate: false,
  storeUrl: '',
});

const channelPrice = () => ({
  adminAmount: 0,
  hostAmount: 0,
});

const DEFAULTS = {
  isMaintenanceMode: false,
  setHostPrice: {
    audio: channelPrice(),
    video: channelPrice(),
    message: { adminAmount: 0 },
    surgeCharge: [],
  },
  appVersion: {
    android: platformVersion(),
    ios: platformVersion(),
    updateMessage: 'A new version of Zuno is available. Update to continue.',
  },
};

const apply = process.argv.includes('--apply');

const isPlainObject = (value) =>
  value !== null && typeof value === 'object' && !Array.isArray(value);

function missingFields(defaults, existing) {
  const result = {};
  for (const [key, value] of Object.entries(defaults)) {
    const current = existing?.[key];
    if (isPlainObject(value)) {
      const nested = missingFields(value, isPlainObject(current) ? current : undefined);
      if (Object.keys(nested).length) result[key] = nested;
    } else if (current === undefined) {
      result[key] = value;
    }
  }
  return result;
}

async function main() {
  initializeApp({ credential: applicationDefault(), projectId: PROJECT_ID });
  const reference = getFirestore().collection(COLLECTION).doc(DOCUMENT);
  const snapshot = await reference.get();
  const existing = snapshot.exists ? snapshot.data() : undefined;
  const update = missingFields(DEFAULTS, existing);

  console.log(
    `${PROJECT_ID}/${COLLECTION}/${DOCUMENT} ` +
      (snapshot.exists ? 'exists' : 'does not exist') +
      (apply ? ' — applying changes' : ' — dry run, pass --apply to write'),
  );
  console.log('  current:', JSON.stringify(existing ?? null));
  console.log('  adds   :', JSON.stringify(update));

  if (!Object.keys(update).length) {
    console.log('\nNothing to add; existing values are kept.');
    return;
  }
  if (apply) {
    await reference.set(
      {
        ...update,
        ...(snapshot.exists ? {} : { createdAt: FieldValue.serverTimestamp() }),
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
    console.log('\nSaved.');
  }
}

main().catch((error) => {
  console.error(error.message);
  process.exitCode = 1;
});
