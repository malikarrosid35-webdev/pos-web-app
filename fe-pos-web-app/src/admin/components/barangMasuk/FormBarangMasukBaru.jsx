import { useEffect, useState } from "react";
import Swal from "sweetalert2";
import { useBarangMasukStore } from "../../../stores/useBarangMasukStore.js";
import { useBarangMasuk } from "../../../shared/hooks/useBarangMasuk.js";
import {
  formatNumber,
  parseNumber,
  formatToRupiah,
} from "../../../shared/utils/numberFormat.js";

export default function FormBarangMasukBaru({ onSuccess }) {
  const { setBarangMasuk } = useBarangMasukStore();
  const { createNew } = useBarangMasuk({
    setBarangMasuk,
    mode: "admin",
  });

  const [isSubmitting, setIsSubmitting] = useState(false);

  const [form, setForm] = useState({
    nama_barang: "",
    // kategori_barang: "",
    stok_dasar: "",
    satuan_dasar: "",
    harga_beli_total: "",
    harga_jual_per_sd: "",
  });

  const [displayHargaBeli, setDisplayHargaBeli] = useState("");
  const [displayHargaJual, setDisplayHargaJual] = useState("");
  const [hargaPerSd, setHargaPerSd] = useState("");
  const [inputUnit, setInputUnit] = useState("GRAM");
  const [displayQty, setDisplayQty] = useState("");

  const unitConversion = {
    GRAM: 1,
    ONS: 100,
    KG: 1000,
  };

  useEffect(() => {
    const total = Number(form.harga_beli_total);
    const qty = Number(form.stok_dasar);
    if (total > 0 && qty > 0) setHargaPerSd((total / qty).toFixed(2));
    else setHargaPerSd("");
  }, [form.harga_beli_total, form.stok_dasar]);

  useEffect(() => {
    if (form.satuan_dasar === "GRAM") {
      setInputUnit("GRAM");
    } else {
      setDisplayQty("");
      setForm({ ...form, stok_dasar: "" });
    }
  }, [form.satuan_dasar]);

  const handleQtyChange = (value) => {
    // For PCS (non-GRAM), strip any decimal part
    const safeValue =
      form.satuan_dasar !== "GRAM" && value !== "" && value.includes(".")
        ? String(Math.floor(Number(value)))
        : value;
    setDisplayQty(safeValue);
    if (form.satuan_dasar === "GRAM" && safeValue) {
      const convertedValue = Number(safeValue) * unitConversion[inputUnit];
      setForm({ ...form, stok_dasar: convertedValue.toString() });
    } else {
      setForm({ ...form, stok_dasar: safeValue });
    }
  };

  const handleUnitChange = (unit) => {
    setInputUnit(unit);
    if (displayQty) {
      const convertedValue = Number(displayQty) * unitConversion[unit];
      setForm({ ...form, stok_dasar: convertedValue.toString() });
    }
  };

  const resetForm = () => {
    setForm({
      nama_barang: "",
      // kategori_barang: "",
      stok_dasar: "",
      satuan_dasar: "",
      harga_beli_total: "",
      harga_jual_per_sd: "",
    });
    setHargaPerSd("");
    setInputUnit("GRAM");
    setDisplayQty("");
    setDisplayHargaBeli("");
    setDisplayHargaJual("");
  };

  const handleHargaBeli = (value) => {
    const parsed = value === "" ? "" : parseNumber(value);
    setForm({ ...form, harga_beli_total: parsed });
    setDisplayHargaBeli(value === "" ? "" : formatNumber(parsed));
  };

  const handleHargaJual = (value) => {
    const parsed = value === "" ? "" : parseNumber(value);
    setForm({ ...form, harga_jual_per_sd: parsed });
    setDisplayHargaJual(value === "" ? "" : formatNumber(parsed));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (isSubmitting) return;

    if (
      !form.nama_barang ||
      // '!form.kategori_barang ||
      !form.stok_dasar ||
      !form.satuan_dasar
    ) {
      return Swal.fire("Error", "Lengkapi semua field wajib", "error");
    }

    if (!hargaPerSd) {
      return Swal.fire("Error", "Harga beli per satuan tidak valid", "error");
    }

    setIsSubmitting(true);
    try {
      const payload = {
        nama_barang: form.nama_barang.trim(),
        // kategori_barang: form.kategori_barang.trim(),
        stok_dasar: parseInt(form.stok_dasar, 10),
        satuan_dasar: form.satuan_dasar.toUpperCase(),
        harga_modal_per_sd: parseFloat(hargaPerSd),
        harga_jual_per_sd: form.harga_jual_per_sd
          ? parseFloat(form.harga_jual_per_sd)
          : 0,
      };

      const success = await createNew(payload);
      if (success) {
        resetForm();
        onSuccess?.();
      }
    } catch (err) {
      Swal.fire({
        icon: "error",
        title: "Gagal Menambahkan Barang",
        text: err.message || "Terjadi kesalahan saat menyimpan barang",
        confirmButtonColor: "#3085d6",
      });
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <input
        className="w-full border p-2 rounded"
        placeholder="Nama Barang"
        value={form.nama_barang}
        onChange={(e) => setForm({ ...form, nama_barang: e.target.value })}
      />

      {/* <input
        className="w-full border p-2 rounded"
        placeholder="Kategori"
        value={form.kategori_barang}
        onChange={(e) => setForm({ ...form, kategori_barang: e.target.value })}
      /> */}

      <select
        className="w-full border p-2 rounded cursor-pointer"
        value={form.satuan_dasar}
        onChange={(e) => setForm({ ...form, satuan_dasar: e.target.value })}
      >
        <option value="">Pilih Satuan Dasar</option>
        <option value="PCS">PCS</option>
        <option value="GRAM">GRAM</option>
      </select>

      <div>
        <input
          type="number"
          className="w-full border p-2 rounded"
          placeholder={
            form.satuan_dasar === "GRAM"
              ? `Qty dalam ${inputUnit}`
              : "Qty (Stok Awal)"
          }
          step={form.satuan_dasar === "PCS" ? "1" : "any"}
          value={form.satuan_dasar === "GRAM" ? displayQty : form.stok_dasar}
          onKeyDown={
            form.satuan_dasar === "PCS"
              ? (e) => {
                  if ([".", ",", "e", "E", "+", "-"].includes(e.key))
                    e.preventDefault();
                }
              : undefined
          }
          onChange={(e) => handleQtyChange(e.target.value)}
        />

        {form.satuan_dasar === "GRAM" && (
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
                = <strong>{form.stok_dasar} gram</strong>
              </p>
            )}
          </div>
        )}
      </div>

      <input
        type="text"
        className="w-full border p-2 rounded"
        placeholder="Harga Beli Total"
        value={displayHargaBeli}
        onChange={(e) => handleHargaBeli(e.target.value)}
      />

      <p className="text-sm text-gray-600">
        Harga Beli per Satuan Dasar:{" "}
        <strong>{hargaPerSd ? formatToRupiah(hargaPerSd) : "-"}</strong>
      </p>

      <input
        type="text"
        className="w-full border p-2 rounded"
        placeholder="Harga Jual per Satuan Dasar"
        value={displayHargaJual}
        onChange={(e) => handleHargaJual(e.target.value)}
      />

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
          {isSubmitting ? "Menyimpan..." : "Simpan Barang Baru"}
        </button>
      </div>
    </form>
  );
}