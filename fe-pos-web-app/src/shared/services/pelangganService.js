import adminClient from "../../lib/http/adminClient.js";
import kasirClient from "../../lib/http/kasirClient.js";
import ownerClient from "../../lib/http/ownerClient.js";

const getPelangganAdmin = (params) =>
  adminClient.get(`/pelanggan`, { params });
const getPelangganKasir = (params) =>
  kasirClient.get(`/pelanggan`, { params });
const getPelangganOwner = (params) =>
  ownerClient.get(`/pelanggan`, { params });
const getPelangganByIdAdmin = (id) => adminClient.get(`/pelanggan/${id}`);
const getPelangganByIdKasir = (id) => kasirClient.get(`/pelanggan/${id}`);
const getPelangganByIdOwner = (id) => ownerClient.get(`/pelanggan/${id}`);
const searchPelangganAdmin = (keyword, params = {}) => {
  // Validasi keyword
  if (!keyword || keyword.trim() === "") {
    return Promise.reject(new Error("Keyword pencarian tidak boleh kosong"));
  }

  // Hanya kirim keyword jika tidak kosong
  const searchParams = {
    keyword: keyword.trim(),
    ...params,
  };

  return adminClient.get(`/pelanggan/search`, { params: searchParams });
};

const searchPelangganKasir = (keyword, params = {}) => {
  if (!keyword || keyword.trim() === "") {
    return Promise.reject(new Error("Keyword pencarian tidak boleh kosong"));
  }

  const searchParams = {
    keyword: keyword.trim(),
    ...params,
  };

  return kasirClient.get(`/pelanggan/search`, { params: searchParams });
};

const searchPelangganOwner = (keyword, params = {}) => {
  if (!keyword || keyword.trim() === "") {
    return Promise.reject(new Error("Keyword pencarian tidak boleh kosong"));
  }

  const searchParams = {
    keyword: keyword.trim(),
    ...params,
  };

  return ownerClient.get(`/pelanggan/search`, { params: searchParams });
};

const createPelanggan = (data) => kasirClient.post("/pelanggan", data);
const updatePelanggan = (id, data) => kasirClient.patch(`/pelanggan/${id}`, data);
const deletePelanggan = (id) => adminClient.delete(`/pelanggan/${id}`);

const getRiwayatPoinKasir = (id, params) =>
  kasirClient.get(`/pelanggan/${id}/riwayat-poin`, { params });
const getRiwayatPoinOwner = (id, params) =>
  ownerClient.get(`/pelanggan/${id}/riwayat-poin`, { params });
const adjustPoinOwner = (id, data) =>
  ownerClient.post(`/pelanggan/${id}/poin`, data);

export {
  getPelangganAdmin,
  getPelangganByIdAdmin,
  searchPelangganAdmin,
  getPelangganKasir,
  getPelangganByIdKasir,
  searchPelangganKasir,
  getPelangganOwner,
  getPelangganByIdOwner,
  searchPelangganOwner,
  createPelanggan,
  updatePelanggan,
  deletePelanggan,
  getRiwayatPoinKasir,
  getRiwayatPoinOwner,
  adjustPoinOwner,
};