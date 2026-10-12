import { create } from "zustand";

export const useDashboardStore = create((set) => ({
  dashboardStats: {
    totalBarang: 0,
    totalBarangMasukHariIni: 0,
    totalTransaksi: 0,
    totalPelanggan: 0,
  },
  setDashboardStats: (stats) => set({ dashboardStats: stats }),

  dateRangeData: [],
  setDateRangeData: (data) => set({ dateRangeData: data }),

  clearDashboard: () =>
    set({
      dashboardStats: {
        totalBarang: 0,
        totalBarangMasukHariIni: 0,
        totalTransaksi: 0,
        totalPelanggan: 0,
      },
      dateRangeData: [],
    }),
}));