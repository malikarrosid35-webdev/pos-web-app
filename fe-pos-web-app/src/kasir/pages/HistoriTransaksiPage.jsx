import { useState, useEffect } from "react";
import { useTransaksi } from "../../shared/hooks/useTransaksi.js";
import { formatToRupiah } from "../../shared/utils/numberFormat.js";
import { useNavigate } from "react-router-dom";
import {
  Download,
  Eye,
  ChevronLeft,
  ChevronRight,
  X,
} from "lucide-react";
import { useUIStore } from "../../stores/useUIStore.js";

export const HistoriTransaksiPage = () => {
  const [searchTerm, setSearchTerm] = useState("");
  const [isSearching, setIsSearching] = useState(false);
  const {
    historiTransaksi,
    fetchHistoriTransaksi,
    searchHistoriTransaksi,
    loading,
    meta,
    downloadInvoice,
  } = useTransaksi({ mode: "kasir" });
  const [currentPage, setCurrentPage] = useState(1);
  const [limit] = useState(10);
  const navigate = useNavigate();
  const { setActiveTab } = useUIStore();

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
  const formatDate = (dateString) =>
    new Date(dateString).toLocaleDateString("id-ID", {
      day: "2-digit",
      month: "short",
      year: "numeric",
    });

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
  
  // Komponen badge status — dipakai di card & tabel
  const StatusBadge = ({ tipe }) =>
    tipe === "member" ? (
      <span className="bg-green-800 text-white py-1 px-2 rounded-full text-xs">
        Member
      </span>
    ) : (
      <span className="bg-gray-200 text-black py-1 px-2 rounded-full text-xs">
        Guest
      </span>
    );

  // Komponen tombol aksi — dipakai di card & tabel
  const ActionButtons = ({ transaction }) => (
    <div className="flex gap-1 sm:gap-2 justify-center">
      <button
        onClick={() => downloadInvoice(transaction.id_transaksi)}
        title="Unduh File Invoice PDF"
        className="cursor-pointer p-1.5 sm:p-2 bg-blue-600 text-white rounded hover:bg-blue-700"
      >
        <Download size={15} />
      </button>
      <button
        onClick={() =>
          navigate(`/kasir/detail-transaksi/${transaction.id_transaksi}`)
        }
        title="Detail Transaksi"
        className="cursor-pointer p-1.5 sm:p-2 bg-indigo-600 text-white rounded hover:bg-indigo-700"
      >
        <Eye size={15} />
      </button>
    </div>
  );

  return (
    <div className="container mx-auto p-3 sm:p-4">
      <div className="flex justify-between items-center mb-4 sm:mb-6">
        <h1 className="text-xl sm:text-2xl font-bold">
          Histori Transaksi
        </h1>
        <div className="text-sm text-gray-500">
          Total Data: {meta.total_data || 0} transaksi
        </div>
      </div>

      <form onSubmit={handleSearch} className="mb-4">
        <div className="relative w-full sm:w-1/2">
          <input
            type="text"
            placeholder="Cari dengan Kode Transaksi atau Member..."
            className="w-full px-3 sm:px-4 py-2 pr-24 border rounded shadow-sm focus:outline-none focus:ring-2 focus:ring-green-400 text-sm"
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
            className="absolute right-1 top-1 bottom-1 px-4 rounded-md bg-green-700 text-white hover:bg-green-800 active:bg-green-900 cursor-pointer"
          >
            Cari
          </button>
        </div>
      </form>

      {loading ? (
        <div className="flex items-center justify-center py-16">
          <div className="animate-spin rounded-full h-10 w-10 border-b-2 border-green-600" />
        </div>
      ) : (
        <>
          {/* ── Mobile: card list (< 768px) ─────────────────────────────── */}
          <div className="flex flex-col gap-3 md:hidden">
            {historiTransaksi.length === 0 ? (
              <div className="bg-white rounded-xl border shadow-sm p-6 text-center text-gray-500 text-sm">
                {isSearching
                  ? "Tidak ada transaksi ditemukan"
                  : "Belum ada transaksi"}
              </div>
            ) : (
              historiTransaksi.map((transaction) => (
                <div
                  key={transaction.id_transaksi}
                  className="bg-white rounded-xl border shadow-sm p-4"
                >
                  <div className="flex justify-between items-start mb-2">
                    <div>
                      <p className="font-semibold text-sm text-gray-900">
                        {/* {transaction.kode_transaksi} */}
                        TRX-1A2B3C
                      </p>
                      <p className="text-xs text-gray-500 mt-0.5">
                        {/* {formatDate(transaction.created_at)} */}
                        01 Januari 2025
                      </p>
                      <p className="text-xs text-gray-600 mt-0.5">
                        {transaction.tipe_pelanggan === "member"
                          ? transaction.nama_pelanggan || "-"
                          : "-"}
                      </p>
                    </div>
                    <StatusBadge tipe={transaction.tipe_pelanggan} />
                  </div>
                  <div className="flex justify-between items-center text-sm mb-3">
                    <span className="text-gray-500">
                      {transaction.jumlah_item || 0} item
                    </span>
                    <span className="font-bold text-green-700">
                      {formatToRupiah(parseFloat(transaction.total_harga))}
                    </span>
                  </div>
                  <div className="flex justify-end">
                    <ActionButtons transaction={transaction} />
                  </div>
                </div>
              ))
            )}
          </div>

          {/* ── Tablet + Desktop: tabel (≥ 768px) ──────────────────────── */}
          <div className="hidden md:block overflow-x-auto">
            <table className="min-w-full bg-white rounded-lg overflow-hidden">
              <thead className="bg-green-700 text-white">
                <tr>
                  <th className="py-3 px-4 text-left">Kode Transaksi</th>
                  <th className="py-3 px-4 text-left">Tanggal</th>
                  <th className="py-3 px-4 text-left">Qty Barang</th>
                  <th className="py-3 px-4 text-left">Total Harga</th>
                  <th className="py-3 px-4 text-left">Tipe Pelanggan</th>
                  <th className="py-3 px-4 text-left">
                    Pelanggan
                  </th>
                  <th className="py-3 px-4 text-center">Aksi</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200">
                {historiTransaksi.length === 0 ? (
                  <tr>
                    <td
                      colSpan="7"
                      className="py-4 px-4 text-center text-gray-500 text-sm"
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
                    <td className="py-3 px-4 text-sm">
                      {transaction.kode_transaksi}
                    </td>
                    <td className="py-3 px-4 text-sm">
                      {formatDate(transaction.created_at)}
                    </td>
                    <td className="py-3 px-4 text-sm">
                      {transaction.jumlah_item || "0"}
                    </td>
                    <td className="py-3 px-4 text-sm">
                      {formatToRupiah(parseFloat(transaction.total_harga))}
                    </td>
                    <td className="py-3 px-4">
                      <StatusBadge tipe={transaction.tipe_pelanggan} />
                    </td>
                    <td className="py-3 px-4 text-sm">
                      {transaction.tipe_pelanggan === "member"
                        ? transaction.nama_pelanggan || "-"
                        : "-"}
                    </td>
                    <td className="py-3 px-4 flex justify-around">
                      <ActionButtons transaction={transaction} />
                    </td>
                  </tr>
                  ))
                )}
              </tbody>
            </table>
            {!loading && meta.total_page > 0 && (
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
                            ? "bg-green-700 text-white border-green-700"
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
          </div>
        </>
      )}
    </div>
  );
};