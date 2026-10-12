import { useEffect, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import { useUIStore } from "../../stores/useUIStore.js";
import {
  downloadOwnerDailyReportNotificationPdf,
  getOwnerNotificationDetail,
  markOwnerNotificationAsRead,
} from "../../shared/services/notificationService.js";
import { formatToRupiah } from "../../shared/utils/numberFormat.js";
import { formatQty } from "../../shared/utils/qtyFormat.js";

const formatReportQty = (value, unit) => {
  const satuan = String(unit ?? "")
    .trim()
    .toUpperCase();
  const numericValue = Number(value);

  if ((satuan === "GRAM" || satuan === "G") && Number.isFinite(numericValue)) {
    if (numericValue >= 1000) {
      const kgValue = numericValue / 1000;
      const formattedKg = Number.isInteger(kgValue)
        ? String(kgValue)
        : kgValue.toLocaleString("id-ID", {
            maximumFractionDigits: 3,
          });
      return `${formattedKg} kg`;
    }

    const formattedGram = Number.isInteger(numericValue)
      ? String(numericValue)
      : numericValue.toLocaleString("id-ID", {
          maximumFractionDigits: 3,
        });
    return `${formattedGram} gr`;
  }

  return formatQty(value, unit);
};

const formatDetailDateTime = (dateValue) => {
  if (!dateValue) return "-";

  const dateObj = new Date(dateValue);
  if (Number.isNaN(dateObj.getTime())) return "-";

  return dateObj
    .toLocaleString("id-ID", {
      day: "2-digit",
      month: "long",
      year: "numeric",
      hour: "2-digit",
      minute: "2-digit",
      second: "2-digit",
      hour12: false,
    })
    .replace(/\./g, ":"); 
};

const formatDetailDate = (dateValue) => {
  if (!dateValue) return "-";

  const dateObj = new Date(dateValue);
  if (Number.isNaN(dateObj.getTime())) return "-";

  return dateObj.toLocaleDateString("id-ID", {
    day: "2-digit",
    month: "long",
    year: "numeric",
  });
};

const parseFilenameFromDisposition = (dispositionHeader) => {
  if (!dispositionHeader) return null;

  const utf8FilenameMatch = dispositionHeader.match(
    /filename\*=UTF-8''([^;]+)/i,
  );
  if (utf8FilenameMatch?.[1]) {
    return decodeURIComponent(utf8FilenameMatch[1]);
  }

  const filenameMatch = dispositionHeader.match(/filename="?([^";]+)"?/i);
  return filenameMatch?.[1] || null;
};

export default function DetailNotifikasi() {
  const { id } = useParams();
  const navigate = useNavigate();
  const { setActiveTab } = useUIStore();
  const [notification, setNotification] = useState(null);
  const [loading, setLoading] = useState(true);
  const [errorMessage, setErrorMessage] = useState("");
  const [downloadError, setDownloadError] = useState("");
  const [isDownloadingPdf, setIsDownloadingPdf] = useState(false);

  useEffect(() => {
    let isMounted = true;

    const fetchNotificationDetail = async () => {
      setLoading(true);
      setErrorMessage("");
      setDownloadError("");

      try {
        const selectedNotification = await getOwnerNotificationDetail(id);

        if (!selectedNotification) {
          if (isMounted) {
            setNotification(null);
            setErrorMessage("Notifikasi tidak ditemukan.");
          }
          return;
        }

        let normalizedNotification = selectedNotification;
        if (!selectedNotification.is_read) {
          try {
            await markOwnerNotificationAsRead(
              selectedNotification.id_notification,
            );
            normalizedNotification = { ...selectedNotification, is_read: true };
          } catch (markReadError) {
            console.error(
              "Gagal menandai notifikasi owner dibaca:",
              markReadError,
            );
          }
        }

        if (isMounted) {
          setNotification(normalizedNotification);
        }
      } catch (error) {
        console.error("Gagal memuat detail notifikasi owner:", error);
        if (isMounted) {
          setErrorMessage(
            error?.response?.data?.message ||
              "Terjadi kesalahan saat memuat detail notifikasi.",
          );
        }
      } finally {
        if (isMounted) {
          setLoading(false);
        }
      }
    };

    setActiveTab("Notifikasi");
    fetchNotificationDetail();

    return () => {
      isMounted = false;
    };
  }, [id, setActiveTab]);

  const handleDownloadPdf = async () => {
    if (!notification?.can_download_pdf) return;

    setIsDownloadingPdf(true);
    setDownloadError("");

    try {
      const response = await downloadOwnerDailyReportNotificationPdf(
        notification.id_notification,
      );
      const blob = new Blob([response.data], { type: "application/pdf" });
      const blobUrl = window.URL.createObjectURL(blob);

      const disposition = response.headers?.["content-disposition"];
      const preferredFilename = parseFilenameFromDisposition(disposition);
      const fallbackFilename = `daily-report-${
        notification?.report_detail?.report_date || notification.id_notification
      }.pdf`;

      const downloadLink = document.createElement("a");
      downloadLink.href = blobUrl;
      downloadLink.download = preferredFilename || fallbackFilename;
      document.body.appendChild(downloadLink);
      downloadLink.click();
      downloadLink.remove();
      window.URL.revokeObjectURL(blobUrl);
    } catch (error) {
      console.error("Gagal mengunduh PDF notifikasi laporan harian:", error);
      setDownloadError("Gagal mengunduh PDF laporan harian.");
    } finally {
      setIsDownloadingPdf(false);
    }
  };

  const isReportDaily = notification?.notification_type === "REPORT_DAILY";
  const reportDetail = notification?.report_detail;
  const reportSummary = reportDetail?.summary || null;
  const highestTransaction = reportDetail?.highest_transaction || null;
  const dailyItems = Array.isArray(reportDetail?.daily_items)
    ? reportDetail.daily_items
    : [];

  if (loading) {
    return (
      <div className="flex-1 p-3 sm:p-6 bg-gray-50 min-h-screen flex items-center justify-center">
        <p className="text-lg text-gray-600">Memuat detail notifikasi...</p>
      </div>
    );
  }

  if (errorMessage) {
    return (
      <div className="flex-1 p-3 sm:p-6 bg-gray-50 min-h-screen">
        <div className="max-w-4xl mx-auto">
          <button
            type="button"
            onClick={() => navigate("/owner/dashboard")}
            className="mb-4 px-3 sm:px-4 py-2 bg-violet-700 text-white rounded hover:bg-violet-800 cursor-pointer text-sm flex items-center gap-1"
          >
            ← Kembali
          </button>
          <div className="bg-white rounded-lg shadow p-6">
            <p className="text-red-600 font-medium">{errorMessage}</p>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="flex-1 p-3 sm:p-6 bg-gray-50 min-h-screen">
      <div className="max-w-4xl mx-auto">
        <button
          type="button"
          onClick={() => navigate("/owner/dashboard")}
          className="mb-4 px-3 sm:px-4 py-2 bg-violet-700 text-white rounded hover:bg-violet-800 cursor-pointer text-sm flex items-center gap-1"
        >
          ← Kembali
        </button>

        <div className="bg-white rounded-lg shadow p-4 sm:p-6">
          <div className="mb-4">
            <h2 className="text-2xl sm:text-3xl font-bold text-gray-900">
              Detail Notifikasi
            </h2>
          </div>

          <div className="space-y-5">
            <div>
              <p className="text-sm font-semibold text-gray-500 mb-1">Judul</p>
              <p className="text-base sm:text-lg font-medium text-gray-900 break-words">
                {notification?.title || "-"}
              </p>
            </div>

            <div>
              <p className="text-sm font-semibold text-gray-500 mb-1">Waktu</p>
              <p className="text-sm sm:text-base text-gray-700">
                {formatDetailDateTime(notification?.created_at)}
              </p>
            </div>

            <div>
              <p className="text-sm font-semibold text-gray-500 mb-1">Pesan</p>
              <p className="text-sm sm:text-base text-gray-800 whitespace-pre-wrap break-words leading-relaxed">
                {notification?.message || "-"}
              </p>
            </div>

            {isReportDaily && (
              <>
                {notification?.can_download_pdf && (
                  <div>
                    <button
                      type="button"
                      onClick={handleDownloadPdf}
                      disabled={isDownloadingPdf}
                      className="px-4 py-2 bg-violet-700 text-white rounded hover:bg-violet-800 disabled:opacity-50 disabled:cursor-not-allowed cursor-pointer text-sm font-medium"
                    >
                      {isDownloadingPdf
                        ? "Mengunduh PDF..."
                        : "Unduh Laporan Harian (PDF)"}
                    </button>
                    {downloadError && (
                      <p className="text-sm text-red-600 mt-2">
                        {downloadError}
                      </p>
                    )}
                  </div>
                )}

                <div className="pt-3 border-t border-gray-200">
                  <p className="text-sm font-semibold text-gray-500 mb-3">
                    Detail Laporan Harian
                  </p>

                  {reportDetail ? (
                    <div className="space-y-4">
                      <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                        <div className="bg-violet-50 rounded-md p-3">
                          <p className="text-xs text-gray-600">
                            Tanggal Laporan
                          </p>
                          <p className="text-sm font-semibold text-gray-900 mt-1">
                            {formatDetailDate(reportDetail.report_date)}
                          </p>
                        </div>
                      </div>

                      <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                        <div className="bg-gray-50 rounded-md p-3">
                          <p className="text-xs text-gray-600">
                            Total Penjualan
                          </p>
                          <p className="text-base font-semibold text-gray-900 mt-1">
                            {formatToRupiah(reportSummary?.total_sales || 0)}
                          </p>
                        </div>
                        <div className="bg-gray-50 rounded-md p-3">
                          <p className="text-xs text-gray-600">
                            Total Transaksi
                          </p>
                          <p className="text-base font-semibold text-gray-900 mt-1">
                            {reportSummary?.total_transactions || 0}
                          </p>
                        </div>
                        <div className="bg-gray-50 rounded-md p-3">
                          <p className="text-xs text-gray-600">
                            Transaksi Member
                          </p>
                          <p className="text-base font-semibold text-gray-900 mt-1">
                            {reportSummary?.total_member_transactions || 0}
                          </p>
                        </div>
                        <div className="bg-gray-50 rounded-md p-3">
                          <p className="text-xs text-gray-600">
                            Transaksi Guest
                          </p>
                          <p className="text-base font-semibold text-gray-900 mt-1">
                            {reportSummary?.total_guest_transactions || 0}
                          </p>
                        </div>
                      </div>

                      <div className="bg-gray-50 rounded-md p-3">
                        <p className="text-xs text-gray-600 mb-1">
                          Transaksi Tertinggi
                        </p>
                        {highestTransaction ? (
                          <div className="text-sm text-gray-800 space-y-1">
                            <p>
                              <span className="font-semibold">Kode:</span>{" "}
                              {highestTransaction.kode_transaksi || "-"}
                            </p>
                            <p>
                              <span className="font-semibold">Pelanggan:</span>{" "}
                              {highestTransaction.customer_name || "-"}
                            </p>
                            <p>
                              <span className="font-semibold">Tipe:</span>{" "}
                              {highestTransaction.customer_type || "-"}
                            </p>
                            <p>
                              <span className="font-semibold">Total:</span>{" "}
                              {formatToRupiah(
                                highestTransaction.total_harga || 0,
                              )}
                            </p>
                          </div>
                        ) : (
                          <p className="text-sm text-gray-600">
                            Tidak ada transaksi pada tanggal ini.
                          </p>
                        )}
                      </div>

                      <div>
                        <p className="text-xs text-gray-600 mb-2">
                          Item Transaksi Harian
                        </p>
                        {dailyItems.length > 0 ? (
                          <div className="overflow-auto border border-gray-200 rounded-md">
                            <table className="min-w-full text-sm">
                              <thead className="bg-gray-100 text-gray-700">
                                <tr>
                                  <th className="px-3 py-2 text-left">
                                    Barang
                                  </th>
                                  <th className="px-3 py-2 text-left">Qty</th>
                                  <th className="px-3 py-2 text-left">
                                    Subtotal
                                  </th>
                                  <th className="px-3 py-2 text-left">
                                    Transaksi
                                  </th>
                                </tr>
                              </thead>
                              <tbody>
                                {dailyItems.map((item) => (
                                  <tr
                                    key={item.id_detail_transaksi}
                                    className="border-t border-gray-200"
                                  >
                                    <td className="px-3 py-2">
                                      {item.item_name}
                                    </td>
                                    <td className="px-3 py-2">
                                      {formatReportQty(
                                        item.quantity,
                                        item.satuan_dasar,
                                      )}
                                    </td>
                                    <td className="px-3 py-2">
                                      {formatToRupiah(item.subtotal || 0)}
                                    </td>
                                    <td className="px-3 py-2">
                                      {item.kode_transaksi || "-"}
                                    </td>
                                  </tr>
                                ))}
                              </tbody>
                            </table>
                          </div>
                        ) : (
                          <p className="text-sm text-gray-600">
                            Belum ada item transaksi untuk laporan ini.
                          </p>
                        )}
                      </div>
                    </div>
                  ) : (
                    <p className="text-sm text-gray-600">
                      Detail laporan harian belum tersedia.
                    </p>
                  )}
                </div>
              </>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
