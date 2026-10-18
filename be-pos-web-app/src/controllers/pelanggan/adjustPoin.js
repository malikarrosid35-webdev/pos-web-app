import pool from "../../database/db.js";
import Joi from "joi";
import {
  JENIS_RIWAYAT_POIN,
  PoinError,
  applyPoinChange,
} from "../../services/poin.service.js";

const MAKS_JUMLAH_PENYESUAIAN = 100000;

const schema = Joi.object({
  tipe: Joi.string().valid("tambah", "kurangi").required().messages({
    "any.only": "Tipe harus 'tambah' atau 'kurangi'",
    "any.required": "Tipe penyesuaian wajib diisi",
    "string.base": "Tipe harus 'tambah' atau 'kurangi'",
  }),
  jumlah: Joi.number()
    .integer()
    .min(1)
    .max(MAKS_JUMLAH_PENYESUAIAN)
    .required()
    .messages({
      "number.base": "Jumlah poin harus berupa angka",
      "number.integer": "Jumlah poin harus bilangan bulat",
      "number.min": "Jumlah poin minimal 1",
      "number.max": `Jumlah poin maksimal ${MAKS_JUMLAH_PENYESUAIAN}`,
      "any.required": "Jumlah poin wajib diisi",
    }),
  alasan: Joi.string().trim().min(3).max(255).required().messages({
    "string.base": "Alasan wajib diisi",
    "string.empty": "Alasan wajib diisi",
    "string.min": "Alasan minimal 3 karakter",
    "string.max": "Alasan maksimal 255 karakter",
    "any.required": "Alasan wajib diisi",
  }),
});

const adjustPoin = async (req, res) => {
  const { id_pelanggan } = req.params;

  if (Joi.string().guid().validate(id_pelanggan).error) {
    return res.status(404).json({
      success: false,
      message: "Pelanggan tidak ditemukan!",
    });
  }

  const { error, value } = schema.validate(req.body ?? {});
  if (error) {
    return res.status(400).json({
      success: false,
      message: error.details[0].message,
    });
  }

  const { tipe, jumlah, alasan } = value;
  const perubahan = tipe === "tambah" ? jumlah : -jumlah;

  let client;

  try {
    client = await pool.connect();
    await client.query("BEGIN");

    const hasil = await applyPoinChange(client, {
      id_pelanggan,
      perubahan,
      jenis: JENIS_RIWAYAT_POIN.PENYESUAIAN,
      id_user: req.user?.id_user || null,
      alasan,
    });

    await client.query("COMMIT");

    return res.status(200).json({
      success: true,
      message: "Poin pelanggan berhasil disesuaikan",
      data: {
        id_pelanggan,
        perubahan_poin: hasil.perubahan_efektif,
        poin_sebelum: hasil.poin_sebelum,
        poin_sesudah: hasil.poin_sesudah,
      },
    });
  } catch (err) {
    if (client) {
      try {
        await client.query("ROLLBACK");
      } catch (rollbackErr) {
        console.error("Error rolling back adjustPoin:", rollbackErr.message);
      }
    }

    if (err instanceof PoinError) {
      return res.status(err.status).json({
        success: false,
        message: err.message,
      });
    }

    console.error("Error adjustPoin:", err.message);
    return res.status(500).json({
      success: false,
      message: "Server Error",
      error: err.message,
    });
  } finally {
    if (client) client.release();
  }
};

export default adjustPoin;
