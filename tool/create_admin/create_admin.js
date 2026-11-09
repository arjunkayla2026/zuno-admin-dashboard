'use strict';

const readline = require('node:readline/promises');
const { applicationDefault, initializeApp } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');

const PROJECT_ID = 'suno-staging-aaa4d';
const ADMIN_CLAIM = 'admin';
const MIN_PASSWORD_LENGTH = 12;
const EMAIL_PATTERN = /^[^@\s]+@[^@\s]+\.[^@\s]+$/;

async function ask(question) {
  const prompt = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });
  try {
    return (await prompt.question(question)).trim();
  } finally {
    prompt.close();
  }
}

function askHidden(question) {
  return new Promise((resolve, reject) => {
    const { stdin, stdout } = process;
    let value = '';

    const finish = (settle, result) => {
      stdin.setRawMode(false);
      stdin.pause();
      stdin.removeListener('data', onData);
      stdout.write('\n');
      settle(result);
    };

    const onData = (chunk) => {
      for (const character of chunk.toString('utf8')) {
        if (character === '\r' || character === '\n') {
          return finish(resolve, value);
        }
        if (character === '\u0003') {
          return finish(reject, new Error('Cancelled.'));
        }
        if (character === '\u007f' || character === '\b') {
          value = value.slice(0, -1);
        } else if (character >= ' ') {
          value += character;
        }
      }
    };

    stdout.write(question);
    stdin.setRawMode(true);
    stdin.resume();
    stdin.on('data', onData);
  });
}

async function askNewPassword() {
  const password = await askHidden(
    `New password (at least ${MIN_PASSWORD_LENGTH} characters, hidden): `,
  );
  if (password.length < MIN_PASSWORD_LENGTH) {
    throw new Error(`Password must be at least ${MIN_PASSWORD_LENGTH} characters.`);
  }
  if ((await askHidden('Confirm password (hidden): ')) !== password) {
    throw new Error('The passwords do not match.');
  }
  return password;
}

async function findUser(auth, email) {
  try {
    return await auth.getUserByEmail(email);
  } catch (error) {
    if (error.code === 'auth/user-not-found') return null;
    throw error;
  }
}

async function grantAdmin(auth, user) {
  await auth.setCustomUserClaims(user.uid, {
    ...user.customClaims,
    [ADMIN_CLAIM]: true,
  });
}

async function approveExistingUser(auth, user) {
  console.log(`An account already exists for this email (uid ${user.uid}).`);
  console.log('No new account was created and its password was not changed.');

  if (user.customClaims?.[ADMIN_CLAIM] === true) {
    console.log('It is already an approved admin. Nothing to do.');
    return;
  }

  const answer = await ask('Approve this existing account as an admin? [y/N]: ');
  if (answer.toLowerCase() !== 'y') {
    console.log('Left unchanged.');
    return;
  }
  await grantAdmin(auth, user);
  console.log('Approved. The account can now sign in to the admin dashboard.');
}

async function createAdmin(auth, email) {
  const password = await askNewPassword();
  const user = await auth.createUser({ email, password });
  console.log(`Created account ${user.uid}.`);
  await grantAdmin(auth, user);
  console.log('Approved. The account can now sign in to the admin dashboard.');
}

function explain(error) {
  switch (error.code) {
    case 'auth/email-already-exists':
      return 'That email was registered while this script ran. Run it again to review the account.';
    case 'auth/invalid-password':
      return 'Firebase rejected that password. Choose a different one.';
    case 'app/invalid-credential':
    case 'auth/invalid-credential':
      return (
        'No usable credentials found. Set GOOGLE_APPLICATION_CREDENTIALS to a ' +
        `service account key for ${PROJECT_ID}, stored outside this repository.`
      );
    case 'auth/insufficient-permission':
      return `These credentials are not allowed to manage users in ${PROJECT_ID}.`;
    default:
      return error.code ? `${error.code}: ${error.message}` : error.message;
  }
}

async function main() {
  if (!process.stdin.isTTY) {
    throw new Error(
      'Run this in an interactive terminal such as PowerShell. Passwords cannot be piped or passed as arguments.',
    );
  }

  initializeApp({ credential: applicationDefault(), projectId: PROJECT_ID });
  const auth = getAuth();

  console.log(`Firebase project: ${PROJECT_ID}`);
  const email = (await ask('Admin email: ')).toLowerCase();
  if (!EMAIL_PATTERN.test(email)) throw new Error('Enter a valid email.');

  const existing = await findUser(auth, email);
  if (existing) {
    await approveExistingUser(auth, existing);
  } else {
    await createAdmin(auth, email);
  }
}

main()
  .catch((error) => {
    console.error(explain(error));
    process.exitCode = 1;
  })
  .finally(() => process.stdin.destroy());
