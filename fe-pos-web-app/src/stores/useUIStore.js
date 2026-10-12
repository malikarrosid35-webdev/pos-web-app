import { create } from "zustand";

export const useUIStore = create((set) => ({
  activeTab: "Dashboard",
  setActiveTab: (tabName) => set({ activeTab: tabName }),

  activeTabKasir: "Buat Transaksi",
  setActiveTabKasir: (tabName) => set({ activeTabKasir: tabName }),
}));