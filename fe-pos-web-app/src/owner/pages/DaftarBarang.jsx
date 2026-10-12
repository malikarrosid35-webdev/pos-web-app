import { useEffect, useState } from "react";
import { useUIStore } from "../../stores/useUIStore.js";
import { useBarangStore } from "../../stores/useBarangStore.js";
import { useBarang } from "../../shared/hooks/useBarang.js";
import { formatToRupiah } from "../../shared/utils/numberFormat.js";
import { formatQty } from "../../shared/utils/qtyFormat.js";
import { ChevronLeft, ChevronRight } from "lucide-react";

const LIMIT = 10;

export default function DaftarBarang() {
  const { setActiveTab } = useUIStore();
  const { barang, setBarang } = useBarangStore();
  const [searchQuery, setSearchQuery] = useState("");
  const [page, setPage] = useState(1);

  const { fetchBarang, search, loading, meta } = useBarang({
    searchQuery,
    setBarang,
    mode: "owner",
  });

  useEffect(() => {
    setActiveTab("Daftar Barang");
    fetchBarang({ page: 1, limit: LIMIT });
  }, []);

  // Saat page berubah (tanpa pencarian aktif), fetch ulang
  useEffect(() => {
    if (!searchQuery.trim()) {
      fetchBarang({ page, limit: LIMIT });
    }
  }, [page]);

  // Saat searchQuery berubah: jika kosong, reset ke halaman 1 dan fetch semua
  useEffect(() => {
    if (searchQuery.trim() === "") {
      setPage(1);
      fetchBarang({ page: 1, limit: LIMIT });
    }
  }, [searchQuery]);

  const handleSearch = (e) => {
    e.preventDefault();
    setPage(1);
    if (searchQuery.trim()) {
      search();
    } else {
      fetchBarang({ page: 1, limit: LIMIT });
    }
  };

  const totalPage = meta?.total_page || 1;
  const currentPage = meta?.page || page;
  const totalData = meta?.total_data || 0;

  const handlePageChange = (newPage) => {
    if (newPage >= 1 && newPage <= totalPage) {
      setPage(newPage);
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
          Daftar Barang
        </h1>
        <p className="text-sm sm:text-base text-gray-600 mt-1 sm:mt-2">
          Lihat daftar semua barang (Mode Tampilan)
        </p>
      </div>

      {/* Search */}
      <form onSubmit={handleSearch} className="mb-4 sm:mb-6">
        <div className="relative w-full sm:w-1/2">
          <input
            type="text"
            placeholder="Cari barang..."
            className="w-full p-3 pr-24 rounded-lg border border-gray-300 bg-white shadow-sm focus:outline-none focus:ring-2 focus:ring-violet-500 text-sm"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
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
                  {/* <th className="px-4 sm:px-6 py-3 text-left font-bold">
                    Kategori
                  </th> */}
                  <th className="px-4 sm:px-6 py-3 text-left font-bold">
                    Stok
                  </th>
                  <th className="px-4 sm:px-6 py-3 text-left font-bold">
                    Harga Beli
                  </th>
                  <th className="px-4 sm:px-6 py-3 text-left font-bold">
                    Harga Jual
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {barang.length === 0 ? (
                  <tr>
                    <td
                      colSpan="6"
                      className="px-4 sm:px-6 py-4 text-center text-gray-500"
                    >
                      Tidak ada data barang
                    </td>
                  </tr>
                ) : (
                  barang.map((item, index) => (
                    <tr key={item.id_barang} className="hover:bg-gray-50">
                      <td className="px-4 sm:px-6 py-3 sm:py-4 text-gray-700">
                        {(currentPage - 1) * LIMIT + index + 1}
                      </td>
                      <td className="px-4 sm:px-6 py-3 sm:py-4 text-gray-900 font-semibold">
                        {item.nama_barang}
                      </td>
                      {/* <td className="px-4 sm:px-6 py-3 sm:py-4 text-gray-700">
                        {item.kategori_barang}
                      </td> */}
                      <td className="px-4 sm:px-6 py-3 sm:py-4 text-gray-700">
                        {formatQty(item.stok_dasar, item.satuan_dasar)}
                      </td>
                      <td className="px-4 sm:px-6 py-3 sm:py-4 text-gray-700">
                        {formatToRupiah(parseFloat(item.harga_modal_per_sd))}
                      </td>
                      <td className="px-4 sm:px-6 py-3 sm:py-4 text-gray-700">
                        {formatToRupiah(parseFloat(item.harga_jual_per_sd))}
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>

          {/* Pagination — hanya tampil jika tidak dalam mode search atau ada meta */}
          {!searchQuery.trim() && totalPage > 0 && (
            <div className="flex flex-col sm:flex-row justify-between items-center gap-4 mt-4">
              <div className="text-sm text-gray-500">
                Menampilkan{" "}
                {barang.length > 0 ? (currentPage - 1) * LIMIT + 1 : 0} -{" "}
                {Math.min(currentPage * LIMIT, totalData)} dari {totalData} data
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