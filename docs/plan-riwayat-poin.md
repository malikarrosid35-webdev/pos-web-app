# Plan: Riwayat Poin Pelanggan dan Penyesuaian Poin Owner

Status: sudah diimplementasikan di working tree, belum di-commit. Migrasi SQL belum dijalankan ke database produksi.

Penyimpangan dari rencana awal:

- `PaginationControl.jsx` ternyata seluruhnya di-comment, jadi modal riwayat memakai tombol sebelumnya/berikutnya sendiri.
- Hook `usePelanggan` hanya mendapat `adjustPoin`. Modal riwayat memanggil service langsung supaya error tampil di dalam modal, bukan lewat Swal di atasnya.
- `created_at` riwayat diisi `clock_timestamp()` (bukan default `CURRENT_TIMESTAMP`) agar urutan riwayat mengikuti urutan saldo walau dua transaksi DB saling antre.

## 1. Tujuan dan cakupan

- Owner bisa **menambah atau mengurangi** poin pelanggan, dengan alasan wajib.
- Setiap perubahan poin tercatat di **riwayat poin**. Ini mencakup poin dari transaksi, penyesuaian owner, pembatalan transaksi, dan saldo awal.
- **Owner dan kasir** bisa melihat riwayat poin (read-only). Hanya owner yang bisa menyesuaikan poin.
- Pembatalan transaksi member **menarik poin kembali**, dengan batas minimal 0.
- Data lama dimulai dari satu baris **saldo awal** per pelanggan.

Di luar cakupan: mengubah `total_pembelian` dan `frekuensi_transaksi` saat transaksi dibatalkan (lihat pertanyaan terbuka 3).

## 2. Database

Repo belum punya folder migrasi, jadi SQL disimpan di file baru `be-pos-web-app/sql/001_riwayat_poin.sql` dan dijalankan manual.

```sql
BEGIN;

CREATE TABLE public.riwayat_poin (
    id_riwayat_poin uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    id_pelanggan    uuid NOT NULL REFERENCES public.pelanggan(id_pelanggan),
    jenis           varchar(30) NOT NULL
        CHECK (jenis IN ('saldo_awal','transaksi','penyesuaian','pembatalan_transaksi')),
    perubahan_poin  integer NOT NULL,          -- bertanda: +5 / -10
    poin_sebelum    integer NOT NULL CHECK (poin_sebelum >= 0),
    poin_sesudah    integer NOT NULL CHECK (poin_sesudah >= 0),
    id_transaksi    uuid REFERENCES public.transaksi(id_transaksi),
    id_user         uuid REFERENCES public.users(id_user),   -- NULL untuk saldo awal
    alasan          text,
    created_at      timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CHECK (poin_sesudah = poin_sebelum + perubahan_poin)
);

CREATE INDEX idx_riwayat_poin_pelanggan ON riwayat_poin (id_pelanggan, created_at DESC);

-- satu transaksi hanya boleh punya 1 baris 'transaksi' dan 1 baris 'pembatalan_transaksi'
CREATE UNIQUE INDEX uniq_riwayat_poin_transaksi
    ON riwayat_poin (id_transaksi, jenis) WHERE id_transaksi IS NOT NULL;

-- riwayat bersifat append-only
CREATE FUNCTION public.block_riwayat_poin_mutation() RETURNS trigger LANGUAGE plpgsql AS
$$ BEGIN RAISE EXCEPTION 'riwayat_poin tidak boleh diubah atau dihapus'; END $$;
CREATE TRIGGER trg_riwayat_poin_immutable
    BEFORE UPDATE OR DELETE ON riwayat_poin
    FOR EACH ROW EXECUTE FUNCTION block_riwayat_poin_mutation();

-- saldo awal: satu baris per pelanggan yang sudah punya poin
INSERT INTO riwayat_poin (id_pelanggan, jenis, perubahan_poin, poin_sebelum, poin_sesudah, alasan)
SELECT id_pelanggan, 'saldo_awal', poin_loyalitas, 0, poin_loyalitas,
       'Poin sebelum fitur riwayat poin dibuat'
FROM pelanggan WHERE poin_loyalitas > 0;

COMMIT;
```

Query rekonsiliasi untuk dijalankan setelah migrasi dan kapan saja. Hasilnya harus kosong:

```sql
SELECT p.id_pelanggan, p.poin_loyalitas, COALESCE(r.total, 0) AS total_riwayat
FROM pelanggan p
LEFT JOIN (SELECT id_pelanggan, SUM(perubahan_poin) total FROM riwayat_poin GROUP BY 1) r USING (id_pelanggan)
WHERE p.poin_loyalitas <> COALESCE(r.total, 0);
```

Dokumentasi skema `struktur-tabel-field-now.txt` ikut diperbarui. File itu ber-encoding UTF-16, jadi perlu hati-hati saat diedit.

## 3. Backend (`be-pos-web-app/src`)

### 3.1 Helper baru: `services/poin.service.js`

Fungsi `applyPoinChange(client, { id_pelanggan, perubahan, jenis, id_transaksi, id_user, alasan, clampAtZero })`. Fungsi ini harus dipanggil di dalam transaksi DB milik pemanggil.

1. `SELECT poin_loyalitas FROM pelanggan WHERE id_pelanggan = $1 FOR UPDATE`.
2. Hitung `poin_sesudah = poin_sebelum + perubahan`.
3. Kalau hasilnya negatif: dengan `clampAtZero` dibatasi ke 0, tanpa itu melempar error "Poin tidak cukup".
4. `UPDATE pelanggan SET poin_loyalitas = poin_sesudah`.
5. `INSERT INTO riwayat_poin (...)`.
6. Mengembalikan `{ poin_sebelum, poin_sesudah, perubahan_efektif }`.

### 3.2 Perubahan `controllers/transaksi/addTransaksi.js` (sekitar baris 209-223)

- `UPDATE` untuk `total_pembelian` dan `frekuensi_transaksi` tetap, dengan `RETURNING nama_pelanggan`. Bagian `poin_loyalitas` dipindah ke `applyPoinChange`.
- Jenis riwayat `transaksi`, `id_user` = kasir, `id_transaksi` terisi.
- Kalau `poinBaru = 0` (belanja di bawah Rp10.000), **tidak ada baris riwayat**.

### 3.3 Perubahan `controllers/transaksi/updateTransaksi.js`

Sekarang controller ini memakai `pool.query` tanpa transaksi DB. Perubahannya:

- Pindah ke `pool.connect()` dengan BEGIN/COMMIT dan `SELECT ... FOR UPDATE` pada baris `transaksi`. Dengan begitu dua request pembatalan bersamaan akan antre.
- Kalau status lama bukan `dibatalkan`, status baru `dibatalkan`, `tipe_pelanggan = 'member'` dan `id_pelanggan` ada, maka tarik `floor(total_harga / 10000)` poin dengan `clampAtZero: true`.
- Jenis riwayat `pembatalan_transaksi`, `id_user` = pengguna yang membatalkan.
- Kalau poin yang ditarik lebih besar dari saldo, `alasan` ditulis misalnya "Pembatalan TRX-ABC123 (ditarik 3 dari 8 poin, saldo tidak cukup)".
- Penarikan hanya sekali. Cek dulu apakah baris `pembatalan_transaksi` untuk transaksi itu sudah ada, dan unique index jadi pengaman terakhir.
- Kalau poin yang harus ditarik lebih dari 0 tetapi saldo sudah 0, tetap tulis baris dengan `perubahan_poin = 0` sebagai penanda.

### 3.4 Controller dan route baru (`controllers/pelanggan/`, `routes/pelanggan/pelangganRoutes.js`)

| Endpoint | Role | Fungsi |
|---|---|---|
| `POST /:id_pelanggan/poin` | owner | Penyesuaian poin |
| `GET /:id_pelanggan/riwayat-poin` | kasir, owner | Daftar riwayat |

Route ini otomatis tersedia di `/api/owner/pelanggan/...` dan `/api/kasir/pelanggan/...` karena `roleRoutes` dipakai bersama.

**`POST /:id_pelanggan/poin`**
- Body: `{ tipe: "tambah" | "kurangi", jumlah: integer >= 1, alasan: string }`.
- Validasi Joi: `jumlah` punya batas atas, `alasan` minimal 3 karakter dan maksimal 255.
- Pengurangan yang melebihi saldo **ditolak** dengan 400 dan pesan "Poin tidak cukup (saldo: X)". Ini tidak dibatasi ke 0 seperti pembatalan, karena owner harus tahu angkanya.
- Response berisi poin sebelum dan sesudah.

**`GET /:id_pelanggan/riwayat-poin`**
- Query: `page`, `limit`, dengan format `meta` yang sama seperti `getPelanggan.js`.
- Response berisi tiga bagian:
  - `pelanggan`: nama dan saldo saat ini.
  - `ringkasan`: total diperoleh dari transaksi, total penyesuaian, total pembatalan.
  - `riwayat[]`: tanggal, jenis, `perubahan_poin`, `poin_sebelum`, `poin_sesudah`, `kode_transaksi`, `total_harga`, `username` dan `role` pelaku, `alasan`.
- Data transaksi dan pelaku diambil lewat `LEFT JOIN` ke `transaksi` dan `users`.
- Diurutkan terbaru dulu.

## 4. Frontend (`fe-pos-web-app/src`)

| File | Perubahan |
|---|---|
| `shared/services/pelangganService.js` | Tambah `getRiwayatPoinOwner`, `getRiwayatPoinKasir`, `adjustPoinOwner` |
| `shared/hooks/usePelanggan.js` | Tambah `adjustPoin` (khusus owner, feedback lewat Swal seperti fungsi lain) |
| `shared/components/RiwayatPoinModal.jsx` (baru) | Modal read-only dipakai owner dan kasir, berisi ringkasan, daftar riwayat, dan pagination sebelumnya/berikutnya. Warna tema ikut `mode` (violet untuk owner, hijau untuk kasir). Memanggil service langsung. |
| `owner/components/PoinAdjustModal.jsx` (baru) | Form: pilih Tambah/Kurangi, jumlah, alasan, dan pratinjau "Poin: 45 -> 35". Ada konfirmasi sebelum kirim. |
| `owner/pages/DaftarPelanggan.jsx` | Tambah kolom Aksi dengan tombol **Riwayat** dan **Sesuaikan Poin**. `colSpan` empty-state berubah dari 6 ke 7. Daftar di-refresh setelah penyesuaian. |
| `kasir/pages/DaftarPelangganPage.jsx` | Tambah tombol **Riwayat Poin** di kartu pelanggan, di samping "Edit Profile" |

## 5. Urutan pengerjaan

1. File SQL migrasi, lalu uji di database lokal.
2. `poin.service.js`.
3. Ubah `addTransaksi.js`.
4. Ubah `updateTransaksi.js` (pembatalan).
5. Endpoint GET riwayat dan POST penyesuaian.
6. Frontend: service, hook, modal riwayat, modal penyesuaian, pasang di dua halaman.
7. Verifikasi (bagian 6).

Migrasi dan deploy backend sebaiknya dilakukan berdekatan. Transaksi member yang masuk di antara keduanya akan menambah poin tanpa baris riwayat. Query rekonsiliasi di atas bisa menangkap dan memperbaiki selisih itu.

## 6. Verifikasi

Repo belum punya test otomatis, jadi verifikasinya manual di lokal:

- **Transaksi member:** belanja Rp55.000 menambah 5 poin dan muncul satu baris riwayat dengan kode transaksi dan nama kasir. Belanja Rp9.000 tidak menambah baris.
- **Penyesuaian:** tambah, kurangi, dan kurangi melebihi saldo (harus ditolak). Cek poin di daftar pelanggan dan baris riwayat dengan username owner dan alasan.
- **Pembatalan:**
  - Normal: poin berkurang dan baris `pembatalan_transaksi` muncul.
  - Saldo kurang: poin menjadi 0, tidak negatif.
  - Dibatalkan dua kali: poin ditarik sekali saja.
  - Transaksi guest: tidak ada efek.
- **Akses:** kasir bisa GET riwayat tapi mendapat 403 di POST penyesuaian. Role admin mendapat 403 di keduanya.
- **Integritas:** query rekonsiliasi kosong. `UPDATE` atau `DELETE` langsung ke `riwayat_poin` ditolak trigger.
- **Frontend:** `npm run lint` dan `npm run build` di `fe-pos-web-app`, lalu cek tampilan modal di lebar mobile.

### Hasil verifikasi (database uji lokal, hasil restore dari `backup_dbfromrailway29sep26.sql`)

Lolos:

- Migrasi: rekonsiliasi kosong, `UPDATE`/`DELETE` ditolak trigger, CHECK saldo menolak baris tidak konsisten.
- Transaksi member Rp56.000 menambah 5 poin dan tercatat dengan kode transaksi dan kasir. Belanja Rp9.000 dan transaksi guest tidak menambah baris. `total_pembelian` dan `frekuensi_transaksi` tetap bertambah.
- Penyesuaian: tambah, kurangi, kurangi melebihi saldo (400), validasi input (alasan pendek, tipe salah, jumlah 0 atau desimal, body kosong), id tidak ada atau bukan UUID (404). Kasir dan admin mendapat 403, tanpa token 401.
- Pembatalan: normal (-5), dibatalkan dua kali, diaktifkan lalu dibatalkan lagi, dan dua request bersamaan, semuanya hanya menarik sekali. Saldo kurang sebagian (ditarik 3 dari 5), saldo nol (baris dengan perubahan 0), guest, dan belanja di bawah Rp10.000 tidak menarik poin.
- GET riwayat: kasir 200, admin 403, pagination dan batas `limit` 50, ringkasan benar, pelanggan tanpa riwayat tidak error.
- Rekonsiliasi akhir kosong.
- Frontend: `eslint` pada file yang diubah tanpa error, `npm run build` berhasil.

Belum diuji:

- Tampilan modal di browser (desktop dan lebar mobile) belum dilihat langsung.
- Migrasi belum dijalankan di database Railway.

## 7. Risiko dan rollback

- Perubahan database hanya menambah tabel, jadi tidak mengubah data yang ada. Rollback: revert kode, lalu `DROP TABLE riwayat_poin`.
- Menjalankan SQL ke database Railway adalah langkah produksi. Sebaiknya backup dulu (ada `backup_dbfromrailway29sep26.sql` sebagai contoh) lalu jalankan manual, atau beri izin eksplisit sebelum dijalankan dari sini.
- `updateTransaksi` diubah dari query biasa menjadi transaksi DB. Perilaku untuk pengguna tetap sama, tetapi jalur ini dipakai kasir dan admin, jadi perlu diuji.

## 8. Asumsi dan pertanyaan terbuka

1. **Bentuk input penyesuaian.** Diasumsikan owner memasukkan penambahan atau pengurangan (+/-), bukan menimpa dengan angka baru.
2. **Transaksi diaktifkan kembali.** `PATCH /transaksi` tidak memvalidasi nilai status, jadi `dibatalkan` bisa diubah lagi menjadi `berhasil`. Usulan: poin tidak dikembalikan otomatis, dan penarikan tetap hanya sekali karena unique index.
3. **`total_pembelian` dan `frekuensi_transaksi`.** Saat transaksi dibatalkan, keduanya tidak berkurang, jadi pelanggan tetap dihitung membeli. Ini di luar cakupan dan tidak diubah kecuali diminta.
4. **Poin dari transaksi di bawah Rp10.000.** Usulan: tidak mencatat baris dengan perubahan 0.
5. **Notifikasi ke owner untuk penyesuaian poin.** Tidak dibuat, karena owner sendiri yang melakukannya. Kalau mau ada, itu menambah satu tipe notifikasi.

## Keputusan yang sudah disepakati

- Kasir sudah bisa melihat poin pelanggan, jadi kasir juga boleh melihat riwayat poin (read-only).
- Data lama memakai **saldo awal**.
- Pembatalan transaksi **menarik poin kembali**, dibatasi minimal 0.
