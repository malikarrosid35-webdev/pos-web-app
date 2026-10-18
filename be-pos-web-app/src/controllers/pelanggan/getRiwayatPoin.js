import pool from "../../database/db.js";
import Joi from "joi";

const MAKS_LIMIT = 50;

const parsePositiveInteger = (value, fallback) => {
  const parsed = Number.parseInt(value, 10);
  if (!Number.isFinite(parsed) || parsed <= 0) {
    return fallback;
  }
  return parsed;
};

const getRiwayatPoin = async (req, res) => {
  try {
    const { id_pelanggan } = req.params;

    if (Joi.string().guid().validate(id_pelanggan).error) {
      return res.status(404).json({
        success: false,
        message: "Pelanggan tidak ditemukan!",
      });
    }

    const pageNum = parsePositiveInteger(req.query.page, 1);
    const limitNum = Math.min(
      parsePositiveInteger(req.query.limit, 10),
      MAKS_LIMIT,
    );
    const offset = (pageNum - 1) * limitNum;

    const pelangganResult = await pool.query(
      `SELECT id_pelanggan, nama_pelanggan, poin_loyalitas
       FROM pelanggan
       WHERE id_pelanggan = $1`,
      [id_pelanggan],
    );

    if (pelangganResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Pelanggan tidak ditemukan!",
      });
    }

    const [ringkasanResult, riwayatResult] = await Promise.all([
      pool.query(
        `SELECT
           COUNT(*)::int AS total_data,
           COALESCE(SUM(perubahan_poin) FILTER (WHERE jenis = 'saldo_awal'), 0)::int
             AS saldo_awal,
           COALESCE(SUM(perubahan_poin) FILTER (WHERE jenis = 'transaksi'), 0)::int
             AS total_transaksi,
           COALESCE(SUM(perubahan_poin) FILTER (
             WHERE jenis = 'penyesuaian' AND perubahan_poin > 0), 0)::int
             AS total_penambahan,
           COALESCE(SUM(perubahan_poin) FILTER (
             WHERE jenis = 'penyesuaian' AND perubahan_poin < 0), 0)::int
             AS total_pengurangan,
           COALESCE(SUM(perubahan_poin) FILTER (
             WHERE jenis = 'pembatalan_transaksi'), 0)::int
             AS total_pembatalan
         FROM riwayat_poin
         WHERE id_pelanggan = $1`,
        [id_pelanggan],
      ),
      pool.query(
        `SELECT
           r.id_riwayat_poin,
           r.jenis,
           r.perubahan_poin,
           r.poin_sebelum,
           r.poin_sesudah,
           r.alasan,
           r.created_at,
           r.id_transaksi,
           t.kode_transaksi,
           t.total_harga,
           u.username AS nama_user,
           u.role AS role_user
         FROM riwayat_poin r
         LEFT JOIN transaksi t ON t.id_transaksi = r.id_transaksi
         LEFT JOIN users u ON u.id_user = r.id_user
         WHERE r.id_pelanggan = $1
         ORDER BY r.created_at DESC, r.id_riwayat_poin DESC
         LIMIT $2 OFFSET $3`,
        [id_pelanggan, limitNum, offset],
      ),
    ]);

    const { total_data, ...ringkasan } = ringkasanResult.rows[0];

    return res.status(200).json({
      success: true,
      message: "Berhasil mendapatkan riwayat poin",
      data: {
        pelanggan: pelangganResult.rows[0],
        ringkasan,
        riwayat: riwayatResult.rows,
      },
      meta: {
        page: pageNum,
        limit: limitNum,
        total_data,
        total_page: Math.ceil(total_data / limitNum),
      },
    });
  } catch (err) {
    console.error("Error getRiwayatPoin:", err.message);
    return res.status(500).json({
      success: false,
      message: "Server Error",
      error: err.message,
    });
  }
};

export default getRiwayatPoin;
