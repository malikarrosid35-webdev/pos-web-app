import { useState, useEffect } from "react";
import { Routes, Route, Navigate } from "react-router-dom";
import ProtectedRoute from "../auth/ProtectedRoute.jsx";
import SidebarOwner from "../owner/components/SidebarOwner.jsx";
import OwnerTopbar from "../owner/components/OwnerTopbar.jsx";
import Dashboard from "../owner/pages/Dashboard.jsx";
import LaporanToko from "../owner/pages/LaporanToko.jsx";
import BarangMasuk from "../owner/pages/BarangMasuk.jsx";
import DaftarBarang from "../owner/pages/DaftarBarang.jsx";
import HistoriTransaksi from "../owner/pages/HistoriTransaksi.jsx";
import DaftarPelanggan from "../owner/pages/DaftarPelanggan.jsx";
import DetailTransaksi from "../owner/pages/DetailTransaksi.jsx";
import DetailNotifikasi from "../owner/pages/DetailNotifikasi.jsx";
import Notifikasi from "../owner/pages/Notifikasi.jsx";
import HistoriTukarPoin from "../owner/pages/HistoriTukarPoin.jsx";
import useFcmNotification from "../shared/hooks/useFcmNotification.js";
import { useAuthStore } from "../stores/useAuthStore.js";

export default function OwnerRoutes() {
  const [isSidebarOpen, setIsSidebarOpen] = useState(false);
  const [isMobile, setIsMobile] = useState(false);
  const role = useAuthStore((state) => state.role);

  // Hanya minta izin & daftarkan FCM token saat device benar-benar sedang
  // login sebagai owner — bukan hanya karena route /owner/* sedang diakses.
  useFcmNotification({ enabled: role === "owner" });
  
  // Deteksi ukuran layar — mobile: sidebar tertutup default, desktop: terbuka
  useEffect(() => {//
    const checkScreen = () => {
      const mobile = window.innerWidth < 1024;
      setIsMobile(mobile);
      setIsSidebarOpen(!mobile);
    };
    checkScreen();
    window.addEventListener("resize", checkScreen);
    return () => window.removeEventListener("resize", checkScreen);
  }, []);

  const toggleSidebar = () => setIsSidebarOpen((prev) => !prev);
  const closeSidebar = () => {
    if (isMobile) setIsSidebarOpen(false);
  };

  return (
    <ProtectedRoute role="owner">
      <div className="flex min-h-screen bg-gray-50 relative">
        {/* Overlay gelap di belakang sidebar saat mobile */}
        {isMobile && isSidebarOpen && (
          <div
            className="fixed inset-0 bg-black/50 z-30"
            onClick={closeSidebar}
            aria-hidden="true"
          />
        )}

        <SidebarOwner
          isOpen={isSidebarOpen}
          toggleSidebar={toggleSidebar}
          isMobile={isMobile}
          closeSidebar={closeSidebar}
        />

        <div className="flex-1 min-w-0">
          <OwnerTopbar isMobile={isMobile} onToggleSidebar={toggleSidebar} />

          <Routes>
            <Route index element={<Navigate to="dashboard" replace />} />
            <Route path="dashboard" element={<Dashboard />} />
            <Route path="laporan-toko" element={<LaporanToko />} />
            <Route path="barang-masuk" element={<BarangMasuk />} />
            <Route
              path="barang-masuk"
              element={<Navigate to="/owner/barang-masuk" replace />}
            />
            <Route path="daftar-barang" element={<DaftarBarang />} />
            <Route path="histori-transaksi" element={<HistoriTransaksi />} />
            <Route path="detail-transaksi/:id" element={<DetailTransaksi />} />
            <Route path="detail-notifikasi/:id" element={<DetailNotifikasi />} />
            <Route path="notifikasi" element={<Notifikasi />} />
            <Route path="daftar-pelanggan" element={<DaftarPelanggan />} />
            <Route
              path="daftar-pelanggan/:id_pelanggan/histori-tukar-poin"
              element={<HistoriTukarPoin />}
            />
          </Routes>
        </div>
      </div>
    </ProtectedRoute>
  );
}