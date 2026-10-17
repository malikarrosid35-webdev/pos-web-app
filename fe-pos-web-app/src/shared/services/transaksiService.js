import kasirClient from "../../lib/http/kasirClient.js";
import ownerClient from "../../lib/http/ownerClient.js";

// Owner's auth cookie is path-scoped to /api/owner, so an owner sale must go
// through ownerClient; kasirClient would reach the server without a cookie.
export const createTransaksi = (data, mode = "kasir") =>
  (mode === "owner" ? ownerClient : kasirClient).post("/transaksi", data);

export const getHistoriTransaksiKasir = (params) =>
  kasirClient.get("/transaksi", { params });

export const getHistoriTransaksiOwner = (params) =>
  ownerClient.get("/transaksi", { params });

export const searchTransaksiKasir = (keyword, params = {}) =>
  kasirClient.get("/transaksi/search", {
    params: { keyword, ...params },
  });

export const searchTransaksiOwner = (keyword, params = {}) =>
  ownerClient.get("/transaksi/search", {
    params: { keyword, ...params },
  });

export const getDetailTransaksiKasir = (id) =>
  kasirClient.get(`/transaksi/${id}`);

export const getDetailTransaksiOwner = (id) =>
  ownerClient.get(`/transaksi/${id}`);

export const downloadInvoiceKasir = (idTransaksi) =>
  kasirClient.get(`/transaksi/${idTransaksi}/invoice/download`, {
    responseType: "blob",
  });
  
export const downloadInvoiceOwner = (idTransaksi) =>
  ownerClient.get(`/transaksi/${idTransaksi}/invoice/download`, {
    responseType: "blob",
  });