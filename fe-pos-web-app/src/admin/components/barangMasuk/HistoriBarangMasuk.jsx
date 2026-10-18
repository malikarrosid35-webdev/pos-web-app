import { useEffect, useState } from "react";
import { useBarangMasukStore } from "../../../stores/useBarangMasukStore.js";
import { useBarangMasuk } from "../../../shared/hooks/useBarangMasuk.js";
import { formatQty } from "../../../shared/utils/qtyFormat.js";
import { ChevronLeft, ChevronRight } from "lucide-react";

export default function HistoriBarangMasuk({ mode = "admin" }) {
  const isOwner = mode === "owner";
  const { barangMasuk, setBarangMasuk } = useBarangMasukStore();
  const [page, setPage] = useState(1);
  const [searchInput, setSearchInput] = useState("");
  const [keyword, setKeyword] = useState("");

  const { fetchBarangMasuk, meta, loading } = useBarangMasuk({
    setBarangMasuk,
    mode,
  });

  useEffect(() => {
    fetchBarangMasuk({ page, limit: 10, keyword });
  }, [page, keyword]);

  const totalPage = meta.total_page || 1;
  const totalData = meta.total_data || 0;
  const currentPage = meta.page || page;
  const formatDate = (dateString) =>
    new Date(dateString).toLocaleDateString("id-ID", {
      day: "2-digit",
      month: "short",
      year: "numeric",
    });

  const handlePageChange = (newPage) => {
    if (newPage >= 1 && newPage <= totalPage) {
      setPage(newPage);
    }
  };

  const handleSearch = (e) => {
    e.preventDefault();
    const nextKeyword = searchInput.trim();

    setKeyword(nextKeyword);
    if (page !== 1) {
      setPage(1);
    } else {
      fetchBarangMasuk({ page: 1, limit: 10, keyword: nextKeyword });
    }
  };

  const getPageNumbers = () => {
    const total = totalPage;
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

  if (loading) {
    return <p className="text-center py-6">Memuat riwayat...</p>;
  }

  return (
    <div>
      <h3 className="text-lg font-semibold mb-4">Riwayat Barang Masuk</h3>
      <form onSubmit={handleSearch} className="mb-4">
        <div className="relative">
          <input
            type="text"
            placeholder="Cari nama barang masuk..."
            className={`w-full p-3 pr-24 rounded-lg border border-gray-300 focus:outline-none focus:ring-2 ${isOwner ? "focus:ring-violet-400" : "focus:ring-blue-400"}`}
            value={searchInput}
            onChange={(e) => setSearchInput(e.target.value)}
          />
          <button
            type="submit"
            className={`absolute right-1 top-1 bottom-1 px-4 rounded-md text-white cursor-pointer ${
              isOwner
                ? "bg-violet-700 hover:bg-violet-800 active:bg-violet-900"
                : "bg-blue-500 hover:bg-blue-600 active:bg-blue-700"
            }`}
          >
            Cari
          </button>
        </div>
      </form>

      <div className="overflow-x-auto">
        <table className="min-w-full">
          <thead className={isOwner ? "bg-violet-800 text-white" : "bg-blue-400"}>
            <tr>
              <th className="border px-3 py-2">No</th>
              <th className="border px-3 py-2">Nama Barang</th>
              <th className="border px-3 py-2">Qty</th>
              <th className="border px-3 py-2">HB per Satuan Dasar</th>
              <th className="border px-3 py-2">Total</th>
              <th className="border px-3 py-2">Tanggal Masuk</th>
            </tr>
          </thead>
          <tbody>
            {barangMasuk.length === 0 ? (
              <tr>
                <td colSpan="7" className="text-center py-4 text-gray-500">
                  Belum ada data barang masuk
                </td>
              </tr>
            ) : (
              barangMasuk.map((item, idx) => (
                <tr key={item.id_barang_masuk} className="text-center">
                  <td className="border px-3 py-2">
                    {(currentPage - 1) * 10 + idx + 1}
                  </td>
                  <td className="border px-3 py-2">{item.nama_barang}</td>
                  <td className="border px-3 py-2">
                    {formatQty(item.qty_dasar, item.satuan_dasar)}
                  </td>
                  <td className="border px-3 py-2">
                    Rp {Number(item.harga_beli_per_sd).toLocaleString("id-ID")}
                  </td>
                  <td className="border px-3 py-2">
                    Rp {Number(item.harga_beli_total).toLocaleString("id-ID")}
                  </td>
                  <td className="border px-3 py-2">
                    {formatDate(item.created_at)}
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      {/* Pagination */}
      {totalPage > 0 && (
        <div className="flex flex-col sm:flex-row justify-between items-center gap-4 mt-4">
          <div className="text-sm text-gray-500">
            Menampilkan{" "}
            {barangMasuk.length > 0 ? (currentPage - 1) * 10 + 1 : 0} -{" "}
            {Math.min(currentPage * 10, totalData)} dari {totalData} data
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
                      ? isOwner
                        ? "bg-violet-700 text-white border-violet-700"
                        : "bg-blue-500 text-white border-blue-500"
                      : "hover:bg-gray-100"
                  } cursor-pointer`}
                >
                  {pageNum}
                </button>
              ),
            )}

            <button
              onClick={() => handlePageChange(currentPage + 1)}
              disabled={currentPage >= totalPage}
              className="p-2 border rounded hover:bg-gray-100 disabled:opacity-50 disabled:cursor-not-allowed cursor-pointer"
            >
              <ChevronRight size={18} />
            </button>
          </div>
        </div>
      )}
    </div>
  );
}