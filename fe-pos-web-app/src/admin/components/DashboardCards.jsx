import { useEffect } from "react";
import { useDashboardStore } from "../../stores/useDashboardStore.js";
import { useDashboard } from "../../shared/hooks/useDashboard.js";

export default function DashboardCards() {
  const { dashboardStats, setDashboardStats } = useDashboardStore();
  const { fetchDashboardStats } = useDashboard({
    mode: "admin",
    setDashboardStats,
  });

  useEffect(() => {
    fetchDashboardStats();
  }, []);

  const cardData = [
    {
      title: "Jumlah Barang Toko Kelontong",
      value: dashboardStats.totalBarang,
    },
    {
      title: "Jumlah Barang Masuk Hari Ini",
      value: dashboardStats.totalBarangMasukHariIni,
    },
  ];

  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-4 p-4 my-6 mx-12">
      {cardData.map(({ title, value }) => (
        <div
          key={title}
          className="bg-slate-900 text-blue-400 py-4 px-8 rounded-lg text-center shadow-lg"
        >
          <h3 className="font-semibold">{title}</h3>
          <p className="text-2xl font-bold mt-2">{value}</p>
        </div>
      ))}
    </div>
  );
}