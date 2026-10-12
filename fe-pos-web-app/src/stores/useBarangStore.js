import { create } from "zustand";

export const useBarangStore = create((set) => ({
  barang: [],
  setBarang: (barang) => set({ barang }),

  searchQuery: "",
  setSearchQuery: (query) => set({ searchQuery: query }),

  error: null,
  setError: (error) => set({ error }),

  isLoading: false,
  setIsLoading: (loading) => set({ isLoading: loading }),

  totalBarang: 0,
  setTotalBarang: (total) => set({ totalBarang: total }),
}));
