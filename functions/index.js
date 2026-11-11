const {initializeApp} = require("firebase-admin/app");
const {FieldValue, getFirestore} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");
const {setGlobalOptions} = require("firebase-functions");
const {HttpsError, onCall} = require("firebase-functions/https");
const logger = require("firebase-functions/logger");
const {requireNotificationAdmin} = require("./src/admin_access");
const {parseNotificationRequest} = require("./src/notification_request");
const {targetsFor, topicsFor} = require("./src/topics");

initializeApp();
setGlobalOptions({region: "asia-south1", maxInstances: 10});

const NOTIFICATIONS_COLLECTION = "notifications";

const statusFor = ({successCount, failureCount}) => {
  if (failureCount === 0) return "sent";
  if (successCount === 0) return "failed";
  return "partiallySent";
};

const sendToTargets = async (messaging, notificationId, request, targets) => {
  const payload = {
    notification: {title: request.title, body: request.message},
    data: {notificationId, type: "adminNotification"},
  };
  const results = await Promise.all(targets.map(async (target) => {
    try {
      const messageId = await messaging.send({...payload, ...target});
      return {...target, messageId};
    } catch (error) {
      logger.error("FCM topic send failed.", {
        notificationId,
        ...target,
        code: error.code,
        errorMessage: error.message,
      });
      return {...target, error: error.code || "unknown"};
    }
  }));
  const successCount = results.filter((item) => item.messageId).length;
  return {
    deliveries: results,
    successCount,
    failureCount: results.length - successCount,
  };
};

exports.sendAdminNotification = onCall(
    {timeoutSeconds: 60},
    async (callRequest) => {
      const firestore = getFirestore();
      const admin = await requireNotificationAdmin(firestore, callRequest.auth);
      const request = parseNotificationRequest(callRequest.data);
      const topics = topicsFor(request);

      const reference = firestore.collection(NOTIFICATIONS_COLLECTION).doc();
      await reference.set({
        title: request.title,
        message: request.message,
        audience: request.audience,
        motherTongues: request.motherTongues,
        topics,
        status: "sending",
        createdBy: admin.uid,
        createdByEmail: admin.email,
        createdAt: FieldValue.serverTimestamp(),
      });

      const result = await sendToTargets(
          getMessaging(),
          reference.id,
          request,
          targetsFor(topics),
      );
      const status = statusFor(result);
      await reference.update({
        ...result,
        status,
        completedAt: FieldValue.serverTimestamp(),
      });
      logger.info("Admin notification processed.", {
        notificationId: reference.id,
        status,
        topics,
      });

      if (status === "failed") {
        throw new HttpsError(
            "internal",
            "The notification could not be sent. Try again.",
            {notificationId: reference.id},
        );
      }
      return {notificationId: reference.id, status, topics};
    },
);
