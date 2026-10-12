import { useEffect, useState } from "react";
import ownerClient from "../../../lib/http/ownerClient.js";
import { formatToRupiah } from "../../../shared/utils/numberFormat.js";
import { Calendar } from "lucide-react";
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  Tooltip,
  CartesianGrid,
  ResponsiveContainer,
} from "recharts";

export default function LaporanTahunan() {
  const [selectedYear, setSelectedYear] = useState(new Date().getFullYear());
  const [reportData, setReportData] = useState(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    fetchReport();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [selectedYear]);

  const fetchReport = async () => {
    setLoading(true);
    try {
      const res = await ownerClient.get(`/reports/yearly?year=${selectedYear}`);
      setReportData(res.data.data);
    } catch (error) {
      console.error("Error fetching yearly report:", error);
    } finally {
      setLoading(false);
    }
  };

  const years = Array.from(
    { length: 10 },
    (_, i) => new Date().getFullYear() - i,
  );

  const monthNames = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "Mei",
    "Jun",
    "Jul",
    "Agu",
    "Sep",
    "Okt",
    "Nov",
    "Des",
  ];

  const chartData =
    reportData?.monthly?.map((item) => ({
      bulan: monthNames[item.bulan - 1],
      pendapatan: item.pendapatan_bulanan,
    })) || [];

  return (
    <div className="p-3 sm:p-6 bg-gray-50 min-h-screen">
      <div className="mb-4 sm:mb-6">
        <h1 className="text-xl sm:text-3xl font-bold text-gray-800">
          Laporan Tahunan
        </h1>
        <p className="text-sm sm:text-base text-gray-600 mt-2">
          Ringkasan transaksi tahunan toko kelontong
        </p>
      </div>

      <div className="bg-white rounded-lg shadow p-3 sm:p-6 mb-4 sm:mb-6">
        <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:gap-4 mb-4">
          <Calendar
            className="text-violet-800 w-5 h-5 sm:w-6 sm:h-6 flex-shrink-0"
            size={24}
          />
          <label className="font-semibold text-sm sm:text-base text-gray-700">
            Pilih Tahun:
          </label>
          <select
            value={selectedYear}
            onChange={(e) => setSelectedYear(Number(e.target.value))}
            className="border rounded px-3 sm:px-8 py-2 text-sm sm:text-base appearance-none cursor-pointer flex-1 sm:flex-none"
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
      ) : reportData?.summary ? (
        <>
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 sm:gap-6 mb-6 sm:mb-8">
            <div className="bg-violet-700 text-white p-4 sm:p-6 rounded-lg shadow-lg">
              <h3 className="font-semibold text-base sm:text-lg">
                Total Transaksi
              </h3>
              <p className="text-2xl sm:text-4xl font-bold mt-2">
                {reportData.summary.total_transaksi}
              </p>
            </div>

            <div className="bg-violet-700 text-white p-4 sm:p-6 rounded-lg shadow-lg">
              <h3 className="font-semibold text-base sm:text-lg">
                Total Penjualan
              </h3>
              <p className="text-xl sm:text-3xl font-bold mt-2">
                {formatToRupiah(reportData.summary.total_pendapatan)}
              </p>
            </div>
          </div>

          <div className="bg-white rounded-lg shadow p-3 sm:p-6 mb-4 sm:mb-6">
            <h3 className="text-lg sm:text-xl font-semibold mb-4">
              Grafik Penjualan Bulanan
            </h3>
            <div className="h-48 sm:h-96">
              <ResponsiveContainer width="100%" height="100%">
                <BarChart
                  data={chartData}
                  margin={{ top: 8, right: 8, left: -20, bottom: 8 }}
                >
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="bulan" tick={{ fontSize: 12 }} />
                  <YAxis
                    tickFormatter={(v) => v.toLocaleString("id-ID")}
                    tick={{ fontSize: 12 }}
                  />
                  <Tooltip
                    formatter={(value) =>
                      `Rp${Number(value).toLocaleString("id-ID")}`
                    }
                    contentStyle={{ fontSize: 12 }}
                  />
                  <Bar dataKey="pendapatan" fill="#7c3aed" />
                </BarChart>
              </ResponsiveContainer>
            </div>
          </div>

          <div className="bg-white rounded-lg shadow p-3 sm:p-6">
            <h3 className="text-lg sm:text-xl font-semibold mb-4">
              Detail Bulanan
            </h3>
            <div className="overflow-x-auto">
              <table className="w-full text-sm sm:text-base">
                <thead className="bg-violet-800 text-white">
                  <tr>
                    <th className="px-2 sm:px-4 py-3 text-left">Bulan</th>
                    <th className="px-2 sm:px-4 py-3 text-right">
                      Jumlah Transaksi
                    </th>
                    <th className="px-2 sm:px-4 py-3 text-right">Penjualan</th>
                  </tr>
                </thead>
                <tbody>
                  {reportData.monthly.map((item, index) => (
                    <tr
                      key={index}
                      className={index % 2 === 0 ? "bg-gray-50" : "bg-white"}
                    >
                      <td className="px-2 sm:px-4 py-3">
                        {monthNames[item.bulan - 1]} {selectedYear}
                      </td>
                      <td className="px-2 sm:px-4 py-3 text-right">
                        {Number(item.total_transaksi || 0).toLocaleString(
                          "id-ID",
                        )}
                      </td>
                      <td className="px-2 sm:px-4 py-3 text-right font-semibold">
                        {formatToRupiah(item.pendapatan_bulanan)}
                      </td>
                    </tr>
                  ))}
                </tbody>
                <tfoot className="bg-violet-700 text-white font-bold">
                  <tr>
                    <td className="px-2 sm:px-4 py-3">Total</td>
                    <td className="px-2 sm:px-4 py-3 text-right">
                      {Number(
                        reportData.summary.total_transaksi || 0,
                      ).toLocaleString("id-ID")}
                    </td>
                    <td className="px-2 sm:px-4 py-3 text-right">
                      {formatToRupiah(reportData.summary.total_pendapatan)}
                    </td>
                  </tr>
                </tfoot>
              </table>
            </div>
          </div>
        </>
      ) : (
        <div className="text-center py-20">
          <p className="text-gray-500 text-sm sm:text-base">
            Tidak ada data tersedia
          </p>
        </div>
      )}
    </div>
  );
}
