export default function BarangMasukTabs({ activeTab, onChange, mode = "admin" }) {
  const isOwner = mode === "owner";
  const activeClass = isOwner
    ? "bg-violet-700 text-white font-semibold"
    : "bg-white border-b-0";
  const inactiveClass = isOwner
    ? "bg-violet-100 text-violet-800 hover:bg-violet-200"
    : "bg-gray-200";
  const tabClass = (tab) =>
    `px-4 py-2 rounded-t ${activeTab === tab ? activeClass : inactiveClass}`;

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