// import { useEffect, useState, useMemo } from "react";
// import { useNavigate } from "react-router-dom";
// import clsx from "clsx";
// import Swal from "sweetalert2";
// import { ProductSlider } from "../components/ProductSlider.jsx";
// import { useCartStore } from "../../stores/useCartStore.js";
// import {
//   formatToRupiah,
//   formatNumber,
//   parseNumber,
// } from "../../shared/utils/numberFormat.js";
// import { useBarang } from "../../shared/hooks/useBarang.js";
// import { useUIStore } from "../../stores/useUIStore.js";
// import { usePelanggan } from "../../shared/hooks/usePelanggan.js";
// import { usePelangganStore } from "../../stores/usePelangganStore.js";
// import { useTransaksiStore } from "../../stores/useTransaksiStore.js";
// import { useTransaksi } from "../../shared/hooks/useTransaksi.js";
// import {
//   Trash2,
//   Plus,
//   Minus,
//   ArrowRight,
//   ArrowLeft,
//   ShoppingCart,
//   ChevronUp,
//   ChevronDown,
//   X,
// } from "lucide-react";

// const MAX_BAYAR = 500000;

// export const TransaksiBarangPage = () => {
//   const navigate = useNavigate();
//   const {
//     addToCart,
//     cartItems,
//     getCartTotal,
//     updateQuantity,
//     removeFromCart,
//     clearCart,
//   } = useCartStore();
//   const {
//     fetchBarang,
//     groupedProducts,
//     categories,
//     loading: isLoading,
//   } = useBarang({ mode: "kasir" });
//   const { setActiveTab } = useUIStore();
//   const [searchTerm, setSearchTerm] = useState("");
//   const { pelanggan, setPelanggan } = usePelangganStore();
//   const { pelangganTerpilih, setPelangganTerpilih } = useTransaksiStore();
//   const [custSearch, setCustSearch] = useState("");
//   const {
//     fetchPelanggan,
//     search: searchPelanggan,
//     loading: loadingPelanggan,
//   } = usePelanggan({ searchQuery: custSearch, setPelanggan, mode: "kasir" });
//   const [qtyInputs, setQtyInputs] = useState({});
//   const [paymentMode, setPaymentMode] = useState(false);
//   const [bayarInput, setBayarInput] = useState("");
//   const [isProcessing, setIsProcessing] = useState(false);
//   const { addTransaksi } = useTransaksi({ mode: "kasir" });
//   const [successData, setSuccessData] = useState(null);

//   // State responsivitas
//   const [isMobile, setIsMobile] = useState(false);
//   const [mobileCartOpen, setMobileCartOpen] = useState(false);

//   useEffect(() => {
//     const check = () => setIsMobile(window.innerWidth < 1024);
//     check();
//     window.addEventListener("resize", check);
//     return () => window.removeEventListener("resize", check);
//   }, []);

//   // Tutup bottom sheet jika keranjang kosong
//   useEffect(() => {
//     if (cartItems.length === 0) setMobileCartOpen(false);
//   }, [cartItems.length]);

//   const total = useMemo(() => getCartTotal(), [cartItems, getCartTotal]);
//   const bayar = useMemo(
//     () => (bayarInput ? parseNumber(bayarInput) : 0),
//     [bayarInput],
//   );
//   const kembalian = useMemo(() => Math.max(bayar - total, 0), [bayar, total]);
//   const kurangBayar = bayar < total;

//   // ── Handler bayar (dari doc, MAX_BAYAR logic) ──────────────────────────
//   const handleChangeBayar = (e) => {
//     const raw = e.target.value.replace(/[^\d]/g, "");
//     const numValue = Number(raw) || 0;
//     if (numValue > MAX_BAYAR) {
//       Swal.fire({
//         icon: "warning",
//         title: "Batas Maksimum",
//         text: `Jumlah bayar tidak bisa melebihi Rp${formatNumber(MAX_BAYAR)}`,
//         timer: 2000,
//         showConfirmButton: false,
//       });
//       setBayarInput(formatNumber(MAX_BAYAR));
//       return;
//     }
//     const formatted = raw.replace(/\B(?=(\d{3})+(?!\d))/g, ".");
//     setBayarInput(formatted);
//   };

//   const setBayarPas = () => setBayarInput(formatNumber(total));

//   const tambahIncrement = (inc) => {
//     const next = Math.min(bayar + inc, MAX_BAYAR);
//     setBayarInput(formatNumber(next));
//     if (next >= MAX_BAYAR) {
//       Swal.fire({
//         icon: "info",
//         title: "Batas Maksimum Tercapai",
//         text: `Jumlah bayar sudah mencapai batas maksimum Rp${formatNumber(MAX_BAYAR)}`,
//         timer: 1500,
//         showConfirmButton: false,
//       });
//     }
//   };

//   const handleBuatTransaksi = async () => {
//     if (cartItems.length === 0) {
//       Swal.fire("Transaksi Gagal", "Keranjang kosong!", "warning");
//       return;
//     }
//     if (kurangBayar) {
//       Swal.fire(
//         "Jumlah Bayar Kurang",
//         "Silakan input jumlah bayar yang ≥ total.",
//         "warning",
//       );
//       return;
//     }
//     const tipePelanggan = pelangganTerpilih ? "member" : "guest";
//     const payload = {
//       tipe_pelanggan: tipePelanggan,
//       id_pelanggan:
//         tipePelanggan === "member" ? pelangganTerpilih?.id_pelanggan : null,
//       id_user: null,
//       nama_pelanggan:
//         tipePelanggan === "member"
//           ? pelangganTerpilih?.nama_pelanggan
//           : "Guest",
//       jumlah_bayar: bayar,
//       items: cartItems.map((item) => ({
//         id_barang: item.id,
//         quantity: item.quantity,
//         subtotal:
//           typeof item.subtotal === "number"
//             ? Number(item.subtotal)
//             : Number(
//                 ((item.price ?? item.harga ?? item.harga_jual_per_sd) || 0) *
//                   item.quantity,
//               ),
//       })),
//     };
//     try {
//       setIsProcessing(true);
//       setSuccessData(null);
//       await addTransaksi(payload);
//       setSuccessData({
//         total,
//         kembalian,
//         jumlahBayar: bayar,
//         namaPelanggan: pelangganTerpilih
//           ? pelangganTerpilih.nama_pelanggan
//           : "Guest",
//         tipePelanggan: pelangganTerpilih ? "member" : "guest",
//       });

//       clearCart();
//       setMobileCartOpen(false);
//     } catch (err) {
//       console.error(err);
//       Swal.fire(
//         "Transaksi Gagal",
//         err.response?.data?.message || "Server error",
//         "error",
//       );
//       clearCart();
//     } finally {
//       setIsProcessing(false);
//     }
//   };

//   useEffect(() => {
//     setActiveTab("Buat Transaksi");
//     fetchBarang();
//     fetchPelanggan();
//   }, []);

//   useEffect(() => {
//     if (custSearch.trim() === "") fetchPelanggan();
//   }, [custSearch]);

//   useEffect(() => {
//     const next = { ...qtyInputs };
//     cartItems.forEach((it) => {
//       const id = it.id;
//       const satuanDasar = (it.satuan_dasar || it.satuan || "")
//         .toString()
//         .toUpperCase();
//       if (satuanDasar === "GRAM") {
//         if (!next[id]) {
//           const selectedUnit = it.unit || "GRAM";
//           const displayValue = convertFromGrams(it.quantity ?? 0, selectedUnit);
//           next[id] = { value: String(displayValue), unit: selectedUnit };
//         } else {
//           next[id].value =
//             next[id].value === ""
//               ? String(convertFromGrams(it.quantity ?? 0, next[id].unit))
//               : next[id].value;
//         }
//       } else {
//         if (next[id]) delete next[id];
//       }
//     });

//     // Clean up qtyInputs for items removed from cart
//     Object.keys(next).forEach(key => {
//       if (!cartItems.some(it => String(it.id) === key)) {
//         delete next[key];
//       }
//     });

//     setQtyInputs(next);
//   }, [cartItems]);

//   useEffect(() => {
//     if (cartItems.length === 0) {
//       setPaymentMode(false);
//       setBayarInput("");
//     }
//   }, [cartItems.length]);

//   const convertToGrams = (qty, unit) => {
//     const q = Number(qty || 0);
//     const u = (unit || "GRAM").toString().toUpperCase();
//     if (isNaN(q)) return 0;
//     if (u === "GRAM") return q;
//     if (u === "ONS") return q * 100;
//     if (u === "KG") return q * 1000;
//     return q;
//   };

//   const convertFromGrams = (grams, unit) => {
//     const g = Number(grams || 0);
//     const u = (unit || "GRAM").toString().toUpperCase();
//     if (isNaN(g)) return 0;
//     if (u === "GRAM") return g;
//     if (u === "ONS") return g / 100;
//     if (u === "KG") return g / 1000;
//     return g;
//   };

//   const handleQtyInputChange = (id, rawValue) => {
//     const entry = qtyInputs[id] || { value: "", unit: "GRAM" };
//     const next = { ...qtyInputs, [id]: { ...entry, value: rawValue } };
//     setQtyInputs(next);
//     const num = Number(rawValue);
//     if (!rawValue || isNaN(num)) return;
//     const grams = convertToGrams(num, entry.unit);
//     if (grams >= 1) updateQuantity(id, grams);
//   };

//   const handleUnitChange = (id, newUnit) => {
//     const entry = qtyInputs[id] || { value: "", unit: "GRAM" };
//     const next = { ...qtyInputs, [id]: { ...entry, unit: newUnit } };
//     setQtyInputs(next);
//     const num = Number(entry.value);
//     if (!entry.value || isNaN(num)) return;
//     const grams = convertToGrams(num, newUnit);
//     if (grams >= 1) updateQuantity(id, grams);
//   };

//   const filterProducts = (items) =>
//     items.filter((item) =>
//       item.name.toLowerCase().includes(searchTerm.toLowerCase()),
//     );

//   const handleTransaksiBaru = () => {
//     setSuccessData(null);
//     setPelangganTerpilih(null);
//     setPaymentMode(false);
//     setBayarInput("");
//   };

//   // ── Modal Sukses (dari doc, warna green) ──────────────────────────────
//   const ModalSukses = () => {
//     if (!successData) return null;
//     const {
//       total: totalTrx,
//       kembalian: kembalianTrx,
//       jumlahBayar,
//       namaPelanggan,
//       tipePelanggan,
//     } = successData;
//     return (
//       <div className="fixed inset-0 bg-black/60 z-50 flex items-center justify-center px-4">
//         <div className="bg-white rounded-2xl shadow-xl w-full max-w-sm overflow-hidden">
//           <div className="bg-green-600 px-6 py-5 text-center">
//             <div className="w-12 h-12 bg-white rounded-full flex items-center justify-center mx-auto mb-3">
//               <svg
//                 className="w-7 h-7 text-green-600"
//                 fill="none"
//                 stroke="currentColor"
//                 viewBox="0 0 24 24"
//               >
//                 <path
//                   strokeLinecap="round"
//                   strokeLinejoin="round"
//                   strokeWidth={2.5}
//                   d="M5 13l4 4L19 7"
//                 />
//               </svg>
//             </div>
//             <h2 className="text-white text-xl font-bold">Transaksi Berhasil</h2>
//             <p className="text-green-100 text-sm mt-1">
//               {namaPelanggan} &middot;{" "}
//               <span className="capitalize">{tipePelanggan}</span>
//             </p>
//           </div>
//           <div className="px-6 py-5 space-y-3">
//             <div className="flex justify-between text-sm">
//               <span className="text-gray-500">Total belanja</span>
//               <span className="font-semibold">{formatToRupiah(totalTrx)}</span>
//             </div>
//             <div className="flex justify-between text-sm">
//               <span className="text-gray-500">Jumlah bayar</span>
//               <span className="font-semibold">
//                 {formatToRupiah(jumlahBayar)}
//               </span>
//             </div>
//             <div className="flex justify-between text-sm border-t pt-3">
//               <span className="text-gray-700 font-medium">Kembalian</span>
//               <span className="text-green-700 font-bold text-base">
//                 {formatToRupiah(kembalianTrx)}
//               </span>
//             </div>
//           </div>
//           <div className="px-6 pb-6 flex flex-col gap-2">
//             <button
//               onClick={handleTransaksiBaru}
//               className="w-full bg-green-600 hover:bg-green-700 text-white py-3 rounded-lg font-semibold cursor-pointer"
//             >
//               Transaksi Baru
//             </button>
//             <button
//               onClick={() => navigate("/kasir/histori-transaksi")}
//               className="w-full bg-gray-100 hover:bg-gray-200 text-gray-700 py-3 rounded-lg font-medium cursor-pointer"
//             >
//               Lihat Histori
//             </button>
//           </div>
//         </div>
//       </div>
//     );
//   };

//   // ── Stepper (dari doc, warna green) — flex-wrap agar tidak terpotong ──
//   const Stepper = () => (
//     <div className="flex flex-wrap items-center gap-1 sm:gap-2 mb-4 text-xs sm:text-sm">
//       <span
//         className={`px-2 py-1 rounded ${!pelangganTerpilih ? "bg-green-700 text-white" : "bg-gray-200"}`}
//       >
//         1. Pilih Pelanggan
//       </span>
//       <span className="text-gray-400">→</span>
//       <span
//         className={`px-2 py-1 rounded ${pelangganTerpilih && !paymentMode ? "bg-green-700 text-white" : "bg-gray-200"}`}
//       >
//         2. Pilih Barang
//       </span>
//       <span className="text-gray-400">→</span>
//       <span
//         className={`px-2 py-1 rounded ${paymentMode ? "bg-green-700 text-white" : "bg-gray-200"}`}
//       >
//         3. Konfirmasi
//       </span>
//     </div>
//   );

//   // ── Isi cart items — dipakai oleh sidebar desktop & bottom sheet mobile ─
//   const CartItemsList = () => (
//     <>
//       {cartItems.map((item) => {
//         const satuan = (item.satuan_dasar || item.satuan || "")
//           .toString()
//           .toUpperCase();
//         const entry = qtyInputs[item.id] || {
//           value: String(item.quantity ?? 0),
//           unit: "GRAM",
//         };
//         return (
//           <div key={item.id} className="flex items-center border-b py-2 gap-2">
//             <img
//               src={item.image}
//               alt={item.name}
//               className="w-10 h-10 sm:w-12 sm:h-12 object-cover rounded shrink-0"
//             />
//             <div className="flex-1 min-w-0">
//               <p className="font-bold text-sm truncate">{item.name}</p>
//               {satuan === "GRAM" ? (
//                 <div className="flex items-center gap-1 mt-1">
//                   <input
//                     type="number"
//                     min="0"
//                     step="any"
//                     value={entry.value}
//                     onChange={(e) =>
//                       handleQtyInputChange(item.id, e.target.value)
//                     }
//                     className="w-16 border p-1 rounded text-xs"
//                     aria-label={`Jumlah ${item.name}`}
//                   />
//                   <select
//                     value={entry.unit}
//                     onChange={(e) => handleUnitChange(item.id, e.target.value)}
//                     className="border px-1 py-1 rounded text-xs cursor-pointer appearance-none"
//                     style={{
//                       backgroundImage: `url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="%23555" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"></polyline></svg>')`,
//                       backgroundRepeat: "no-repeat",
//                       backgroundPosition: "right 4px center",
//                       backgroundSize: "12px",
//                       paddingRight: "18px",
//                     }}
//                     aria-label={`Satuan ${item.name}`}
//                   >
//                     <option value="GRAM">Gram (g)</option>
//                     <option value="ONS">Ons (ons)</option>
//                     <option value="KG">Kg (kg)</option>
//                   </select>
//                 </div>
//               ) : (
//                 <p className="text-xs text-gray-600">x{item.quantity}</p>
//               )}
//               <div className="text-xs font-semibold mt-0.5">
//                 {item.satuan_dasar?.toLowerCase() === "pcs" ? (
//                   <p>{formatToRupiah(item.price * item.quantity)}</p>
//                 ) : item.satuan_dasar?.toLowerCase() === "gram" ? (
//                   <p className="flex items-center gap-1">
//                     {formatToRupiah(item.price * item.quantity)}
//                     <ArrowRight className="w-3 h-3 text-black" />
//                     {formatToRupiah(
//                       Number(item.subtotal ?? item.price * item.quantity),
//                     )}
//                   </p>
//                 ) : (
//                   <p>{formatToRupiah(item.price * item.quantity)}</p>
//                 )}
//               </div>
//             </div>
//             {satuan !== "GRAM" && (
//               <div className="flex items-center shrink-0">
//                 <button
//                   onClick={() => updateQuantity(item.id, item.quantity - 1)}
//                   className="p-1 text-gray-600 hover:text-green-600"
//                   title="Kurangi"
//                 >
//                   <Minus size={14} className="cursor-pointer" />
//                 </button>
//                 <span className="mx-1 w-6 text-center text-sm">
//                   {item.quantity}
//                 </span>
//                 <button
//                   onClick={() => updateQuantity(item.id, item.quantity + 1)}
//                   className="p-1 text-gray-600 hover:text-green-600"
//                   title="Tambah"
//                 >
//                   <Plus size={14} className="cursor-pointer" />
//                 </button>
//               </div>
//             )}
//             <button
//               onClick={() => removeFromCart(item.id)}
//               className="ml-1 text-red-500 hover:text-red-700 shrink-0"
//               title="Hapus"
//             >
//               <Trash2 size={16} className="cursor-pointer" />
//             </button>
//           </div>
//         );
//       })}
//     </>
//   );

//   // ── Panel pembayaran — dipakai sidebar desktop & bottom sheet mobile ───
//   const PaymentContent = () => (
//     <div className="space-y-2">
//       {cartItems.map((item) => {
//         const satuan = (item.satuan_dasar || item.satuan || "")
//           .toString()
//           .toUpperCase();
//         const entry = qtyInputs[item.id] || {
//           value: String(item.quantity ?? 0),
//           unit: "GRAM",
//         };
//         const displayQty =
//           satuan === "GRAM"
//             ? convertFromGrams(item.quantity, entry.unit)
//             : item.quantity;
//         const displayUnit =
//           satuan === "GRAM" ? entry.unit.toLowerCase() : satuan.toLowerCase();
//         return (
//           <div key={item.id} className="flex justify-between text-sm">
//             <span className="text-gray-700 truncate mr-2">
//               {item.name}{" "}
//               <span className="text-gray-500 text-xs">
//                 ({displayQty} {displayUnit})
//               </span>
//             </span>
//             <span className="font-semibold shrink-0">
//               {formatToRupiah(
//                 Number(item.subtotal ?? item.price * item.quantity),
//               )}
//             </span>
//           </div>
//         );
//       })}
//       <div className="border-t pt-3 flex justify-between font-bold text-base">
//         <span>Total</span>
//         <span>{formatToRupiah(total)}</span>
//       </div>
//       <div className="pt-2">
//         <label className="block text-sm font-medium mb-1">Jumlah Bayar</label>
//         <input
//           type="text"
//           inputMode="numeric"
//           placeholder="Masukkan nominal"
//           className={`w-full px-3 py-2 border rounded shadow-sm focus:outline-none focus:ring-2 text-sm ${
//             kurangBayar
//               ? "border-red-400 focus:ring-red-300"
//               : "focus:ring-green-300"
//           }`}
//           value={bayarInput}
//           onChange={handleChangeBayar}
//         />
//         <p className="text-xs text-gray-500 mt-1">
//           Batas maksimum: Rp{formatNumber(MAX_BAYAR)}
//         </p>
//         <div className="flex flex-wrap gap-1 mt-2">
//           <button
//             type="button"
//             onClick={setBayarPas}
//             className="px-2 py-1 rounded bg-gray-100 hover:bg-gray-200 text-xs cursor-pointer"
//           >
//             Bayar Pas
//           </button>
//           {[10000, 20000, 50000, 100000].map((inc) => (
//             <button
//               key={inc}
//               type="button"
//               onClick={() => tambahIncrement(inc)}
//               className="px-2 py-1 rounded bg-gray-100 hover:bg-gray-200 text-xs cursor-pointer"
//             >
//               +{inc / 1000}K
//             </button>
//           ))}
//         </div>
//         <div className="mt-2 text-sm">
//           {kurangBayar ? (
//             <p className="text-red-600">
//               Kurang: {formatToRupiah(total - bayar)}
//             </p>
//           ) : (
//             <p className="text-green-700 font-semibold">
//               Kembalian: {formatToRupiah(kembalian)}
//             </p>
//           )}
//         </div>
//       </div>
//     </div>
//   );

//   // ── Sidebar Desktop (right panel fixed) — sama dengan doc ──────────────
//   const SidebarCartPreview = () => (
//     <>
//       <div className="p-4 border-b flex justify-between items-center">
//         <h2 className="text-lg font-bold">Keranjang</h2>
//         <button
//           onClick={() => setPaymentMode(true)}
//           className="bg-green-700 text-white px-3 py-1 rounded hover:bg-green-800 cursor-pointer text-sm"
//         >
//           Konfirmasi Pembayaran
//         </button>
//       </div>
//       <div className="p-4 flex-1 overflow-y-auto">
//         <CartItemsList />
//       </div>
//       <div className="p-4 border-t font-bold flex justify-between">
//         <span>Total</span>
//         <span>{formatToRupiah(getCartTotal())}</span>
//       </div>
//     </>
//   );

//   const SidebarPayment = () => (
//     <>
//       <div className="p-4 border-b flex items-center gap-3">
//         <button
//           onClick={() => {
//             setPaymentMode(false);
//             setBayarInput("");
//           }}
//           className="text-gray-500 hover:text-green-700"
//           title="Kembali ke keranjang"
//         >
//           <ArrowLeft size={20} className="cursor-pointer" />
//         </button>
//         <h2 className="text-lg font-bold">Pembayaran</h2>
//       </div>
//       <div className="p-4 flex-1 overflow-y-auto space-y-2">
//         <PaymentContent />
//       </div>
//       <div className="p-4 border-t">
//         <button
//           className={`w-full text-white py-3 px-4 rounded-lg ${
//             kurangBayar
//               ? "bg-gray-300 cursor-not-allowed"
//               : "bg-green-700 hover:bg-green-800 cursor-pointer"
//           }`}
//           onClick={handleBuatTransaksi}
//           disabled={kurangBayar}
//         >
//           Buat Transaksi
//         </button>
//       </div>
//     </>
//   );

//   // ── Bottom Sheet Mobile ─────────────────────────────────────────────────
//   const MobileCart = () => {
//     if (cartItems.length === 0) return null;
//     return (
//       <>
//         {mobileCartOpen && (
//           <div
//             className="fixed inset-0 bg-black/40 z-40"
//             onClick={() => setMobileCartOpen(false)}
//           />
//         )}
//         <div
//           className={clsx(
//             "fixed bottom-0 left-0 right-0 bg-white z-50 rounded-t-2xl shadow-2xl flex flex-col",
//             "transition-[max-height] duration-300 ease-in-out",
//             mobileCartOpen ? "max-h-[85vh]" : "max-h-20",
//           )}
//         >
//           {/* Handle bar — tap toggle */}
//           <div
//             className="flex items-center justify-between px-4 py-3 cursor-pointer select-none border-b"
//             onClick={() => setMobileCartOpen((v) => !v)}
//           >
//             <div className="flex items-center gap-2">
//               <ShoppingCart size={18} className="text-green-700" />
//               <span className="font-bold text-sm">
//                 {cartItems.length} item · {formatToRupiah(total)}
//               </span>
//             </div>
//             <div className="flex items-center gap-2">
//               {!mobileCartOpen && (
//                 <button
//                   className="bg-green-700 text-white text-xs px-3 py-1.5 rounded-full cursor-pointer"
//                   onClick={(e) => {
//                     e.stopPropagation();
//                     setMobileCartOpen(true);
//                     setPaymentMode(true);
//                   }}
//                 >
//                   Bayar
//                 </button>
//               )}
//               {mobileCartOpen ? (
//                 <ChevronDown size={20} className="text-gray-400" />
//               ) : (
//                 <ChevronUp size={20} className="text-gray-400" />
//               )}
//             </div>
//           </div>

//           {/* Konten bottom sheet */}
//           {mobileCartOpen && (
//             <div className="flex flex-col flex-1 overflow-hidden">
//               {paymentMode ? (
//                 <>
//                   <div className="px-4 py-3 border-b flex items-center gap-2">
//                     <button
//                       onClick={() => {
//                         setPaymentMode(false);
//                         setBayarInput("");
//                       }}
//                       className="text-gray-500 hover:text-green-700"
//                     >
//                       <ArrowLeft size={18} className="cursor-pointer" />
//                     </button>
//                     <span className="font-bold text-sm">Pembayaran</span>
//                     <button
//                       className="ml-auto text-gray-400 hover:text-gray-600"
//                       onClick={() => setMobileCartOpen(false)}
//                     >
//                       <X size={18} className="cursor-pointer" />
//                     </button>
//                   </div>
//                   <div className="flex-1 overflow-y-auto px-4 py-3">
//                     <PaymentContent />
//                   </div>
//                   <div className="px-4 pb-6 pt-3 border-t">
//                     <button
//                       className={`w-full text-white py-3 rounded-xl font-semibold text-sm ${
//                         kurangBayar
//                           ? "bg-gray-300 cursor-not-allowed"
//                           : "bg-green-700 hover:bg-green-800 cursor-pointer"
//                       }`}
//                       onClick={handleBuatTransaksi}
//                       disabled={kurangBayar}
//                     >
//                       Buat Transaksi
//                     </button>
//                   </div>
//                 </>
//               ) : (
//                 <>
//                   <div className="px-4 py-2 border-b flex justify-between items-center">
//                     <span className="text-sm text-gray-500">
//                       {cartItems.length} barang
//                     </span>
//                     <button
//                       className="text-gray-400 hover:text-gray-600"
//                       onClick={() => setMobileCartOpen(false)}
//                     >
//                       <X size={18} className="cursor-pointer" />
//                     </button>
//                   </div>
//                   <div className="flex-1 overflow-y-auto px-4 py-2">
//                     <CartItemsList />
//                   </div>
//                   <div className="px-4 pb-6 pt-3 border-t">
//                     <button
//                       className="w-full bg-green-700 hover:bg-green-800 cursor-pointer text-white py-3 rounded-xl font-semibold text-sm"
//                       onClick={() => setPaymentMode(true)}
//                     >
//                       Konfirmasi Pembayaran · {formatToRupiah(total)}
//                     </button>
//                   </div>
//                 </>
//               )}
//             </div>
//           )}
//         </div>
//       </>
//     );
//   };

//   // ── RENDER UTAMA ─────────────────────────────────────────────────────────
//   return (
//     <div
//       className={clsx(
//         "container mx-auto p-3 sm:p-4",
//         // Padding kanan untuk sidebar desktop agar konten tidak tertimpa cart
//         !isMobile && cartItems.length > 0 ? "lg:pr-[400px]" : "",
//         // Padding bawah untuk bottom sheet mobile
//         isMobile && cartItems.length > 0 ? "pb-24" : "",
//       )}
//     >
//       <h1 className="text-xl sm:text-2xl font-bold mb-4 sm:mb-6">
//         Buat Transaksi
//       </h1>
//       <Stepper />

//       {/* ── SECTION 1: Pilih Pelanggan ── */}
//       {!pelangganTerpilih && (
//         <div className="mb-4 sm:mb-6 border rounded-xl p-3 sm:p-4 bg-white shadow-sm">
//           <h2 className="text-base sm:text-lg font-semibold mb-3">
//             Pilih Pelanggan
//           </h2>
//           <div className="flex flex-col sm:flex-row gap-2 mb-4">
//             <input
//               type="text"
//               placeholder="Cari pelanggan..."
//               className="flex-1 px-3 sm:px-4 py-2 border rounded shadow-sm focus:outline-none focus:ring-2 focus:ring-green-400 text-sm"
//               value={custSearch}
//               onChange={(e) => setCustSearch(e.target.value)}
//             />
//             <div className="flex gap-2">
//               <button
//                 className="flex-1 sm:flex-none bg-green-700 text-white px-4 py-2 rounded hover:bg-green-800 cursor-pointer text-sm"
//                 onClick={() =>
//                   custSearch.trim() === ""
//                     ? fetchPelanggan()
//                     : searchPelanggan()
//                 }
//               >
//                 Cari
//               </button>
//               {/* <button
//                 className="flex-1 sm:flex-none bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700 cursor-pointer text-sm"
//                 onClick={() => setPelangganTerpilih(null)}
//                 title="Transaksi Guest"
//               >
//                 Transaksi Guest
//               </button> */}
//             </div>
//           </div>
//           {loadingPelanggan ? (
//             <p className="text-sm text-gray-500">Memuat pelanggan...</p>
//           ) : (
//             <div className="grid grid-cols-1 sm:grid-cols-2 gap-2 sm:gap-3">
//               {pelanggan.map((c) => (
//                 <div
//                   key={c.id_pelanggan}
//                   className="p-3 border rounded flex items-center justify-between gap-2"
//                 >
//                   <div className="min-w-0">
//                     <div className="font-semibold text-sm truncate">
//                       {c.nama_pelanggan}
//                     </div>
//                     <div className="text-xs text-gray-600">{c.no_hp}</div>
//                   </div>
//                   <button
//                     className="shrink-0 bg-green-700 text-white px-3 py-1 rounded hover:bg-green-800 cursor-pointer text-sm"
//                     onClick={() => setPelangganTerpilih(c)}
//                   >
//                     Pilih
//                   </button>
//                 </div>
//               ))}
//               {pelanggan.length === 0 && (
//                 <p className="text-gray-500 text-sm">
//                   Pelanggan tidak ditemukan.
//                 </p>
//               )}
//             </div>
//           )}
//         </div>
//       )}

//       {/* ── SECTION 2: Pilih Barang ── */}
//       {pelangganTerpilih !== undefined && (
//         <>
//           <div className="flex items-center justify-between mb-3 sm:mb-4">
//             <h2 className="text-base sm:text-xl font-semibold">
//               {pelangganTerpilih
//                 ? `Pelanggan: ${pelangganTerpilih.nama_pelanggan}`
//                 : "Pelanggan: Guest"}
//             </h2>
//             {pelangganTerpilih && (
//               <button
//                 className="text-xs sm:text-sm bg-green-700 text-white px-3 py-1 rounded hover:bg-green-800 cursor-pointer"
//                 onClick={() => setPelangganTerpilih(null)}
//                 title="Ganti Pelanggan"
//               >
//                 Ganti Pelanggan
//               </button>
//             )}
//           </div>

//           <div className="mb-4 sm:mb-6">
//             <input
//               type="text"
//               placeholder="Cari barang ..."
//               className="w-full sm:w-1/2 px-3 sm:px-4 py-2 border rounded shadow-sm focus:outline-none focus:ring-2 focus:ring-green-400 text-sm"
//               value={searchTerm}
//               onChange={(e) => setSearchTerm(e.target.value)}
//             />
//           </div>

//           {isLoading ? (
//             <div className="text-center p-6">
//               <div className="animate-spin rounded-full h-10 sm:h-12 w-10 sm:w-12 border-b-2 border-green-600 mx-auto" />
//               <p className="mt-2 text-sm text-gray-500">
//                 Memuat data barang...
//               </p>
//             </div>
//           ) : Array.isArray(categories) && categories.length > 0 ? (
//             categories.map(
//               (category) =>
//                 groupedProducts[category]?.length > 0 && (
//                   <ProductSlider
//                     key={category}
//                     category={category}
//                     products={filterProducts(groupedProducts[category])}
//                     onAddToCart={addToCart}
//                   />
//                 ),
//             )
//           ) : (
//             <div className="text-center text-gray-500 text-sm">
//               Tidak ada kategori atau barang ditemukan.
//             </div>
//           )}

//           {/* Desktop: sidebar kanan fixed */}
//           {!isMobile && (
//             <div
//               className={clsx(
//                 "fixed right-0 top-0 sm:right-4 sm:top-4 bg-white shadow-lg w-full sm:w-[380px] z-40 transition-transform duration-300 border-l sm:border sm:rounded-xl max-h-screen sm:max-h-[90vh] flex flex-col overflow-hidden",
//                 {
//                   "translate-x-0": cartItems.length > 0,
//                   "translate-x-full": cartItems.length === 0,
//                 },
//               )}
//             >
//               {paymentMode ? <SidebarPayment /> : <SidebarCartPreview />}
//             </div>
//           )}

//           {/* Mobile/Tablet: bottom sheet */}
//           {isMobile && <MobileCart />}
//         </>
//       )}

//       <ModalSukses />

//       {isProcessing && (
//         <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center">
//           <div className="bg-white rounded-lg px-6 py-6 flex flex-col items-center shadow-lg">
//             <div className="animate-spin rounded-full h-14 w-14 border-4 border-green-600 border-t-transparent" />
//             <p className="mt-3 text-sm text-gray-700">Memproses Request...</p>
//           </div>
//         </div>
//       )}
//     </div>
//   );
// };
