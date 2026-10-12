import Header from "../components/Header.jsx";
import { useUIStore } from "../../stores/useUIStore.js";
import { useBarangStore } from "../../stores/useBarangStore.js";
import { useState, useEffect } from "react";
import { useBarang } from "../../shared/hooks/useBarang.js";
import SearchBar from "../components/barang/SearchBar.jsx";
import BarangTable from "../components/barang/BarangTable.jsx";
import BarangModal from "../components/barang/BarangModal.jsx";
import { useNavigate } from "react-router-dom";
import { ArrowRight, ChevronLeft, ChevronRight } from "lucide-react";

export default function DaftarBarang() {
  const navigate = useNavigate();
  const { setActiveTab } = useUIStore();
  const { barang, setBarang, searchQuery, setSearchQuery } = useBarangStore();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [currentBarang, setCurrentBarang] = useState(null);
  const LIMIT = 10;
  const [page, setPage] = useState(1);

  const { fetchBarang, search, remove, loading, error, meta } = useBarang({
    searchQuery,
    setBarang,
    mode: "admin",
  });

  useEffect(() => {
    setActiveTab("Daftar Barang");
    fetchBarang({ page: 1, limit: LIMIT });
  }, []);

  useEffect(() => {
    if (!(searchQuery ?? "").trim()) {
      setPage(1);
      fetchBarang({ page: 1, limit: LIMIT });
    }
  }, [searchQuery]);

  useEffect(() => {
    if (!(searchQuery ?? "").trim()) {
      fetchBarang({ page, limit: LIMIT });
    }
  }, [page]);

  const handleSearch = (e) => {
    e.preventDefault();
    setPage(1);
    if (!searchQuery.trim()) {
      fetchBarang({ page: 1, limit: LIMIT });
    } else {
      search();
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
    <div className="flex-1">
      <Header />
      <div className="p-6">
        <div className="flex justify-between mb-6">
          <h1 className="text-2xl font-bold">Daftar Barang</h1>
          <div className="text-sm">
            Untuk menambah barang baru atau menambah stok, gunakan menu{" "}
            <button
              onClick={() => navigate("/admin/barang-masuk")}
              className="bg-blue-500 font-semibold px-4 py-2 rounded-lg inline-flex items-center gap-2 hover:bg-blue-600 active:bg-blue-700 cursor-pointer"
            >
              Barang Masuk
              <ArrowRight size={18} />
            </button>
          </div>
        </div>

        <SearchBar
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          onSubmit={handleSearch}
        />

        <BarangTable
          barang={barang}
          pageOffset={(meta?.page ? meta.page - 1 : 0) * LIMIT}
          isLoading={loading}
          error={error}
          onEdit={setCurrentBarang}
          onDelete={remove}
          openModal={() => setIsModalOpen(true)}
        />

        {!(searchQuery ?? "").trim() && totalPage > 0 && (
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
                        ? "bg-blue-500 text-white border-blue-500"
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

        {isModalOpen && (
          <BarangModal
            currentBarang={currentBarang}
            onClose={() => setIsModalOpen(false)}
            onSuccess={() => {
              fetchBarang({ page, limit: LIMIT });
              setIsModalOpen(false);
            }}
          />
        )}
      </div>
    </div>
  );
}