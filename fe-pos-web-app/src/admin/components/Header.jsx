import { useLocation } from "react-router-dom";
import { useUIStore } from "../../stores/useUIStore.js";

export default function Header() {
  const location = useLocation();
  const { activeTab } = useUIStore();

  const getTitle = () => {
    switch (location.pathname) {
      case "/admin/dashboard":
        return "Dashboard";
      case "/admin/daftar-barang":
        return "Daftar Barang";
      default:
        return activeTab || "Dashboard";
    }
  };

  return (
    <header className="bg-gray-400 text-black p-4 flex justify-between">
      <h1 className="text-xl font-bold">{getTitle()}</h1>
    </header>
  );
}