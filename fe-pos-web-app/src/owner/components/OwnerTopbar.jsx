import { useEffect, useMemo, useRef, useState } from "react";
import { Bell, Menu } from "lucide-react";
import { useNavigate } from "react-router-dom";
import {
  getOwnerNotifications,
  markAllOwnerNotificationsAsRead,
  markOwnerNotificationAsRead,
} from "../../shared/services/notificationService.js";
import { toApiUrl } from "../../lib/http/apiOrigin.js";
import { useUIStore } from "../../stores/useUIStore.js";

const NOTIFICATION_EVENT = "notification";
const NOTIFICATION_PAGE_LIMIT = 10;

const getUnreadNotificationTotal = (meta, notifications) => {
  const unreadTotalCandidates = [
    meta?.total_unread,
    meta?.total_unread_data,
    meta?.unread_total,
    meta?.unread_count,
    meta?.total_unread_notifications,
  ];

  const unreadTotal = unreadTotalCandidates.find((value) =>
    Number.isFinite(Number(value)),
  );

  if (unreadTotal !== undefined) {
    return Number(unreadTotal);
  }

  return notifications.filter((item) => !item.is_read).length;
};

const formatNotificationTime = (dateValue) => {
  if (!dateValue) return "-";

  const createdTime = new Date(dateValue).getTime();
  if (Number.isNaN(createdTime)) return "-";

  const diffMs = Date.now() - createdTime;
  const diffMinutes = Math.floor(diffMs / 60000);

  if (diffMinutes < 1) return "Baru saja";
  if (diffMinutes < 60) return `${diffMinutes} menit lalu`;

  const diffHours = Math.floor(diffMinutes / 60);
  if (diffHours < 24) return `${diffHours} jam lalu`;

  const diffDays = Math.floor(diffHours / 24);
  if (diffDays < 7) return `${diffDays} hari lalu`;

  return new Date(dateValue).toLocaleDateString("id-ID", {
    day: "2-digit",
    month: "short",
    year: "numeric",
  });
};

export default function OwnerTopbar({ isMobile, onToggleSidebar }) {
  const { activeTab } = useUIStore();
  const navigate = useNavigate();
  const [notifications, setNotifications] = useState([]);
  const [unreadNotificationTotal, setUnreadNotificationTotal] = useState(0);
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const bellWrapperRef = useRef(null);
  const notificationsRef = useRef([]);

  useEffect(() => {
    notificationsRef.current = notifications;
  }, [notifications]);

  useEffect(() => {
    let isMounted = true;

    const fetchNotifications = async () => {
      setIsLoading(true);
      try {
        const response = await getOwnerNotifications();
        if (isMounted) {
          const nextNotifications = Array.isArray(response.data) ? response.data : [];

          notificationsRef.current = nextNotifications;
          setNotifications(nextNotifications);
          setUnreadNotificationTotal(
            getUnreadNotificationTotal(response.meta, nextNotifications),
          );
        }
      } catch (error) {
        console.error("Gagal memuat notifikasi owner:", error);
      } finally {
        if (isMounted) {
          setIsLoading(false);
        }
      }
    };

    fetchNotifications();

    return () => {
      isMounted = false;
    };
  }, []);

  useEffect(() => {
    const streamUrl = toApiUrl("/api/owner/notifications/stream");
    const source = new EventSource(streamUrl, { withCredentials: true });

    source.addEventListener(NOTIFICATION_EVENT, (event) => {
      try {
        const payload = JSON.parse(event.data);
        const incomingNotification = payload?.data;
        if (!incomingNotification?.id_notification) {
          return;
        }

        const alreadyExists = notificationsRef.current.some(
          (item) => item.id_notification === incomingNotification.id_notification,
        );

        const filteredNotifications = notificationsRef.current.filter(
          (item) => item.id_notification !== incomingNotification.id_notification,
        );
        const nextNotifications = [incomingNotification, ...filteredNotifications].slice(
          0,
          NOTIFICATION_PAGE_LIMIT,
        );

        notificationsRef.current = nextNotifications;
        setNotifications(nextNotifications);

        if (!alreadyExists && !incomingNotification.is_read) {
          setUnreadNotificationTotal((prev) => prev + 1);
        }
      } catch (error) {
        console.error("Gagal memproses notifikasi SSE:", error);
      }
    });

    source.onerror = (error) => {
      console.error("SSE notifikasi owner error:", error);
    };

    return () => {
      source.close();
    };
  }, []);

  useEffect(() => {
    const handleClickOutside = (event) => {
      if (
        bellWrapperRef.current &&
        !bellWrapperRef.current.contains(event.target)
      ) {
        setIsDropdownOpen(false);
      }
    };

    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  const unreadCount = useMemo(
    () => notifications.filter((item) => !item.is_read).length,
    [notifications],
  );
  const notificationBadgeCount =
    unreadNotificationTotal > 0 ? unreadNotificationTotal : 0;

  const handleMarkAsRead = async (idNotification) => {
    try {
      await markOwnerNotificationAsRead(idNotification);
      setNotifications((prev) => {
        const wasUnread = prev.some(
          (item) => item.id_notification === idNotification && !item.is_read,
        );

        if (wasUnread) {
          setUnreadNotificationTotal((count) => Math.max(0, count - 1));
        }

        return prev.map((item) =>
          item.id_notification === idNotification
            ? { ...item, is_read: true }
            : item,
        );
      });
    } catch (error) {
      console.error("Gagal menandai notifikasi dibaca:", error);
    }
  };

  const handleMarkAllAsRead = async () => {
    try {
      await markAllOwnerNotificationsAsRead();
      setUnreadNotificationTotal(0);
      setNotifications((prev) => prev.map((item) => ({ ...item, is_read: true })));
    } catch (error) {
      console.error("Gagal menandai semua notifikasi dibaca:", error);
    }
  };

  const handleNotificationClick = async (notification) => {
    if (!notification.is_read) {
      await handleMarkAsRead(notification.id_notification);
    }

    setIsDropdownOpen(false);
    navigate(`/owner/detail-notifikasi/${notification.id_notification}`);
  };

  const handleViewAllNotifications = () => {
    setIsDropdownOpen(false);
    navigate("/owner/notifikasi");
  };

  return (
    <div className="bg-violet-900 border-b border-violet-700 px-4 py-3 sm:px-6 sticky top-0 z-20 shadow-md">
      <div className="flex items-center justify-between gap-3">
        <div className="flex items-center gap-3 min-w-0">
          {isMobile && (
            <button
              onClick={onToggleSidebar}
              className="p-1 rounded text-white hover:bg-violet-800 cursor-pointer"
              aria-label="Buka menu"
            >
              <Menu size={22} />
            </button>
          )}
          <h1 className="text-base sm:text-xl font-bold text-white truncate">
            {activeTab || "Owner"}
          </h1>
        </div>

        <div className="relative" ref={bellWrapperRef}>
          <button
            type="button"
            onClick={() => setIsDropdownOpen((prev) => !prev)}
            className="relative p-2 rounded-full text-white hover:bg-violet-800 cursor-pointer"
            aria-label="Lihat notifikasi"
          >
            <Bell size={20} />
            {notificationBadgeCount > 0 && (
              <span className="absolute -top-0.5 -right-0.5 min-w-5 h-5 px-1 rounded-full bg-red-500 text-white text-[11px] leading-5 text-center">
                {notificationBadgeCount > 99 ? "99+" : notificationBadgeCount}
              </span>
            )}
          </button>

          {isDropdownOpen && (
            <div className="absolute right-0 mt-2 w-80 max-w-[90vw] bg-white border border-gray-200 rounded-lg shadow-xl overflow-hidden">
              <div className="flex items-center justify-between px-4 py-3 border-b">
                <p className="font-semibold text-gray-800">Notifikasi</p>
                <button
                  type="button"
                  onClick={handleMarkAllAsRead}
                  className="text-xs text-violet-700 hover:text-violet-900 cursor-pointer disabled:opacity-50"
                  disabled={unreadCount === 0}
                >
                  Tandai semua dibaca
                </button>
              </div>

              <div className="max-h-96 overflow-y-auto">
                {isLoading ? (
                  <p className="px-4 py-6 text-sm text-gray-500 text-center">
                    Memuat notifikasi...
                  </p>
                ) : notifications.length === 0 ? (
                  <p className="px-4 py-6 text-sm text-gray-500 text-center">
                    Belum ada notifikasi
                  </p>
                ) : (
                  notifications.map((notification) => (
                    <button
                      key={notification.id_notification}
                      type="button"
                      onClick={() => handleNotificationClick(notification)}
                      className={`w-full text-left px-4 py-3 border-b border-gray-200 hover:bg-gray-50 transition-colors ${
                        notification.is_read
                          ? "bg-gray-100 hover:bg-gray-200"
                          : "bg-indigo-100 hover:bg-indigo-200 border-l-4 border-l-indigo-600"
                      }`}
                    >
                      <div className="flex items-start gap-2">
                        {!notification.is_read && (
                          <span className="inline-block w-2 h-2 mt-1.5 rounded-full bg-indigo-600 shrink-0" />
                        )}
                        <div className="flex-1 min-w-0">
                          <p
                            className={`text-sm font-semibold ${
                              notification.is_read
                                ? "text-gray-700"
                                : "text-indigo-900"
                            }`}
                          >
                            {notification.title}
                          </p>
                          <p
                            className={`text-sm mt-1 ${
                              notification.is_read
                                ? "text-gray-600"
                                : "text-gray-800"
                            }`}
                          >
                            {notification.message}
                          </p>
                          <p className="text-xs text-gray-500 mt-1.5">
                            {formatNotificationTime(notification.created_at)}
                          </p>
                        </div>
                      </div>
                    </button>
                  ))
                )}
              </div>

              <div className="px-4 py-3 border-t border-gray-200 bg-gray-50">
                <button
                  type="button"
                  onClick={handleViewAllNotifications}
                  className="w-full px-3 py-2 text-sm font-semibold text-violet-700 border border-violet-300 rounded-md hover:bg-violet-50 cursor-pointer"
                >
                  Lihat Semua Notifikasi
                </button>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}