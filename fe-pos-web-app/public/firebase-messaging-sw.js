/* eslint-env serviceworker */
/* eslint-disable no-undef */

importScripts(
  "https://www.gstatic.com/firebasejs/10.13.0/firebase-app-compat.js",
);
importScripts(
  "https://www.gstatic.com/firebasejs/10.13.0/firebase-messaging-compat.js",
);

const resolveFirebaseConfig = () => {
  const params = new URL(self.location.href).searchParams;
  return {
    apiKey: (params.get("apiKey") || "").trim(),
    authDomain: (params.get("authDomain") || "").trim(),
    projectId: (params.get("projectId") || "").trim(),
    storageBucket: (params.get("storageBucket") || "").trim(),
    messagingSenderId: (params.get("messagingSenderId") || "").trim(),
    appId: (params.get("appId") || "").trim(),
  };
};

const firebaseConfig = resolveFirebaseConfig();
const requiredFirebaseWebConfigKeys = [
  "apiKey",
  "projectId",
  "messagingSenderId",
  "appId",
];
const missingFirebaseConfigKeys = requiredFirebaseWebConfigKeys.filter(
  (key) => !firebaseConfig[key],
);
const hasFirebaseConfig = missingFirebaseConfigKeys.length === 0;
const sanitizedFirebaseConfig = Object.fromEntries(
  Object.entries(firebaseConfig).filter(([, value]) => value),
);

if (!hasFirebaseConfig) {
  console.error(
    "Konfigurasi Firebase pada service worker tidak lengkap. FCM web push dinonaktifkan. Missing keys:",
    missingFirebaseConfigKeys,
  );
} else {
  firebase.initializeApp(sanitizedFirebaseConfig);

  const messaging = firebase.messaging();

  messaging.onBackgroundMessage((payload) => {
    const { title, body } = payload.notification || {};
    const data = payload.data || {};
    const resolvedTitle = data.notification_title || title;
    const resolvedBody = data.notification_body || body;

    if (!resolvedTitle || !resolvedBody) {
      console.error( 
        "Notifikasi background FCM diabaikan karena title/body tidak tersedia pada payload notifications.",
        payload,
      );
      return;
    }

    self.registration.showNotification(resolvedTitle, {
      body: resolvedBody,
      icon: "/icon-store.svg",
      badge: "/icon-store.svg",
      data,
      requireInteraction: false,
    });
  });
}

self.addEventListener("notificationclick", (event) => {
  event.notification.close();
  const notificationData = event.notification.data || {};
  const targetPath = notificationData.id_notification
    ? `/owner/detail-notifikasi/${notificationData.id_notification}`
    : "/owner/notifikasi";

  event.waitUntil(
    clients
      .matchAll({ type: "window", includeUncontrolled: true })
      .then((clientList) => {
        for (const client of clientList) {
          if (client.url.includes(targetPath) && "focus" in client) {
            return client.focus();
          }
        }
        if (clients.openWindow) {
          return clients.openWindow(targetPath);
        }
      }),
  );
});