const {FieldPath} = require("firebase-admin/firestore");

const USERS_COLLECTION = "users";
const ROLE_FIELD = "role";
const MOTHER_TONGUE_FIELD = "hostDetails.motherTongue";
const DELETED_FIELD = "isAccountDeleted";
const TOKEN_FIELD = "fcmToken";
const USER_ROLE = "user";
const HOST_ROLE = "host";
const MAX_IN_VALUES = 30;
const PAGE_SIZE = 500;
const TOKEN_PATTERN = /^[A-Za-z0-9_:-]{32,4096}$/;

const chunk = (values, size) => {
  const chunks = [];
  for (let start = 0; start < values.length; start += size) {
    chunks.push(values.slice(start, start + size));
  }
  return chunks;
};

const recipientQueries = (firestore, {audience, motherTongues}) => {
  const users = firestore.collection(USERS_COLLECTION);
  if (audience === "both" && motherTongues.length === 0) {
    return [users.where(ROLE_FIELD, "in", [USER_ROLE, HOST_ROLE])];
  }

  const queries = [];
  if (audience !== "host") {
    queries.push(users.where(ROLE_FIELD, "==", USER_ROLE));
  }
  if (audience !== "user") {
    const hosts = users.where(ROLE_FIELD, "==", HOST_ROLE);
    if (motherTongues.length === 0) {
      queries.push(hosts);
    } else {
      for (const group of chunk(motherTongues, MAX_IN_VALUES)) {
        queries.push(hosts.where(MOTHER_TONGUE_FIELD, "in", group));
      }
    }
  }
  return queries;
};

const pagesOf = async function* (query) {
  const ordered = query
      .select(TOKEN_FIELD, DELETED_FIELD)
      .orderBy(FieldPath.documentId())
      .limit(PAGE_SIZE);
  let last = null;
  while (true) {
    const snapshot = await (last ? ordered.startAfter(last) : ordered).get();
    if (snapshot.empty) return;
    yield snapshot.docs;
    if (snapshot.size < PAGE_SIZE) return;
    last = snapshot.docs[snapshot.docs.length - 1];
  }
};

const tokenOf = (document) => {
  const value = document.get(TOKEN_FIELD);
  if (typeof value !== "string") return null;
  const token = value.trim();
  return TOKEN_PATTERN.test(token) ? token : null;
};

const recipientsFor = async function* (firestore, request) {
  const seenDocuments = new Set();
  for (const query of recipientQueries(firestore, request)) {
    for await (const documents of pagesOf(query)) {
      for (const document of documents) {
        if (seenDocuments.has(document.id)) continue;
        seenDocuments.add(document.id);
        if (document.get(DELETED_FIELD) === true) continue;
        yield {document, token: tokenOf(document)};
      }
    }
  }
};

module.exports = {recipientsFor, TOKEN_FIELD};
