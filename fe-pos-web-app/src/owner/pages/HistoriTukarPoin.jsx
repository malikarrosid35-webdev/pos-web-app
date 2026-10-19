import { useEffect, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import { ArrowLeft, ChevronLeft, ChevronRight } from "lucide-react";
import Swal from "sweetalert2";
import { getHistoriTukarPoinOwner } from "../../shared/services/historiTukarPoinService.js";
import { getPelangganByIdOwner } from "../../shared/services/pelangganService.js";
import { useUIStore } from "../../stores/useUIStore.js";

const LIMIT = 10;

export default function HistoriTukarPoin() {
  const { id_pelanggan } = useParams();
  const navigate = useNavigate();
  const { setActiveTab } = useUIStore();
  const [pelanggan, setPelanggan] = useState(null);
  const [histori, setHistori] = useState([]);
  const [loading, setLoading] = useState(true);
  const [currentPage, setCurrentPage] = useState(1);
  const [meta, setMeta] = useState({ total_page: 0, total_data: 0 });

  useEffect(() => {
    setActiveTab("Daftar Pelanggan");
  }, [setActiveTab]);

  useEffect(() => {
    let isCurrent = true;
    setLoading(true);

    Promise.all([
      getPelangganByIdOwner(id_pelanggan),
      getHistoriTukarPoinOwner({
        id_pelanggan,
        page: currentPage,
        limit: LIMIT,
      }),
    ])
      .then(([pelangganResponse, historiResponse]) => {
        if (!isCurrent) return;
        setPelanggan(pelangganResponse.data.data);
        setHistori(historiResponse.data.data || []);
        setMeta(historiResponse.data.meta || { total_page: 0, total_data: 0 });
      })
      .catch((error) => {
        if (!isCurrent) return;
        const message =
          error.response?.data?.message || "Gagal memuat histori tukar poin";
        Swal.fire("Error", message, "error");
      })
      .finally(() => {
        if (isCurrent) setLoading(false);
      });

    return () => {
      isCurrent = false;
    };
  }, [id_pelanggan, currentPage]);

  const formatDate = (dateString) =>
    new Date(dateString).toLocaleString("id-ID", {
      day: "2-digit",
      month: "long",
      year: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    });

  return (
    <div className="flex-1 p-3 sm:p-6 bg-gray-50 min-h-screen">
      <div className="max-w-5xl mx-auto">
        <button
          type="button"
          onClick={() => navigate("/owner/daftar-pelanggan")}
          className="mb-4 flex items-center gap-2 rounded bg-violet-700 px-4 py-2 text-sm text-white hover:bg-violet-800 cursor-pointer"
        >
          <ArrowLeft size={16} />
          Kembali ke Daftar Pelanggan
        </button>

        <div className="mb-4 sm:mb-6">
          <h1 className="text-2xl sm:text-3xl font-bold text-gray-800">
            Histori Tukar Poin
          </h1>
          {pelanggan && (
            <p className="mt-1 text-gray-600">
              Nama Pelanggan:{" "}
              <span className="font-semibold">{pelanggan.nama_pelanggan}</span>
            </p>
          )}
        </div>

        {loading ? (
          <div className="flex items-center justify-center py-20">
            <p className="text-lg text-gray-600">Memuat histori...</p>
          </div>
        ) : (
          <>
            <div className="overflow-x-auto rounded-lg bg-white shadow">
              <table className="min-w-full divide-y divide-gray-200 text-sm">
                <thead className="bg-violet-800 text-white">
                  <tr>
                    <th className="px-4 py-3 text-left font-bold">Tanggal Tukar</th>
                    <th className="px-4 py-3 text-left font-bold">Pelanggan</th>
                    <th className="px-4 py-3 text-left font-bold">Hadiah</th>
                    <th className="px-4 py-3 text-right font-bold">Harga (Poin)</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-200">
                  {histori.length === 0 ? (
                    <tr>
                      <td colSpan="4" className="px-4 py-6 text-center text-gray-500">
                        Belum ada histori penukaran poin.
                      </td>
                    </tr>
                  ) : (
                    histori.map((item) => (
                      <tr key={item.id_histori_tukar} className="hover:bg-gray-50">
                        <td className="px-4 py-3 text-gray-700">
                          {formatDate(item.created_at)}
                        </td>
                        <td className="px-4 py-3 text-gray-700">
                          {item.nama_pelanggan || pelanggan?.nama_pelanggan}
                        </td>
                        <td className="px-4 py-3 font-medium text-gray-900">
                          {item.hadiah}
                        </td>
                        <td className="px-4 py-3 text-right text-gray-700">
                          {Number(item.harga_hadiah).toLocaleString("id-ID")}
                        </td>
                      </tr>
                    ))
                  )}
                </tbody>
              </table>
            </div>

            {meta.total_page > 1 && (
              <div className="mt-6 flex items-center justify-between">
                <span className="text-sm text-gray-500">
                  {meta.total_data} histori penukaran
                </span>
                <div className="flex items-center gap-2">
                  <button
                    type="button"
                    onClick={() => setCurrentPage((page) => page - 1)}
                    disabled={currentPage <= 1}
                    aria-label="Halaman sebelumnya"
                    className="rounded border p-2 hover:bg-gray-100 disabled:opacity-50"
                  >
                    <ChevronLeft size={18} />
                  </button>
                  <span className="text-sm">
                    {currentPage} / {meta.total_page}
                  </span>
                  <button
                    type="button"
                    onClick={() => setCurrentPage((page) => page + 1)}
                    disabled={currentPage >= meta.total_page}
                    aria-label="Halaman berikutnya"
                    className="rounded border p-2 hover:bg-gray-100 disabled:opacity-50"
                  >
                    <ChevronRight size={18} />
                  </button>
                </div>
              </div>
            )}
          </>
        )}
      </div>
    </div>
  );
}
