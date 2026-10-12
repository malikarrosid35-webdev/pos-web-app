import { useState } from "react";
import Swal from "sweetalert2";
import {
  createTransaksi,
  getHistoriTransaksiKasir,
  getHistoriTransaksiOwner,
  searchTransaksiKasir,
  searchTransaksiOwner,
  getDetailTransaksiKasir,
  getDetailTransaksiOwner,
  downloadInvoiceKasir,
  downloadInvoiceOwner,
} from "../services/transaksiService.js";
import { buildOwnerNotificationFeedback } from "../utils/ownerNotificationHelper.js";

export function useTransaksi({ mode }) {
  const [historiTransaksi, setHistoriTransaksi] = useState([]);
  const [detailTransaksi, setDetailTransaksi] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [meta, setMeta] = useState({
    page: 1,
    limit: 10,
    total_data: 0,
    total_page: 0,
  });

  const fetchHistoriTransaksi = async (page = 1, limit = 10) => {
    setLoading(true);
    setError(null);
    try {
      let res;

      if (mode === "kasir") {
        res = await getHistoriTransaksiKasir({ page, limit });
      } else if (mode === "owner") {
        res = await getHistoriTransaksiOwner({ page, limit });
      } else {
        throw new Error(`Mode tidak dikenal: ${mode}`);
      }

      const data = (res.data.data || []).map((transaksi) => ({
        ...transaksi,
        total_harga: parseFloat(transaksi.total_harga) || 0,
        jumlah_bayar: parseFloat(transaksi.jumlah_bayar) || 0,
        kembalian: parseFloat(transaksi.kembalian) || 0,
      }));

      setHistoriTransaksi(data);

      if (res.data.meta) {
        setMeta(res.data.meta);
      }

      return { data, meta: res.data.meta };
    } catch (err) {
      console.error(err);
      setError(err.message);
      Swal.fire("Error", "Gagal memuat histori transaksi", "error");
      return {
        data: [],
        meta: { page: 1, limit: 10, total_data: 0, total_page: 0 },
      };
    } finally {
      setLoading(false);
    }
  };

  const searchHistoriTransaksi = async (keyword, page = 1, limit = 10) => {
    const trimmedKeyword = (keyword || "").trim();

    if (!trimmedKeyword) {
      return fetchHistoriTransaksi(page, limit);
    }

    setLoading(true);
    setError(null);
    try {
      let res;

      if (mode === "kasir") {
        res = await searchTransaksiKasir(trimmedKeyword, { page, limit });
      } else if (mode === "owner") {
        res = await searchTransaksiOwner(trimmedKeyword, { page, limit });
      } else {
        throw new Error(`Mode tidak dikenal: ${mode}`);
      }

      const data = (res.data.data || []).map((transaksi) => ({
        ...transaksi,
        total_harga: parseFloat(transaksi.total_harga) || 0,
        jumlah_bayar: parseFloat(transaksi.jumlah_bayar) || 0,
        kembalian: parseFloat(transaksi.kembalian) || 0,
      }));

      setHistoriTransaksi(data);

      if (res.data.meta) {
        setMeta(res.data.meta);
      }

      return { data, meta: res.data.meta };
    } catch (err) {
      console.error(err);
      setError(err.message);
      Swal.fire("Error", "Gagal mencari transaksi", "error");
      return {
        data: [],
        meta: { page: 1, limit: 10, total_data: 0, total_page: 0 },
      };
    } finally {
      setLoading(false);
    }
  };

  const fetchDetailTransaksi = async (id) => {
    setLoading(true);
    setError(null);
    try {
      let res;
      if (mode === "kasir") {
        res = await getDetailTransaksiKasir(id);
      } else if (mode === "owner") {
        res = await getDetailTransaksiOwner(id);
      }
      setDetailTransaksi(res.data.data);
    } catch (err) {
      console.error(err);
      Swal.fire("Error", "Gagal memuat detail transaksi", "error");
    } finally {
      setLoading(false);
    }
  };

  const addTransaksi = async (data, onSuccess) => {
    try {
      const response = await createTransaksi(data);
      const ownerNotificationFeedback = buildOwnerNotificationFeedback(response);
      const successMessage = ownerNotificationFeedback
        ? `Transaksi telah dibuat\n\n${ownerNotificationFeedback}`
        : "Transaksi telah dibuat";
      Swal.fire("Berhasil", successMessage, "success");
      if (onSuccess) onSuccess();
    } catch (err) {
      console.error(err);
      Swal.fire("Gagal", "Transaksi gagal dibuat", "error");
    }
  };

  const handleDownloadInvoice = async (idTransaksi) => {
    try {
      let res;
      if (mode === "kasir") {
        res = await downloadInvoiceKasir(idTransaksi);
      } else if (mode === "owner") {
        res = await downloadInvoiceOwner(idTransaksi);
      } else {
        throw new Error(`Mode tidak dikenal: ${mode}`);
      }

      const blob = new Blob([res.data], { type: "application/pdf" });
      const blobUrl = window.URL.createObjectURL(blob);

      const downloadLink = document.createElement("a");
      downloadLink.href = blobUrl;
      downloadLink.download = `invoice-trx-${idTransaksi.slice(-6)}.pdf`;
      document.body.appendChild(downloadLink);
      downloadLink.click();
      downloadLink.remove();
      window.URL.revokeObjectURL(blobUrl);
    } catch (err) {
      console.error(err);
      Swal.fire("Error", "Gagal mengunduh invoice", "error");
    }
  };

  return {
    historiTransaksi,
    detailTransaksi,
    loading,
    error,
    meta,
    fetchHistoriTransaksi,
    searchHistoriTransaksi,
    fetchDetailTransaksi,
    addTransaksi,
    downloadInvoice: handleDownloadInvoice,
  };
}