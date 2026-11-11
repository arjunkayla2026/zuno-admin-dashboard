const {HttpsError} = require("firebase-functions/https");

const ADMIN_COLLECTION = "admin";
const EMAIL_FIELD = "email";
const PERMISSIONS_FIELD = "permissions";
const REQUIRED_PERMISSION = "settings";

const requireNotificationAdmin = async (firestore, auth) => {
  if (!auth) {
    throw new HttpsError("unauthenticated", "Sign in to send notifications.");
  }
  const email = auth.token.email;
  if (typeof email !== "string" || email.trim().length === 0) {
    throw new HttpsError("permission-denied", "This account is not an admin.");
  }

  const id = email.trim().toLowerCase();
  const snapshot = await firestore
      .collection(ADMIN_COLLECTION)
      .where(EMAIL_FIELD, "==", id)
      .limit(1)
      .get();
  const account = snapshot.docs[0];
  const permissions = account ? account.get(PERMISSIONS_FIELD) : null;
  if (
    !Array.isArray(permissions) ||
    !permissions.includes(REQUIRED_PERMISSION)
  ) {
    throw new HttpsError(
        "permission-denied",
        "This account is not allowed to send notifications.",
    );
  }
  return {uid: auth.uid, email: id};
};

module.exports = {requireNotificationAdmin};
