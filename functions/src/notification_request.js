const {HttpsError} = require("firebase-functions/https");
const {HOST_LANGUAGE_TOPICS} = require("./topics");

const AUDIENCES = Object.freeze(["user", "host", "both"]);
const MOTHER_TONGUES = Object.freeze(Object.keys(HOST_LANGUAGE_TOPICS));
const TITLE_MAX_LENGTH = 100;
const MESSAGE_MAX_LENGTH = 1000;

const requiredText = (value, field, maxLength) => {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new HttpsError("invalid-argument", `${field} is required.`);
  }
  const text = value.trim();
  if (text.length > maxLength) {
    throw new HttpsError(
        "invalid-argument",
        `${field} must be at most ${maxLength} characters.`,
    );
  }
  return text;
};

const motherTonguesFrom = (value, audience) => {
  if (value === undefined || value === null) return [];
  if (!Array.isArray(value)) {
    throw new HttpsError("invalid-argument", "motherTongues must be a list.");
  }
  const unknown = value.filter((item) => !MOTHER_TONGUES.includes(item));
  if (unknown.length > 0) {
    throw new HttpsError(
        "invalid-argument",
        `Unknown mother tongue: ${[...new Set(unknown)].join(", ")}.`,
    );
  }
  if (audience === "user" && value.length > 0) {
    throw new HttpsError(
        "invalid-argument",
        "Mother tongues can only be selected when hosts are included.",
    );
  }
  return MOTHER_TONGUES.filter((item) => value.includes(item));
};

const parseNotificationRequest = (data) => {
  if (data === null || typeof data !== "object" || Array.isArray(data)) {
    throw new HttpsError(
        "invalid-argument",
        "Notification details are required.",
    );
  }
  const audience = data.audience;
  if (!AUDIENCES.includes(audience)) {
    throw new HttpsError(
        "invalid-argument",
        `audience must be one of: ${AUDIENCES.join(", ")}.`,
    );
  }
  return {
    title: requiredText(data.title, "title", TITLE_MAX_LENGTH),
    message: requiredText(data.message, "message", MESSAGE_MAX_LENGTH),
    audience,
    motherTongues: motherTonguesFrom(data.motherTongues, audience),
  };
};

module.exports = {parseNotificationRequest};
