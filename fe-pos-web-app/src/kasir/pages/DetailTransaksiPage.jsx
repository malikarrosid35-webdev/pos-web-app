import { useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { useTransaksi } from "../../shared/hooks/useTransaksi.js";
import { formatToRupiah } from "../../shared/utils/numberFormat.js";
import { formatQty } from "../../shared/utils/qtyFormat.js";

export const DetailTransaksiPage = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const { detailTransaksi, fetchDetailTransaksi, loading } = useTransaksi({
    mode: "kasir",
  });

  useEffect(() => {
    fetchDetailTransaksi(id);
  }, [id]);

  if (loading || !detailTransaksi)
    return (
      <div className="flex-1 p-3 sm:p-6 bg-gray-50 min-h-screen flex items-center justify-center">
        <div className="animate-spin rounded-full h-10 w-10 border-b-2 border-green-600" />
      </div>
    );

  const {
    kode_transaksi,
    tipe_pelanggan,
    nama_pelanggan,
    total_harga,
    jumlah_bayar,
    kembalian,
    status_transaksi,
    kasir,
    created_at,
    detail_barang,
  } = detailTransaksi;

  return (
    <div className="flex-1 p-3 sm:p-6 bg-gray-50 min-h-screen">
      <div className="max-w-5xl mx-auto">
        <button
          className="mb-4 px-3 sm:px-4 py-2 bg-gray-300 text-gray-800 rounded hover:bg-gray-400 cursor-pointer text-sm flex items-center gap-1"
          onClick={() => navigate("/kasir/histori-transaksi/")}
        >
          ← Kembali
        </button>

        <div className="bg-white rounded-lg shadow p-4 sm:p-6">
          <h2 className="text-2xl sm:text-3xl font-bold mb-2">
            Detail Transaksi
          </h2>
          <p className="mb-4 sm:mb-6 text-gray-600 text-sm">
            Kode Transaksi: {kode_transaksi}
          </p>

          {/* Info transaksi — 1 kolom mobile, 2 kolom tablet+ */}
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 sm:gap-4 mb-6">
            <div className="space-y-2 text-sm">
              <p>
                <strong>Tanggal:</strong>{" "}
                {new Date(created_at)
                  .toLocaleString("id-ID", {
                    day: "2-digit",
                    month: "2-digit",
                    year: "numeric",
                    hour: "2-digit",
                    minute: "2-digit",
                    second: "2-digit",
                    hour12: false,
                  })
                  .replace(/\./g, ":")}
              </p>
              <p>
                <strong>Kasir:</strong> {kasir}
              </p>
              <p>
                <strong>Status Transaksi:</strong> {status_transaksi}
              </p>
            </div>
            <div className="space-y-2 text-sm">
              <p>
                <strong>Pelanggan:</strong> {nama_pelanggan}
              </p>
              <p>
                <strong>Tipe Pelanggan:</strong> {tipe_pelanggan}
              </p>
            </div>
          </div>

          <h3 className="text-lg sm:text-xl font-semibold mb-3">
            Barang Dibeli
          </h3>

          {/* Tabel — scroll horizontal di mobile */}
          <div className="overflow-x-auto mb-6">
            <table className="w-full text-sm border min-w-[400px]">
              <thead className="bg-green-700 text-white">
                <tr>
                  <th className="p-2 sm:p-3 text-left">Nama Barang</th>
                  <th className="p-2 sm:p-3 text-right">Harga per Gram/Pcs</th>
                  <th className="p-2 sm:p-3 text-center">Qty</th>
                  <th className="p-2 sm:p-3 text-right">Subtotal</th>
                </tr>
              </thead>
              <tbody>
                {detail_barang.map((item, i) => (
                  <tr key={i} className="border-t hover:bg-gray-50">
                    <td className="p-2 sm:p-3">{item.nama_barang}</td>
                    <td className="p-2 sm:p-3 text-right">
                      {formatToRupiah(parseFloat(item.harga_jual_per_sd))}
                    </td>
                    <td className="p-2 sm:p-3 text-center">
                      {formatQty(item.quantity, item.satuan_dasar)}
                    </td>
                    <td className="p-2 sm:p-3 text-right">
                      {formatToRupiah(parseFloat(item.subtotal))}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          {/* Ringkasan bayar */}
          <div className="border-t pt-4">
            <div className="flex flex-col sm:flex-row sm:justify-end">
              <div className="sm:w-64">
                <div className="flex justify-between mb-2 text-sm">
                  <span className="font-semibold">Total:</span>
                  <span className="font-bold text-base">
                    {formatToRupiah(parseFloat(total_harga))}
                  </span>
                </div>
                <div className="flex justify-between mb-2 text-sm">
                  <span>Bayar:</span>
                  <span>{formatToRupiah(parseFloat(jumlah_bayar))}</span>
                </div>
                <div className="flex justify-between text-sm">
                  <span>Kembalian:</span>
                  <span>{formatToRupiah(parseFloat(kembalian))}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};