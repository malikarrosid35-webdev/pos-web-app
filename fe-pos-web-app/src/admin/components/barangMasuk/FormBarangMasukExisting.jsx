import { useEffect, useState } from "react";
import { useBarangMasukStore } from "../../../stores/useBarangMasukStore.js";
import { useBarangMasuk } from "../../../shared/hooks/useBarangMasuk.js";
import { formatQty } from "../../../shared/utils/qtyFormat.js";
import {
  formatNumber,
  parseNumber,
  formatToRupiah,
} from "../../../shared/utils/numberFormat.js";

export default function FormBarangMasukExisting({
  barangList,
  loading,
  onSuccess,
  mode = "admin",
}) {
  const { setBarangMasuk } = useBarangMasukStore();
  const { createExisting } = useBarangMasuk({
    setBarangMasuk,
    mode,
  });

  const [idBarang, setIdBarang] = useState("");
  const [qty, setQty] = useState("");
  const [total, setTotal] = useState("");
  const [displayTotal, setDisplayTotal] = useState("");
  const [hargaPerSd, setHargaPerSd] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [inputUnit, setInputUnit] = useState("GRAM");
  const [displayQty, setDisplayQty] = useState("");

  const unitConversion = {
    GRAM: 1,
    ONS: 100,
    KG: 1000,
  };

  useEffect(() => {
    const q = Number(qty);
    const t = Number(total);
    if (q > 0 && t > 0) setHargaPerSd((t / q).toFixed(2));
    else setHargaPerSd("");
  }, [qty, total]);

  const selectedBarang = barangList.find((b) => b.id_barang === idBarang);

  useEffect(() => {
    if (selectedBarang?.satuan_dasar === "GRAM") {
      setInputUnit("GRAM");
    } else {
      setDisplayQty("");
      setQty("");
    }
  }, [idBarang, selectedBarang]);

  const handleQtyChange = (value) => {
    // For PCS (non-GRAM), strip any decimal part
    const isPcs = selectedBarang?.satuan_dasar !== "GRAM";
    const safeValue =
      isPcs && value !== "" && value.includes(".")
        ? String(Math.floor(Number(value)))
        : value;
    setDisplayQty(safeValue);
    if (selectedBarang?.satuan_dasar === "GRAM" && safeValue) {
      const convertedValue = Number(safeValue) * unitConversion[inputUnit];
      setQty(convertedValue.toString());
    } else {
      setQty(safeValue);
    }
  };

  const handleUnitChange = (unit) => {
    setInputUnit(unit);
    if (displayQty) {
      const convertedValue = Number(displayQty) * unitConversion[unit];
      setQty(convertedValue.toString());
    }
  };

  const handleTotalChange = (value) => {
    const parsed = value === "" ? "" : parseNumber(value);
    setTotal(parsed);
    setDisplayTotal(value === "" ? "" : formatNumber(parsed));
  };

  const resetForm = () => {
    setIdBarang("");
    setQty("");
    setTotal("");
    setDisplayTotal("");
    setHargaPerSd("");
    setInputUnit("GRAM");
    setDisplayQty("");
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (isSubmitting) return;

    if (!idBarang || !qty || !hargaPerSd) return;

    setIsSubmitting(true);
    const success = await createExisting({
      id_barang: idBarang,
      qty_dasar: qty,
      harga_beli_per_sd: hargaPerSd,
    });

    if (success) {
      resetForm();
      onSuccess?.();
    }
    setIsSubmitting(false);
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <select
        className="w-full border p-2 rounded cursor-pointer"
        value={idBarang}
        onChange={(e) => setIdBarang(e.target.value)}
      >
        <option value="">{loading ? "Memuat..." : "Pilih Barang"}</option>
        {barangList.map((b) => (
          <option key={b.id_barang} value={b.id_barang}>
            {b.nama_barang} (Stok: {formatQty(b.stok_dasar, b.satuan_dasar)})
          </option>
        ))}
      </select>

      <div>
        <input
          type="number"
          className="w-full border p-2 rounded"
          placeholder={
            selectedBarang?.satuan_dasar === "GRAM"
              ? `Qty dalam ${inputUnit}`
              : "Qty"
          }
          step={selectedBarang?.satuan_dasar !== "GRAM" ? "1" : "any"}
          value={selectedBarang?.satuan_dasar === "GRAM" ? displayQty : qty}
          onKeyDown={
            selectedBarang?.satuan_dasar !== "GRAM"
              ? (e) => {
                  if ([".", ",", "e", "E", "+", "-"].includes(e.key))
                    e.preventDefault();
                }
              : undefined
          }
          onChange={(e) => handleQtyChange(e.target.value)}
        />

        {selectedBarang?.satuan_dasar === "GRAM" && (
          <div className="mt-2">
            <label className="block text-slate-700 text-sm font-bold mb-2">
              Pilih Satuan Input:
            </label>
            <select
              className="w-full border p-2 rounded"
              value={inputUnit}
              onChange={(e) => handleUnitChange(e.target.value)}
            >
              <option value="GRAM">Gram</option>
              <option value="ONS">Ons (100 gram)</option>
              <option value="KG">Kg (1000 gram)</option>
            </select>
            {displayQty && (
              <p className="text-sm text-gray-600 mt-2">
                = <strong>{qty} gram</strong>
              </p>
            )}
          </div>
        )}
      </div>

      <input
        type="text"
        className="w-full border p-2 rounded"
        placeholder="Harga Beli Total"
        value={displayTotal}
        onChange={(e) => handleTotalChange(e.target.value)}
      />

      <p className="text-sm text-gray-600">
        Harga Beli per Satuan Dasar:{" "}
        <strong>{hargaPerSd ? formatToRupiah(hargaPerSd) : "-"}</strong>
      </p>

      <div className="flex justify-end">
        <button
          type="submit"
          disabled={isSubmitting}
          className={`px-6 py-2 rounded font-semibold transition cursor-pointer
          ${
            isSubmitting
              ? "bg-gray-300 text-gray-500 cursor-not-allowed"
              : "bg-blue-400 text-slate-900 hover:bg-blue-500"
          }`}
        >
          {isSubmitting ? "Memproses..." : "Tambah Stok"}
        </button>
      </div>
    </form>
  );
}