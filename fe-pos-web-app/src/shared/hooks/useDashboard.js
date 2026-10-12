import { useState } from "react";
import Swal from "sweetalert2";
import {
  getDashboardStatsAdmin,
  getDashboardStatsOwner,
  getDateRangeSalesAdmin,
  getDateRangeSalesOwner,
} from "../services/dashboardService.js";

export function useDashboard({ mode, setDashboardStats, setDateRangeData }) {
  if (!mode) throw new Error("Mode is required in useDashboard hook");

  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const fetchDashboardStats = async () => {
    setError(null);
    try {
      let stats;
      if (mode === "admin") {
        stats = await getDashboardStatsAdmin();
      } else if (mode === "owner") {
        stats = await getDashboardStatsOwner();
      }

      if (setDashboardStats) setDashboardStats(stats);
      return stats;
    } catch (err) {
      setError(err.message);
      Swal.fire("Error", "Gagal memuat data dashboard", "error");
      console.error("Dashboard stats error:", err);
      return null;
    }
  };

  const fetchDateRangeSales = async (startDate, endDate) => {
    setError(null);
    try {
      let res;
      if (mode === "admin") {
        res = await getDateRangeSalesAdmin(startDate, endDate);
      } else if (mode === "owner") {
        res = await getDateRangeSalesOwner(startDate, endDate);
      }

      const data = res.data?.data || [];

      // Format data for chart
      const formatted = data.map((d) => {
        if (mode === "owner") {
          return {
            day: new Date(d.date_iso + "T00:00:00").toLocaleDateString(
              "id-ID",
              {
                day: "2-digit",
                month: "short",
              },
            ),
            total: d.total_harian,
          };
        } else {
          // Admin format
          return {
            day: d.day || d.date_iso,
            total: d.total || d.total_harian,
          };
        }
      });

      if (setDateRangeData) setDateRangeData(formatted);
      return formatted;
    } catch (err) {
      setError(err.message);
      console.error("Date range sales error:", err);
      return [];
    }
  };

  const fetchAllDashboardData = async (startDate, endDate) => {
    setLoading(true);
    try {
      await Promise.all([
        fetchDashboardStats(),
        fetchDateRangeSales(startDate, endDate),
      ]);
    } catch (err) {
      console.error("Error fetching all dashboard data:", err);
    } finally {
      setLoading(false);
    }
  };

  return {
    fetchDashboardStats,
    fetchDateRangeSales,
    fetchAllDashboardData,
    loading,
    error,
  };
}