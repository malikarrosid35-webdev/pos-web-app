export default function BarangMasukTabs({ activeTab, onChange }) {
  const tabClass = (tab) =>
    `px-4 py-2 rounded-t ${
      activeTab === tab ? "bg-white border-b-0" : "bg-gray-200"
    }`;

  return (
    <div className="mb-4">
      <div className="inline-flex border rounded-t">
        <button className={`${tabClass("baru")} cursor-pointer`} onClick={() => onChange("baru")}>
          Barang Baru
        </button>
        <button
          className={`${tabClass("existing")} cursor-pointer`}
          onClick={() => onChange("existing")}
        >
          Barang Existing
        </button>
        <button
          className={`${tabClass("history")} cursor-pointer`}
          onClick={() => onChange("history")}
        >
          Riwayat Barang Masuk
        </button>
      </div>
    </div>
  );
}