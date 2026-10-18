import { useEffect, useState } from "react";
import Swal from "sweetalert2";
import ownerClient from "../../lib/http/ownerClient.js";
import { useUIStore } from "../../stores/useUIStore.js";

import BarangMasukTabs from "../../admin/components/barangMasuk/BarangMasukTabs.jsx";
import FormBarangMasukBaru from "../../admin/components/barangMasuk/FormBarangMasukBaru.jsx";
import FormBarangMasukExisting from "../../admin/components/barangMasuk/FormBarangMasukExisting.jsx";
import HistoriBarangMasuk from "../../admin/components/barangMasuk/HistoriBarangMasuk.jsx";

export default function BarangMasuk() {
  const { setActiveTab } = useUIStore();
  const [activeTab, setActiveTabLocal] = useState("baru");
  const [barangList, setBarangList] = useState([]);
  const [loadingBarang, setLoadingBarang] = useState(true);

  useEffect(() => {
    setActiveTab("Barang Masuk");
    fetchBarang();
  }, []);

  const fetchBarang = async () => {
    try {
      setLoadingBarang(true);
      const res = await ownerClient.get("/barang");
      setBarangList(res.data?.data || res.data?.rows || []);
    } catch (err) {
      console.error(err);
      Swal.fire("Error", "Gagal memuat data barang", "error");
    } finally {
      setLoadingBarang(false);
    }
  };

  return (
    <div className="flex-1 p-3 sm:p-6 bg-gray-50 min-h-screen">
      <div className="mb-4 sm:mb-6">
        <h1 className="text-2xl sm:text-3xl font-bold text-gray-800">
          Barang Masuk
        </h1>
      </div>

      <BarangMasukTabs
        activeTab={activeTab}
        onChange={setActiveTabLocal}
        mode="owner"
      />

      <div className="bg-white rounded-lg shadow p-4 sm:p-6">
        {activeTab === "baru" && (
          <FormBarangMasukBaru onSuccess={fetchBarang} mode="owner" />
        )}

        {activeTab === "existing" && (
          <FormBarangMasukExisting
            barangList={barangList}
            loading={loadingBarang}
            onSuccess={fetchBarang}
            mode="owner"
          />
        )}

        {activeTab === "history" && <HistoriBarangMasuk mode="owner" />}
      </div>
    </div>
  );
}
