import { X } from "lucide-react";

export const PelangganForm = ({
  title,
  submitLabel,
  form,
  setForm,
  onSubmit,
  onCancel,
}) => {
  return (
    // Mobile: sheet dari bawah (items-end) | Tablet+: modal di tengah (items-center)
    <div className="fixed inset-0 bg-black/40 flex items-end sm:items-center justify-center z-50 p-0 sm:p-4">
      <div className="bg-white w-full sm:max-w-md sm:rounded-xl rounded-t-2xl shadow-xl overflow-hidden">
        {/* Header */}
        <div className="flex items-center justify-between px-5 py-4 border-b">
          <h3 className="text-lg font-semibold">{title}</h3>
          <button
            type="button"
            onClick={onCancel}
            className="p-1 rounded-full text-black hover:bg-red-500  hover:text-white cursor-pointer"
            aria-label="Tutup"
          >
            <X size={20} />
          </button>
        </div>

        <form onSubmit={onSubmit} className="px-5 py-4 space-y-4">
          <div>
            <label className="block text-sm font-medium mb-1">
              Nama Pelanggan <span className="text-red-600">*</span>
            </label>
            <input
              type="text"
              className="w-full border rounded px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-green-400 text-sm"
              value={form.nama_pelanggan}
              onChange={(e) =>
                setForm((f) => ({ ...f, nama_pelanggan: e.target.value }))
              }
              maxLength={100}
              required
              placeholder="Masukkan nama pelanggan"
            />
          </div>

          <div>
            <label className="block text-sm font-medium mb-1">No. HP</label>
            <input
              type="text"
              inputMode="numeric"
              pattern="[0-9]*"
              className="w-full border rounded px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-green-400 text-sm"
              value={form.no_hp ?? ""}
              onChange={(e) => {
                const value = e.target.value;
                if (value === "" || /^\d+$/.test(value)) {
                  setForm((f) => ({ ...f, no_hp: value }));
                }
              }}
              maxLength={15}
              placeholder="Boleh dikosongkan"
            />
            <p className="text-xs text-gray-500 mt-1">
              Hanya angka. Kosongkan jika tidak ada nomor HP.
            </p>
          </div>

          {/* Tombol — kolom di mobile, baris di tablet+ */}
          <div className="flex flex-col-reverse sm:flex-row sm:justify-end gap-2 pt-1 pb-2 sm:pb-0">
            <button
              type="button"
              onClick={onCancel}
              className="w-full sm:w-auto px-4 py-2.5 rounded border cursor-pointer hover:bg-gray-100 text-sm"
            >
              Batal
            </button>
            <button
              type="submit"
              className="w-full sm:w-auto px-4 py-2.5 rounded bg-green-600 text-white hover:bg-green-700 cursor-pointer text-sm"
            >
              {submitLabel}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};