import { useState } from "react";
import Swal from "sweetalert2";
import { X } from "lucide-react";

const MAKS_JUMLAH = 100000;

export default function PoinAdjustModal({ pelanggan, onSubmit, onClose }) {
  const [tipe, setTipe] = useState("tambah");
  const [jumlah, setJumlah] = useState("");
  const [alasan, setAlasan] = useState("");
  const [submitting, setSubmitting] = useState(false);

  const saldo = pelanggan.poin_loyalitas || 0;
  const jumlahNum = Number(jumlah) || 0;
  const poinBaru = tipe === "tambah" ? saldo + jumlahNum : saldo - jumlahNum;
  const melebihiSaldo = tipe === "kurangi" && jumlahNum > saldo;

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (jumlahNum < 1)
      return Swal.fire("Validasi", "Jumlah poin minimal 1", "warning");
    if (jumlahNum > MAKS_JUMLAH)
      return Swal.fire(
        "Validasi",
        `Jumlah poin maksimal ${MAKS_JUMLAH}`,
        "warning",
      );
    if (melebihiSaldo)
      return Swal.fire(
        "Validasi",
        `Poin tidak cukup (saldo: ${saldo})`,
        "warning",
      );
    if (alasan.trim().length < 3)
      return Swal.fire("Validasi", "Alasan minimal 3 karakter", "warning");

    const konfirmasi = await Swal.fire({
      title: tipe === "tambah" ? "Tambah poin?" : "Kurangi poin?",
      text: `${pelanggan.nama_pelanggan}: ${saldo} → ${poinBaru} poin`,
      icon: "question",
      showCancelButton: true,
      confirmButtonText: "Ya, simpan",
      cancelButtonText: "Batal",
    });
    if (!konfirmasi.isConfirmed) return;

    setSubmitting(true);
    const hasil = await onSubmit({
      tipe,
      jumlah: jumlahNum,
      alasan: alasan.trim(),
    });
    setSubmitting(false);
    if (hasil) onClose();
  };

  return (
    // Mobile: sheet dari bawah (items-end) | Tablet+: modal di tengah (items-center)
    <div className="fixed inset-0 bg-black/40 flex items-end sm:items-center justify-center z-50 p-0 sm:p-4">
      <div className="bg-white w-full sm:max-w-md sm:rounded-xl rounded-t-2xl shadow-xl overflow-hidden">
        <div className="flex items-center justify-between px-5 py-4 border-b">
          <div className="min-w-0">
            <h3 className="text-lg font-semibold">Sesuaikan Poin</h3>
            <p className="text-sm text-gray-600 truncate">
              {pelanggan.nama_pelanggan}
            </p>
          </div>
          <button
            type="button"
            onClick={onClose}
            className="p-1 rounded-full text-black hover:bg-red-500 hover:text-white cursor-pointer"
            aria-label="Tutup"
          >
            <X size={20} />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="px-5 py-4 space-y-4">
          <div className="grid grid-cols-2 gap-2">
            <button
              type="button"
              aria-pressed={tipe === "tambah"}
              onClick={() => setTipe("tambah")}
              className={`px-4 py-2.5 rounded border text-sm font-medium cursor-pointer ${
                tipe === "tambah"
                  ? "bg-violet-700 text-white border-violet-700"
                  : "hover:bg-gray-100"
              }`}
            >
              Tambah
            </button>
            <button
              type="button"
              aria-pressed={tipe === "kurangi"}
              onClick={() => setTipe("kurangi")}
              className={`px-4 py-2.5 rounded border text-sm font-medium cursor-pointer ${
                tipe === "kurangi"
                  ? "bg-red-600 text-white border-red-600"
                  : "hover:bg-gray-100"
              }`}
            >
              Kurangi
            </button>
          </div>

          <div>
            <label className="block text-sm font-medium mb-1">
              Jumlah Poin <span className="text-red-600">*</span>
            </label>
            <input
              type="text"
              inputMode="numeric"
              className="w-full border rounded px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-violet-400 text-sm"
              value={jumlah}
              onChange={(e) => {
                const value = e.target.value;
                if (value === "" || /^\d+$/.test(value)) setJumlah(value);
              }}
              maxLength={6}
              placeholder="Contoh: 10"
              required
            />
          </div>

          <div>
            <label className="block text-sm font-medium mb-1">
              Alasan <span className="text-red-600">*</span>
            </label>
            <textarea
              className="w-full border rounded px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-violet-400 text-sm"
              rows={3}
              value={alasan}
              onChange={(e) => setAlasan(e.target.value)}
              maxLength={255}
              placeholder="Contoh: Koreksi salah input"
              required
            />
            <p className="text-xs text-gray-500 mt-1">
              Minimal 3 karakter. Alasan tercatat di riwayat poin.
            </p>
          </div>

          <div className="bg-gray-50 border rounded-lg px-4 py-3 text-sm">
            <div className="flex justify-between">
              <span className="text-gray-600">Poin saat ini</span>
              <span className="font-semibold">{saldo}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-600">Setelah disesuaikan</span>
              <span
                className={`font-semibold ${melebihiSaldo ? "text-red-600" : ""}`}
              >
                {jumlahNum > 0 ? poinBaru : "-"}
              </span>
            </div>
            {melebihiSaldo && (
              <p className="text-xs text-red-600 mt-1">
                Poin tidak cukup untuk dikurangi sebanyak itu.
              </p>
            )}
          </div>

          <div className="flex flex-col-reverse sm:flex-row sm:justify-end gap-2 pt-1 pb-2 sm:pb-0">
            <button
              type="button"
              onClick={onClose}
              className="w-full sm:w-auto px-4 py-2.5 rounded border cursor-pointer hover:bg-gray-100 text-sm"
            >
              Batal
            </button>
            <button
              type="submit"
              disabled={submitting || melebihiSaldo}
              className="w-full sm:w-auto px-4 py-2.5 rounded bg-violet-700 text-white hover:bg-violet-800 disabled:opacity-50 disabled:cursor-not-allowed cursor-pointer text-sm"
            >
              {submitting ? "Menyimpan..." : "Simpan"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
