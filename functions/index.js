const {initializeApp} = require("firebase-admin/app");
const {FieldValue, getFirestore} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");
const {setGlobalOptions} = require("firebase-functions");
const {HttpsError, onCall} = require("firebase-functions/https");
const logger = require("firebase-functions/logger");
const {requireNotificationAdmin} = require("./src/admin_access");
const {createDelivery} = require("./src/delivery");
const {parseNotificationRequest} = require("./src/notification_request");
const {recipientsFor} = require("./src/recipients");

initializeApp();
setGlobalOptions({region: "asia-south1", maxInstances: 10});

const NOTIFICATIONS_COLLECTION = "notifications";

const statusFor = ({tokenCount, successCount, failureCount}) => {
  if (tokenCount === 0) return "noRecipients";
  if (failureCount === 0) return "sent";
  if (successCount === 0) return "failed";
  return "partiallySent";
};

exports.sendAdminNotification = onCall(
    {timeoutSeconds: 540, memory: "512MiB"},
    async (callRequest) => {
      const firestore = getFirestore();
      const admin = await requireNotificationAdmin(firestore, callRequest.auth);
      const request = parseNotificationRequest(callRequest.data);

      const reference = firestore.collection(NOTIFICATIONS_COLLECTION).doc();
      await reference.set({
        title: request.title,
        message: request.message,
        audience: request.audience,
        motherTongues: request.motherTongues,
        status: "sending",
        createdBy: admin.uid,
        createdByEmail: admin.email,
        createdAt: FieldValue.serverTimestamp(),
      });

      const delivery = createDelivery(getMessaging(), reference.id, request);
      try {
        for await (const recipient of recipientsFor(firestore, request)) {
          await delivery.add(recipient);
        }
        await delivery.flush();
      } catch (error) {
        logger.error("Sending admin notification failed.", {
          notificationId: reference.id,
          code: error.code,
          errorMessage: error.message,
        });
        await reference.update({
          ...delivery.stats,
          status: "failed",
          error: "Recipients could not be loaded.",
          completedAt: FieldValue.serverTimestamp(),
        });
        throw new HttpsError(
            "internal",
            "The notification could not be sent. Try again.",
            {notificationId: reference.id},
        );
      }

      const status = statusFor(delivery.stats);
      await reference.update({
        ...delivery.stats,
        status,
        completedAt: FieldValue.serverTimestamp(),
      });
      logger.info("Admin notification processed.", {
        notificationId: reference.id,
        status,
        ...delivery.stats,
      });
      return {notificationId: reference.id, status, ...delivery.stats};
    },
);
