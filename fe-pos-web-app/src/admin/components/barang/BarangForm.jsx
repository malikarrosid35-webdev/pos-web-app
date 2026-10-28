import { useEffect, useState } from "react";
import { formatQty } from "../../../shared/utils/qtyFormat.js";

const unitConversion = { GRAM: 1, ONS: 100, KG: 1000 };

export default function BarangForm({
  currentBarang,
  onSubmit,
  hargaValue,
  onHargaChange,
}) {
  const isGram = (currentBarang?.satuan_dasar || "").toUpperCase() === "GRAM";
  
  const [minimumStokDisplay, setMinimumStokDisplay] = useState("");
  const [minimumStokUnit, setMinimumStokUnit] = useState("GRAM");
  const [minimumStokInGram, setMinimumStokInGram] = useState("");
  
  useEffect(() => {
    if (currentBarang) {
      const raw = Number(currentBarang.minimum_stok ?? 0);
      if (isGram) {
        setMinimumStokUnit("GRAM");
        setMinimumStokDisplay(raw > 0 ? String(raw) : "");
        setMinimumStokInGram(raw > 0 ? String(raw) : "");
      } else {
        setMinimumStokDisplay(raw > 0 ? String(raw) : "");
        setMinimumStokInGram("");
      }
    } else {
      setMinimumStokDisplay("");
      setMinimumStokInGram("");
      setMinimumStokUnit("GRAM");
    }
  }, [currentBarang, isGram]);
  
  useEffect(() => {
    if (!isGram) return;
    if (minimumStokDisplay === "") {
      setMinimumStokInGram("");
      return;
    }
    const val = Number(minimumStokDisplay);
    if (Number.isNaN(val)) {
      setMinimumStokInGram("");
      return;
    }
    setMinimumStokInGram(String(val * unitConversion[minimumStokUnit]));
  }, [minimumStokDisplay, minimumStokUnit, isGram]);

  const handleMinimumStokChange = (e) => {
    const value = e.target.value;
    // hanya angka (boleh kosong); PCS = bulat, GRAM boleh desimal
    const isPcs = !isGram;
    if (isPcs) {
      if (value === "" || /^\d+$/.test(value)) setMinimumStokDisplay(value);
    } else {
      if (value === "" || /^\d*\.?\d*$/.test(value))
        setMinimumStokDisplay(value);
    }
  };

  const handleSubmitLocal = (e) => {
    e.preventDefault();

    // sisipkan nilai minimum_stok final (dalam satuan dasar) ke FormData
    const formData = new FormData(e.target);
    const finalMinimumStok = isGram
      ? minimumStokInGram === ""
        ? "0"
        : minimumStokInGram
      : minimumStokDisplay === ""
        ? "0"
        : minimumStokDisplay;
    formData.set("minimum_stok", finalMinimumStok);

    onSubmit(e, formData);
  };
  
  return (
    <form onSubmit={handleSubmitLocal}>
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

      <div className="mb-4">
        <label className="block text-slate-700 text-sm font-bold mb-2">
          Minimum Stok
          {isGram && (
            <span className="ml-1 text-xs font-normal text-gray-500">
              (dalam gram / ons / kg)
            </span>
          )}
        </label>
        <div className="flex gap-2">
          <input
            type="text"
            inputMode="decimal"
            value={minimumStokDisplay}
            onChange={handleMinimumStokChange}
            placeholder={isGram ? "Contoh: 5" : "Contoh: 10"}
            className="shadow border rounded w-full py-2 px-3 text-slate-700"
          />
          {isGram && (
            <select
              value={minimumStokUnit}
              onChange={(e) => setMinimumStokUnit(e.target.value)}
              className="shadow border rounded py-2 px-3 text-slate-700 cursor-pointer min-w-24"
            >
              <option value="GRAM">Gram</option>
              <option value="ONS">Ons (100 gr)</option>
              <option value="KG">Kg (1000 gr)</option>
            </select>
          )}
        </div>
        {isGram && minimumStokInGram !== "" && (
          <p className="text-sm text-gray-600 mt-2">
            = <strong>{minimumStokInGram} gram</strong>
          </p>
        )}
        <p className="text-xs text-gray-500 mt-1 italic">
          Batas minimum stok untuk peringatan. Kosongkan jika tidak ingin
          peringatan.
        </p>
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
