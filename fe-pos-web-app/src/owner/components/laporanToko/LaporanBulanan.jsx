import { useEffect, useState } from "react";
import ownerClient from "../../../lib/http/ownerClient.js";
import { formatToRupiah } from "../../../shared/utils/numberFormat.js";
import { Calendar } from "lucide-react";

export default function LaporanBulanan() {
  const [selectedYear, setSelectedYear] = useState(new Date().getFullYear());
  const [selectedMonth, setSelectedMonth] = useState(new Date().getMonth() + 1);
  const [reportData, setReportData] = useState(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    fetchReport();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [selectedYear, selectedMonth]);

  const fetchReport = async () => {
    setLoading(true);
    try {
      const res = await ownerClient.get(
        `/reports/monthly?year=${selectedYear}&month=${selectedMonth}`,
      );
      setReportData(res.data.data);
    } catch (error) {
      console.error("Error fetching monthly report:", error);
    } finally {
      setLoading(false);
    }
  };

  const monthNames = [
    "Januari",
    "Februari",
    "Maret",
    "April",
    "Mei",
    "Juni",
    "Juli",
    "Agustus",
    "September",
    "Oktober",
    "November",
    "Desember",
  ];

  const years = Array.from(
    { length: 10 },
    (_, i) => new Date().getFullYear() - i,
  );

  return (
    <div className="p-3 sm:p-6 bg-gray-50 min-h-screen">
      <div className="mb-4 sm:mb-6">
        <h1 className="text-xl sm:text-3xl font-bold text-gray-800">Laporan Bulanan</h1>
        <p className="text-sm sm:text-base text-gray-600 mt-2">
          Ringkasan transaksi bulanan toko kelontong
        </p>
      </div>

      <div className="bg-white rounded-lg shadow p-3 sm:p-6 mb-4 sm:mb-6">
        <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:gap-4 mb-4">
          <Calendar className="text-violet-800 w-5 h-5 sm:w-6 sm:h-6 flex-shrink-0" size={24} />
          <label className="font-semibold text-sm sm:text-base text-gray-700">Pilih Periode:</label>
          <select
            value={selectedMonth}
            onChange={(e) => setSelectedMonth(Number(e.target.value))}
            className="border rounded px-3 sm:px-6 py-2 text-sm sm:text-base appearance-none cursor-pointer flex-1 sm:flex-none"
            style={{
              backgroundImage: `url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"></polyline></svg>')`,
              backgroundRepeat: "no-repeat",
              backgroundPosition: "right 8px center",
              backgroundSize: "16px",
            }}
          >
            {monthNames.map((month, index) => (
              <option key={index} value={index + 1}>
                {month}
              </option>
            ))}
          </select>
          <select
            value={selectedYear}
            onChange={(e) => setSelectedYear(Number(e.target.value))}
            className="text-left border rounded px-3 sm:px-8 py-2 text-sm sm:text-base appearance-none cursor-pointer flex-1 sm:flex-none"
            style={{
              backgroundImage: `url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"></polyline></svg>')`,
              backgroundRepeat: "no-repeat",
              backgroundPosition: "right 8px center",
              backgroundSize: "16px",
            }}
          >
            {years.map((year) => (
              <option key={year} value={year}>
                {year}
              </option>
            ))}
          </select>
        </div>
      </div>

      {loading ? (
        <div className="flex items-center justify-center py-20">
          <p className="text-lg sm:text-xl">Memuat data...</p>
        </div>
      ) : reportData ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3 sm:gap-6">
          <div className="bg-violet-700 text-white p-4 sm:p-6 rounded-lg shadow-lg">
            <h3 className="font-semibold text-base sm:text-lg">Total Transaksi</h3>
            <p className="text-2xl sm:text-4xl font-bold mt-2">
              {reportData.total_transaksi}
            </p>
          </div>

          <div className="bg-violet-700 text-white p-4 sm:p-6 rounded-lg shadow-lg">
            <h3 className="font-semibold text-base sm:text-lg">Total Penjualan</h3>
            <p className="text-xl sm:text-3xl font-bold mt-2">
              {formatToRupiah(reportData.total_pendapatan)}
            </p>
          </div>
        </div>
      ) : (
        <div className="text-center py-20">
          <p className="text-gray-500 text-sm sm:text-base">Tidak ada data tersedia</p>
        </div>
      )}
    </div>
  );
}
