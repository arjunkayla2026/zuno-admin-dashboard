const {FieldValue} = require("firebase-admin/firestore");
const {HttpsError} = require("firebase-functions/https");
const logger = require("firebase-functions/logger");
const {
  ADMIN_COLLECTION,
  EMAIL_FIELD,
  ROLE_FIELD,
  SUPER_ADMIN_ROLE,
} = require("./admin_access");

const EMAIL_EXISTS = "auth/email-already-exists";
const USER_NOT_FOUND = "auth/user-not-found";

const denied = (message) => new HttpsError("permission-denied", message);

const loginError = (error) => {
  switch (error.code) {
    case "auth/invalid-password":
      return new HttpsError(
          "invalid-argument",
          "This password was rejected. Choose a stronger one.",
      );
    case "auth/invalid-email":
      return new HttpsError("invalid-argument", "Enter a valid email.");
    default:
      logger.error("Admin login update failed.", {
        code: error.code,
        errorMessage: error.message,
      });
      return new HttpsError(
          "internal",
          "Could not save the login for this admin. Try again.",
      );
  }
};

const createLogin = async (auth, {email, name, password}) => {
  try {
    await auth.createUser({email, password, displayName: name});
    return true;
  } catch (error) {
    if (error.code === EMAIL_EXISTS) return false;
    throw loginError(error);
  }
};

const setPassword = async (auth, {email, name, password}) => {
  let user = null;
  try {
    user = await auth.getUserByEmail(email);
  } catch (error) {
    if (error.code !== USER_NOT_FOUND) throw loginError(error);
  }
  if (!user) {
    await createLogin(auth, {email, name, password});
    return;
  }
  try {
    await auth.updateUser(user.uid, {password});
  } catch (error) {
    throw loginError(error);
  }
};

const fieldsFor = (request) => ({
  name: request.name,
  phoneNumber: request.phoneNumber,
  role: request.role,
  permissions: request.permissions,
  updatedAt: FieldValue.serverTimestamp(),
});

const storedEmail = (snapshot) => {
  const email = snapshot.get(EMAIL_FIELD);
  if (typeof email === "string" && email.trim().length > 0) {
    return email.trim().toLowerCase();
  }
  return snapshot.id.includes("@") ? snapshot.id.toLowerCase() : null;
};

const assertRoleChange = (currentRole, request, caller) => {
  if (caller.isSuperAdmin || currentRole === request.role) return;
  if (currentRole === SUPER_ADMIN_ROLE || request.role === SUPER_ADMIN_ROLE) {
    throw denied("Only super admins can grant or remove the Super Admin role.");
  }
};

const assertSuperAdminRemains = async (read, admins, currentRole, request) => {
  if (currentRole !== SUPER_ADMIN_ROLE || request.role === SUPER_ADMIN_ROLE) {
    return;
  }
  const superAdmins = await read(
      admins.where(ROLE_FIELD, "==", SUPER_ADMIN_ROLE).limit(2),
  );
  if (superAdmins.size < 2) {
    throw new HttpsError(
        "failed-precondition",
        "At least one super admin must remain. Make another admin a super " +
        "admin first.",
    );
  }
};

const createAdminAccount = async ({firestore, auth, caller, request}) => {
  if (request.role === SUPER_ADMIN_ROLE && !caller.isSuperAdmin) {
    throw denied("Only super admins can add a super admin.");
  }
  const admins = firestore.collection(ADMIN_COLLECTION);
  const reference = admins.doc();

  await firestore.runTransaction(async (transaction) => {
    const byEmail = await transaction.get(
        admins.where(EMAIL_FIELD, "==", request.email).limit(1),
    );
    const byId = request.email.includes("/") ?
      null :
      await transaction.get(admins.doc(request.email));
    if (!byEmail.empty || (byId && byId.exists)) {
      throw new HttpsError(
          "already-exists",
          "An admin with this email already exists.",
      );
    }
    transaction.create(reference, {
      ...fieldsFor(request),
      email: request.email,
      createdAt: FieldValue.serverTimestamp(),
    });
  });

  try {
    const loginCreated = await createLogin(auth, request);
    return {id: reference.id, loginCreated, passwordChanged: loginCreated};
  } catch (error) {
    await reference.delete().catch((deleteError) => {
      logger.error("Could not remove admin after a login failure.", {
        adminId: reference.id,
        errorMessage: deleteError.message,
      });
    });
    throw error;
  }
};

const updateAdminAccount = async ({firestore, auth, caller, request}) => {
  if (request.password !== null && !caller.isSuperAdmin) {
    throw denied("Only super admins can change admin passwords.");
  }
  const admins = firestore.collection(ADMIN_COLLECTION);
  const reference = admins.doc(request.id);
  const snapshot = await reference.get();
  if (!snapshot.exists) {
    throw new HttpsError("not-found", "This admin no longer exists.");
  }
  const currentRole = snapshot.get(ROLE_FIELD);
  assertRoleChange(currentRole, request, caller);
  await assertSuperAdminRemains(
      (query) => query.get(),
      admins,
      currentRole,
      request,
  );

  if (request.password !== null) {
    const email = storedEmail(snapshot);
    if (!email) {
      throw new HttpsError(
          "failed-precondition",
          "This admin has no email, so their password cannot be changed.",
      );
    }
    await setPassword(auth, {
      email,
      name: request.name,
      password: request.password,
    });
  }

  await firestore.runTransaction(async (transaction) => {
    const current = await transaction.get(reference);
    if (!current.exists) {
      throw new HttpsError("not-found", "This admin no longer exists.");
    }
    const role = current.get(ROLE_FIELD);
    assertRoleChange(role, request, caller);
    await assertSuperAdminRemains(
        (query) => transaction.get(query),
        admins,
        role,
        request,
    );
    transaction.update(reference, fieldsFor(request));
  });

  return {
    id: reference.id,
    loginCreated: false,
    passwordChanged: request.password !== null,
  };
};

const saveAdminAccount = (context) => context.request.id === null ?
  createAdminAccount(context) :
  updateAdminAccount(context);

module.exports = {saveAdminAccount};
