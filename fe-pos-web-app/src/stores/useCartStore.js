import { create } from "zustand";
import Swal from "sweetalert2";
import { roundKasirGramSubtotal } from "../shared/utils/subTotalPriceHelper.js";

const toGrams = (qty, unit) => {
  if (!unit) return Number(qty) || 0;
  const u = unit.toString().toUpperCase();
  if (u === "GRAM") return Number(qty) || 0;
  if (u === "ONS") return (Number(qty) || 0) * 100;
  if (u === "KG") return (Number(qty) || 0) * 1000;
  return Number(qty) || 0;
};

export const useCartStore = create((set, get) => ({
  cartItems: [],

  addToCart: (product, qty = null, unit = null) => {
    const items = get().cartItems;
    const productId =
      product.id ?? product.id_barang ?? product.id_product ?? null;

    const satuanDasar = (product.satuan_dasar || product.satuan || "")
      .toString()
      .toUpperCase();

    let desiredQty;
    if (satuanDasar === "GRAM") {
      if (qty === null) {
        Swal.fire(
          "Peringatan",
          "Masukkan jumlah untuk produk berbasis gram.",
          "warning",
        );
        return;
      }
      desiredQty = toGrams(qty, unit);
      if (!desiredQty || desiredQty <= 0) {
        Swal.fire("Peringatan", "Jumlah tidak valid.", "warning");
        return;
      }
    } else {
      // non-gram products: qty is count; default to 1
      desiredQty = qty === null ? 1 : Number(qty) || 0;
      if (desiredQty <= 0) {
        Swal.fire("Peringatan", "Jumlah tidak valid.", "warning");
        return;
      }
    }

    // const existingItem = items.find((item) => item.id === product.id);
    const existingItem = items.find(
      (it) => (it.id ?? it.id_barang ?? it.id_product) === productId,
    );

    const availableStock = Number(
      product.stock ?? product.stok_dasar ?? product.qty_available ?? 0,
    );

    const price = Number(
      product.price ?? product.harga ?? product.harga_jual_per_sd ?? 0,
    );
    const rawSubtotal = price * desiredQty;
    const finalSubtotal =
      satuanDasar === "GRAM"
        ? roundKasirGramSubtotal(rawSubtotal)
        : rawSubtotal;

    if (existingItem) {
      const newQty = Number(existingItem.quantity) + Number(desiredQty);
      if (availableStock && newQty > availableStock) {
        Swal.fire("Peringatan", "Stok barang tidak mencukupi", "warning");
        return;
      }
      set({
        cartItems: items.map((it) =>
          (it.id ?? it.id_barang ?? it.id_product) === productId
            ? {
                ...it,
                quantity: newQty,
                unit: satuanDasar === "GRAM" ? unit || it.unit || "GRAM" : null,
                subtotal:
                  it.satuan_dasar?.toString().toUpperCase() === "GRAM"
                    ? roundKasirGramSubtotal(price * newQty)
                    : price * newQty,
              }
            : it,
        ),
      });
    } else {
      if (availableStock && desiredQty > availableStock) {
        Swal.fire("Peringatan", "Stok barang tidak mencukupi", "warning");
        return;
      }
      set({
        cartItems: [
          ...items,
          {
            ...product,
            id: productId,
            satuan_dasar: product.satuan_dasar ?? product.satuan ?? null,
            unit: satuanDasar === "GRAM" ? unit || "GRAM" : null,
            quantity: desiredQty,
            subtotal: finalSubtotal,
          },
        ],
      });
    }
  },
  removeFromCart: (id) => {
    set({
      cartItems: get().cartItems.filter(
        (item) => (item.id ?? item.id_barang ?? item.id_product) !== id,
      ),
    });
  },
  updateQuantity: (id, newQty) => {
    if (newQty < 1) return;
    const items = get().cartItems;
    const product = items.find(
      (item) => (item.id ?? item.id_barang ?? item.id_product) === id,
    );
    if (!product) return;
    const availableStock = Number(product.stock ?? product.stok_dasar ?? 0);
    if (availableStock && newQty > availableStock) {
      Swal.fire("Peringatan", "Jumlah melebihi stok yang tersedia", "warning");
      return;
    }
    const price = Number(
      product.price ?? product.harga ?? product.harga_jual_per_sd ?? 0,
    );
    const satuanDasar = (product.satuan_dasar || product.satuan || "")
      .toString()
      .toUpperCase();
    const raw = price * newQty;
    const final = satuanDasar === "GRAM" ? roundKasirGramSubtotal(raw) : raw;
    set({
      cartItems: items.map((item) =>
        (item.id ?? item.id_barang ?? item.id_product) === id
          ? { ...item, quantity: newQty, subtotal: final }
          : item,
      ),
    });
  },
  clearCart: () => set({ cartItems: [] }),
  getCartTotal: () => {
    const items = get().cartItems;

    return items.reduce((total, item) => {
      const satuanDasar = (item.satuan_dasar || item.satuan || "")
        .toString()
        .toUpperCase();

      const price = Number(
        item.price ?? item.harga ?? item.harga_jual_per_sd ?? 0,
      );

      const quantity = Number(item.quantity || 0);

      if (!price || !quantity) return total;

      if (typeof item.subtotal === "number")
        return total + Number(item.subtotal);

      const rawSubtotal = price * quantity;

      const finalSubtotal =
        satuanDasar === "GRAM"
          ? roundKasirGramSubtotal(rawSubtotal)
          : rawSubtotal;

      return total + finalSubtotal;
    }, 0);
  },

  getCartDistinctCount: () => {
    return get().cartItems.length;
  },

  getCartItemCount: () => {
    return get().cartItems.reduce(
      (count, item) => count + Number(item.quantity || 0),
      0,
    );
  },
}));