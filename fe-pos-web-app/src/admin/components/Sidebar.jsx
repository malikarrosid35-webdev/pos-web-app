import {
  BarChart2,
  List,
  LogOut,
  Menu,
  Package,
} from "lucide-react";
import { Link, useNavigate } from "react-router-dom";
import { useState } from "react";
import { useUIStore } from "../../stores/useUIStore.js";
import { logout } from "../../auth/authService.js";

export default function Sidebar({ isOpen, toggleSidebar }) {
  const { activeTab, setActiveTab } = useUIStore();
  const navigate = useNavigate();
  const [showLogoutConfirm, setShowLogoutConfirm] = useState(false);

  const menuAdmin = [
    {
      name: "Dashboard",
      icon: <BarChart2 size={20} />,
      path: "/admin/dashboard",
    },
    {
      name: "Barang Masuk",
      icon: <Package size={20} />,
      path: "/admin/barang-masuk",
    },
    {
      name: "Daftar Barang",
      icon: <List size={20} />,
      path: "/admin/daftar-barang",
    },
  ];

  const handleLogoutClick = () => {
    setShowLogoutConfirm(true);
  };

  const confirmLogout = () => {
    setShowLogoutConfirm(false);
    logout();
    navigate("/login");
  };

  const ConfirmLogoutModal = () => (
    <div className="fixed inset-0 bg-black opacity-90 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg shadow-lg p-6 w-96 max-w-sm mx-4">
        <h2 className="text-xl font-bold text-gray-800 mb-4">
          Konfirmasi Logout
        </h2>
        <p className="text-gray-600 mb-6">
          Apakah Anda yakin ingin keluar dari aplikasi?
        </p>
        <div className="flex gap-3 justify-end">
          <button
            onClick={() => setShowLogoutConfirm(false)}
            className="px-4 py-2 bg-gray-300 hover:bg-gray-400 text-gray-800 rounded-lg font-medium transition-colors cursor-pointer"
          >
            Batal
          </button>
          <button
            onClick={confirmLogout}
            className="px-4 py-2 bg-red-500 hover:bg-red-700 text-white rounded-lg font-medium transition-colors cursor-pointer"
          >
            Ya, Keluar
          </button>
        </div>
      </div>
    </div>
  );

  return (
    <>
      <aside
        className={`bg-slate-900 text-blue-400 flex flex-col transition-all duration-300 shrink-0 ${
          isOpen ? "w-64" : "w-16"}`}
      >
        <div className="p-4 flex items-center justify-between">
          <Menu onClick={toggleSidebar} className="cursor-pointer" size={22} />
          {isOpen && <h1 className="text-lg font-bold">Admin</h1>}
        </div>

        <nav className="mt-6 space-y-2 px-4">
          {menuAdmin.map((item) => (
            <Link
              to={item.path}
              key={item.name}
              className={`
                flex items-center space-x-2 hover:bg-slate-800 p-2 rounded
                ${!isOpen ? "justify-center" : ""}
                ${activeTab === item.name ? "bg-slate-700 font-bold" : ""}
              `}
              title={!isOpen ? item.name : undefined}
              onClick={() => setActiveTab(item.name)}
            >
              {item.icon}
              {isOpen && <span>{item.name}</span>}
            </Link>
          ))}
        </nav>
        <div className="p-4">
          <button
            onClick={handleLogoutClick}
            title={!isOpen ? "Keluar" : undefined}
            className={`
              cursor-pointer bg-red-500 hover:bg-red-700 text-white py-2 rounded w-full
              flex items-center justify-center
              ${isOpen ? "gap-2 px-4" : "px-0"}
            `}
          >
            <LogOut size={18} />
            {isOpen && <span>Keluar</span>}
          </button>
        </div>
      </aside>
      {showLogoutConfirm && <ConfirmLogoutModal />}
    </>
  );
}