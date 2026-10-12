import { create } from "zustand";

export const usePelangganStore = create((set) => ({
  pelanggan: [],
  setPelanggan: (pelanggan) => set({ pelanggan }),
  searchQuery: "",
  setSearchQuery: (query) => set({ searchQuery: query }),
  error: null,
  setError: (error) => set({ error }),
  isLoading: false,
  setIsLoading: (loading) => set({ isLoading: loading }),
  jumlahPelanggan: 0,
  setJumlahPelanggan: (jumlah) => set({ jumlahPelanggan: jumlah }),
}));
