// import { useState, useMemo, useEffect } from "react";
// import { Trash2, Plus, Minus } from "lucide-react";
// import { useNavigate } from "react-router-dom";
// import Swal from "sweetalert2";
// import { useCartStore } from "../../stores/useCartStore.js";
// import { useTransaksiStore } from "../../stores/useTransaksiStore.js";
// import { useTransaksi } from "../../shared/hooks/useTransaksi.js";
// import {
//   formatNumber,
//   formatToRupiah,
//   parseNumber,
// } from "../../shared/utils/numberFormat.js";
// import { formatQty } from "../../shared/utils/qtyFormat.js";

// export const CartPage = () => {
//   const navigate = useNavigate();
//   const { cartItems, removeFromCart, updateQuantity, getCartTotal, clearCart } =
//     useCartStore();
//   const { pelangganTerpilih } = useTransaksiStore();
//   const { addTransaksi } = useTransaksi({ mode: "kasir" });

//   const [bayarInput, setBayarInput] = useState("");
//   const [isProcessing, setIsProcessing] = useState(false);

//   const total = useMemo(() => getCartTotal(), [cartItems, getCartTotal]);
//   const bayar = useMemo(
//     () => (bayarInput ? parseNumber(bayarInput) : 0),
//     [bayarInput],
//   );
//   const kembalian = useMemo(() => Math.max(bayar - total, 0), [bayar, total]);
//   const kurangBayar = bayar < total;

//   const [qtyInputs, setQtyInputs] = useState({});

//   useEffect(() => {
//     const next = { ...qtyInputs };
//     cartItems.forEach((it) => {
//       const id = it.id;
//       const satuanDasar = (it.satuan_dasar || it.satuan || "")
//         .toString()
//         .toUpperCase();
//       if (satuanDasar === "GRAM") {
//         if (!next[id]) {
//           next[id] = { value: String(it.quantity ?? 0), unit: "GRAM" };
//         } else {
//           next[id].value =
//             next[id].value === "" ? String(it.quantity ?? 0) : next[id].value;
//         }
//       } else {
//         if (next[id]) delete next[id];
//       }
//     });
//     setQtyInputs(next);
//   }, [cartItems]);

//   const convertToGrams = (qty, unit) => {
//     const q = Number(qty || 0);
//     const u = (unit || "GRAM").toString().toUpperCase();
//     if (isNaN(q)) return 0;
//     if (u === "GRAM") return q;
//     if (u === "ONS") return q * 100;
//     if (u === "KG") return q * 1000;
//     return q;
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

//   const handleChangeBayar = (e) => {
//     const raw = e.target.value.replace(/[^\d]/g, "");
//     const formatted = raw.replace(/\B(?=(\d{3})+(?!\d))/g, ".");
//     setBayarInput(formatted);
//   };

//   const setBayarPas = () => setBayarInput(formatNumber(total));
//   const tambahIncrement = (inc) => {
//     const next = Math.max(0, bayar + inc);
//     setBayarInput(formatNumber(next));
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
//       await addTransaksi(payload);
//       clearCart();
//       navigate("/kasir/histori-transaksi");
//     } catch (err) {
//       console.error(err);
//       Swal.fire(
//         "Transaksi Gagal",
//         err.response?.data?.message || "Server error",
//         "error",
//       );
//     } finally {
//       setIsProcessing(false);
//     }
//   };

//   return (
//     <div className="container mx-auto p-4">
//       <h1 className="text-2xl font-bold mb-6">Keranjang Belanja</h1>
//       {cartItems.length === 0 ? (
//         <div className="text-center py-10">
//           <p className="text-gray-500">Keranjang belanja kosong</p>
//         </div>
//       ) : (
//         <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
//           <div className="md:col-span-2">
//             <div className="bg-white rounded-lg shadow-md overflow-hidden">
//               {cartItems.map((item) => {
//                 const satuan = (item.satuan_dasar || item.satuan || "")
//                   .toString()
//                   .toUpperCase();
//                 const entry = qtyInputs[item.id] || {
//                   value: String(item.quantity ?? 0),
//                   unit: "GRAM",
//                 };

//                 return (
//                   <div key={item.id} className="p-4 border-b flex items-center">
//                     <img
//                       src={item.image}
//                       alt={item.name}
//                       className="w-20 h-20 object-cover rounded mr-4"
//                     />
//                     <div className="grow">
//                       <h3 className="font-bold">{item.name}</h3>
//                       <p className="text-gray-600">
//                         {formatToRupiah(item.price)}
//                       </p>
//                       {/* <p className="text-sm mb-3 font-bold">
//                         Stok: {formatQty(item.stok_dasar, item.satuan_dasar)}
//                       </p> */}
//                     </div>

//                     {satuan === "GRAM" ? (
//                       <div className="flex items-center gap-2 w-64">
//                         <input
//                           type="number"
//                           min="0"
//                           step="any"
//                           value={entry.value}
//                           onChange={(e) =>
//                             handleQtyInputChange(item.id, e.target.value)
//                           }
//                           className="w-1/2 border p-1 rounded text-sm"
//                           aria-label={`Jumlah ${item.name}`}
//                         />
//                         <select
//                           value={entry.unit}
//                           onChange={(e) =>
//                             handleUnitChange(item.id, e.target.value)
//                           }
//                           className="w-1/2 border p-1 rounded text-sm"
//                           aria-label={`Satuan ${item.name}`}
//                         >
//                           <option value="GRAM">Gram (g)</option>
//                           <option value="ONS">Ons (ons)</option>
//                           <option value="KG">Kg (kg)</option>
//                         </select>
//                       </div>
//                     ) : (
//                       <div className="flex items-center">
//                         <button
//                           onClick={() =>
//                             updateQuantity(
//                               item.id,
//                               Math.max(1, item.quantity - 1),
//                             )
//                           }
//                           className="p-1 text-gray-500 hover:text-green-600"
//                         >
//                           <Minus size={16} />
//                         </button>
//                         <span className="mx-2 w-8 text-center">
//                           {item.quantity}
//                         </span>
//                         <button
//                           onClick={() =>
//                             updateQuantity(item.id, item.quantity + 1)
//                           }
//                           className="p-1 text-gray-500 hover:text-green-600"
//                         >
//                           <Plus size={16} />
//                         </button>
//                       </div>
//                     )}

//                     <div className="ml-4 font-bold">
//                       {formatToRupiah(
//                         Number(item.subtotal ?? item.price * item.quantity),
//                       )}
//                     </div>

//                     <button
//                       onClick={() => removeFromCart(item.id)}
//                       className="ml-4 text-red-500 hover:text-red-700"
//                     >
//                       <Trash2 size={18} />
//                     </button>
//                   </div>
//                 );
//               })}
//             </div>
//           </div>

//           <div className="bg-white rounded-lg shadow-md p-6 h-fit">
//             <h2 className="text-xl font-bold mb-4">Ringkasan Belanja</h2>
//             <div className="space-y-3 mb-6">
//               {cartItems.map((item) => (
//                 <div key={item.id} className="flex justify-between">
//                   <span>
//                     {item.name} ({item.quantity}{" "}
//                     {item.satuan_dasar.toLowerCase()})
//                   </span>
//                   <div className="ml-4 font-bold">
//                     {" "}
//                     {formatToRupiah(
//                       Number(item.subtotal ?? item.price * item.quantity),
//                     )}{" "}
//                   </div>
//                 </div>
//               ))}
//             </div>
//             <div className="border-t pt-4">
//               <div className="flex justify-between font-bold text-lg">
//                 <span>Total</span>
//                 <span>{formatToRupiah(total)}</span>
//               </div>
//             </div>

//             <div className="mt-3">
//               <label className="block text-sm font-medium mb-1">
//                 Jumlah Bayar
//               </label>
//               <input
//                 type="text"
//                 inputMode="numeric"
//                 placeholder="Masukkan nominal ()"
//                 className={`w-full px-4 py-2 border rounded shadow-sm focus:outline-none focus:ring-2 ${
//                   kurangBayar
//                     ? "border-red-400 focus:ring-red-300"
//                     : "focus:ring-green-300"
//                 }`}
//                 value={bayarInput}
//                 onChange={handleChangeBayar}
//               />

//               {/* Tombol cepat */}
//               <div className="flex flex-wrap gap-2 mt-2">
//                 <button
//                   type="button"
//                   onClick={setBayarPas}
//                   className="px-3 py-1 rounded bg-gray-100 hover:bg-gray-200"
//                 >
//                   Bayar Pas
//                 </button>
//                 <button
//                   type="button"
//                   onClick={() => tambahIncrement(10000)}
//                   className="px-3 py-1 rounded bg-gray-100 hover:bg-gray-200"
//                 >
//                   +10K
//                 </button>
//                 <button
//                   type="button"
//                   onClick={() => tambahIncrement(20000)}
//                   className="px-3 py-1 rounded bg-gray-100 hover:bg-gray-200"
//                 >
//                   +20K
//                 </button>
//                 <button
//                   type="button"
//                   onClick={() => tambahIncrement(50000)}
//                   className="px-3 py-1 rounded bg-gray-100 hover:bg-gray-200"
//                 >
//                   +50K
//                 </button>
//                 <button
//                   type="button"
//                   onClick={() => tambahIncrement(100000)}
//                   className="px-3 py-1 rounded bg-gray-100 hover:bg-gray-200"
//                 >
//                   +100K
//                 </button>
//               </div>
//               <div className="mt-3 text-sm">
//                 {kurangBayar ? (
//                   <p className="text-red-600">
//                     Kurang: {formatToRupiah(total - bayar)}
//                   </p>
//                 ) : (
//                   <p className="text-green-700 font-semibold">
//                     Kembalian: {formatToRupiah(kembalian)}
//                   </p>
//                 )}
//               </div>
//             </div>

//             <button
//               className={`w-full text-white py-3 px-4 rounded-lg mt-4 ${
//                 kurangBayar
//                   ? "bg-gray-300 cursor-not-allowed"
//                   : "bg-green-600 hover:bg-green-700"
//               }`}
//               onClick={handleBuatTransaksi}
//               disabled={kurangBayar}
//             >
//               Buat Transaksi
//             </button>
//           </div>
//         </div>
//       )}

//       {/* Overlay loading ketika processing */}
//       {isProcessing && (
//         <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center">
//           <div className="bg-white rounded-lg px-6 py-6 flex flex-col items-center shadow-lg">
//             <div className="animate-spin rounded-full h-14 w-14 border-4 border-green-600 border-t-transparent"></div>
//             <p className="mt-3 text-sm text-gray-700">Memproses Request...</p>
//           </div>
//         </div>
//       )}
//     </div>
//   );
// };