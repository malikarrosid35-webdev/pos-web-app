const hasNotificationIdentity = (value) =>
  Boolean(
    value &&
      typeof value === "object" &&
      !Array.isArray(value) &&
      (value.id_notification ||
        value.notification_type ||
        value.title ||
        value.message),
  );

const extractOwnerNotificationCandidate = (payload) => {
  if (!payload || typeof payload !== "object") return null;

  const candidates = [
    payload.owner_notification,
    payload.ownerNotification,
    payload.notification_owner,
    payload.notificationOwner,
    payload.notification
  ];

  const match = candidates.find(hasNotificationIdentity);
  return match || null;
};

export const extractOwnerNotificationResult = (response) => {
  const rootPayload = response?.data || response || {};
  const dataPayload =
    rootPayload?.data && typeof rootPayload.data === "object"
      ? rootPayload.data
      : null;

  const ownerNotification =
    extractOwnerNotificationCandidate(rootPayload) ||
    extractOwnerNotificationCandidate(dataPayload);

  const notificationError =
    rootPayload?.notification_error || dataPayload?.notification_error || null;

  return {
    ownerNotification,
    notificationError,
  };
};

export const buildOwnerNotificationFeedback = (response) => {
  const { ownerNotification, notificationError } =
    extractOwnerNotificationResult(response);

  const feedback = [];

  if (ownerNotification) {
    const title = ownerNotification.title || "Notifikasi owner";
    const message = ownerNotification.message || "";
    feedback.push(
      message
        ? `Notifikasi owner: ${title} - ${message}`
        : `Notifikasi owner: ${title}`,
    );
  }

  if (notificationError) {
    feedback.push(
      "Aktivitas berhasil, tetapi notifikasi owner gagal disimpan ke sistem.",
    );
  }

  return feedback.join("\n");
};