const {HttpsError} = require("firebase-functions/https");
const {SUPER_ADMIN_ROLE, normalizeEmail} = require("./admin_access");

const ROLES = Object.freeze([
  SUPER_ADMIN_ROLE,
  "financeAdmin",
  "supportAdmin",
  "moderator",
]);
const MODULES = Object.freeze([
  "dashboard",
  "userManagement",
  "hostManagement",
  "calls",
  "approval",
  "reports",
  "packages",
  "recharge",
  "payment",
  "settings",
]);
const NAME_MAX_LENGTH = 100;
const EMAIL_MAX_LENGTH = 254;
const MIN_PASSWORD_LENGTH = 6;
const MAX_PASSWORD_LENGTH = 128;
const ID_MAX_LENGTH = 1500;
const EMAIL_PATTERN = /^[^@\s]+@[^@\s]+\.[^@\s]+$/;
const PHONE_PATTERN = /^[0-9]{10}$/;

const invalid = (message) => new HttpsError("invalid-argument", message);

const idFrom = (value) => {
  if (value === undefined || value === null) return null;
  if (typeof value !== "string" || value.length === 0 ||
      value.length > ID_MAX_LENGTH || value.includes("/")) {
    throw invalid("The admin to update is not valid.");
  }
  return value;
};

const nameFrom = (value) => {
  const name = typeof value === "string" ? value.trim() : "";
  if (name.length === 0) throw invalid("Enter a name.");
  if (name.length > NAME_MAX_LENGTH) {
    throw invalid(`Use at most ${NAME_MAX_LENGTH} characters for the name.`);
  }
  return name;
};

const emailFrom = (value) => {
  const email = typeof value === "string" ? normalizeEmail(value) : "";
  if (email.length > EMAIL_MAX_LENGTH || !EMAIL_PATTERN.test(email)) {
    throw invalid("Enter a valid email.");
  }
  return email;
};

const phoneFrom = (value) => {
  const phone = typeof value === "string" ? value.trim() : "";
  if (!PHONE_PATTERN.test(phone)) {
    throw invalid("Enter a 10-digit phone number.");
  }
  return phone;
};

const roleFrom = (value) => {
  if (!ROLES.includes(value)) throw invalid("Choose a valid role.");
  return value;
};

const permissionsFrom = (value, role) => {
  if (role === SUPER_ADMIN_ROLE) return [...MODULES];
  if (!Array.isArray(value)) throw invalid("Choose at least one module.");
  const unknown = value.filter((item) => !MODULES.includes(item));
  if (unknown.length > 0) {
    throw invalid(`Unknown module: ${[...new Set(unknown)].join(", ")}.`);
  }
  const permissions = MODULES.filter((module) => value.includes(module));
  if (permissions.length === 0) throw invalid("Choose at least one module.");
  return permissions;
};

const passwordFrom = (value, required) => {
  if (value === undefined || value === null || value === "") {
    if (required) throw invalid("Enter a password.");
    return null;
  }
  if (typeof value !== "string" || value.length < MIN_PASSWORD_LENGTH) {
    throw invalid(`Use at least ${MIN_PASSWORD_LENGTH} characters.`);
  }
  if (value.length > MAX_PASSWORD_LENGTH) {
    throw invalid(`Use at most ${MAX_PASSWORD_LENGTH} characters.`);
  }
  return value;
};

const parseAdminAccountRequest = (data) => {
  if (!data || typeof data !== "object") {
    throw invalid("The admin details are missing.");
  }
  const id = idFrom(data.id);
  const role = roleFrom(data.role);
  return {
    id,
    name: nameFrom(data.name),
    email: id === null ? emailFrom(data.email) : null,
    phoneNumber: phoneFrom(data.phoneNumber),
    role,
    permissions: permissionsFrom(data.permissions, role),
    password: passwordFrom(data.password, id === null),
  };
};

module.exports = {parseAdminAccountRequest};
