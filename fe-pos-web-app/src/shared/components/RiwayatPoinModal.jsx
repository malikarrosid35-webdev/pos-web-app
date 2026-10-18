import { useEffect, useState } from "react";
import { ChevronLeft, ChevronRight, X } from "lucide-react";
import {
  getRiwayatPoinKasir,
  getRiwayatPoinOwner,
} from "../services/pelangganService.js";

const LIMIT = 10;

const THEMES = {
  owner: {
    header: "bg-violet-800 text-white",
    saldo: "bg-violet-700 text-white",
    closeHover: "hover:bg-violet-600",
  },
  kasir: {
    header: "bg-green-800 text-white",
    saldo: "bg-yellow-700 text-white",
    closeHover: "hover:bg-green-700",
  },
};

const JENIS = {
  saldo_awal: { label: "Saldo awal", badge: "bg-gray-100 text-gray-700" },
  transaksi: { label: "Transaksi", badge: "bg-blue-100 text-blue-700" },
  penyesuaian: {
    label: "Penyesuaian owner",
    badge: "bg-amber-100 text-amber-800",
  },
  pembatalan_transaksi: {
    label: "Pembatalan transaksi",
    badge: "bg-red-100 text-red-700",
  },
};

const PERAN = { owner: "Owner", kasir: "Kasir", admin: "Admin" };

const formatTanggal = (value) =>
  new Date(value).toLocaleString("id-ID", {
    day: "2-digit",
    month: "short",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });

const formatPerubahan = (n) => (n > 0 ? `+${n}` : `${n}`);

const warnaPerubahan = (n) =>
  n > 0 ? "text-green-700" : n < 0 ? "text-red-600" : "text-gray-500";

const rupiah = (n) => `Rp${Number(n || 0).toLocaleString("id-ID")}`;

function RingkasanItem({ label, value }) {
  return (
    <div className="bg-gray-50 border rounded-lg p-3">
      <p className="text-xs text-gray-500">{label}</p>
      <p className={`text-lg font-bold ${warnaPerubahan(value)}`}>
        {formatPerubahan(value)}
      </p>
    </div>
  );
}

export default function RiwayatPoinModal({
  pelanggan,
  mode = "kasir",
  onClose,
}) {
  const theme = THEMES[mode] || THEMES.kasir;
  const [page, setPage] = useState(1);
  const [state, setState] = useState({
    loading: true,
    error: null,
    data: null,
    meta: null,
  });

  useEffect(() => {
    let ignore = false;
    const request =
      mode === "owner" ? getRiwayatPoinOwner : getRiwayatPoinKasir;

    setState((s) => ({ ...s, loading: true, error: null }));

    request(pelanggan.id_pelanggan, { page, limit: LIMIT })
      .then((res) => {
        if (ignore) return;
        setState({
          loading: false,
          error: null,
          data: res.data?.data || null,
          meta: res.data?.meta || null,
        });
      })
      .catch((err) => {
        if (ignore) return;
        setState((s) => ({
          ...s,
          loading: false,
          error:
            err.response?.data?.message ||
            err.message ||
            "Gagal memuat riwayat poin",
        }));
      });

    return () => {
      ignore = true;
    };
  }, [mode, pelanggan.id_pelanggan, page]);

  const { loading, error, data, meta } = state;
  const ringkasan = data?.ringkasan;
  const riwayat = data?.riwayat || [];
  const totalPage = meta?.total_page || 0;

  return (
    // Mobile: sheet dari bawah (items-end) | Tablet+: modal di tengah (items-center)
    <div className="fixed inset-0 bg-black/40 flex items-end sm:items-center justify-center z-50 p-0 sm:p-4">
      <div className="bg-white w-full sm:max-w-2xl sm:rounded-xl rounded-t-2xl shadow-xl overflow-hidden flex flex-col max-h-[90vh]">
        <div
          className={`flex items-center justify-between px-5 py-4 ${theme.header}`}
        >
          <div className="min-w-0">
            <h3 className="text-lg font-semibold">Riwayat Poin</h3>
            <p className="text-sm opacity-90 truncate">
              {pelanggan.nama_pelanggan}
            </p>
          </div>
          <button
            type="button"
            onClick={onClose}
            className={`p-1 rounded-full cursor-pointer ${theme.closeHover}`}
            aria-label="Tutup"
          >
            <X size={20} />
          </button>
        </div>

        <div className="overflow-y-auto flex-1">
          {loading && !data ? (
            <p className="text-center text-gray-600 py-12 text-sm">
              Memuat riwayat poin...
            </p>
          ) : error && !data ? (
            <p className="text-center text-red-600 py-12 text-sm px-4">
              {error}
            </p>
          ) : (
            <>
              <div className="grid grid-cols-2 sm:grid-cols-3 gap-2 p-4">
                <div className={`${theme.saldo} rounded-lg p-3`}>
                  <p className="text-xs opacity-90">Saldo saat ini</p>
                  <p className="text-lg font-bold">
                    {data?.pelanggan?.poin_loyalitas ?? 0} poin
                  </p>
                </div>
                <RingkasanItem
                  label="Saldo awal"
                  value={ringkasan?.saldo_awal ?? 0}
                />
                <RingkasanItem
                  label="Dari transaksi"
                  value={ringkasan?.total_transaksi ?? 0}
                />
                <RingkasanItem
                  label="Penambahan manual"
                  value={ringkasan?.total_penambahan ?? 0}
                />
                <RingkasanItem
                  label="Pengurangan manual"
                  value={ringkasan?.total_pengurangan ?? 0}
                />
                <RingkasanItem
                  label="Pembatalan transaksi"
                  value={ringkasan?.total_pembatalan ?? 0}
                />
              </div>

              {error && (
                <p className="text-center text-red-600 text-sm px-4 pb-2">
                  {error}
                </p>
              )}

              {riwayat.length === 0 ? (
                <p className="text-center text-gray-500 py-8 text-sm">
                  Belum ada riwayat poin.
                </p>
              ) : (
                <ul
                  className={`divide-y border-t ${loading ? "opacity-50" : ""}`}
                >
                  {riwayat.map((r) => {
                    const jenis = JENIS[r.jenis] || {
                      label: r.jenis,
                      badge: "bg-gray-100 text-gray-700",
                    };
                    return (
                      <li
                        key={r.id_riwayat_poin}
                        className="px-4 py-3 flex items-start justify-between gap-3"
                      >
                        <div className="min-w-0 space-y-1">
                          <div className="flex flex-wrap items-center gap-2">
                            <span
                              className={`text-xs font-semibold px-2 py-0.5 rounded-full ${jenis.badge}`}
                            >
                              {jenis.label}
                            </span>
                            <span className="text-xs text-gray-500">
                              {formatTanggal(r.created_at)}
                            </span>
                          </div>
                          {r.alasan && r.jenis !== "transaksi" && (
                            <p className="text-sm text-gray-800 break-words">
                              {r.alasan}
                            </p>
                          )}
                          {r.kode_transaksi && (
                            <p className="text-xs text-gray-600">
                              {r.kode_transaksi} · {rupiah(r.total_harga)}
                            </p>
                          )}
                          {r.nama_user && (
                            <p className="text-xs text-gray-500">
                              Oleh {r.nama_user} (
                              {PERAN[r.role_user] || r.role_user})
                            </p>
                          )}
                        </div>
                        <div className="text-right shrink-0">
                          <p
                            className={`text-lg font-bold ${warnaPerubahan(r.perubahan_poin)}`}
                          >
                            {formatPerubahan(r.perubahan_poin)}
                          </p>
                          <p className="text-xs text-gray-500">
                            {r.poin_sebelum} → {r.poin_sesudah}
                          </p>
                        </div>
                      </li>
                    );
                  })}
                </ul>
              )}
            </>
          )}
        </div>

        {totalPage > 1 && (
          <div className="flex items-center justify-between gap-2 px-4 py-3 border-t">
            <button
              type="button"
              onClick={() => setPage((p) => Math.max(1, p - 1))}
              disabled={page <= 1 || loading}
              className="p-2 border rounded hover:bg-gray-100 disabled:opacity-50 disabled:cursor-not-allowed cursor-pointer"
              aria-label="Halaman sebelumnya"
            >
              <ChevronLeft size={18} />
            </button>
            <span className="text-sm text-gray-600">
              Halaman {page} dari {totalPage}
            </span>
            <button
              type="button"
              onClick={() => setPage((p) => Math.min(totalPage, p + 1))}
              disabled={page >= totalPage || loading}
              className="p-2 border rounded hover:bg-gray-100 disabled:opacity-50 disabled:cursor-not-allowed cursor-pointer"
              aria-label="Halaman berikutnya"
            >
              <ChevronRight size={18} />
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
