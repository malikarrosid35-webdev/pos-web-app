import { Bell } from "lucide-react";
// import { useState } from "react";
import { useLocation } from "react-router-dom";
import { useUIStore } from "../../stores/useUIStore.js";

export default function Header() {
  // const [hasUnread, setHasUnread] = useState(true);
  // const [isHovered, setIsHovered] = useState(false);
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

  // const notifications = [
  //   {
  //     id: 1,
  //     text: "Pesanan baru dari Pelanggan A",
  //     time: "2 menit lalu",
  //     read: false,
  //   },
  //   {
  //     id: 2,
  //     text: "Stok barang X hampir habis",
  //     time: "1 jam lalu",
  //     read: true,
  //   },
  //   {
  //     id: 3,
  //     text: "Pembelian barang baru Z dari Supplier Y",
  //     time: "3 jam lalu",
  //     read: true,
  //   },
  // ];

  // const handleViewMore = () => {
  //   setHasUnread(false);
  //   console.log("View more notifications");
  // };

  return (
    <header className="bg-gray-400 text-black p-4 flex justify-between">
      <h1 className="text-xl font-bold">{getTitle()}</h1>
      {/* <div
        className="relative cursor-pointer"
        onMouseEnter={() => setIsHovered(true)}
        onMouseLeave={() => setIsHovered(false)}
      >
        <div className="relative">
          <Bell size={24} />
          {hasUnread && (
            <div className="absolute -top-1 -right-1 w-3 h-3 bg-red-500 rounded-full border-white"></div>
          )}
        </div>
        {isHovered && (
          <div className="absolute right-0 top-full mt-2 w-72 bg-white rounded-md shadow-lg z-10 overflow-hidden">
            <div className="p-3 border-b border-gray-200">
              <h3 className="font-semibold text-gray-800">Notifikasi</h3>
            </div>
            <div className="max-h-60 overflow-y-auto">
              {notifications.map((notification) => (
                <div
                  key={notification.id}
                  className={`p-3 border-b border-gray-100 hover:bg-gray-500 ${
                    !notification.read ? "bg-blue-50" : ""
                  }`}
                >
                  <div>
                    <p className="text-sm text-gray-800">{notification.text}</p>
                    <p className="text-sm text-gray-500  hover:text-gray-800 mt-1">
                      {notification.time}
                    </p>
                  </div>
                </div>
              ))}
            </div>
            <div
              onClick={handleViewMore}
              className="p-2 bg-gray-100 text-center text-sm text-blue-600 hover:bg-gray-200 cursor-pointer flex items-center justify-center"
            >
              Lihat Semua Notifikasi
            </div>
          </div>
        )}
      </div> */}
    </header>
  );
}