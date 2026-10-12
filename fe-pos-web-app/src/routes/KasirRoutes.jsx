import { Routes, Route, Navigate } from "react-router-dom";
import ProtectedRoute from "../auth/ProtectedRoute.jsx";
import SidebarKasir from "../kasir/components/SidebarKasir.jsx";
import { TransaksiFormPage } from "../kasir/pages/TransaksiFormPage.jsx";
import { HistoriTransaksiPage } from "../kasir/pages/HistoriTransaksiPage.jsx";
import { DetailTransaksiPage } from "../kasir/pages/DetailTransaksiPage.jsx";
import { DaftarPelangganPage } from "../kasir/pages/DaftarPelangganPage.jsx";
import { useState, useEffect } from "react";

export default function KasirRoutes() {
  const [isSidebarOpen, setIsSidebarOpen] = useState(false);
  const [isMobile, setIsMobile] = useState(false);

  // Deteksi ukuran layar — desktop default sidebar terbuka, mobile tertutup
  useEffect(() => {
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
    <ProtectedRoute role="kasir">
      <div className="flex min-h-screen bg-gray-50 relative">
        {/* Overlay gelap di belakang sidebar saat mobile/tablet */}
        {isMobile && isSidebarOpen && (
          <div
            className="fixed inset-0 bg-black/50 z-30"
            onClick={closeSidebar}
            aria-hidden="true"
          />
        )}

        <SidebarKasir
          isOpen={isSidebarOpen}
          toggleSidebar={toggleSidebar}
          isMobile={isMobile}
          closeSidebar={closeSidebar}
        />

        <div className="flex-1 min-w-0">
          {/* Topbar hamburger — hanya tampil di mobile/tablet */}
          {isMobile && (
            <div className="bg-green-800 text-white px-4 py-3 flex items-center gap-3 sticky top-0 z-20">
              <button
                onClick={toggleSidebar}
                className="p-1 rounded hover:bg-green-700"
                aria-label="Buka menu"
              >
                <svg
                  className="w-6 h-6"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M4 6h16M4 12h16M4 18h16"
                  />
                </svg>
              </button>
              <span className="text-lg font-bold">Kasir</span>
            </div>
          )}

          <Routes>
            <Route index element={<Navigate to="buat-transaksi" replace />} />
            <Route path="buat-transaksi" element={<TransaksiFormPage />} />
            <Route
              path="histori-transaksi"
              element={<HistoriTransaksiPage />}
            />
            <Route
              path="detail-transaksi/:id"
              element={<DetailTransaksiPage />}
            />
            <Route path="daftar-pelanggan" element={<DaftarPelangganPage />} />
          </Routes>
        </div>
      </div>
    </ProtectedRoute>
  );
}