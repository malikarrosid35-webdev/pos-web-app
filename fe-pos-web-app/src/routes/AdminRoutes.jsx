import { useState } from "react";
import { Routes, Route, Navigate } from "react-router-dom";
import ProtectedRoute from "../auth/ProtectedRoute.jsx";
import Sidebar from "../admin/components/Sidebar.jsx";
import Dashboard from "../admin/pages/Dashboard.jsx";
import DaftarBarang from "../admin/pages/DaftarBarang.jsx";
import BarangMasuk from "../admin/pages/BarangMasuk.jsx";

export default function AdminRoutes() {
  const [isSidebarOpen, setIsSidebarOpen] = useState(true);
  const toggleSidebar = () => setIsSidebarOpen(!isSidebarOpen);

  return (
    <ProtectedRoute role="admin">
      <div className="flex min-h-screen">
        <Sidebar isOpen={isSidebarOpen} toggleSidebar={toggleSidebar} />
        <Routes>
          <Route index element={<Navigate to="dashboard" replace />} />
          <Route path="dashboard" element={<Dashboard />} />
          <Route path="barang-masuk" element={<BarangMasuk />} />
          <Route path="daftar-barang" element={<DaftarBarang />} />
        </Routes>
      </div>
    </ProtectedRoute>
  );
}