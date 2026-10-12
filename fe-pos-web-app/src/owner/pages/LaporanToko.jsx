import { useEffect, useState } from "react";
import { useUIStore } from "../../stores/useUIStore.js";
import LaporanTabs from "../components/laporanToko/LaporanTabs.jsx";
import LaporanMingguan from "../components/laporanToko/LaporanMingguan.jsx";
import LaporanBulanan from "../components/laporanToko/LaporanBulanan.jsx";
import LaporanTahunan from "../components/laporanToko/LaporanTahunan.jsx";

export default function LaporanToko() {
  const { setActiveTab } = useUIStore();
  const [activeTab, setActiveTabLocal] = useState("mingguan");

  useEffect(() => {
    setActiveTab("Laporan Toko");
  }, []);

  return (
    <div className="flex-1 min-h-screen bg-gray-50">
      <div className="p-3 sm:p-6">
        <LaporanTabs activeTab={activeTab} onChange={setActiveTabLocal} />
        <div className="bg-white rounded-lg shadow">
          {activeTab === "mingguan" && <LaporanMingguan />}
          {activeTab === "bulanan" && <LaporanBulanan />}
          {activeTab === "tahunan" && <LaporanTahunan />}
        </div>
      </div>
    </div>
  );
}