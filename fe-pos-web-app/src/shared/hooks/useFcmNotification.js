import { useEffect, useState, useCallback } from "react";
import * as firebaseMessaging from "firebase/messaging";
import Swal from "sweetalert2";
import {
  firebaseConfig,
  getFirebaseMessaging,
  hasFirebaseWebConfig,
  missingFirebaseWebConfigKeys,
} from "../../lib/firebase/firebaseConfig.js";
import ownerClient from "../../lib/http/ownerClient.js";

const VAPID_KEY = (
  import.meta.env.VITE_FIREBASE_VAPID_KEY ||
  import.meta.env.FIREBASE_VAPID_KEY ||
  ""
).trim();
const FCM_REGISTRATION_ID_STORAGE_KEY = "owner_fcm_registration_id";
const FCM_SERVICE_WORKER_PATH = "/firebase-messaging-sw.js";
const FCM_SERVICE_WORKER_SCOPE = "/firebase-cloud-messaging-push-scope";

const buildFirebaseServiceWorkerUrl = () => {
  const params = new URLSearchParams();
  Object.entries(firebaseConfig).forEach(([key, value]) => {
    if (value) params.set(key, value);
  });

  const query = params.toString();
  return query ? `${FCM_SERVICE_WORKER_PATH}?${query}` : FCM_SERVICE_WORKER_PATH;
};

const registerFirebaseServiceWorker = () =>
  navigator.serviceWorker.register(buildFirebaseServiceWorkerUrl(), {
    scope: FCM_SERVICE_WORKER_SCOPE,
  });

const getFirebaseServiceWorkerRegistration = () =>
  navigator.serviceWorker.getRegistration(FCM_SERVICE_WORKER_SCOPE);

const readStoredRegistrationId = () => {
  if (typeof window === "undefined") return null;
  try {
    return window.localStorage.getItem(FCM_REGISTRATION_ID_STORAGE_KEY);
  } catch (error) {
    console.error("Gagal membaca FCM registration id dari storage:", error);
    return null;
  }
};

const writeStoredRegistrationId = (registrationId) => {
  if (typeof window === "undefined") return;
  try {
    if (!registrationId) {
      window.localStorage.removeItem(FCM_REGISTRATION_ID_STORAGE_KEY);
      return;
    }
    window.localStorage.setItem(FCM_REGISTRATION_ID_STORAGE_KEY, registrationId);
  } catch (error) {
    console.error("Gagal menyimpan FCM registration id ke storage:", error);
  }
};

const registerMessagingClient = async (messaging, swRegistration) => {
  const registerFn = firebaseMessaging.register;
  const onRegisteredFn = firebaseMessaging.onRegistered;

  if (typeof registerFn === "function" && typeof onRegisteredFn === "function") {
    const registrationId = await new Promise((resolve, reject) => {
      let timeoutId = null;
      const unsubscribe = onRegisteredFn(messaging, (fid) => {
        if (timeoutId) clearTimeout(timeoutId);
        unsubscribe();
        resolve(fid || null);
      });

      timeoutId = setTimeout(() => {
        unsubscribe();
        reject(new Error("Timeout menunggu FID dari Firebase Messaging."));
      }, 10000);

      registerFn(messaging, {
        vapidKey: VAPID_KEY,
        serviceWorkerRegistration: swRegistration,
      }).catch((error) => {
        if (timeoutId) clearTimeout(timeoutId);
        unsubscribe();
        reject(error);
      });
    });

    return registrationId;
  }

  const getTokenFn = firebaseMessaging.getToken;
  if (typeof getTokenFn !== "function") {
    throw new Error("Firebase Messaging tidak menyediakan API register/getToken.");
  }

  return getTokenFn(messaging, {
    vapidKey: VAPID_KEY,
    serviceWorkerRegistration: swRegistration,
  });
};

const unregisterMessagingClient = async (messaging) => {
  const unregisterFn = firebaseMessaging.unregister;
  if (typeof unregisterFn === "function") {
    await unregisterFn(messaging);
    return;
  }

  const deleteTokenFn = firebaseMessaging.deleteToken;
  if (typeof deleteTokenFn === "function") {
    await deleteTokenFn(messaging);
    return;
  }

  throw new Error("Firebase Messaging tidak menyediakan API unregister/deleteToken.");
};

// Dipanggil di luar React (mis. saat logout) untuk menghapus token FCM milik
// device ini saja dari server, supaya device yang sudah logout tidak lagi
// menerima notifikasi heads-up meski sebelumnya pernah mengizinkan notifikasi.
export async function unregisterCurrentDeviceFcmToken() {
  if (typeof window === "undefined" || !("Notification" in window)) return null;
  if (!("serviceWorker" in navigator)) return null;
  if (Notification.permission !== "granted") return null;

  try {
    const messaging = await getFirebaseMessaging();
    if (!messaging) return null;

    const swRegistration = await getFirebaseServiceWorkerRegistration();
    if (!swRegistration) return null;

    const registrationId =
      readStoredRegistrationId() ||
      (await registerMessagingClient(messaging, swRegistration));
    if (!registrationId) return null;

    await ownerClient
      .delete("/fcm-tokens/unregister", { data: { fcm_token: registrationId } })
      .catch((error) => {
        console.error("Gagal menghapus FCM token di server saat logout:", error);
      });

    // Hapus juga token di sisi client supaya login berikutnya (device/user
    // apapun) mendapat token FCM yang baru, bukan token lama yang sudah
    // dihapus dari server.
    await unregisterMessagingClient(messaging).catch((error) => {
      console.error("Gagal unregister FCM di client saat logout:", error);
    });

    writeStoredRegistrationId(null);

    return registrationId;
  } catch (error) {
    console.error("Gagal unregister FCM token saat logout:", error);
    return null;
  }
}

export default function useFcmNotification({ enabled = true } = {}) {
  const [permission, setPermission] = useState(
    typeof Notification !== "undefined"
      ? Notification.permission
      : "unsupported",
  );
  const [fcmToken, setFcmToken] = useState(null);
  const [isRegistering, setIsRegistering] = useState(false);

  const registerToken = useCallback(async () => {
    if (typeof window === "undefined" || !("Notification" in window)) {
      return null;
    }
    if (!("serviceWorker" in navigator)) return null;
    if (!hasFirebaseWebConfig) {
      console.warn(
        "Konfigurasi Firebase web belum lengkap. Token FCM tidak dibuat. Missing keys:",
        missingFirebaseWebConfigKeys,
      );
      return null;
    }
    if (!VAPID_KEY) {
      console.warn("VAPID key Firebase belum diisi. Token FCM tidak dibuat.");
      return null;
    }

    setIsRegistering(true);
    try {
      const swRegistration = await registerFirebaseServiceWorker();

      const permissionResult = await Notification.requestPermission();
      setPermission(permissionResult);

      if (permissionResult !== "granted") {
        return null;
      }

      const messaging = await getFirebaseMessaging();
      if (!messaging) {
        console.warn("FCM tidak didukung di browser ini.");
        return null;
      }

      const token = await registerMessagingClient(messaging, swRegistration);

      if (!token) return null;

      setFcmToken(token);
      writeStoredRegistrationId(token);

      await ownerClient.post("/fcm-tokens/register", {
        fcm_token: token,
        device_info: navigator.userAgent,
      });

      return token;
    } catch (error) {
      console.error("Gagal mendaftarkan FCM token:", error);
      return null;
    } finally {
      setIsRegistering(false);
    }
  }, []);

  const unregisterToken = useCallback(async () => {
    if (!fcmToken) return;
    try {
      await ownerClient.delete("/fcm-tokens/unregister", {
        data: { fcm_token: fcmToken },
      });

      const messaging = await getFirebaseMessaging();
      if (messaging) {
        await unregisterMessagingClient(messaging);
      }
    } catch (error) {
      console.error("Gagal menghapus FCM token:", error);
    } finally {
      writeStoredRegistrationId(null);
      setFcmToken(null);
    }
  }, [fcmToken]);

  // Auto-register saat hook pertama kali dipakai (dipasang di OwnerRoutes).
  // `enabled` harus mencerminkan status login owner yang sesungguhnya, agar
  // device yang belum/tidak lagi login tidak diminta izin notifikasi dan
  // tidak ikut terdaftar menerima push.
  useEffect(() => {
    if (!enabled) return;
    if (permission === "granted" || permission === "default") {
      registerToken();
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [enabled]);

  // Listener untuk notifikasi saat tab owner sedang aktif (foreground)
  useEffect(() => {
    if (!enabled) return undefined;

    let unsubscribe;

    const setupForegroundListener = async () => {
      const messaging = await getFirebaseMessaging();
      if (!messaging) return;

      unsubscribe = firebaseMessaging.onMessage(messaging, (payload) => {
        const { title, body } = payload.notification || {};
        const data = payload.data || {};
        const resolvedTitle = title || data.notification_title || "Notifikasi Baru";
        const resolvedBody = body || data.notification_body || "";
        Swal.fire({
          icon: "info",
          title: resolvedTitle,
          text: resolvedBody,
          toast: true,
          position: "top-end",
          showConfirmButton: false,
          timer: 5000,
          timerProgressBar: true,
        });
      });
    };

    setupForegroundListener();

    return () => {
      if (unsubscribe) unsubscribe();
    };
  }, [enabled]);

  return {
    permission,
    fcmToken,
    isRegistering,
    registerToken,
    unregisterToken,
  };
}