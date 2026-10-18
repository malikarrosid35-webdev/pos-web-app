import pool from "../../database/db.js";
import {
  JENIS_RIWAYAT_POIN,
  PoinError,
  applyPoinChange,
  hitungPoinTransaksi,
} from "../../services/poin.service.js";

const updateTransaksiById = async (req, res) => {
  const { id_transaksi } = req.params;
  const { jumlah_bayar, status_transaksi } = req.body;

  if (!jumlah_bayar && !status_transaksi) {
    return res.status(400).json({
      success: false,
      message:
        "Minimal satu field (jumlah_bayar atau status_transaksi) harus diisi.",
    });
  }

  let client;

  try {
    client = await pool.connect();
    await client.query("BEGIN");

    // Kunci baris transaksi supaya pembatalan bersamaan diproses bergantian.
    const trx = await client.query(
      `SELECT * FROM transaksi WHERE id_transaksi = $1 FOR UPDATE`,
      [id_transaksi]
    );
    if (trx.rowCount === 0) {
      await client.query("ROLLBACK");
      return res
        .status(404)
        .json({ success: false, message: "Transaksi tidak ditemukan." });
    }

    const dataLama = trx.rows[0];
    let finalJumlahBayar = dataLama.jumlah_bayar;
    let finalStatus = dataLama.status_transaksi;

    if (jumlah_bayar) {
      if (jumlah_bayar < dataLama.total_harga) {
        await client.query("ROLLBACK");
        return res
          .status(400)
          .json({
            success: false,
            message: "Jumlah bayar tidak boleh kurang dari total harga.",
          });
      }
      finalJumlahBayar = jumlah_bayar;
    }

    if (status_transaksi) {
      finalStatus = status_transaksi;
    }

    const kembalianBaru = finalJumlahBayar - dataLama.total_harga;

    await client.query(
      `
      UPDATE transaksi
      SET jumlah_bayar = $1,
          kembalian = $2,
          status_transaksi = $3
      WHERE id_transaksi = $4
    `,
      [finalJumlahBayar, kembalianBaru, finalStatus, id_transaksi]
    );

    // Pembatalan transaksi member: tarik kembali poin dari transaksi ini (sekali saja).
    let poinDitarik = null;
    const baruDibatalkan =
      dataLama.status_transaksi !== "dibatalkan" &&
      finalStatus === "dibatalkan";

    if (
      baruDibatalkan &&
      dataLama.tipe_pelanggan === "member" &&
      dataLama.id_pelanggan
    ) {
      const poinTarik = hitungPoinTransaksi(dataLama.total_harga);

      if (poinTarik > 0) {
        const sudahDitarik = await client.query(
          `SELECT 1 FROM riwayat_poin WHERE id_transaksi = $1 AND jenis = $2`,
          [id_transaksi, JENIS_RIWAYAT_POIN.PEMBATALAN_TRANSAKSI]
        );

        if (sudahDitarik.rowCount === 0) {
          const hasil = await applyPoinChange(client, {
            id_pelanggan: dataLama.id_pelanggan,
            perubahan: -poinTarik,
            jenis: JENIS_RIWAYAT_POIN.PEMBATALAN_TRANSAKSI,
            id_transaksi,
            id_user: req.user?.id_user || null,
            alasan: `Pembatalan transaksi ${dataLama.kode_transaksi}`,
            clampAtZero: true,
          });
          poinDitarik = Math.abs(hasil.perubahan_efektif);
        }
      }
    }

    await client.query("COMMIT");

    return res.status(200).json({
      success: true,
      message: "Transaksi berhasil diperbarui.",
      data: {
        id_transaksi,
        total_harga: dataLama.total_harga,
        jumlah_bayar: finalJumlahBayar,
        kembalian: kembalianBaru,
        status_transaksi: finalStatus,
        ...(poinDitarik !== null ? { poin_ditarik: poinDitarik } : {}),
      },
    });
  } catch (err) {
    if (client) {
      try {
        await client.query("ROLLBACK");
      } catch (rollbackErr) {
        console.error(
          "Error rolling back updateTransaksiById:",
          rollbackErr.message
        );
      }
    }
    console.error("Error updateTransaksiById:", err.message);
    if (err instanceof PoinError) {
      return res.status(err.status).json({ success: false, message: err.message });
    }
    res.status(500).json({ success: false, message: "Server Error" });
  } finally {
    if (client) client.release();
  }
};

export default updateTransaksiById;
