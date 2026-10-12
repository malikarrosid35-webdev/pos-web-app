import { useEffect, useState } from "react";
import { useUIStore } from "../../stores/useUIStore.js";
import { useBarangMasukStore } from "../../stores/useBarangMasukStore.js";
import { useBarangMasuk } from "../../shared/hooks/useBarangMasuk.js";
import { formatToRupiah } from "../../shared/utils/numberFormat.js";
import { formatQty } from "../../shared/utils/qtyFormat.js";
import { ChevronLeft, ChevronRight } from "lucide-react";

export default function BarangMasuk() {
  const { setActiveTab } = useUIStore();
  const { barangMasuk, setBarangMasuk } = useBarangMasukStore();
  const [page, setPage] = useState(1);
  const [searchInput, setSearchInput] = useState("");
  const [keyword, setKeyword] = useState("");
  const { fetchBarangMasuk, loading, meta } = useBarangMasuk({
    setBarangMasuk,
    mode: "owner",
  });

  useEffect(() => {
    setActiveTab("Riwayat Barang Masuk");
  }, []);

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

  return (
    <div className="flex-1 p-3 sm:p-6 bg-gray-50 min-h-screen">
      <div className="mb-4 sm:mb-6">
        <h1 className="text-2xl sm:text-3xl font-bold text-gray-800">
          Riwayat Barang Masuk
        </h1>
      </div>
      <form onSubmit={handleSearch} className="mb-4 sm:mb-6">
        <div className="relative">
          <input
            type="text"
            placeholder="Cari nama barang masuk..."
            className="w-full p-3 pr-24 rounded-lg border border-gray-300 bg-white focus:outline-none focus:ring-2 focus:ring-violet-400"
            value={searchInput}
            onChange={(e) => setSearchInput(e.target.value)}
          />
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
          <div className="overflow-x-auto bg-white rounded-lg shadow">
            <table className="min-w-full divide-y divide-gray-200 text-sm">
              <thead className="bg-violet-800 text-white">
                <tr>
                  <th className="px-4 sm:px-6 py-3 text-left font-bold">No</th>
                  <th className="px-4 sm:px-6 py-3 text-left font-bold">
                    Nama Barang
                  </th>
                  <th className="px-4 sm:px-6 py-3 text-left font-bold">
                    Jumlah Masuk
                  </th>
                  <th className="px-4 sm:px-6 py-3 text-left font-bold">
                    Harga Beli
                  </th>
                  <th className="px-4 sm:px-6 py-3 text-left font-bold">
                    Total Harga
                  </th>
                  <th className="px-4 sm:px-6 py-3 text-left font-bold">
                    Tanggal
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {barangMasuk.length === 0 ? (
                  <tr>
                    <td
                      colSpan="6"
                      className="px-4 sm:px-6 py-4 text-center text-gray-500"
                    >
                      Tidak ada data barang masuk
                    </td>
                  </tr>
                ) : (
                  barangMasuk.map((item, index) => (
                    <tr key={item.id_barang_masuk} className="hover:bg-gray-50">
                      <td className="px-4 sm:px-6 py-3 sm:py-4 text-gray-700">
                        {(currentPage - 1) * 10 + index + 1}
                      </td>
                      <td className="px-4 sm:px-6 py-3 sm:py-4 text-gray-900 font-semibold">
                        {item.nama_barang}
                      </td>
                      <td className="px-4 sm:px-6 py-3 sm:py-4 text-gray-700">
                        {formatQty(item.qty_dasar, item.satuan_dasar)}
                      </td>
                      <td className="px-4 sm:px-6 py-3 sm:py-4 text-gray-700">
                        {formatToRupiah(parseFloat(item.harga_beli_per_sd))}
                      </td>
                      <td className="px-4 sm:px-6 py-3 sm:py-4 text-gray-700">
                        {formatToRupiah(parseFloat(item.harga_beli_total))}
                      </td>
                      <td className="px-4 sm:px-6 py-3 sm:py-4 text-gray-700">
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
                  disabled={currentPage >= totalPage}
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