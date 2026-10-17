import { useEffect, useState, useMemo } from "react";
import { useNavigate } from "react-router-dom";
import Swal from "sweetalert2";
import { useUIStore } from "../../stores/useUIStore.js";
import { usePelanggan } from "../../shared/hooks/usePelanggan.js";
import { usePelangganStore } from "../../stores/usePelangganStore.js";
import { useBarang } from "../../shared/hooks/useBarang.js";
import { useTransaksiStore } from "../../stores/useTransaksiStore.js";
import { useTransaksi } from "../../shared/hooks/useTransaksi.js";
import {
  formatToRupiah,
  formatNumber,
  parseNumber,
} from "../../shared/utils/numberFormat.js";
import { formatQty } from "../../shared/utils/qtyFormat.js";
import { roundKasirGramSubtotal } from "../../shared/utils/subTotalPriceHelper.js";
import {
  Trash2,
  UserCheck,
  ShoppingBag,
  CreditCard,
  CheckCircle,
} from "lucide-react";

const toGrams = (qty, unit) => {
  const q = Number(qty) || 0;
  const u = (unit || "GRAM").toUpperCase();
  if (u === "GRAM") return q;
  if (u === "ONS") return q * 100;
  if (u === "KG") return q * 1000;
  return q;
};

const MAX_BAYAR = 500000;

export const TransaksiFormPage = () => {
  const navigate = useNavigate();
  const { setActiveTab } = useUIStore();

  // State Pelanggan
  const { pelanggan, setPelanggan } = usePelangganStore();
  const { pelangganTerpilih, setPelangganTerpilih } = useTransaksiStore();
  const [custSearch, setCustSearch] = useState("");
  const [pelangganStep, setPelangganStep] = useState("idle");
  const {
    fetchPelanggan,
    search: searchPelanggan,
    loading: loadingPelanggan,
  } = usePelanggan({ searchQuery: custSearch, setPelanggan, mode: "kasir" });

  // State Barang
  const {
    fetchBarang,
    groupedProducts,
    loading: loadingBarang,
  } = useBarang({ mode: "kasir" });

  const allProducts = useMemo(() => {
    return Object.values(groupedProducts).flat();
  }, [groupedProducts]);

  // ── Form state untuk satu item ─────────────────────────
  const [selectedProductId, setSelectedProductId] = useState("");
  const [qtyInput, setQtyInput] = useState("");
  const [unitInput, setUnitInput] = useState("GRAM");
  const [productSearch, setProductSearch] = useState("");

  // ── Daftar item yang sudah ditambahkan ─────────────────
  const [items, setItems] = useState([]);

  // ── Pembayaran ─────────────────────────────────────────
  const [bayarInput, setBayarInput] = useState("");
  const [isProcessing, setIsProcessing] = useState(false);
  const [successData, setSuccessData] = useState(null);

  const { addTransaksi } = useTransaksi({ mode: "kasir" });

  // ── Computed ───────────────────────────────────────────
  const selectedProduct = allProducts.find((p) => p.id === selectedProductId);
  const isGram = selectedProduct
    ? (
        selectedProduct.satuan_dasar ||
        selectedProduct.satuan ||
        ""
      ).toUpperCase() === "GRAM"
    : false;

  const totalHarga = useMemo(
    () => items.reduce((sum, it) => sum + it.subtotal, 0),
    [items],
  );

  const bayar = useMemo(
    () => (bayarInput ? parseNumber(bayarInput) : 0),
    [bayarInput],
  );
  const kembalian = useMemo(
    () => Math.max(bayar - totalHarga, 0),
    [bayar, totalHarga],
  );
  const kurangBayar = bayar < totalHarga && bayarInput !== "";

  const filteredProducts = useMemo(() => {
    if (!productSearch.trim()) return allProducts;
    return allProducts.filter((p) =>
      p.name.toLowerCase().includes(productSearch.toLowerCase()),
    );
  }, [allProducts, productSearch]);

  // ── Init ───────────────────────────────────────────────
  useEffect(() => {
    setActiveTab("Buat Transaksi");
    fetchBarang();
    fetchPelanggan();
  }, []);

  useEffect(() => {
    if (isGram) setUnitInput("GRAM");
    else setUnitInput("PCS");
    setQtyInput("");
  }, [selectedProductId]);

  useEffect(() => {
    if (!custSearch.trim()) {
      fetchPelanggan();
    } else {
      searchPelanggan();
    }
  }, [custSearch]);

  // ── Handler: Pilih Member ──────────────────────────────
  const handlePilihMember = (pelangganObj) => {
    setPelangganTerpilih(pelangganObj);
    setPelangganStep("member_selected");
  };

  // ── Handler: Pilih Guest ───────────────────────────────
  const handlePilihGuest = () => {
    setPelangganTerpilih(null);
    setPelangganStep("guest");
  };

  // ── Handler: Ganti Pelanggan ───────────────────────────
  const handleGantiPelanggan = () => {
    setPelangganTerpilih(undefined);
    setPelangganStep("idle");
    setItems([]);
    setBayarInput("");
  };

  // ── Handler: Tambah item ke daftar ────────────────────
  const handleTambahItem = () => {
    if (!selectedProduct) {
      return Swal.fire("Peringatan", "Pilih barang terlebih dahulu", "warning");
    }
    const qtyNum = Number(qtyInput);
    if (!qtyNum || qtyNum <= 0) {
      return Swal.fire("Peringatan", "Masukkan jumlah yang valid", "warning");
    }

    const qtyDasar = isGram ? toGrams(qtyNum, unitInput) : qtyNum;

    const stokTersedia = Number(
      selectedProduct.stock ?? selectedProduct.stok_dasar ?? 0,
    );
    const alreadyInList = items
      .filter((it) => it.id === selectedProduct.id)
      .reduce((sum, it) => sum + it.qty_dasar, 0);
    if (stokTersedia > 0 && alreadyInList + qtyDasar > stokTersedia) {
      return Swal.fire(
        "Stok Tidak Cukup",
        `Stok tersedia: ${formatQty(stokTersedia - alreadyInList, isGram ? "GRAM" : "PCS")}`,
        "warning",
      );
    }

    const price = Number(
      selectedProduct.price ?? selectedProduct.harga_jual_per_sd ?? 0,
    );
    const rawSubtotal = price * qtyDasar;
    const subtotal = isGram ? roundKasirGramSubtotal(rawSubtotal) : rawSubtotal;

    const existingIdx = items.findIndex(
      (it) =>
        it.id === selectedProduct.id &&
        it.unit === (isGram ? unitInput : "PCS"),
    );
    if (existingIdx >= 0) {
      const updated = [...items];
      const existing = updated[existingIdx];
      const newQtyDasar = existing.qty_dasar + qtyDasar;
      const newRaw = price * newQtyDasar;
      const newSubtotal = isGram ? roundKasirGramSubtotal(newRaw) : newRaw;
      updated[existingIdx] = {
        ...existing,
        qty_dasar: newQtyDasar,
        qty_display: isGram
          ? unitInput === "KG"
            ? newQtyDasar / 1000
            : unitInput === "ONS"
              ? newQtyDasar / 100
              : newQtyDasar
          : newQtyDasar,
        subtotal: newSubtotal,
      };
      setItems(updated);
    } else {
      setItems([
        ...items,
        {
          id: selectedProduct.id,
          name: selectedProduct.name,
          satuan_dasar: (
            selectedProduct.satuan_dasar ||
            selectedProduct.satuan ||
            "PCS"
          ).toUpperCase(),
          price,
          qty_dasar: qtyDasar,
          qty_display: qtyNum,
          unit: isGram ? unitInput : "PCS",
          subtotal,
        },
      ]);
    }

    setSelectedProductId("");
    setQtyInput("");
    setProductSearch("");
  };

  // ── Handler: Hapus item ────────────────────────────────
  const handleHapusItem = (idx) => {
    setItems(items.filter((_, i) => i !== idx));
  };

  // ── Handler: Input bayar ───────────────────────────────
  const handleChangeBayar = (e) => {
    const raw = e.target.value.replace(/[^\d]/g, "");
    const numValue = Number(raw) || 0;
    if (numValue > MAX_BAYAR) {
      setBayarInput(formatNumber(MAX_BAYAR));
      return;
    }
    setBayarInput(raw.replace(/\B(?=(\d{3})+(?!\d))/g, "."));
  };

  const setBayarPas = () => setBayarInput(formatNumber(totalHarga));
  const tambahIncrement = (inc) => {
    const next = Math.min(bayar + inc, MAX_BAYAR);
    setBayarInput(formatNumber(next));
  };

  // ── Handler: Submit transaksi ──────────────────────────
  const handleBuatTransaksi = async () => {
    if (items.length === 0) {
      return Swal.fire("Peringatan", "Tambahkan minimal 1 barang", "warning");
    }
    if (!bayarInput || bayar <= 0) {
      return Swal.fire("Peringatan", "Masukkan jumlah bayar", "warning");
    }
    if (kurangBayar) {
      return Swal.fire(
        "Peringatan",
        "Jumlah bayar kurang dari total harga",
        "warning",
      );
    }

    const tipePelanggan = pelangganTerpilih ? "member" : "guest";
    const payload = {
      tipe_pelanggan: tipePelanggan,
      id_pelanggan:
        tipePelanggan === "member" ? pelangganTerpilih?.id_pelanggan : null,
      id_user: null,
      jumlah_bayar: bayar,
      items: items.map((it) => ({
        id_barang: it.id,
        quantity: it.qty_dasar,
        subtotal: it.subtotal,
      })),
    };

    try {
      setIsProcessing(true);
      await addTransaksi(payload);
      setSuccessData({
        total: totalHarga,
        kembalian,
        jumlahBayar: bayar,
        namaPelanggan: pelangganTerpilih
          ? pelangganTerpilih.nama_pelanggan
          : "Guest",
        tipePelanggan,
      });
      setItems([]);
      setBayarInput("");
    } catch (err) {
      Swal.fire(
        "Transaksi Gagal",
        err.response?.data?.message || "Server error",
        "error",
      );
    } finally {
      setIsProcessing(false);
    }
  };

  // ── Handler: Transaksi Baru ────────────────────────────
  const handleTransaksiBaru = () => {
    setSuccessData(null);
    setPelangganTerpilih(undefined);
    setPelangganStep("idle");
    setItems([]);
    setBayarInput("");
    setCustSearch("");
  };

  // ────────────────────────────────────────────────────────
  // RENDER
  // ────────────────────────────────────────────────────────

  return (
    <div className="container mx-auto p-3 sm:p-6 max-w-3xl">
      <h1 className="text-xl sm:text-2xl font-bold mb-6 text-green-900">
        Buat Transaksi
      </h1>

      {/* ── SECTION 1: Pilih Pelanggan ── */}
      <div className="bg-white rounded-xl shadow-sm border p-4 sm:p-6 mb-4">
        <div className="flex items-center gap-2 mb-4">
          <UserCheck size={20} className="text-green-700" />
          <h2 className="text-base font-semibold">1. Pilih Pelanggan</h2>
        </div>

        {pelangganStep === "member_selected" ? (
          <div className="flex items-center justify-between bg-green-50 border border-green-200 rounded-lg px-4 py-3">
            <div>
              <p className="font-semibold text-green-800">
                {pelangganTerpilih.nama_pelanggan}
              </p>
              <p className="text-xs text-green-600">
                {pelangganTerpilih.no_hp || "Tidak ada nomor HP"}
              </p>
            </div>
            <button
              onClick={handleGantiPelanggan}
              className="text-sm text-green-700 underline hover:text-green-900 cursor-pointer"
            >
              Ganti
            </button>
          </div>
        ) : pelangganStep === "guest" ? (
          <div className="flex items-center justify-between bg-gray-50 border border-gray-200 rounded-lg px-4 py-3">
            <div>
              <p className="font-semibold text-gray-700">Guest</p>
              <p className="text-xs text-gray-400">Transaksi tanpa member</p>
            </div>
            <button
              onClick={handleGantiPelanggan}
              className="text-sm text-gray-600 underline hover:text-gray-800 cursor-pointer"
            >
              Ganti
            </button>
          </div>
        ) : (
          <div>
            <div className="flex gap-2 mb-3">
              <input
                type="text"
                placeholder="Cari nama / nomor HP pelanggan..."
                className="flex-1 px-3 py-2 border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-green-400"
                value={custSearch}
                onChange={(e) => setCustSearch(e.target.value)}
                onKeyDown={(e) => {
                  if (e.key === "Enter") {
                    e.preventDefault();
                  }
                }}
              />
              <button
                className="bg-green-700 text-white px-4 py-2 rounded-lg text-sm hover:bg-green-800 cursor-pointer"
                onClick={() => {
                  if (custSearch.trim()) {
                    searchPelanggan();
                  } else {
                    fetchPelanggan();
                  }
                }}
              >
                Cari
              </button>
            </div>

            <div className="mb-3">
              <button
                onClick={handlePilihGuest}
                className="text-sm text-gray-700 border border-dashed border-gray-300 px-4 py-2 rounded-lg hover:bg-gray-400 hover:text-white cursor-pointer w-full"
              >
                Lanjut sebagai Guest (tanpa member)
              </button>
            </div>

            {loadingPelanggan ? (
              <p className="text-sm text-gray-500 py-2">Memuat pelanggan...</p>
            ) : (
              <div className="max-h-48 overflow-y-auto space-y-2">
                {pelanggan.map((c) => (
                  <div
                    key={c.id_pelanggan}
                    className="flex items-center justify-between border rounded-lg px-3 py-2.5"
                  >
                    <div>
                      <p className="font-semibold text-sm">
                        {c.nama_pelanggan}
                      </p>
                      <p className="text-xs text-gray-500">{c.no_hp || "-"}</p>
                    </div>
                    <button
                      onClick={() => handlePilihMember(c)}
                      className="bg-green-700 text-white px-3 py-1 rounded text-sm hover:bg-green-800 cursor-pointer"
                    >
                      Pilih
                    </button>
                  </div>
                ))}
                {pelanggan.length === 0 && (
                  <p className="text-sm text-gray-400 text-center py-3">
                    Pelanggan tidak ditemukan
                  </p>
                )}
              </div>
            )}
          </div>
        )}
      </div>

      {/* ── SECTION 2: Pilih Barang (tampil setelah pelanggan dipilih) ── */}
      {pelangganStep !== "idle" && (
        <div className="bg-white rounded-xl shadow-sm border p-4 sm:p-6 mb-4">
          <div className="flex items-center gap-2 mb-4">
            <ShoppingBag size={20} className="text-green-700" />
            <h2 className="text-base font-semibold">2. Pilih Barang</h2>
          </div>

          {/* Form tambah item */}
          <div className="grid grid-cols-1 sm:grid-cols-[1fr_auto_auto_auto] gap-2 mb-4 items-end">
            {/* Cari & Pilih Barang */}
            <div className="relative">
              <label className="block text-xs font-medium text-gray-600 mb-1">
                Barang
              </label>
              <input
                type="text"
                placeholder="Ketik nama barang..."
                className="w-full px-3 py-2 border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-green-400 mb-1"
                value={productSearch}
                onChange={(e) => {
                  setProductSearch(e.target.value);
                  setSelectedProductId("");
                }}
              />
              {productSearch && !selectedProductId && (
                <div className="border rounded-lg max-h-40 overflow-y-auto shadow-lg absolute z-10 bg-white w-full top-full inset-x-0">
                  {filteredProducts.length === 0 ? (
                    <p className="text-sm text-gray-400 px-3 py-2">
                      Tidak ditemukan
                    </p>
                  ) : (
                    filteredProducts.map((p) => (
                      <button
                        key={p.id}
                        onClick={() => {
                          setSelectedProductId(p.id);
                          setProductSearch(p.name);
                        }}
                        className="w-full text-left px-3 py-2 text-sm hover:bg-green-50 border-b last:border-0 cursor-pointer"
                      >
                        <span className="font-medium">{p.name}</span>
                        <span className="text-gray-400 text-xs ml-2">
                          (Stok:{" "}
                          {formatQty(
                            p.stock ?? p.stok_dasar ?? 0,
                            p.satuan_dasar || p.satuan,
                          )}
                          )
                        </span>
                      </button>
                    ))
                  )}
                </div>
              )}
              {!productSearch && (
                <select
                  className="w-full px-3 py-2 border rounded-lg text-sm cursor-pointer focus:outline-none focus:ring-2 focus:ring-green-400"
                  value={selectedProductId}
                  onChange={(e) => setSelectedProductId(e.target.value)}
                >
                  <option value="">-- Pilih barang --</option>
                  {allProducts.map((p) => (
                    <option key={p.id} value={p.id}>
                      {p.name} (Stok:{" "}
                      {formatQty(
                        p.stock ?? 0,
                        p.satuan_dasar || p.satuan,
                      )}
                      )
                    </option>
                  ))}
                </select>
              )}
            </div>

            {/* Input Qty */}
            <div>
              <label className="block text-xs font-medium text-gray-600 mb-1">
                Jumlah
              </label>
              <input
                type="number"
                min="0"
                step={isGram ? "any" : "1"}
                placeholder="Qty"
                className="w-24 px-3 py-2 border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-green-400"
                value={qtyInput}
                onKeyDown={
                  !isGram
                    ? (e) => {
                        if (
                          [".", ",", "e", "E", "+", "-"].includes(e.key)
                        )
                          e.preventDefault();
                      }
                    : undefined
                }
                onChange={(e) => {
                  const val = e.target.value;
                  if (!isGram && val !== "" && val.includes(".")) {
                    setQtyInput(String(Math.floor(Number(val))));
                  } else {
                    setQtyInput(val);
                  }
                }}
              />
            </div>

            {/* Pilih Satuan */}
            <div>
              <label className="block text-xs font-medium text-gray-600 mb-1">
                Satuan
              </label>
              {isGram ? (
                <select
                  className="px-3 py-2 border rounded-lg text-sm cursor-pointer focus:outline-none focus:ring-2 focus:ring-green-400"
                  value={unitInput}
                  onChange={(e) => setUnitInput(e.target.value)}
                >
                  <option value="GRAM">Gram (g)</option>
                  <option value="ONS">Ons (100g)</option>
                  <option value="KG">Kg (1000g)</option>
                </select>
              ) : (
                <div className="px-3 py-2 border rounded-lg text-sm bg-gray-50 text-gray-500">
                  pcs
                </div>
              )}
            </div>

            {/* Tombol Tambah */}
            <div>
              <label className="block text-xs font-medium text-gray-600 mb-1 opacity-0">
                _
              </label>
              <button
                onClick={handleTambahItem}
                disabled={loadingBarang}
                className="bg-green-700 text-white px-4 py-2 rounded-lg text-sm hover:bg-green-800 cursor-pointer disabled:opacity-50 whitespace-nowrap"
              >
                + Tambah
              </button>
            </div>
          </div>

          {/* Info harga produk terpilih */}
          {selectedProduct && (
            <div className="text-xs text-gray-500 mb-4 bg-gray-50 px-3 py-2 rounded">
              Harga:{" "}
              <strong>
                {formatToRupiah(
                  selectedProduct.price ?? selectedProduct.harga_jual_per_sd,
                )}
              </strong>{" "}
              / {isGram ? "gram" : "pcs"}
              &nbsp;·&nbsp; Stok:{" "}
              <strong>
                {formatQty(
                  selectedProduct.stock ?? 0,
                  selectedProduct.satuan_dasar || selectedProduct.satuan,
                )}
              </strong>
            </div>
          )}

          {/* Daftar item yang sudah ditambahkan */}
          {items.length > 0 ? (
            <div className="overflow-x-auto">
              <table className="w-full text-sm">
                <thead>
                  <tr className="bg-green-700 text-white">
                    <th className="px-3 py-2 text-left">Barang</th>
                    <th className="px-3 py-2 text-center">Qty</th>
                    <th className="px-3 py-2 text-right">Harga/Satuan</th>
                    <th className="px-3 py-2 text-right">Subtotal</th>
                    <th className="px-3 py-2"></th>
                  </tr>
                </thead>
                <tbody>
                  {items.map((item, idx) => (
                    <tr key={idx} className="border-b hover:bg-gray-50">
                      <td className="px-3 py-2 font-medium">{item.name}</td>
                      <td className="px-3 py-2 text-center text-gray-600">
                        {item.qty_display} {item.unit.toLowerCase()}
                        {item.satuan_dasar === "GRAM" &&
                          item.unit !== "GRAM" && (
                            <span className="text-xs text-gray-400 block">
                              = {item.qty_dasar} g
                            </span>
                          )}
                      </td>
                      <td className="px-3 py-2 text-right text-gray-600">
                        {formatToRupiah(item.price)}
                      </td>
                      <td className="px-3 py-2 text-right font-semibold">
                        {formatToRupiah(item.subtotal)}
                      </td>
                      <td className="px-3 py-2 text-center">
                        <button
                          onClick={() => handleHapusItem(idx)}
                          className="text-red-500 hover:text-red-700 cursor-pointer"
                          title="Hapus item"
                        >
                          <Trash2 size={16} />
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
                <tfoot>
                  <tr className="bg-green-50 font-bold">
                    <td colSpan={3} className="px-3 py-2 text-right">
                      Total:
                    </td>
                    <td className="px-3 py-2 text-right text-green-800">
                      {formatToRupiah(totalHarga)}
                    </td>
                    <td></td>
                  </tr>
                </tfoot>
              </table>
            </div>
          ) : (
            <p className="text-sm text-gray-400 text-center py-4">
              Belum ada barang yang dipilih
            </p>
          )}
        </div>
      )}

      {/* ── SECTION 3: Pembayaran (tampil setelah ada item) ── */}
      {pelangganStep !== "idle" && items.length > 0 && (
        <div className="bg-white rounded-xl shadow-sm border p-4 sm:p-6 mb-4">
          <div className="flex items-center gap-2 mb-4">
            <CreditCard size={20} className="text-green-700" />
            <h2 className="text-base font-semibold">3. Pembayaran</h2>
          </div>

          <div className="mb-4 text-sm flex justify-between font-bold">
            <span>Total Belanja:</span>
            <span className="text-green-800 text-base">
              {formatToRupiah(totalHarga)}
            </span>
          </div>

          <div className="mb-3">
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Jumlah Bayar
            </label>
            <input
              type="text"
              inputMode="numeric"
              placeholder="Masukkan nominal"
              className={`w-full px-3 py-2.5 border rounded-lg text-sm focus:outline-none focus:ring-2 ${
                kurangBayar
                  ? "border-red-400 focus:ring-red-300"
                  : "focus:ring-green-300"
              }`}
              value={bayarInput}
              onChange={handleChangeBayar}
            />
            <p className="text-xs text-gray-400 mt-1">
              Batas maksimum: {formatToRupiah(MAX_BAYAR)}
            </p>
          </div>

          {/* Quick buttons */}
          <div className="flex flex-wrap gap-2 mb-3">
            <button
              onClick={setBayarPas}
              className="px-3 py-1.5 rounded border text-sm hover:bg-gray-100 cursor-pointer"
            >
              Bayar Pas
            </button>
            {[10000, 20000, 50000, 100000].map((inc) => (
              <button
                key={inc}
                onClick={() => tambahIncrement(inc)}
                className="px-3 py-1.5 rounded border text-sm hover:bg-gray-100 cursor-pointer"
              >
                +{inc / 1000}K
              </button>
            ))}
          </div>

          {/* Info kembalian */}
          {bayarInput && (
            <div className="mb-4">
              {kurangBayar ? (
                <p className="text-red-600 text-sm">
                  Kurang: {formatToRupiah(totalHarga - bayar)}
                </p>
              ) : (
                <p className="text-green-700 font-semibold text-sm">
                  Kembalian: {formatToRupiah(kembalian)}
                </p>
              )}
            </div>
          )}

          {/* Tombol Buat Transaksi */}
          <button
            onClick={handleBuatTransaksi}
            disabled={kurangBayar || !bayarInput || isProcessing}
            className={`w-full py-3 rounded-xl font-semibold text-white transition-colors ${
              kurangBayar || !bayarInput
                ? "bg-gray-300 cursor-not-allowed"
                : "bg-green-700 hover:bg-green-800 cursor-pointer"
            }`}
          >
            {isProcessing ? "Memproses..." : "Buat Transaksi"}
          </button>
        </div>
      )}

      {/* ── OVERLAY PROCESSING ── */}
      {isProcessing && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center">
          <div className="bg-white rounded-lg px-6 py-6 flex flex-col items-center shadow-lg">
            <div className="animate-spin rounded-full h-12 w-12 border-4 border-green-600 border-t-transparent" />
            <p className="mt-3 text-sm text-gray-700">Memproses transaksi...</p>
          </div>
        </div>
      )}
    </div>
  );
};