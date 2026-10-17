import adminClient from "../../lib/http/adminClient.js";
import kasirClient from "../../lib/http/kasirClient.js";
import ownerClient from "../../lib/http/ownerClient.js";

const getBarangMasukAdmin = (params) => adminClient.get("/barang-masuk", { params });
const getBarangMasukKasir = (params) => kasirClient.get("/barang-masuk", { params });
const getBarangMasukOwner = (params) => ownerClient.get("/barang-masuk", { params });

const getBarangMasukByIdAdmin = (id) => adminClient.get(`/barang-masuk/${id}`);
const getBarangMasukByIdKasir = (id) => kasirClient.get(`/barang-masuk/${id}`);
const getBarangMasukByIdOwner = (id) => ownerClient.get(`/barang-masuk/${id}`);

const createBarangMasukNew = (data, mode = "admin") =>
  (mode === "owner" ? ownerClient : adminClient).post("/barang-masuk/new", data);

const createBarangMasukExisting = (data, mode = "admin") =>
  (mode === "owner" ? ownerClient : adminClient).post(
    "/barang-masuk/existing",
    data,
  );

const deleteBarangMasuk = (id) => adminClient.delete(`/barang-masuk/${id}`);

export {
  getBarangMasukAdmin,
  getBarangMasukKasir,
  getBarangMasukOwner,
  getBarangMasukByIdAdmin,
  getBarangMasukByIdKasir,
  getBarangMasukByIdOwner,
  createBarangMasukNew,
  createBarangMasukExisting,
  deleteBarangMasuk,
};