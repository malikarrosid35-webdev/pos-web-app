import express from "express";
const router = express.Router();
import { authenticate, authorize } from "../../middlewares/auth.middleware.js";
import {
  addPelanggan,
  getAllPelanggan,
  getPelangganById,
  searchPelanggan,
  updatePelangganById,
  adjustPoin,
  getRiwayatPoin,
  // deletePelangganById,
} from "../../controllers/pelanggan/index.js";

router.post("/", authenticate, authorize(["kasir"]), addPelanggan);

router.get(
  "/",
  authenticate,
  authorize(["kasir", "owner"]),
  getAllPelanggan,
);

router.get(
  "/search",
  authenticate,
  authorize(["kasir", "owner"]),
  searchPelanggan,
);

router.get(
  "/:id_pelanggan",
  authenticate,
  authorize(["kasir", "owner"]),
  getPelangganById,
);

router.patch(
  "/:id_pelanggan",
  authenticate,
  authorize(["kasir"]),
  updatePelangganById,
);

router.get(
  "/:id_pelanggan/riwayat-poin",
  authenticate,
  authorize(["kasir", "owner"]),
  getRiwayatPoin,
);

router.post(
  "/:id_pelanggan/poin",
  authenticate,
  authorize(["owner"]),
  adjustPoin,
);

// router.delete(
//   "/:id_pelanggan",
//   authenticate,
//   authorize(["admin"]),
//   deletePelangganById,
// );

export default router;
