const {HttpsError} = require("firebase-functions/https");

const ADMIN_COLLECTION = "admin";
const EMAIL_FIELD = "email";
const PERMISSIONS_FIELD = "permissions";
const REQUIRED_PERMISSION = "settings";
const ROLE_FIELD = "role";
const SUPER_ADMIN_ROLE = "superAdmin";

const findAdmin = async (firestore, email) => {
  const collection = firestore.collection(ADMIN_COLLECTION);
  const snapshot = await collection
      .where(EMAIL_FIELD, "==", email)
      .limit(1)
      .get();
  if (!snapshot.empty) return snapshot.docs[0];
  const byId = await collection.doc(email).get();
  return byId.exists ? byId : null;
};

const canSendNotifications = (account) => {
  if (account.get(ROLE_FIELD) === SUPER_ADMIN_ROLE) return true;
  const permissions = account.get(PERMISSIONS_FIELD);
  return Array.isArray(permissions) &&
    permissions.includes(REQUIRED_PERMISSION);
};

const requireNotificationAdmin = async (firestore, auth) => {
  if (!auth) {
    throw new HttpsError("unauthenticated", "Sign in to send notifications.");
  }
  const email = auth.token.email;
  if (typeof email !== "string" || email.trim().length === 0) {
    throw new HttpsError("permission-denied", "This account is not an admin.");
  }

  const id = email.trim().toLowerCase();
  const account = await findAdmin(firestore, id);
  if (!account || !canSendNotifications(account)) {
    throw new HttpsError(
        "permission-denied",
        "This account is not allowed to send notifications.",
    );
  }
  return {uid: auth.uid, email: id};
};

module.exports = {requireNotificationAdmin};
