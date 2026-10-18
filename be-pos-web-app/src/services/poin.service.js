const NOMINAL_PER_POIN = 10000;

const JENIS_RIWAYAT_POIN = {
  SALDO_AWAL: "saldo_awal",
  TRANSAKSI: "transaksi",
  PENYESUAIAN: "penyesuaian",
  PEMBATALAN_TRANSAKSI: "pembatalan_transaksi",
};

class PoinError extends Error {
  constructor(message, status = 400) {
    super(message);
    this.name = "PoinError";
    this.status = status;
  }
}

const hitungPoinTransaksi = (totalHarga) =>
  Math.floor(Number(totalHarga) / NOMINAL_PER_POIN);

/**
 * Mengubah poin pelanggan sekaligus mencatatnya di riwayat_poin.
 * Harus dipanggil di dalam transaksi DB milik pemanggil (BEGIN/COMMIT di luar).
 *
 * clampAtZero: kalau saldo tidak cukup, saldo dibatasi ke 0 (dipakai pembatalan
 * transaksi). Tanpa itu, pengurangan yang melebihi saldo ditolak.
 */
async function applyPoinChange(
  client,
  {
    id_pelanggan,
    perubahan,
    jenis,
    id_transaksi = null,
    id_user = null,
    alasan = null,
    clampAtZero = false,
  },
) {
  const { rows } = await client.query(
    `SELECT poin_loyalitas FROM pelanggan WHERE id_pelanggan = $1 FOR UPDATE`,
    [id_pelanggan],
  );
  if (rows.length === 0) {
    throw new PoinError("Pelanggan tidak ditemukan!", 404);
  }

  const poin_sebelum = rows[0].poin_loyalitas;
  let poin_sesudah = poin_sebelum + perubahan;
  let keterangan = alasan;

  if (poin_sesudah < 0) {
    if (!clampAtZero) {
      throw new PoinError(`Poin tidak cukup (saldo: ${poin_sebelum})`, 400);
    }
    poin_sesudah = 0;
    const note = `ditarik ${poin_sebelum} dari ${Math.abs(perubahan)} poin, saldo tidak cukup`;
    keterangan = alasan ? `${alasan} (${note})` : note;
  }

  const perubahan_efektif = poin_sesudah - poin_sebelum;

  await client.query(
    `UPDATE pelanggan SET poin_loyalitas = $1 WHERE id_pelanggan = $2`,
    [poin_sesudah, id_pelanggan],
  );

  // clock_timestamp() (bukan CURRENT_TIMESTAMP) agar urutan riwayat mengikuti
  // urutan saldo, meskipun transaksi DB-nya sudah mulai lebih dulu lalu antre kunci.
  const insert = await client.query(
    `INSERT INTO riwayat_poin (
       id_pelanggan, jenis, perubahan_poin, poin_sebelum, poin_sesudah,
       id_transaksi, id_user, alasan, created_at
     ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, clock_timestamp())
     RETURNING id_riwayat_poin`,
    [
      id_pelanggan,
      jenis,
      perubahan_efektif,
      poin_sebelum,
      poin_sesudah,
      id_transaksi,
      id_user,
      keterangan,
    ],
  );

  return {
    id_riwayat_poin: insert.rows[0].id_riwayat_poin,
    poin_sebelum,
    poin_sesudah,
    perubahan_efektif,
  };
}

export {
  JENIS_RIWAYAT_POIN,
  PoinError,
  hitungPoinTransaksi,
  applyPoinChange,
};
