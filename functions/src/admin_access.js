const {HttpsError} = require("firebase-functions/https");

const ADMIN_COLLECTION = "admin";
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
  const snapshot = await firestore.collection(ADMIN_COLLECTION).doc(id).get();
  const permissions = snapshot.exists ? snapshot.get(PERMISSIONS_FIELD) : null;
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
