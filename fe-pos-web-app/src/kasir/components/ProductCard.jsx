// import { useMemo, useState } from "react";
// import Swal from "sweetalert2";
// import { useCartStore } from "../../stores/useCartStore.js";
// import { formatToRupiah } from "../../shared/utils/numberFormat.js";
// import { formatQty } from "../../shared/utils/qtyFormat.js";

// export const ProductCard = ({ product }) => {
//   const { addToCart, cartItems } = useCartStore();

//   const productId =
//     product.id ?? product.id_barang ?? product.id_product ?? null;

//   const cartItem = useMemo(() => {
//     return cartItems.find(
//       (item) => (item.id ?? item.id_barang ?? item.id_product) === productId,
//     );
//   }, [cartItems, productId]);

//   const satuanDasar = (product.satuan_dasar || product.satuan || "")
//     .toString()
//     .toUpperCase();
//   const isGramProduct = satuanDasar === "GRAM";
//   const inCartQuantity = cartItem ? Number(cartItem.quantity || 0) : 0;
//   const availableStock =
//     Number(product.stock ?? product.stok_dasar ?? 0) - inCartQuantity;

//   const [qtyInput, setQtyInput] = useState("");
//   const [unit, setUnit] = useState("GRAM");

//   const handleAdd = () => {
//     if (isGramProduct) {
//       const parsed = Number(qtyInput);
//       if (!parsed || parsed <= 0) {
//         Swal.fire({
//           icon: "warning",
//           title: "Kuantitas Tidak Valid",
//           text: "Masukkan jumlah yang valid untuk menambahkan ke keranjang",
//           confirmButtonColor: "#3085d6",
//         });
//         return;
//       }
//       addToCart(product, parsed, unit);
//       setQtyInput("");
//       setUnit("GRAM");
//       return;
//     }
//     const parsed = qtyInput ? Number(qtyInput) : 1;
//     if (!parsed || parsed <= 0) {
//       Swal.fire({
//         icon: "warning",
//         title: "Kuantitas Tidak Valid",
//         text: "Masukkan qty yang valid untuk menambahkan ke keranjang",
//         confirmButtonColor: "#3085d6",
//       });
//       return;
//     }
//     addToCart(product, parsed);
//     setQtyInput("");
//   };

//   return (
//     // Lebar responsif: w-36 mobile → w-44 sm → w-56 md → w-64 lg+
//     <div className="bg-white rounded-lg shadow-md overflow-hidden w-36 sm:w-44 md:w-56 lg:w-64 shrink-0 mx-1 sm:mx-2">
//       {/* Gambar — tinggi menyesuaikan lebar kartu */}
//       {product.image ? (
//         <img
//           src={product.image}
//           alt={product.name}
//           className="w-full h-28 sm:h-36 md:h-44 lg:h-48 object-cover"
//           onError={(e) => {
//             console.error("Gagal memuat gambar:", e.target.src);
//             e.target.src = "/images/fallback-product.png";
//             e.target.onerror = null;
//           }}
//         />
//       ) : (
//         <div className="w-full h-28 sm:h-36 md:h-44 lg:h-48 bg-gray-200 flex items-center justify-center">
//           <span className="text-xs text-gray-500">No Image</span>
//         </div>
//       )}

//       <div className="p-2 sm:p-3 lg:p-4">
//         {/* Nama — clamp 2 baris agar kartu tidak elongated */}
//         <h3 className="font-bold text-sm sm:text-base lg:text-lg mb-1 line-clamp-2">
//           {product.name}
//         </h3>

//         <p className="text-gray-600 text-xs sm:text-sm mb-1">
//           {formatToRupiah(
//             product.price ?? product.harga_jual_per_sd ?? product.harga,
//           )}
//         </p>

//         <p className="text-xs sm:text-sm mb-2 sm:mb-3 font-bold">
//           Stok: {formatQty(availableStock, satuanDasar)}
//         </p>

//         {isGramProduct ? (
//           <div className="space-y-1 sm:space-y-2">
//             <div className="flex gap-1 sm:gap-2">
//               <input
//                 type="number"
//                 min="0"
//                 step="any"
//                 placeholder="Qty"
//                 value={qtyInput}
//                 onChange={(e) => setQtyInput(e.target.value)}
//                 className="w-1/2 border p-1 sm:p-2 rounded text-xs sm:text-sm"
//               />
//               {/* Select dengan custom arrow — dipertahankan dari doc */}
//               <select
//                 value={unit}
//                 onChange={(e) => setUnit(e.target.value)}
//                 className="w-1/2 border p-1 sm:p-2 rounded cursor-pointer appearance-none text-xs sm:text-sm"
//                 style={{
//                   backgroundImage: `url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="%23555" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"></polyline></svg>')`,
//                   backgroundRepeat: "no-repeat",
//                   backgroundPosition: "right 4px center",
//                   backgroundSize: "14px",
//                   paddingRight: "20px",
//                 }}
//               >
//                 <option value="GRAM">Gram (g)</option>
//                 <option value="ONS">Ons (ons)</option>
//                 <option value="KG">Kg (kg)</option>
//               </select>
//             </div>
//             <button
//               onClick={handleAdd}
//               disabled={availableStock <= 0}
//               className={`py-1.5 sm:py-2 px-2 rounded w-full text-xs sm:text-sm ${
//                 availableStock > 0
//                   ? "bg-green-700 text-white hover:bg-green-800 cursor-pointer"
//                   : "bg-gray-300 text-gray-500 cursor-not-allowed"
//               }`}
//             >
//               {availableStock <= 0 ? "Stok Habis" : "Tambah ke Keranjang"}
//             </button>
//           </div>
//         ) : (
//           <div className="space-y-1 sm:space-y-2">
//             <input
//               type="number"
//               min="1"
//               step="1"
//               placeholder="Qty"
//               value={qtyInput}
//               onChange={(e) => setQtyInput(e.target.value)}
//               className="w-full border p-1 sm:p-2 rounded text-xs sm:text-sm"
//             />
//             <button
//               onClick={handleAdd}
//               disabled={availableStock <= 0}
//               className={`py-1.5 sm:py-2 px-2 rounded w-full text-xs sm:text-sm ${
//                 availableStock > 0
//                   ? "bg-green-700 text-white hover:bg-green-800 cursor-pointer"
//                   : "bg-gray-300 text-gray-500 cursor-not-allowed"
//               }`}
//             >
//               {availableStock <= 0 ? "Stok Habis" : "Tambah ke Keranjang"}
//             </button>
//           </div>
//         )}
//       </div>
//     </div>
//   );
// };
