const {initializeApp} = require("firebase-admin/app");
const {getAuth} = require("firebase-admin/auth");
const {getFirestore} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");
const {setGlobalOptions} = require("firebase-functions");
const {HttpsError, onCall} = require("firebase-functions/https");
const logger = require("firebase-functions/logger");
const {
  requireAdminManager,
  requireNotificationAdmin,
} = require("./src/admin_access");
const {parseAdminAccountRequest} = require("./src/admin_account_request");
const {saveAdminAccount} = require("./src/admin_accounts");
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

exports.saveAdminAccount = onCall(
    {timeoutSeconds: 60},
    async (callRequest) => {
      const firestore = getFirestore();
      const caller = await requireAdminManager(firestore, callRequest.auth);
      const request = parseAdminAccountRequest(callRequest.data);
      const result = await saveAdminAccount({
        firestore,
        auth: getAuth(),
        caller,
        request,
      });
      logger.info("Admin account saved.", {
        savedBy: caller.uid,
        adminId: result.id,
        created: request.id === null,
        role: request.role,
        loginCreated: result.loginCreated,
        passwordChanged: result.passwordChanged,
      });
      return result;
    },
);
