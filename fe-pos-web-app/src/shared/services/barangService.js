import adminClient from "../../lib/http/adminClient.js";
import kasirClient from "../../lib/http/kasirClient.js";
import ownerClient from "../../lib/http/ownerClient.js";

// params: { page, limit, keyword } — diteruskan sebagai query string
const getBarangAdmin = (params) => adminClient.get("/barang", { params });
const getBarangKasir = (params) => kasirClient.get("/barang", { params });
// const getBarangKasir = () => kasirClient.get("/barang", { params: { limit: 9999 } });
const getBarangOwner = (params) => ownerClient.get("/barang", { params });

const searchBarangAdmin = (query) =>
  adminClient.get(`/barang/search?nama_barang=${encodeURIComponent(query)}`);
const searchBarangKasir = (query) =>
  kasirClient.get(`/barang/search?nama_barang=${encodeURIComponent(query)}`);
const searchBarangOwner = (query) =>
  ownerClient.get(`/barang/search?nama_barang=${encodeURIComponent(query)}`);

const createBarang = (formData) =>
  adminClient.post("/barang", formData, {
    headers: { "Content-Type": "multipart/form-data" },
  });

const updateBarang = (id, formData, isImage, mode = "admin") =>
  (mode === "owner" ? ownerClient : adminClient).patch(`/barang/${id}`, formData, {
    headers: isImage ? { "Content-Type": "multipart/form-data" } : {},
  });

const deleteBarang = (id) => adminClient.delete(`/barang/${id}`);

export {
  getBarangAdmin,
  getBarangKasir,
  getBarangOwner,
  searchBarangAdmin,
  searchBarangKasir,
  searchBarangOwner,
  createBarang,
  updateBarang,
  deleteBarang,
};