import { useState } from "react";
import Swal from "sweetalert2";
import {
  getBarangMasukAdmin,
  getBarangMasukKasir,
  getBarangMasukOwner,
  getBarangMasukByIdAdmin,
  getBarangMasukByIdKasir,
  getBarangMasukByIdOwner,
  createBarangMasukNew,
  createBarangMasukExisting,
  deleteBarangMasuk,
} from "../services/barangMasukService.js";
import { buildOwnerNotificationFeedback } from "../utils/ownerNotificationHelper.js";

export function useBarangMasuk({ setBarangMasuk = () => {}, mode }) {
  if (!mode) throw new Error("Mode is required in useBarangMasuk hook");

  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [meta, setMeta] = useState({});
  const [selectedBarangMasuk, setSelectedBarangMasuk] = useState(null);

  const fetchBarangMasuk = async (params = {}) => {
    setLoading(true);
    setError(null);
    try {
      let res;
      if (mode === "admin") {
        res = await getBarangMasukAdmin(params);
      } else if (mode === "kasir") {
        res = await getBarangMasukKasir(params);
      } else if (mode === "owner") {
        res = await getBarangMasukOwner(params);
      }
      const data = res.data?.data || res.data?.rows || [];
      const metaData = res.data?.meta || {};
      
      setBarangMasuk(data);
      setMeta(metaData);
      return { data, meta: metaData };
    } catch (err) {
      setError(err.message);
      Swal.fire("Error", err.message || "Gagal memuat data barang masuk", "error");
      return { data: [], meta: {} };
    } finally {
      setLoading(false);
    }
  };

  const fetchBarangMasukById = async (id) => {
    setLoading(true);
    try {
      let res;
      if (mode === "admin") {
        res = await getBarangMasukByIdAdmin(id);
      } else if (mode === "kasir") {
        res = await getBarangMasukByIdKasir(id);
      } else if (mode === "owner") {
        res = await getBarangMasukByIdOwner(id);
      }
      const data = res.data?.data || res.data;
      setSelectedBarangMasuk(data);
      return data;
    } catch (err) {
      setError(err.message);
      Swal.fire("Error", "Gagal memuat detail barang masuk", "error");
      return null;
    } finally {
      setLoading(false);
    }
  };

  const createNew = async (data) => {
    try {
      const response = await createBarangMasukNew(data);
      const ownerNotificationFeedback = buildOwnerNotificationFeedback(response);
      const successMessage = ownerNotificationFeedback
        ? `Barang baru berhasil ditambahkan\n\n${ownerNotificationFeedback}`
        : "Barang baru berhasil ditambahkan";
      Swal.fire("Sukses", successMessage, "success");
      return true;
    } catch (err) {
      Swal.fire(
        "Error",
        err.response?.data?.message || "Gagal menambahkan barang baru",
        "error"
      );
      console.error("Create new error:", err);
      return false;
    }
  };

  const createExisting = async (data) => {
    try {
      const response = await createBarangMasukExisting(data);
      const ownerNotificationFeedback = buildOwnerNotificationFeedback(response);
      const successMessage = ownerNotificationFeedback
        ? `Stok berhasil ditambahkan\n\n${ownerNotificationFeedback}`
        : "Stok berhasil ditambahkan";
      Swal.fire("Sukses", successMessage, "success");
      return true;
    } catch (err) {
      Swal.fire(
        "Error",
        err.response?.data?.message || "Gagal menambahkan stok",
        "error"
      );
      console.error("Create existing error:", err);
      return false;
    }
  };

  const remove = async (id, callback) => {
    const result = await Swal.fire({
      title: "Apakah Anda yakin?",
      text: "Data barang masuk yang dihapus tidak dapat dikembalikan!",
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#3085d6",
      cancelButtonColor: "#d33",
      confirmButtonText: "Ya, hapus!",
      cancelButtonText: "Batal",
    });

    if (result.isConfirmed) {
      try {
        await deleteBarangMasuk(id);
        Swal.fire("Deleted!", "Data barang masuk telah dihapus.", "success");
        if (callback) callback();
        return true;
      } catch (err) {
        Swal.fire("Error", "Gagal menghapus data barang masuk", "error");
        console.error("Delete error:", err);
        return false;
      }
    }
    return false;
  };

  return {
    fetchBarangMasuk,
    fetchBarangMasukById,
    createNew,
    createExisting,
    remove,
    selectedBarangMasuk,
    meta,
    loading,
    error,
  };
}