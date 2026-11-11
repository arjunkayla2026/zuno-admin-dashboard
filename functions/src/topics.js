const USERS_TOPIC = "users_all";
const HOSTS_TOPIC = "hosts_all";
const HOST_LANGUAGE_TOPICS = Object.freeze({
  english: "hosts_en",
  malayalam: "hosts_ml",
  tamil: "hosts_ta",
  hindi: "hosts_hi",
  kannada: "hosts_kn",
  telugu: "hosts_te",
});
const MAX_TOPICS_PER_CONDITION = 5;

const topicsFor = ({audience, motherTongues}) => {
  const topics = [];
  if (audience !== "host") topics.push(USERS_TOPIC);
  if (audience !== "user") {
    if (motherTongues.length === 0) {
      topics.push(HOSTS_TOPIC);
    } else {
      topics.push(...motherTongues.map((item) => HOST_LANGUAGE_TOPICS[item]));
    }
  }
  return topics;
};

const targetsFor = (topics) => {
  const targets = [];
  const size = MAX_TOPICS_PER_CONDITION;
  for (let start = 0; start < topics.length; start += size) {
    const group = topics.slice(start, start + size);
    targets.push(
        group.length === 1 ?
          {topic: group[0]} :
          {condition: group.map((item) => `'${item}' in topics`).join(" || ")},
    );
  }
  return targets;
};

module.exports = {HOST_LANGUAGE_TOPICS, targetsFor, topicsFor};
