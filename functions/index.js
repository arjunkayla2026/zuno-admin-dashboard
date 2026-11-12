const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");
const {setGlobalOptions} = require("firebase-functions");
const {HttpsError, onCall} = require("firebase-functions/https");
const logger = require("firebase-functions/logger");
const {requireNotificationAdmin} = require("./src/admin_access");
const {parseNotificationRequest} = require("./src/notification_request");
const {targetsFor, topicsFor} = require("./src/topics");

initializeApp();
setGlobalOptions({region: "asia-south1", maxInstances: 10});

const statusFor = ({successCount, failureCount}) => {
  if (failureCount === 0) return "sent";
  if (successCount === 0) return "failed";
  return "partiallySent";
};

const sendToTargets = async (messaging, request, targets) => {
  const payload = {
    notification: {title: request.title, body: request.message},
    data: {type: "adminNotification"},
  };
  const results = await Promise.all(targets.map(async (target) => {
    try {
      const messageId = await messaging.send({...payload, ...target});
      return {...target, messageId};
    } catch (error) {
      logger.error("FCM topic send failed.", {
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

      const result = await sendToTargets(
          getMessaging(),
          request,
          targetsFor(topics),
      );
      const status = statusFor(result);
      logger.info("Admin notification processed.", {
        createdBy: admin.uid,
        status,
        topics,
        successCount: result.successCount,
        failureCount: result.failureCount,
      });

      if (status === "failed") {
        throw new HttpsError(
            "internal",
            "The notification could not be sent. Try again.",
        );
      }
      return {status, topics};
    },
);
