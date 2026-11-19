const {HttpsError} = require("firebase-functions/https");

const ADMIN_COLLECTION = "admin";
const EMAIL_FIELD = "email";
const PERMISSIONS_FIELD = "permissions";
const ROLE_FIELD = "role";
const SUPER_ADMIN_ROLE = "superAdmin";
const SETTINGS_PERMISSION = "settings";

const normalizeEmail = (email) => email.trim().toLowerCase();

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

const isSuperAdmin = (account) =>
  account.get(ROLE_FIELD) === SUPER_ADMIN_ROLE;

const hasPermission = (account, permission) => {
  if (isSuperAdmin(account)) return true;
  const permissions = account.get(PERMISSIONS_FIELD);
  return Array.isArray(permissions) && permissions.includes(permission);
};

const requireAdmin = async (firestore, auth, permission, deniedMessage) => {
  if (!auth) {
    throw new HttpsError("unauthenticated", "Sign in to continue.");
  }
  const email = auth.token.email;
  if (typeof email !== "string" || email.trim().length === 0) {
    throw new HttpsError("permission-denied", "This account is not an admin.");
  }

  const id = normalizeEmail(email);
  const account = await findAdmin(firestore, id);
  if (!account || !hasPermission(account, permission)) {
    throw new HttpsError("permission-denied", deniedMessage);
  }
  return {
    uid: auth.uid,
    email: id,
    accountId: account.id,
    isSuperAdmin: isSuperAdmin(account),
  };
};

const requireNotificationAdmin = (firestore, auth) => requireAdmin(
    firestore,
    auth,
    SETTINGS_PERMISSION,
    "This account is not allowed to send notifications.",
);

const requireAdminManager = (firestore, auth) => requireAdmin(
    firestore,
    auth,
    SETTINGS_PERMISSION,
    "This account is not allowed to add or edit admins.",
);

module.exports = {
  ADMIN_COLLECTION,
  EMAIL_FIELD,
  ROLE_FIELD,
  SUPER_ADMIN_ROLE,
  findAdmin,
  normalizeEmail,
  requireAdminManager,
  requireNotificationAdmin,
};
