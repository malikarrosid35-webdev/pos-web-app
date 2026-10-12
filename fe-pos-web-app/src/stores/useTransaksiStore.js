import { create } from "zustand";

// ─── PERUBAHAN 6 ──────────────────────────────────────────────────────────────
// Sebelumnya pelangganTerpilih di-persist ke localStorage, yang menyebabkan
// bug: saat kasir refresh browser atau buka tab baru, pelanggan dari sesi
// transaksi sebelumnya masih "terpilih" tanpa disadari.
//
// Pelanggan adalah bagian dari sesi transaksi yang sedang berjalan — bukan
// data persisten. Initial value cukup null (kosong), tanpa baca localStorage.
// setPelangganTerpilih juga tidak perlu tulis/hapus localStorage sama sekali.
// ─────────────────────────────────────────────────────────────────────────────

export const useTransaksiStore = create((set) => ({
  // PERUBAHAN 6: initial value null langsung, tidak baca localStorage
  pelangganTerpilih: null,

  setPelangganTerpilih: (pelanggan) => {
    // PERUBAHAN 6: tidak ada localStorage.setItem / removeItem di sini
    set({ pelangganTerpilih: pelanggan });
  },

  transaksiTerakhir: null,
  setTransaksiTerakhir: (data) => set({ transaksiTerakhir: data }),

  historiTransaksi: [],
  setHistoriTransaksi: (data) => set({ historiTransaksi: data }),

  totalTransaksi: 0,
  setTotalTransaksi: (total) => set({ totalTransaksi: total }),
}));