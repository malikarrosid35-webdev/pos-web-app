import { create } from "zustand";

export const useBarangMasukStore = create((set) => ({
  barangMasuk: [],
  setBarangMasuk: (barangMasuk) => set({ barangMasuk }),
  clearBarangMasuk: () => set({ barangMasuk: [] }),
}));
