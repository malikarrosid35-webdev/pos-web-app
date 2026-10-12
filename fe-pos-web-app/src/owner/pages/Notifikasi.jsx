import { useEffect, useState } from "react";
import { ChevronLeft, ChevronRight } from "lucide-react";
import { useNavigate } from "react-router-dom";
import { useUIStore } from "../../stores/useUIStore.js";
import {
  getOwnerNotifications,
  markOwnerNotificationAsRead,
} from "../../shared/services/notificationService.js";

const formatNotificationTime = (dateValue) => {
  if (!dateValue) return "-";

  const dateObj = new Date(dateValue);
  if (Number.isNaN(dateObj.getTime())) return "-";

  return dateObj
    .toLocaleString("id-ID", {
      day: "2-digit",
      month: "short",
      year: "numeric",
      hour: "2-digit",
      minute: "2-digit",
      hour12: false,
    })
    .replace(/\./g, ":");
};

export default function Notifikasi() {
  const navigate = useNavigate();
  const { setActiveTab } = useUIStore();
  const [notifications, setNotifications] = useState([]);
  const [meta, setMeta] = useState({
    page: 1,
    limit: 10,
    total_data: 0,
    total_page: 0,
  });
  const [currentPage, setCurrentPage] = useState(1);
  const [loading, setLoading] = useState(true);
  const [errorMessage, setErrorMessage] = useState("");

  useEffect(() => {
    setActiveTab("Notifikasi");
  }, [setActiveTab]);

  useEffect(() => {
    let isMounted = true;

    const fetchNotifications = async () => {
      setLoading(true);
      setErrorMessage("");

      try {
        const response = await getOwnerNotifications(currentPage);
        if (!isMounted) return;

        setNotifications(Array.isArray(response.data) ? response.data : []);
        setMeta(
          response.meta || {
            page: currentPage,
            limit: 10,
            total_data: 0,
            total_page: 0,
          },
        );
      } catch (error) {
        console.error("Gagal memuat daftar notifikasi owner:", error);
        if (isMounted) {
          setErrorMessage("Terjadi kesalahan saat memuat daftar notifikasi.");
        }
      } finally {
        if (isMounted) {
          setLoading(false);
        }
      }
    };

    fetchNotifications();

    return () => {
      isMounted = false;
    };
  }, [currentPage]);

  const handleNotificationClick = async (notification) => {
    if (!notification.is_read) {
      try {
        await markOwnerNotificationAsRead(notification.id_notification);
        setNotifications((prev) =>
          prev.map((item) =>
            item.id_notification === notification.id_notification
              ? { ...item, is_read: true }
              : item,
          ),
        );
      } catch (error) {
        console.error("Gagal menandai notifikasi owner dibaca:", error);
      }
    }

    navigate(`/owner/detail-notifikasi/${notification.id_notification}`);
  };

  const handlePageChange = (newPage) => {
    if (newPage >= 1 && newPage <= meta.total_page) {
      setCurrentPage(newPage);
    }
  };

  const getPageNumbers = () => {
    const total = meta.total_page || 1;
    const current = currentPage;
    const pages = [];

    if (total <= 7) {
      for (let i = 1; i <= total; i++) {
        pages.push(i);
      }
    } else if (current <= 4) {
      for (let i = 1; i <= 5; i++) pages.push(i);
      pages.push("...");
      pages.push(total);
    } else if (current >= total - 3) {
      pages.push(1);
      pages.push("...");
      for (let i = total - 4; i <= total; i++) pages.push(i);
    } else {
      pages.push(1);
      pages.push("...");
      for (let i = current - 1; i <= current + 1; i++) pages.push(i);
      pages.push("...");
      pages.push(total);
    }

    return pages;
  };

  return (
    <div className="flex-1 p-3 sm:p-6 bg-gray-50 min-h-screen">
      <div className="mb-4 sm:mb-6 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
        <div>
          <h1 className="text-2xl sm:text-3xl font-bold text-gray-800">
            Daftar Notifikasi
          </h1>
          <p className="text-sm text-gray-600 mt-1">
            Total: {meta.total_data || 0} notifikasi
          </p>
        </div>
        <button
          type="button"
          onClick={() => navigate("/owner/dashboard")}
          className="px-4 py-2 bg-violet-700 text-white rounded-lg hover:bg-violet-800 cursor-pointer text-sm font-medium"
        >
          Kembali ke Dashboard Owner
        </button>
      </div>

      {loading ? (
        <div className="flex items-center justify-center py-20">
          <p className="text-lg text-gray-600">Memuat notifikasi...</p>
        </div>
      ) : errorMessage ? (
        <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded">
          <strong>Error!</strong> {errorMessage}
        </div>
      ) : (
        <>
          <div className="space-y-3">
            {notifications.length === 0 ? (
              <div className="bg-white rounded-lg shadow p-6 text-center text-gray-500">
                Belum ada notifikasi
              </div>
            ) : (
              notifications.map((notification) => (
                <button
                  key={notification.id_notification}
                  type="button"
                  onClick={() => handleNotificationClick(notification)}
                  className={`w-full text-left bg-white rounded-lg shadow px-4 py-3 border transition-colors cursor-pointer ${
                    notification.is_read
                      ? "border-gray-200 hover:bg-gray-50"
                      : "border-indigo-300 bg-indigo-50 hover:bg-indigo-100"
                  }`}
                >
                  <div className="flex items-start gap-2">
                    {!notification.is_read && (
                      <span className="inline-block w-2 h-2 mt-1.5 rounded-full bg-indigo-600 shrink-0" />
                    )}
                    <div className="min-w-0">
                      <p
                        className={`font-semibold ${
                          notification.is_read ? "text-gray-800" : "text-indigo-900"
                        }`}
                      >
                        {notification.title}
                      </p>
                      <p className="text-sm text-gray-700 mt-1">
                        {notification.message}
                      </p>
                      <p className="text-xs text-gray-500 mt-2">
                        {formatNotificationTime(notification.created_at)}
                      </p>
                    </div>
                  </div>
                </button>
              ))
            )}
          </div>

          {meta.total_page > 0 && (
            <div className="flex flex-col sm:flex-row justify-between items-center gap-4 mt-6">
              <div className="text-sm text-gray-500">
                Menampilkan{" "}
                {notifications.length > 0
                  ? (currentPage - 1) * meta.limit + 1
                  : 0}{" "}
                - {Math.min(currentPage * meta.limit, meta.total_data)} dari{" "}
                {meta.total_data} data
              </div>
              <div className="flex items-center gap-2 flex-wrap justify-center">
                <button
                  onClick={() => handlePageChange(currentPage - 1)}
                  disabled={currentPage <= 1}
                  className="p-2 border rounded hover:bg-gray-100 disabled:opacity-50 disabled:cursor-not-allowed cursor-pointer"
                >
                  <ChevronLeft size={18} />
                </button>

                {getPageNumbers().map((pageNum, index) =>
                  pageNum === "..." ? (
                    <span key={`ellipsis-${index}`} className="px-2 text-gray-500">
                      ...
                    </span>
                  ) : (
                    <button
                      key={pageNum}
                      onClick={() => handlePageChange(pageNum)}
                      className={`px-3 py-1 rounded border ${
                        currentPage === pageNum
                          ? "bg-violet-700 text-white border-violet-700"
                          : "hover:bg-gray-100"
                      } cursor-pointer`}
                    >
                      {pageNum}
                    </button>
                  ),
                )}

                <button
                  onClick={() => handlePageChange(currentPage + 1)}
                  disabled={currentPage >= meta.total_page}
                  className="p-2 border rounded hover:bg-gray-100 disabled:opacity-50 disabled:cursor-not-allowed cursor-pointer"
                >
                  <ChevronRight size={18} />
                </button>
              </div>
            </div>
          )}
        </>
      )}
    </div>
  );
}