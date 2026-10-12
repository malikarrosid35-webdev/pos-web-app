// import { ProductCard } from "./ProductCard.jsx";

// export const ProductSlider = ({ category, products, onAddToCart }) => {
//   if (products.length === 0) return null;

//   return (
//     <div className="mb-6 sm:mb-8">
//       <h2 className="text-base sm:text-xl font-bold mb-2 sm:mb-4 px-1">
//         {category}
//       </h2>

//       {/*
//         Horizontal scroll — scrollbar tipis agar tidak makan ruang di mobile.
//         Padding kiri/kanan mencegah kartu pertama & terakhir nempel di tepi.
//       */}
//       <div
//         className="
//           flex overflow-x-auto pb-3 gap-0
//           [&::-webkit-scrollbar]:h-1.5
//           [&::-webkit-scrollbar-track]:bg-gray-100
//           [&::-webkit-scrollbar-thumb]:bg-green-400
//           [&::-webkit-scrollbar-thumb]:rounded-full
//         "
//       >
//         <div className="shrink-0 w-1 sm:w-2" />
//         {products.map((product) => (
//           <ProductCard
//             key={product.id}
//             product={product}
//             onAddToCart={onAddToCart}
//           />
//         ))}P
//         <div className="shrink-0 w-1 sm:w-2" />
//       </div>
//     </div>
//   );
// };