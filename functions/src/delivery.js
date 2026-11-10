const {FieldValue} = require("firebase-admin/firestore");
const logger = require("firebase-functions/logger");
const {TOKEN_FIELD} = require("./recipients");

const MAX_TOKENS_PER_MULTICAST = 500;
const STALE_TOKEN_ERRORS = new Set([
  "messaging/registration-token-not-registered",
  "messaging/invalid-registration-token",
]);

const removeStaleToken = (owners) => Promise.all(
    owners.map(async ({ref, updateTime}) => {
      try {
        await ref.update(
            {[TOKEN_FIELD]: FieldValue.delete()},
            {lastUpdateTime: updateTime},
        );
      } catch (error) {
        logger.info("Skipped stale token cleanup for a changed document.", {
          documentId: ref.id,
          code: error.code,
        });
      }
    }),
);

const sendBatch = async (messaging, payload, batch) => {
  const tokens = [...batch.keys()];
  let response;
  try {
    response = await messaging.sendEachForMulticast({...payload, tokens});
  } catch (error) {
    logger.error("FCM multicast batch failed.", {
      size: tokens.length,
      code: error.code,
      errorMessage: error.message,
    });
    return {
      successCount: 0,
      failureCount: tokens.length,
      invalidTokensRemoved: 0,
    };
  }

  const stale = tokens.filter((token, index) => {
    const item = response.responses[index];
    return !item.success && item.error &&
      STALE_TOKEN_ERRORS.has(item.error.code);
  });
  await Promise.all(stale.map((token) => removeStaleToken(batch.get(token))));
  return {
    successCount: response.successCount,
    failureCount: response.failureCount,
    invalidTokensRemoved: stale.length,
  };
};

const createDelivery = (messaging, notificationId, {title, message}) => {
  const payload = {
    notification: {title, body: message},
    data: {notificationId, type: "adminNotification"},
  };
  const seenTokens = new Set();
  let batch = new Map();
  const stats = {
    recipientCount: 0,
    tokenCount: 0,
    missingTokenCount: 0,
    successCount: 0,
    failureCount: 0,
    invalidTokensRemoved: 0,
  };

  const flush = async () => {
    if (batch.size === 0) return;
    const sending = batch;
    batch = new Map();
    const result = await sendBatch(messaging, payload, sending);
    stats.successCount += result.successCount;
    stats.failureCount += result.failureCount;
    stats.invalidTokensRemoved += result.invalidTokensRemoved;
  };

  const add = async ({document, token}) => {
    stats.recipientCount += 1;
    if (!token) {
      stats.missingTokenCount += 1;
      return;
    }
    const owner = {ref: document.ref, updateTime: document.updateTime};
    if (seenTokens.has(token)) {
      if (batch.has(token)) batch.get(token).push(owner);
      return;
    }
    seenTokens.add(token);
    stats.tokenCount += 1;
    batch.set(token, [owner]);
    if (batch.size >= MAX_TOKENS_PER_MULTICAST) await flush();
  };

  return {add, flush, stats};
};

module.exports = {createDelivery};
