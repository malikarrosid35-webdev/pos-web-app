import {
  LogOut,
  Menu,
  BarChart2,
  FileText,
  Package,
  List,
  History,
  Users,
  X,
} from "lucide-react";
import { Link, useNavigate } from "react-router-dom";
import { useState } from "react";
import { logout } from "../../auth/authService.js";
import { useUIStore } from "../../stores/useUIStore.js";

export default function SidebarOwner({
  isOpen,
  toggleSidebar,
  isMobile,
  closeSidebar,
}) {
  const { activeTab, setActiveTab } = useUIStore();
  const navigate = useNavigate();
  const [showLogoutConfirm, setShowLogoutConfirm] = useState(false);

  const menuOwner = [
    {
      name: "Dashboard",
      icon: <BarChart2 size={20} />,
      path: "/owner/dashboard",
    },
    {
      name: "Laporan Toko",
      icon: <FileText size={20} />,
      path: "/owner/laporan-toko",
    },
    {
      name: "Barang Masuk",
      icon: <Package size={20} />,
      path: "/owner/barang-masuk",
    },
    {
      name: "Daftar Barang",
      icon: <List size={20} />,
      path: "/owner/daftar-barang",
    },
    {
      name: "Histori Transaksi",
      icon: <History size={20} />,
      path: "/owner/histori-transaksi",
    },
    {
      name: "Daftar Pelanggan",
      icon: <Users size={20} />,
      path: "/owner/daftar-pelanggan",
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

  const handleNavClick = (name) => {
    setActiveTab(name);
    if (isMobile) closeSidebar();
  };

  const ConfirmLogoutModal = () => (
    <div className="fixed inset-0 flex items-center justify-center z-50">
      <div className="absolute inset-0 bg-black/20 backdrop-blur-sm" />
      <div className="relative z-10 bg-white rounded-lg shadow-lg p-6 w-96 max-w-sm mx-4">
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

  // ── Mobile/Tablet: drawer overlay dari kiri ─────────────────────────────
  if (isMobile) {
    return (
      <>
        <aside
          className={`
            fixed top-0 left-0 h-full w-72 bg-violet-800 text-white
            flex flex-col z-40 shadow-2xl
            transition-transform duration-300 ease-in-out
            ${isOpen ? "translate-x-0" : "-translate-x-full"}
          `}
        >
          <div className="flex items-center justify-between px-4 py-4 border-b border-violet-700">
            <span className="text-lg font-bold">Menu Owner</span>
            <button
              onClick={closeSidebar}
              className="p-1 rounded hover:bg-violet-700 cursor-pointer"
              aria-label="Tutup menu"
            >
              <X size={22} />
            </button>
          </div>

          <nav className="flex-1 px-3 py-4 space-y-1 overflow-y-auto">
            {menuOwner.map((item) => (
              <Link
                to={item.path}
                key={item.name}
                className={`
                  flex items-center gap-3 px-3 py-3 rounded-lg text-sm font-medium transition-colors
                  ${activeTab === item.name ? "bg-violet-700 text-white font-bold" : "text-violet-100 hover:bg-violet-700"}
                `}
                onClick={() => handleNavClick(item.name)}
              >
                {item.icon}
                <span>{item.name}</span>
              </Link>
            ))}
          </nav>

          <div className="px-3 py-4 border-t border-violet-700">
            <button
              onClick={handleLogoutClick}
              className="w-full flex items-center gap-3 px-3 py-3 rounded-lg text-sm font-medium bg-red-500 hover:bg-red-700 text-white transition-colors cursor-pointer"
            >
              <LogOut size={18} />
              <span>Keluar Aplikasi</span>
            </button>
          </div>
        </aside>
        {showLogoutConfirm && <ConfirmLogoutModal />}
      </>
    );
  }

  // ── Desktop: sidebar statis collapsed/expanded ───────────────────────────
  return (
    <>
      <aside
        className={`
          bg-violet-800 text-white min-h-screen flex flex-col
          transition-all duration-300 shrink-0
          ${isOpen ? "w-64" : "w-16"}
        `}
      >
        <div className="flex justify-between items-center p-4">
          <Menu onClick={toggleSidebar} className="cursor-pointer" size={22} />
          {isOpen && <h1 className="text-lg font-bold">Owner</h1>}
        </div>

        <nav className="mt-6 space-y-2 px-4">
          {menuOwner.map((item) => (
            <Link
              to={item.path}
              key={item.name}
              title={!isOpen ? item.name : undefined}
              className={`
                flex items-center space-x-2 hover:bg-violet-700 p-2 rounded transition-colors
                ${!isOpen ? "justify-center" : ""}
                ${activeTab === item.name ? "bg-violet-700 font-bold" : ""}
              `}
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
