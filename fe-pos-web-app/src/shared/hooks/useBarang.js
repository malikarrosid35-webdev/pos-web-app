import { useState } from "react";
import Swal from "sweetalert2";
import {
  getBarangAdmin,
  getBarangKasir,
  getBarangOwner,
  searchBarangAdmin,
  searchBarangKasir,
  searchBarangOwner,
  createBarang,
  updateBarang,
  deleteBarang,
} from "../services/barangService.js";
import { buildOwnerNotificationFeedback } from "../utils/ownerNotificationHelper.js";

// `catalog` builds the grouped product list the sale form needs (groupedProducts,
// categories). It is always on for kasir; owner passes it when it uses the sale form.
export function useBarang({
  searchQuery = "",
  setBarang = () => {},
  mode,
  catalog = false,
}) {
  if (!mode) throw new Error("Mode is required in useBarang hook");

  const asCatalog = catalog || mode === "kasir";

  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [meta, setMeta] = useState({});
  const [groupedProducts, setGroupedProducts] = useState({});
  const [categories, setCategories] = useState([]);

  const prepareKasirData = (data) => {
    const grouped = {};
    const categorySet = new Set();

    data.forEach((item) => {
      const category = item.kategori_barang || "Lainnya";
      categorySet.add(category);
      if (!grouped[category]) {
        grouped[category] = [];
      }

      const harga =
        typeof item.harga_jual_per_sd === "string"
          ? parseFloat(item.harga_jual_per_sd)
          : item.harga_jual_per_sd;

      grouped[category].push({
        id: item.id_barang,
        name: item.nama_barang,
        satuan: item.satuan_dasar,
        satuan_dasar: item.satuan_dasar,
        price: harga || 0,
        stock: item.stok_dasar || 0,
        category,
      });
    });

    setGroupedProducts(grouped);
    setCategories(Array.from(categorySet));
  };

  // params: { page, limit, keyword } — opsional
  const fetchBarang = async (params = {}) => {
    setLoading(true);
    setError(null);
    try {
      let res;
      if (mode === "admin") {
        res = await getBarangAdmin(params);
      } else if (mode === "kasir") {
        res = await getBarangKasir(params);
      } else if (mode === "owner") {
        res = await getBarangOwner(params);
      }

      const data = res.data?.data || res.data?.rows || [];
      const metaData = res.data?.meta || {};

      if (asCatalog) {
        prepareKasirData(data);
      } else {
        setBarang(data);
        setMeta(metaData);
      }
    } catch (err) {
      setError(err.message);
      Swal.fire("Error", err.message, "error");
    } finally {
      setLoading(false);
    }
  };

  const search = async () => {
    try {
      let res;
      if (mode === "admin") {
        res = await searchBarangAdmin(searchQuery);
      } else if (mode === "kasir") {
        res = await searchBarangKasir(searchQuery);
      } else if (mode === "owner") {
        res = await searchBarangOwner(searchQuery);
      }

      const data = res.data?.data || res.data?.rows || [];

      if (asCatalog) {
        prepareKasirData(data);
      } else {
        setBarang(data);
        setMeta({});
      }
    } catch (err) {
      Swal.fire("Error", "Gagal melakukan pencarian", "error");
      console.error("Search error:", err);
    }
  };

  const create = async (formData) => {
    const response = await createBarang(formData);
    const ownerNotificationFeedback = buildOwnerNotificationFeedback(response);
    const successMessage = ownerNotificationFeedback
      ? `Barang berhasil ditambahkan\n\n${ownerNotificationFeedback}`
      : "Barang berhasil ditambahkan";
    Swal.fire("Sukses", successMessage, "success");
  };

  const update = async (id, formData, isImage = false) => {
    const response = await updateBarang(id, formData, isImage, mode);
    const ownerNotificationFeedback = buildOwnerNotificationFeedback(response);
    const successMessage = ownerNotificationFeedback
      ? `Barang berhasil diperbarui\n\n${ownerNotificationFeedback}`
      : "Barang berhasil diperbarui";
    Swal.fire("Sukses", successMessage, "success");
  };

  const remove = async (id, callback) => {
    const result = await Swal.fire({
      title: "Apakah Anda yakin?",
      text: "Data yang dihapus tidak dapat dikembalikan!",
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#3085d6",
      cancelButtonColor: "#d33",
      confirmButtonText: "Ya, hapus!",
    });

    if (result.isConfirmed) {
      await deleteBarang(id);
      Swal.fire("Deleted!", "Barang telah dihapus.", "success");
      if (callback) callback();
    }
  };

  return {
    fetchBarang,
    groupedProducts,
    categories,
    search,
    create,
    update,
    remove,
    meta,
    loading,
    error,
  };
}