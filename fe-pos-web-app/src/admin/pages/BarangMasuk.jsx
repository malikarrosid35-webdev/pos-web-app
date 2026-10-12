import { useEffect, useState } from "react";
import Header from "../components/Header.jsx";
import Swal from "sweetalert2";
import adminClient from "../../lib/http/adminClient.js";
import { useUIStore } from "../../stores/useUIStore.js";

import BarangMasukTabs from "../components/barangMasuk/BarangMasukTabs.jsx";
import FormBarangMasukBaru from "../components/barangMasuk/FormBarangMasukBaru.jsx";
import FormBarangMasukExisting from "../components/barangMasuk/FormBarangMasukExisting.jsx";
import HistoriBarangMasuk from "../components/barangMasuk/HistoriBarangMasuk.jsx";

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
      const res = await adminClient.get("/barang");
      setBarangList(res.data?.data || res.data?.rows || []);
    } catch (err) {
      console.error(err);
      Swal.fire("Error", "Gagal memuat data barang", "error");
    } finally {
      setLoadingBarang(false);
    }
  };

  return (
    <div className="flex-1">
      <Header />
      <div className="p-6">
        <BarangMasukTabs activeTab={activeTab} onChange={setActiveTabLocal} />

        <div className="bg-white rounded shadow p-6">
          {activeTab === "baru" && (
            <FormBarangMasukBaru onSuccess={fetchBarang} />
          )}

          {activeTab === "existing" && (
            <FormBarangMasukExisting
              barangList={barangList}
              loading={loadingBarang}
              onSuccess={fetchBarang}
            />
          )}

          {activeTab === "history" && <HistoriBarangMasuk />}
        </div>
      </div>
    </div>
  );
}
