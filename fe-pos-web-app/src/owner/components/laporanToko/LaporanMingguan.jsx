import { useEffect, useState } from "react";
import ownerClient from "../../../lib/http/ownerClient.js";
import { formatToRupiah } from "../../../shared/utils/numberFormat.js";
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  Tooltip,
  CartesianGrid,
  ResponsiveContainer,
} from "recharts";

export default function LaporanMingguan() {
  const [weeklyData, setWeeklyData] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchReport = async () => {
      try {
        const res = await ownerClient.get("/reports/weekly");
        const mapped = res.data.data.map((d) => ({
          day: new Date(d.date_iso + "T00:00:00").toLocaleDateString("id-ID", {
            day: "2-digit",
            month: "short",
          }),
          date: d.date_iso,
          total: Number(d.total_harian || 0),
          totalTransaksi: Number(d.total_transaksi_harian || 0),
        }));
        setWeeklyData(mapped);
      } catch (error) {
        console.error("Error fetching weekly report:", error);
      } finally {
        setLoading(false);
      }
    };

    fetchReport();
  }, []);

  const totalPendapatan = weeklyData.reduce((sum, item) => sum + item.total, 0);
  const totalTransaksi = weeklyData.reduce(
    (sum, item) => sum + item.totalTransaksi,
    0,
  );

  if (loading) {
    return (
      <div className="p-3 sm:p-6 bg-gray-50 min-h-screen">
        <div className="flex items-center justify-center min-h-screen">
          <p className="text-lg sm:text-xl">Memuat data...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="p-3 sm:p-6 bg-gray-50 min-h-screen">
      <div className="mb-4 sm:mb-6">
        <h1 className="text-xl sm:text-3xl font-bold text-gray-800">
          Laporan Mingguan
        </h1>
        <p className="text-sm sm:text-base text-gray-600 mt-2">
          Ringkasan transaksi 7 hari terakhir
        </p>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 sm:gap-6 mb-4 sm:mb-6">
        <div className="bg-violet-700 text-white p-4 sm:p-6 rounded-lg shadow-lg">
          <h3 className="font-semibold text-base sm:text-lg">
            Total Penjualan (7 Hari)
          </h3>
          <p className="text-2xl sm:text-4xl font-bold mt-2">
            {formatToRupiah(totalPendapatan)}
          </p>
        </div>
        <div className="bg-violet-700 text-white p-4 sm:p-6 rounded-lg shadow-lg">
          <h3 className="font-semibold text-base sm:text-lg">
            Total Transaksi (7 Hari)
          </h3>
          <p className="text-2xl sm:text-4xl font-bold mt-2">
            {totalTransaksi.toLocaleString("id-ID")}
          </p>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow p-3 sm:p-6 mb-4 sm:mb-6">
        <h3 className="text-lg sm:text-xl font-semibold mb-4">
          Grafik Penjualan Mingguan
        </h3>
        <div className="h-48 sm:h-96">
          <ResponsiveContainer width="100%" height="100%">
            <LineChart
              data={weeklyData}
              margin={{ top: 8, right: 8, left: -20, bottom: 8 }}
            >
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="day" tick={{ fontSize: 12 }} />
              <YAxis
                tickFormatter={(v) => v.toLocaleString("id-ID")}
                tick={{ fontSize: 12 }}
              />
              <Tooltip
                formatter={(value) =>
                  `Rp${Number(value).toLocaleString("id-ID")}`
                }
                labelFormatter={(l) => `Tanggal: ${l}`}
                contentStyle={{ fontSize: 12 }}
              />
              <Line
                type="monotone"
                dataKey="total"
                stroke="#7c3aed"
                strokeWidth={2}
                dot
              />
            </LineChart>
          </ResponsiveContainer>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow p-3 sm:p-6">
        <h3 className="text-lg sm:text-xl font-semibold mb-4">Detail Harian</h3>
        <div className="overflow-x-auto">
          <table className="w-full text-sm sm:text-base">
            <thead className="bg-violet-800 text-white">
              <tr>
                <th className="px-2 sm:px-4 py-3 text-left">Tanggal</th>
                <th className="px-2 sm:px-4 py-3 text-right">
                  Jumlah Transaksi
                </th>
                <th className="px-2 sm:px-4 py-3 text-right">Penjualan</th>
              </tr>
            </thead>
            <tbody>
              {weeklyData.map((item, index) => (
                <tr
                  key={index}
                  className={index % 2 === 0 ? "bg-gray-50" : "bg-white"}
                >
                  <td className="px-2 sm:px-4 py-3">{item.date}</td>
                  <td className="px-2 sm:px-4 py-3 text-right">
                    {item.totalTransaksi.toLocaleString("id-ID")}
                  </td>
                  <td className="px-2 sm:px-4 py-3 text-right font-semibold">
                    {formatToRupiah(item.total)}
                  </td>
                </tr>
              ))}
            </tbody>
            <tfoot className="bg-violet-700 text-white font-bold">
              <tr>
                <td className="px-2 sm:px-4 py-3">Total</td>
                <td className="px-2 sm:px-4 py-3 text-right">
                  {totalTransaksi.toLocaleString("id-ID")}
                </td>
                <td className="px-2 sm:px-4 py-3 text-right">
                  {formatToRupiah(totalPendapatan)}
                </td>
              </tr>
            </tfoot>
          </table>
        </div>
      </div>
    </div>
  );
}
