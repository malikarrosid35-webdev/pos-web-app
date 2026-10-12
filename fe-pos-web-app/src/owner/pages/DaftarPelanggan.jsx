import { useEffect, useState } from "react";
import { useUIStore } from "../../stores/useUIStore.js";
import { usePelangganStore } from "../../stores/usePelangganStore.js";
import { usePelanggan } from "../../shared/hooks/usePelanggan.js";
import { ChevronLeft, ChevronRight, X } from "lucide-react";

export default function DaftarPelanggan() {
  const [searchTerm, setSearchTerm] = useState("");
  const { pelanggan, setPelanggan } = usePelangganStore();
  const [currentPage, setCurrentPage] = useState(1);
  const [limit] = useState(10);
  const [isSearching, setIsSearching] = useState(false);

  const { fetchPelanggan, search, loading, meta } = usePelanggan({
    searchQuery: searchTerm,
    setPelanggan,
    mode: "owner",
  });
  const { setActiveTab } = useUIStore();

  useEffect(() => {
    setActiveTab("Daftar Pelanggan");
  }, [setActiveTab]);

  useEffect(() => {
    const timer = setTimeout(() => {
      const trimmed = searchTerm.trim();
      if (trimmed) {
        setIsSearching(true);
        search(currentPage, limit);
      } else {
        setIsSearching(false);
        fetchPelanggan(currentPage, limit);
      }
    }, 400);

    return () => clearTimeout(timer);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [searchTerm, currentPage]);

  const handleSearch = (e) => {
    e.preventDefault();
    if (currentPage !== 1) {
      setCurrentPage(1);
    } else {
      const trimmed = searchTerm.trim();
      if (trimmed) {
        setIsSearching(true);
        search(1, limit);
      } else {
        setIsSearching(false);
        fetchPelanggan(1, limit);
      }
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
          Daftar Pelanggan Member
        </h1>
        <div className="text-sm text-gray-500">
          {isSearching
            ? `Hasil Data : ${meta.total_data || 0}`
            : `Total Data: ${meta.total_data || 0}`}
        </div>
      </div>

      <form onSubmit={handleSearch} className="mb-4 sm:mb-6">
        <div className="relative w-full sm:w-1/2">
          <input
            type="text"
            placeholder="Cari pelanggan (nama atau no HP)..."
            className="w-full p-3 pr-24 rounded-lg border border-gray-300 bg-white shadow-sm focus:outline-none focus:ring-2 focus:ring-violet-500 text-sm"
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
        <div className="overflow-x-auto bg-white rounded-lg shadow">
          <table className="min-w-full divide-y divide-gray-200 text-sm">
            <thead className="bg-violet-800 text-white">
              <tr>
                <th className="px-4 sm:px-6 py-3 text-left font-bold">No</th>
                <th className="px-4 sm:px-6 py-3 text-left font-bold">Nama</th>
                <th className="px-4 sm:px-6 py-3 text-left font-bold">
                  No. HP
                </th>
                <th className="px-4 sm:px-6 py-3 text-left font-bold">
                  Total Pembelian
                </th>
                <th className="px-4 sm:px-6 py-3 text-left font-bold">
                  Frekuensi
                </th>
                <th className="px-4 sm:px-6 py-3 text-left font-bold">Poin</th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {pelanggan.length === 0 ? (
                <tr>
                  <td
                    colSpan="6"
                    className="px-4 sm:px-6 py-4 text-center text-gray-500"
                  >
                    Tidak ada data pelanggan
                  </td>
                </tr>
              ) : (
                pelanggan.map((p, i) => (
                  <tr key={p.id_pelanggan} className="hover:bg-gray-50">
                    <td className="px-4 sm:px-6 py-3 sm:py-4 text-gray-700">
                      {i + 1}
                    </td>
                    <td className="px-4 sm:px-6 py-3 sm:py-4 text-gray-900 font-semibold">
                      {p.nama_pelanggan}
                    </td>
                    <td className="px-4 sm:px-6 py-3 sm:py-4 text-gray-700">
                      {p.no_hp || "-"}
                    </td>
                    <td className="px-4 sm:px-6 py-3 sm:py-4 text-gray-700">
                      Rp{p.total_pembelian.toLocaleString("id-ID")}
                    </td>
                    <td className="px-4 sm:px-6 py-3 sm:py-4 text-gray-700">
                      {p.frekuensi_transaksi}
                    </td>
                    <td className="px-4 sm:px-6 py-3 sm:py-4 text-gray-700">
                      {p.poin_loyalitas}
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      )}
      {meta.total_page > 0 && (
        <div className="flex flex-col sm:flex-row justify-between items-center gap-4 mt-6">
          <div className="text-sm text-gray-500">
            Menampilkan{" "}
            {pelanggan.length > 0 ? (currentPage - 1) * limit + 1 : 0} -{" "}
            {Math.min(currentPage * limit, meta.total_data)} dari{" "}
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
    </div>
  );
}