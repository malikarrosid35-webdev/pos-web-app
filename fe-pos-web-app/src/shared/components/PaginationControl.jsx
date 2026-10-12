// export default function PaginationControl({
//   meta,
//   currentPage,
//   onPageChange,
//   // colorClass = "blue",
// }) {
//   if (!meta || !meta.total_data) return null;

//   const { total_page, total_data, limit } = meta;

//   const from = (currentPage - 1) * limit + 1;
//   const to = Math.min(currentPage * limit, total_data);

//   return (
//     <div className="flex flex-col sm:flex-row items-center justify-between gap-3 mt-4 px-1">
//       <p className="text-sm text-gray-500">
//         Menampilkan{" "}
//         <strong>
//           {from}–{to}
//         </strong>{" "}
//         dari <strong>{total_data}</strong> transaksi
//       </p>
//       {total_page > 1 && (
//         <div className="flex items-center gap-2">
//           <button
//             disabled={currentPage <= 1}
//             onClick={() => onPageChange(currentPage - 1)}
//             className="px-3 py-1.5 border rounded text-sm disabled:opacity-40 disabled:cursor-not-allowed hover:bg-gray-100 cursor-pointer"
//           >
//             ← Prev
//           </button>
//           <span className="px-3 py-1.5 text-sm font-medium">
//             {currentPage} / {total_page}
//           </span>
//           <button
//             disabled={currentPage >= total_page}
//             onClick={() => onPageChange(currentPage + 1)}
//             className="px-3 py-1.5 border rounded text-sm disabled:opacity-40 disabled:cursor-not-allowed hover:bg-gray-100 cursor-pointer"
//           >
//             Next →
//           </button>
//         </div>
//       )}
//     </div>
//   );
// }