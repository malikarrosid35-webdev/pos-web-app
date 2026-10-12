export default function LaporanTabs({ activeTab, onChange }) {
  const tabClass = (tab) =>
    `px-2 sm:px-4 py-2 rounded-t text-xs sm:text-sm whitespace-nowrap ${
      activeTab === tab ? "bg-white border-b-0" : "bg-gray-200"
    }`;

  return (
    <div className="mb-4 overflow-x-auto">
      <div className="inline-flex border rounded-t min-w-full sm:min-w-0">
        <button
          className={`${tabClass("mingguan")} cursor-pointer`}
          onClick={() => onChange("mingguan")}
        >
          Laporan Mingguan
        </button>
        <button
          className={`${tabClass("bulanan")} cursor-pointer`}
          onClick={() => onChange("bulanan")}
        >
          Laporan Bulanan
        </button>
        <button
          className={`${tabClass("tahunan")} cursor-pointer`}
          onClick={() => onChange("tahunan")}
        >
          Laporan Tahunan
        </button>
      </div>
    </div>
  );
}