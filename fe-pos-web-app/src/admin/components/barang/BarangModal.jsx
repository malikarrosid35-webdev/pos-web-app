import { useState, useEffect } from "react";
import BarangForm from "./BarangForm.jsx";
import { useBarang } from "../../../shared/hooks/useBarang.js";
import {
  formatNumber,
  parseNumber,
} from "../../../shared/utils/numberFormat.js";
import { useBarangStore } from "../../../stores/useBarangStore.js";
import { X } from "lucide-react";

export default function BarangModal({
  currentBarang,
  onClose,
  onSuccess,
  mode = "admin",
}) {
  const { setBarang } = useBarangStore();
  const { create, update } = useBarang({
    setBarang,
    mode,
  });

  const [formattedHargaJual, setFormattedHargaJual] = useState("");

  useEffect(() => {
    if (currentBarang) {
      if (currentBarang.harga_jual_per_sd !== undefined) {
        setFormattedHargaJual(
          formatNumber(Number(currentBarang.harga_jual_per_sd)),
        );
      }
    } else {
      setFormattedHargaJual("");
    }
  }, [currentBarang]);

  const handleHargaJualChange = (e) => {
    setFormattedHargaJual(formatInputCurrency(e.target.value));
  };

  const formatInputCurrency = (value) => {
    const cleaned = value.replace(/[^\d,]/g, "");
    const parts = cleaned.split(",");
    let formatted = parts[0];

    if (parts.length > 1) {
      formatted += "," + parts[1].substring(0, 2);
    }

    if (formatted.length > 3) {
      const integerPart = formatted.split(",")[0];
      const decimalPart = formatted.includes(",")
        ? "," + formatted.split(",")[1]
        : "";
      formatted =
        integerPart.replace(/\B(?=(\d{3})+(?!\d))/g, ".") + decimalPart;
    }

    return formatted;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    const formData = new FormData(e.target);

    if (formattedHargaJual) {
      const rawHargaJual = parseNumber(formattedHargaJual);
      formData.set("harga_jual_per_sd", rawHargaJual.toFixed(2));
    }

    try {
      if (currentBarang) {
        await update(
          currentBarang.id_barang,
          Object.fromEntries(formData),
          false,
        );
      } else {
        await create(formData);
      }
      onSuccess();
    } catch (err) {
      console.error(err);
    }
  };

  return (
    <div className="fixed inset-0 bg-black/85 flex justify-center z-50 overflow-y-auto">
      <div className="bg-white rounded-lg w-full max-w-md my-10 max-h-[90vh] overflow-y-auto">
        <div className="p-6">
          <div className="flex justify-between items-center mb-4">
            <h2 className="text-xl font-bold">
              {currentBarang ? "Edit Barang" : "Tambah Barang"}
            </h2>
            <button
              onClick={onClose}
              className="w-10 h-10 flex items-center justify-center text-red-500 bg-transparent hover:text-white hover:bg-red-500 rounded-full transition duration-300 cursor-pointer"
            >
              <X size={24} />
            </button>
          </div>
          <BarangForm
            currentBarang={currentBarang}
            onSubmit={handleSubmit}
            hargaValue={formattedHargaJual}
            onHargaChange={handleHargaJualChange}
          />
        </div>
      </div>
    </div>
  );
}