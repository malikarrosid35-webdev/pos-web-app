import { formatQty } from "../../../shared/utils/qtyFormat.js";

export default function BarangForm({
  currentBarang,
  onSubmit,
  hargaValue,
  onHargaChange,
}) {
  return (
    <form onSubmit={onSubmit}>
      <div className="mb-4">
        <label className="block text-slate-700 text-sm font-bold mb-2">
          Nama Barang
        </label>
        <input
          type="text"
          name="nama_barang"
          defaultValue={currentBarang?.nama_barang || ""}
          required
          className="shadow border rounded w-full py-2 px-3 text-slate-700"
        />
      </div>

      {/* Harga Jual */}
      <div className="mb-6">
        <label className="block text-slate-700 text-sm font-bold mb-2">
          Harga Jual per Satuan
        </label>
        <input
          type="text"
          name="harga_jual_per_sd"
          value={hargaValue}
          onChange={onHargaChange}
          required
          className="shadow border rounded w-full py-2 px-3 text-slate-700"
          placeholder="Contoh: 12.500"
        />
      </div>

      {/* Stock and Capital Price Information */}
      {currentBarang && (
        <div className="mb-6 bg-gray-100 border border-gray-200 rounded p-4">
          <h3 className="text-sm font-bold text-slate-700 mb-3">
            Informasi Stok & Harga Beli
          </h3>
          <div className="space-y-2">
            <div className="flex justify-between">
              <span className="text-sm text-gray-600">Stok Saat Ini:</span>
              <span className="text-sm font-semibold text-gray-800">
                {formatQty(
                  currentBarang.stok_dasar,
                  currentBarang.satuan_dasar,
                )}
              </span>
            </div>
            {/* <div className="flex justify-between">
              <span className="text-sm text-gray-600">Satuan Dasar:</span>
              <span className="text-sm font-semibold text-gray-800">
                {currentBarang.satuan_dasar}
              </span>
            </div> */}
            <div className="flex justify-between">
              <span className="text-sm text-gray-600">
                Harga Beli per Satuan:
              </span>
              <span className="text-sm font-semibold text-gray-800">
                Rp{" "}
                {Number(currentBarang.harga_modal_per_sd).toLocaleString(
                  "id-ID",
                )}
              </span>
            </div>
          </div>
          <p className="text-xs text-gray-500 mt-3 italic">
            Untuk mengubah stok dan harga beli, gunakan menu Barang Masuk
          </p>
        </div>
      )}

      <div className="flex justify-end">
        <button
          type="submit"
          className="bg-blue-400 text-slate-900 px-4 py-2 rounded hover:bg-blue-500 cursor-pointer"
        >
          Simpan
        </button>
      </div>
    </form>
  );
}