import { useState } from "react";
import Swal from "sweetalert2";
import {
  getPelangganAdmin,
  getPelangganKasir,
  getPelangganOwner,
  getPelangganByIdAdmin,
  getPelangganByIdKasir,
  getPelangganByIdOwner,
  searchPelangganAdmin,
  searchPelangganKasir,
  searchPelangganOwner,
  createPelanggan,
  updatePelanggan,
  deletePelanggan,
} from "../services/pelangganService.js";
import { buildOwnerNotificationFeedback } from "../utils/ownerNotificationHelper.js";

export function usePelanggan({
  searchQuery = "",
  setPelanggan = () => {},
  mode,
}) {
  if (!mode) throw new Error("Mode is required in usePelanggan hook");

  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [selectedPelanggan, setSelectedPelanggan] = useState(null);
  const [meta, setMeta] = useState({
    page: 1,
    limit: 10,
    total_data: 0,
    total_page: 0,
  });

  const fetchPelanggan = async (page = 1, limit = 10) => {
    setLoading(true);
    setError(null);
    try {
      let res;
      if (mode === "admin") {
        res = await getPelangganAdmin({ page, limit });
      } else if (mode === "kasir") {
        res = await getPelangganKasir({ page, limit });
      } else if (mode === "owner") {
        res = await getPelangganOwner({ page, limit });
      }

      const data = res.data?.data || res.data?.rows || [];
      setPelanggan(data);

      if(res.data?.meta) {
        setMeta(res.data.meta);
      }
      
      return { data, meta: res.data?.meta };
    } catch (err) {
      setError(err.message);
      Swal.fire("Error", err.message || "Gagal memuat data pelanggan", "error");
      return {
        data: [],
        meta: { page: 1, limit: 10, total_data: 0, total_page: 0 },
      };
    } finally {
      setLoading(false);
    }
  };

  const search = async (page = 1, limit = 10) => {
    if (!searchQuery || searchQuery.trim() === "") {
      return fetchPelanggan(page, limit);
    }

    setLoading(true);
    setError(null);
    try {
      let res;
      const trimmedQuery = searchQuery.trim();

      if (mode === "admin") {
        res = await searchPelangganAdmin(trimmedQuery, { page, limit });
      } else if (mode === "kasir") {
        res = await searchPelangganKasir(trimmedQuery, { page, limit });
      } else if (mode === "owner") {
        res = await searchPelangganOwner(trimmedQuery, { page, limit });
      } else {
        throw new Error(`Mode tidak dikenal: ${mode}`);
      }

      const data = res.data?.data || res.data?.rows || [];
      setPelanggan(data);

      if (res.data?.meta) {
        setMeta(res.data.meta);
      }

      return { data, meta: res.data?.meta };
    } catch (err) {
      setError(err.message);
      console.error("Search error:", err);
      let errorMessage = "Gagal melakukan pencarian pelanggan";
      if (err.response?.status === 400) {
        errorMessage =
          err.response?.data?.message || "Parameter pencarian tidak valid";
      } else if (err.response?.status === 404) {
        errorMessage = "Endpoint pencarian tidak ditemukan";
      }
      Swal.fire("Error", errorMessage, "error");
      return {
        data: [],
        meta: { page: 1, limit: 10, total_data: 0, total_page: 0 },
      };
    } finally {
      setLoading(false);
    }
  };

  const create = async (data) => {
    try {
      const response = await createPelanggan(data, mode);
      await fetchPelanggan();
      const ownerNotificationFeedback = buildOwnerNotificationFeedback(response);
      const successMessage = ownerNotificationFeedback
        ? `Pelanggan berhasil ditambahkan\n\n${ownerNotificationFeedback}`
        : "Pelanggan berhasil ditambahkan";
      Swal.fire("Sukses", successMessage, "success");
      return true;
    } catch (err) {
      const errorMessage =
        err.response?.data?.message ||
        err.message ||
        "Gagal menambahkan pelanggan";
      Swal.fire("Error", errorMessage, "error");
      console.error("Create error:", err);
      return false;
    }
  };

  const update = async (id, data) => {
    try {
      const response = await updatePelanggan(id, data, mode);
      await fetchPelanggan();
      const ownerNotificationFeedback = buildOwnerNotificationFeedback(response);
      const successMessage = ownerNotificationFeedback
        ? `Pelanggan berhasil diperbarui\n\n${ownerNotificationFeedback}`
        : "Pelanggan berhasil diperbarui";
      Swal.fire("Sukses", successMessage, "success");
      return true;
    } catch (err) {
      const errorMessage =
        err.response?.data?.message ||
        err.message ||
        "Gagal memperbarui pelanggan";
      Swal.fire("Error", errorMessage, "error");
      console.error("Update error:", err);
      return false;
    }
  };

  const remove = async (id, callback) => {
    const result = await Swal.fire({
      title: "Apakah Anda yakin?",
      text: "Data pelanggan yang dihapus tidak dapat dikembalikan!",
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#3085d6",
      cancelButtonColor: "#d33",
      confirmButtonText: "Ya, hapus!",
    });

    if (result.isConfirmed) {
      try {
        await deletePelanggan(id);
        await fetchPelanggan();
        Swal.fire("Deleted!", "Pelanggan telah dihapus.", "success");
        if (callback) callback();
      } catch (err) {
        const errorMessage =
          err.response?.data?.message ||
          err.message ||
          "Gagal menghapus pelanggan";
        Swal.fire("Error", errorMessage, "error");
        console.error("Delete error:", err);
      }
    }
  };

  const fetchPelangganById = async (id) => {
    setLoading(true);
    try {
      let res;
      if (mode === "admin") {
        res = await getPelangganByIdAdmin(id);
      } else if (mode === "kasir") {
        res = await getPelangganByIdKasir(id);
      } else if (mode === "owner") {
        res = await getPelangganByIdOwner(id);
      }
      setSelectedPelanggan(res.data.data);
      return res.data.data;
    } catch (err) {
      const errorMessage =
        err.response?.data?.message ||
        err.message ||
        "Gagal memuat detail pelanggan";
      setError(errorMessage);
      Swal.fire("Error", errorMessage, "error");
      return null;
    } finally {
      setLoading(false);
    }
  };

  return {
    fetchPelanggan,
    search,
    create,
    update,
    remove,
    fetchPelangganById,
    selectedPelanggan,
    loading,
    error,
    meta
  };
}