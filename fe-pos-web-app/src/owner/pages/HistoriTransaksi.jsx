import { useEffect, useState } from "react";
import { useUIStore } from "../../stores/useUIStore.js";
import { formatToRupiah } from "../../shared/utils/numberFormat.js";
import { useNavigate } from "react-router-dom";
import { Eye, ChevronLeft, ChevronRight, X } from "lucide-react";
import { useTransaksi } from "../../shared/hooks/useTransaksi.js";

export default function HistoriTransaksi() {
  const { setActiveTab } = useUIStore();
  const {
    historiTransaksi,
    fetchHistoriTransaksi,
    searchHistoriTransaksi,
    loading,
    meta,
  } = useTransaksi({ mode: "owner" });
  const [searchTerm, setSearchTerm] = useState("");
  const [isSearching, setIsSearching] = useState(false);
  const [currentPage, setCurrentPage] = useState(1);
  const [limit] = useState(10);
  const navigate = useNavigate();

  useEffect(() => {
    setActiveTab("Histori Transaksi");
  }, [setActiveTab]);

  // Setiap kali kata kunci atau halaman berubah, cari ulang ke server
  // (bukan memfilter data di halaman aktif saja) lalu reset ke halaman 1.
  useEffect(() => {
    const timer = setTimeout(() => {
      const trimmed = searchTerm.trim();
      if (trimmed) {
        setIsSearching(true);
        searchHistoriTransaksi(trimmed, currentPage, limit);
      } else {
        setIsSearching(false);
        fetchHistoriTransaksi(currentPage, limit);
      }
    }, 400);

    return () => clearTimeout(timer);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [searchTerm, currentPage]);

  const handleSearch = (e) => {
    e.preventDefault();
    if (currentPage !== 1) {
      setCurrentPage(1);
      return;
    }
    const trimmed = searchTerm.trim();
    if (trimmed) {
      setIsSearching(true);
      searchHistoriTransaksi(trimmed, 1, limit);
    } else {
      setIsSearching(false);
      fetchHistoriTransaksi(1, limit);
    }
  };

  const handleClearSearch = () => {
    setSearchTerm("");
    setIsSearching(false);
    setCurrentPage(1);
  };

  const handlePageChange = (newPage) => {
    if (newPage >= 1 && newPage <= meta.total_page) {
      setCurrentPage(newPage);
    }
  };

  const formatDate = (dateString) => {
    return new Date(dateString).toLocaleDateString("id-ID", {
      day: "2-digit",
      month: "short",
      year: "numeric",
    });
  };
  
  const getPageNumbers = () => {
    const total = meta.total_page || 1;
    const current = currentPage;
    const pages = [];

    if (total <= 7) {
      for (let i = 1; i <= total; i++) {
        pages.push(i);
      }
    } else {
      if (current <= 4) {
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
    }
    return pages;
  };
  
  return (
    <div className="flex-1 p-3 sm:p-6 bg-gray-50 min-h-screen">
      <div className="mb-4 sm:mb-6">
        <h1 className="text-2xl sm:text-3xl font-bold text-gray-800">
          Histori Transaksi
        </h1>
      </div>

      <form onSubmit={handleSearch} className="mb-4 sm:mb-6">
        <div className="relative w-full sm:w-1/2">
          <input
            type="text"
            placeholder="Cari dengan Kode Transaksi atau Member..."
            className="w-full px-3 sm:px-4 py-2 pr-24 border rounded shadow-sm focus:outline-none focus:ring-2 focus:ring-violet-500 text-sm"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
          {searchTerm && (
            <button
              type="button"
              onClick={handleClearSearch}
              className="absolute right-20 top-1 bottom-1 px-3 text-gray-500 hover:text-gray-800 cursor-pointer"
              aria-label="Bersihkan pencarian"
            >
              <X size={18} />
            </button>
          )}
          <button
            type="submit"
            className="absolute right-1 top-1 bottom-1 px-4 rounded-md bg-violet-700 text-white hover:bg-violet-800 active:bg-violet-900 cursor-pointer"
          >
            Cari
          </button>
        </div>
      </form>

      {loading ? (
        <div className="flex items-center justify-center py-20">
          <p className="text-lg text-gray-600">Memuat data...</p>
        </div>
      ) : (
        <>
          {/* Table - Desktop */}
          <div className="hidden md:block overflow-x-auto bg-white rounded-lg shadow">
            <table className="min-w-full divide-y divide-gray-200 text-sm">
              <thead className="bg-violet-800 text-white">
                <tr>
                  <th className="px-4 sm:px-6 py-3 text-left font-bold">
                    Kode Transaksi
                  </th>
                  <th className="px-4 sm:px-6 py-3 text-left font-bold">
                    Tanggal
                  </th>
                  <th className="px-4 sm:px-6 py-3 text-left font-bold">
                    Jumlah Item
                  </th>
                  <th className="px-4 sm:px-6 py-3 text-left font-bold">
                    Total
                  </th>
                  <th className="px-4 sm:px-6 py-3 text-left font-bold">
                    Status Pelanggan
                  </th>
                  <th className="px-4 sm:px-6 py-3 text-left font-bold">
                    Pelanggan
                  </th>
                  <th className="px-4 sm:px-6 py-3 text-left font-bold">
                    Aksi
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {historiTransaksi.length === 0 ? (
                  <tr>
                    <td
                      colSpan="7"
                      className="px-4 sm:px-6 py-4 text-center text-gray-500"
                    >
                      {isSearching
                        ? "Tidak ada transaksi ditemukan"
                        : "Belum ada transaksi"}
                    </td>
                  </tr>
                ) : (
                  historiTransaksi.map((transaction) => (
                    <tr
                      key={transaction.id_transaksi}
                      className="hover:bg-gray-50"
                    >
                      <td className="px-4 sm:px-6 py-3 sm:py-4 text-gray-900 font-semibold">
                        {transaction.kode_transaksi}
                      </td>
                      <td className="px-4 sm:px-6 py-3 sm:py-4 text-gray-700">
                        {formatDate(transaction.created_at)}
                      </td>
                      <td className="px-4 sm:px-6 py-3 sm:py-4 text-gray-700">
                        {transaction.jumlah_item || "0"}
                      </td>
                      <td className="px-4 sm:px-6 py-3 sm:py-4 text-gray-700">
                        {formatToRupiah(parseFloat(transaction.total_harga))}
                      </td>
                      <td className="px-4 sm:px-6 py-3 sm:py-4">
                        {transaction.tipe_pelanggan === "member" ? (
                          <span className="bg-green-100 text-green-800 py-1 px-2 rounded-full text-xs">
                            Member
                          </span>
                        ) : (
                          <span className="bg-gray-200 text-black py-1 px-2 rounded-full text-xs">
                            Guest
                          </span>
                        )}
                      </td>
                      <td className="px-4 sm:px-6 py-3 sm:py-4 text-gray-700">
                        {transaction.tipe_pelanggan === "member"
                          ? transaction.nama_pelanggan || "-"
                          : "-"}
                      </td>
                      <td className="px-4 sm:px-6 py-3 sm:py-4">
                        <button
                          onClick={() =>
                            navigate(
                              `/owner/detail-transaksi/${transaction.id_transaksi}`,
                            )
                          }
                          title="Lihat Detail"
                          className="cursor-pointer p-1.5 sm:p-2 bg-violet-700 text-white rounded hover:bg-violet-800"
                        >
                          <Eye size={16} className="sm:w-5 sm:h-5" />
                        </button>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>

          {/* Card View - Mobile */}
          <div className="md:hidden space-y-3">
            {historiTransaksi.length === 0 ? (
              <div className="bg-white rounded-lg shadow p-6 text-center text-gray-500">
                {isSearching
                  ? "Tidak ada transaksi ditemukan"
                  : "Belum ada transaksi"}
              </div>
            ) : (
              historiTransaksi.map((transaction) => (
                <div
                  key={transaction.id_transaksi}
                  className="bg-white rounded-lg shadow p-4"
                >
                  <div className="flex justify-between items-start mb-2">
                    <div>
                      <p className="font-semibold text-sm text-gray-900">
                        {transaction.kode_transaksi}
                      </p>
                      <p className="text-xs text-gray-500 mt-0.5">
                        {formatDate(transaction.created_at)}
                      </p>
                      <p className="text-xs text-gray-600 mt-0.5">
                        {transaction.tipe_pelanggan === "member"
                          ? transaction.nama_pelanggan || "-"
                          : "-"}
                      </p>
                    </div>
                    {transaction.tipe_pelanggan === "member" ? (
                      <span className="bg-green-100 text-green-800 py-1 px-2 rounded-full text-xs">
                        Member
                      </span>
                    ) : (
                      <span className="bg-gray-200 text-black py-1 px-2 rounded-full text-xs">
                        Guest
                      </span>
                    )}
                  </div>
                  <div className="flex justify-between items-center text-sm mb-3">
                    <span className="text-gray-500">
                      {transaction.jumlah_item || 0} item
                    </span>
                    <span className="font-bold text-violet-700">
                      {formatToRupiah(parseFloat(transaction.total_harga))}
                    </span>
                  </div>
                  <div className="flex justify-end">
                    <button
                      onClick={() =>
                        navigate(
                          `/owner/detail-transaksi/${transaction.id_transaksi}`,
                        )
                      }
                      title="Lihat Detail"
                      className="cursor-pointer p-2 bg-violet-700 text-white rounded hover:bg-violet-800"
                    >
                      <Eye size={16} />
                    </button>
                  </div>
                </div>
              ))
            )}
          </div>

          {/* Pagination */}
          {meta.total_page > 0 && (
            <div className="flex flex-col sm:flex-row justify-between items-center gap-4 mt-4">
              <div className="text-sm text-gray-500">
                Menampilkan{" "}
                {historiTransaksi.length > 0
                  ? (currentPage - 1) * limit + 1
                  : 0}{" "}
                - {Math.min(currentPage * limit, meta.total_data)} dari{" "}
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
                    <span
                      key={`ellipsis-${index}`}
                      className="px-2 text-gray-500"
                    >
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