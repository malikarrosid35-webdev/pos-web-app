import ownerClient from "../../lib/http/ownerClient.js";

export const getOwnerNotifications = async (page = 1) => {
  const response = await ownerClient.get("/notifications", {
    params: { page },
  });

  return {
    data: Array.isArray(response.data?.data) ? response.data.data : [],
    meta: response.data?.meta || null,
  };
};

export const getOwnerNotificationDetail = async (idNotification) => {
  const response = await ownerClient.get(`/notifications/${idNotification}`);
  return response.data?.data || null;
};

export const downloadOwnerDailyReportNotificationPdf = (idNotification) =>
  ownerClient.get(`/notifications/${idNotification}/download`, {
    responseType: "blob",
  });

export const markOwnerNotificationAsRead = async (idNotification) => {
  const response = await ownerClient.patch(`/notifications/read/${idNotification}`);
  return response.data?.data || null;
};

export const markAllOwnerNotificationsAsRead = async () => {
  await ownerClient.patch("/notifications/read-all");
};