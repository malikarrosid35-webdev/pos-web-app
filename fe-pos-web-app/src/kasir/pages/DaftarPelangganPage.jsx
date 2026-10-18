import { useEffect, useState } from "react";
import { usePelanggan } from "../../shared/hooks/usePelanggan.js";
import { usePelangganStore } from "../../stores/usePelangganStore.js";
import { PelangganForm } from "../components/PelangganForm.jsx";
import RiwayatPoinModal from "../../shared/components/RiwayatPoinModal.jsx";
import Swal from "sweetalert2";
import { ChevronLeft, ChevronRight, Search, X } from "lucide-react";
import { useUIStore } from "../../stores/useUIStore.js";

export const DaftarPelangganPage = () => {
  const [searchTerm, setSearchTerm] = useState("");
  const { pelanggan, setPelanggan } = usePelangganStore();
  const [currentPage, setCurrentPage] = useState(1);
  const [limit] = useState(10);
  const [isSearching, setIsSearching] = useState(false);
  const { fetchPelanggan, search, loading, create, update, meta } =
    usePelanggan({
      searchQuery: searchTerm,
      setPelanggan,
      mode: "kasir",
    });
  const [form, setForm] = useState({ nama_pelanggan: "", no_hp: "" });
  const [activeModal, setActiveModal] = useState(null);
  const [editingId, setEditingId] = useState(null);
  const [riwayatTarget, setRiwayatTarget] = useState(null);
  const { setActiveTab } = useUIStore();

  useEffect(() => {
    setActiveTab("Daftar Pelanggan");
    if (!searchTerm.trim()) {
      setIsSearching(false);
      fetchPelanggan(currentPage, limit);
    } else {
      setIsSearching(true);
      search(currentPage, limit);
    }
  }, [currentPage]);

  useEffect(() => {
    if (searchTerm.trim() === "") fetchPelanggan();
  }, [searchTerm]);

  const handleSearch = (e) => {
    e.preventDefault();
    setCurrentPage(1);
    if (searchTerm.trim()) {
      setIsSearching(true);
      search(1, limit);
    } else {
      setIsSearching(false);
      fetchPelanggan(1, limit);
    }
  };

  const handleClearSearch = () => {
    setSearchTerm("");
    setIsSearching(false);
    setCurrentPage(1);
    fetchPelanggan(1, limit);
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

  const openCreate = () => {
    setForm({ nama_pelanggan: "", no_hp: "" });
    setEditingId(null);
    setActiveModal("create");
  };

  const openEdit = (p) => {
    setForm({ nama_pelanggan: p.nama_pelanggan || "", no_hp: p.no_hp || "" });
    setEditingId(p.id_pelanggan);
    setActiveModal("edit");
  };

  const closeModal = () => {
    setActiveModal(null);
    setEditingId(null);
    setForm({ nama_pelanggan: "", no_hp: "" });
  };

  const submitCreate = async (e) => {
    e.preventDefault();
    if (!form.nama_pelanggan.trim())
      return Swal.fire("Validasi", "Nama pelanggan wajib diisi", "warning");
    const ok = await create({
      nama_pelanggan: form.nama_pelanggan.trim(),
      no_hp: form.no_hp?.trim() || null,
    });
    if (ok) closeModal();
  };

  const submitEdit = async (e) => {
    e.preventDefault();
    if (!form.nama_pelanggan.trim())
      return Swal.fire("Validasi", "Nama pelanggan wajib diisi", "warning");
    const ok = await update(editingId, {
      nama_pelanggan: form.nama_pelanggan.trim(),
      no_hp: form.no_hp?.trim() || null,
    });
    if (ok) closeModal();
  };

  return (
    <div className="container mx-auto p-3 sm:p-4">
      <div className="flex justify-between items-center mb-4 sm:mb-6">
        <h1 className="text-xl sm:text-2xl font-bold">
          Daftar Pelanggan Member
        </h1>
        <div className="text-sm text-gray-500">
          {isSearching
            ? `Hasil Data : ${meta.total_data || 0}`
            : `Total Data: ${meta.total_data || 0}`}
        </div>
      </div>

      <form
        onSubmit={handleSearch}
        className="mb-4 sm:mb-6 flex flex-col sm:flex-row gap-2"
      >
        <div className="relative flex-1 max-w-md">
          <input
            type="text"
            placeholder="Cari pelanggan (nama atau no HP)..."
            className="w-full px-4 py-2 pl-10 border rounded-lg focus:outline-none focus:ring-2 focus:ring-green-400"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
          <Search className="absolute left-3 top-2.5 text-gray-400" size={18} />
          {searchTerm && (
            <button
              type="button"
              onClick={handleClearSearch}
              className="absolute right-3 top-2.5 text-gray-500 hover:text-gray-800 cursor-pointer"
            >
              <X size={18} />
            </button>
          )}
        </div>
        <button
          type="submit"
          className="bg-green-700 text-white px-4 py-2 rounded hover:bg-green-800 cursor-pointer text-sm"
        >
          Cari
        </button>
        <button
          type="button"
          onClick={openCreate}
          className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700 cursor-pointer text-sm"
        >
          Tambah Pelanggan
        </button>
      </form>

      {loading ? (
        <div className="text-center py-10">
          <div className="animate-spin rounded-full h-10 sm:h-12 w-10 sm:w-12 border-b-2 border-green-600 mx-auto" />
          <p className="mt-2 text-sm">Memuat data pelanggan...</p>
        </div>
      ) : (
        /*
          Grid responsif:
          - 1 kolom di mobile (full width, mudah dibaca)
          - 2 kolom di tablet/desktop
        */
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 sm:gap-4">
          {pelanggan.map((c) => (
            <div
              key={c.id_pelanggan}
              className="bg-white rounded-lg shadow-md p-4 sm:p-6"
            >
              <div className="flex items-center mb-4">
                <div className="bg-green-800 rounded-full p-3 sm:p-4 mr-3 sm:mr-4 shrink-0">
                  <span className="text-green-100 text-xl sm:text-2xl font-bold">
                    {c.nama_pelanggan?.charAt(0).toUpperCase() || "?"}
                  </span>
                </div>
                <div className="min-w-0">
                  <h2 className="text-base sm:text-xl font-bold truncate">
                    {c.nama_pelanggan}
                  </h2>
                  <p className="text-gray-600 text-sm">{c.no_hp || "-"}</p>
                  <p className="text-xs sm:text-sm mt-1 text-green-700 font-semibold">
                    Status: Member
                  </p>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-2 sm:gap-4 mb-3 sm:mb-2">
                <div className="bg-green-800 text-white p-3 sm:p-4 rounded-lg">
                  <h3 className="font-bold mb-1 text-xs sm:text-sm">
                    Jumlah Transaksi
                  </h3>
                  <p className="text-xl sm:text-2xl font-bold">
                    {c.frekuensi_transaksi || 0}
                  </p>
                  <p className="text-xs sm:text-sm">pembelian</p>
                </div>
                <div className="bg-yellow-700 text-white p-3 sm:p-4 rounded-lg">
                  <h3 className="font-bold mb-1 text-xs sm:text-sm">
                    Poin Loyalitas
                  </h3>
                  <p className="text-xl sm:text-2xl font-bold">
                    {c.poin_loyalitas || 0}
                  </p>
                  <p className="text-xs sm:text-sm">poin</p>
                </div>
              </div>

              <div className="flex gap-2">
                <button
                  className="w-full bg-green-600 text-white py-2 px-4 rounded hover:bg-green-700 cursor-pointer text-sm"
                  onClick={() => openEdit(c)}
                >
                  Edit Profile
                </button>
                <button
                  className="w-full bg-yellow-700 text-white py-2 px-4 rounded hover:bg-yellow-800 cursor-pointer text-sm"
                  onClick={() => setRiwayatTarget(c)}
                >
                  Riwayat Poin
                </button>
              </div>
            </div>
          ))}

          {meta.total_page > 0 && (
            <div className="flex flex-col sm:flex-row justify-between items-center gap-4 mt-6 col-span-full">
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

          {/* Modal tambah/edit */}
          {activeModal === "create" && (
            <PelangganForm
              title="Tambah Pelanggan Member"
              submitLabel="Tambah"
              form={form}
              setForm={setForm}
              onSubmit={submitCreate}
              onCancel={closeModal}
            />
          )}
          {activeModal === "edit" && (
            <PelangganForm
              title="Edit Pelanggan"
              submitLabel="Simpan"
              form={form}
              setForm={setForm}
              onSubmit={submitEdit}
              onCancel={closeModal}
            />
          )}

          {riwayatTarget && (
            <RiwayatPoinModal
              pelanggan={riwayatTarget}
              mode="kasir"
              onClose={() => setRiwayatTarget(null)}
            />
          )}

          {pelanggan.length === 0 && (
            <p className="text-gray-500 text-sm col-span-full">
              Pelanggan tidak ditemukan.
            </p>
          )}
        </div>
      )}
    </div>
  );
};