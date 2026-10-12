import { initializeApp } from "firebase/app";
import { getMessaging, isSupported } from "firebase/messaging";

const readEnv = (...keys) => {
  for (const key of keys) {
    const value = import.meta.env[key];
    if (typeof value === "string" && value.trim()) {
      return value.trim();
    }
  }
  return "";
};

export const firebaseConfig = {
  apiKey: readEnv("VITE_FIREBASE_API_KEY", "FIREBASE_API_KEY"),
  authDomain: readEnv("VITE_FIREBASE_AUTH_DOMAIN", "FIREBASE_AUTH_DOMAIN"),
  projectId: readEnv("VITE_FIREBASE_PROJECT_ID", "FIREBASE_PROJECT_ID"),
  storageBucket: readEnv("VITE_FIREBASE_STORAGE_BUCKET", "FIREBASE_STORAGE_BUCKET"),
  messagingSenderId: readEnv(
    "VITE_FIREBASE_MESSAGING_SENDER_ID",
    "FIREBASE_MESSAGING_SENDER_ID",
  ),
  appId: readEnv("VITE_FIREBASE_APP_ID", "FIREBASE_APP_ID"),
};

const REQUIRED_FIREBASE_WEB_CONFIG_KEYS = [
  "apiKey",
  "projectId",
  "messagingSenderId",
  "appId",
];

export const missingFirebaseWebConfigKeys =
  REQUIRED_FIREBASE_WEB_CONFIG_KEYS.filter(
    (key) =>
      typeof firebaseConfig[key] !== "string" || firebaseConfig[key].trim() === "",
  );

export const hasFirebaseWebConfig = missingFirebaseWebConfigKeys.length === 0;

const sanitizedFirebaseConfig = Object.fromEntries(
  Object.entries(firebaseConfig).filter(([, value]) => value),
);

const firebaseApp = hasFirebaseWebConfig
  ? initializeApp(sanitizedFirebaseConfig)
  : null;

export const getFirebaseMessaging = async () => {
  if (!firebaseApp) return null;
  const supported = await isSupported().catch(() => false);
  if (!supported) return null;
  return getMessaging(firebaseApp);
};

export default firebaseApp;