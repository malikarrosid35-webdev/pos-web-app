# Rencana: Memberi role `owner` akses penuh

Status: **Fase 0-2 sudah diimplementasikan di working tree (belum di-commit); Fase 3 belum dimulai.** Keputusan di §8 sudah final. Lihat §11 untuk apa saja yang berubah, apa yang berbeda dari rencana ini, dan apa yang masih perlu diuji manual pada database yang berjalan.

## 1. Tujuan

Saat ini owner sebagian besar hanya bisa membaca. Tujuannya: owner bisa melakukan semua yang bisa dilakukan `admin` maupun `kasir`, ditambah hal-hal yang memang hanya bisa dilakukan owner sekarang (laporan, notifikasi, push).

### Kesenjangan saat ini (ditegakkan backend)

| Kemampuan | admin | kasir | owner sekarang | target owner |
|---|:-:|:-:|:-:|:-:|
| Tambah barang baru beserta stok awal (`POST /barang-masuk/new`) | ya | tidak | **tidak** | ya |
| Tambah stok barang yang sudah ada (`POST /barang-masuk/existing`) | ya | tidak | **tidak** | ya |
| Tambah / ubah pelanggan (`POST`, `PATCH /pelanggan`) | tidak | ya | **tidak** | ya |
| Buat penjualan (`POST /transaksi`) | tidak | ya | **tidak** | ya |
| Ubah transaksi (`PATCH /transaksi/:id`) | ya | ya | **tidak** | ya |
| Semua yang lain (lihat daftar, ubah harga barang, invoice, laporan, notifikasi, pengguna) | | | sudah ya | ya |

Di luar cakupan kecuali Anda minta lain (lihat §8): route yang **dikomentari di backend untuk semua role**, yaitu tambah/hapus barang, hapus pelanggan, hapus transaksi. Itu keputusan terpisah.

## 2. Cara akses bekerja sekarang (kenapa perubahannya kecil)

- `app.js` memasang satu rangkaian route bersama sebanyak tiga kali: `/api/admin`, `/api/kasir`, `/api/owner`. Prefix URL tidak memberi izin apa pun.
- Setiap route menjalankan `authorize([...roles])`, yang hanya memeriksa **role di dalam JWT** ([auth.middleware.js](be-pos-web-app/src/middlewares/auth.middleware.js)).
- Jadi ketika owner memanggil `POST /api/owner/transaksi`, route-nya sebenarnya sudah ada. Ia ditolak semata-mata karena `"owner"` tidak ada di daftar route itu.
- Tidak perlu perubahan database. `users_role_check` sudah mengizinkan `owner`, dan `transaksi.id_user` adalah foreign key ke `users` tanpa batasan role.

**Pembatasan path cookie penting untuk frontend.** Backend mengatur cookie tiap role dengan `path=/api/<role>` (`loginUser.js:71`). Sesi owner hanya dikirim ke `/api/owner/*`. Setiap panggilan dari owner yang lewat `kasirClient` atau `adminClient` (yang menuju `/api/kasir/*` atau `/api/admin/*`) akan tiba **tanpa cookie** dan gagal dengan 401. Semua penulisan data oleh owner harus memakai `ownerClient`.

## 3. Keputusan pendekatan (backend)

| | Opsi A: tambahkan `"owner"` ke daftar tiap route | **Opsi B (disarankan): owner melewati `authorize`** |
|---|---|---|
| Perubahan | edit ~8 file route | 1 baris di `authorize` |
| Route baru di kemudian hari | harus ingat menambahkan owner | owner otomatis tercakup |
| Jejak audit eksplisit per route | ya | tidak (aturan ada di satu tempat) |
| Masih bisa mengecualikan owner dari suatu route | ya | perlu jalan keluar khusus |

Rekomendasi: **Opsi B**, karena kebutuhannya berupa aturan ("owner punya semua akses"), bukan daftar, dan daftar mudah usang. Simpan aturan itu di satu tempat bernama, misalnya `const SUPER_ROLES = ["owner"]`, dan dokumentasikan. Jika Anda lebih suka mengaudit akses per route, pakai Opsi A; rencana di bawah berlaku untuk keduanya.

## 4. Fase 0: prasyarat keamanan (kerjakan lebih dulu)

Ini jadi lebih penting begitu akun owner berkuasa penuh.

1. **`POST /api/auth/register` bersifat publik dan mempercayai field `role`.**
   [authRoutes.js:9](be-pos-web-app/src/routes/auth/authRoutes.js#L9) tidak punya `authenticate`/`authorize`, dan [registerUser.js](be-pos-web-app/src/controllers/auth/registerUser.js) memasukkan `role` apa pun yang dikirim pemanggil. Siapa pun yang bisa menjangkau API dapat membuat akun `owner`. Perbaikan: wajibkan `authenticate` + role owner, atau hapus route-nya dan isi pengguna lewat cara lain. Validasi juga `role` terhadap `owner|admin|kasir`. *Jika ini sudah di-deploy (repo berisi dump DB Railway), anggap mendesak dan terlepas dari fitur ini.*
2. **`addTransaksi` mempercayai `id_user` yang dikirim klien.**
   [addTransaksi.js:17](be-pos-web-app/src/controllers/transaksi/addTransaksi.js#L17): `idUserFromBody || req.user.id_user`. Pemanggil bisa mengatasnamakan penjualan ke pengguna mana pun. Frontend selalu mengirim `id_user: null`, jadi perbaikannya aman: selalu pakai `req.user.id_user`.
3. **Admin bisa menimpa password owner.**
   `PATCH /users/:id_user` mengizinkan `admin` dan `owner` dan bisa mengatur `username`/`password` pengguna mana pun ([updateUser.js](be-pos-web-app/src/controllers/auth/updateUser.js)). Tambahkan penjaga: hanya owner yang boleh mengubah akun owner. Perhatikan juga controller menjalankan UPDATE dua kali (sekali tanpa `RETURNING`, sekali dengan); buang yang pertama.

## 5. Fase 1: perubahan backend

| # | Perubahan | File | Catatan |
|---|---|---|---|
| B1 | Owner melewati `authorize` (Opsi B) | `middlewares/auth.middleware.js` | `roles.includes(role) \|\| SUPER_ROLES.includes(role)` |
| B2 | Label pelaku: penjualan owner saat ini tertulis "Kasir" | `controllers/transaksi/addTransaksi.js:242` | `admin→Admin`, `owner→Owner`, selain itu `Kasir` |
| B3 | Pakai hanya `req.user.id_user` sebagai pengguna penjualan | file yang sama, baris 17 | dari Fase 0 |
| B4 | Penjaga: hanya owner yang boleh mengubah akun owner | `controllers/auth/updateUser.js` | dari Fase 0 |
| B5 | Kunci `/auth/register` | `routes/auth/authRoutes.js` | dari Fase 0 |
| B6 | Putuskan: apakah penjualan owner sendiri perlu memberi notifikasi ke owner? | `notifications/notification.service.js` | lihat §8 no. 4 |

Hasil efektif B1 tanpa mengedit route: owner mendapat `POST /barang-masuk/new`, `POST /barang-masuk/existing`, `POST|PATCH /pelanggan`, `POST /transaksi`, `PATCH /transaksi/:id`. Perilaku admin dan kasir tidak berubah.

Efek samping yang perlu diperkirakan di backend:

- Penjualan yang dibuat owner disimpan dengan `id_user` owner. Layar histori menampilkan nama pengguna itu di field `kasir` (`u.username AS kasir` di `getAllTransaksi`, `searchTransaksi`, `getTransaksiById`, `downloadInvoicePdf`), sehingga username owner muncul sebagai kasir di invoice dan halaman detail. Ini benar, tetapi perlu dipastikan memang diinginkan.
- `sendTransactionCreated` tetap berjalan, jadi owner menerima notifikasi push/SSE untuk penjualannya sendiri (lihat no. 4).

## 6. Fase 2: perubahan frontend

Bagian-bagian yang bisa dipakai ulang sudah ada, tetapi terikat ke satu role. Pekerjaannya sebagian besar **memparameterkan `mode`** dan menyambungkan layar owner, bukan menulis UI baru.

### 6.1 Service dan hook (harus memakai `ownerClient` untuk owner)

| File | Masalah saat ini | Perubahan |
|---|---|---|
| `shared/services/transaksiService.js` | `createTransaksi` memakai `kasirClient` | tambah `createTransaksiOwner` atau terima `mode` |
| `shared/services/pelangganService.js` | `createPelanggan`/`updatePelanggan` memakai `kasirClient` | tambah varian owner / `mode` |
| `shared/services/barangMasukService.js` | `createBarangMasukNew/Existing` memakai `adminClient` | tambah varian owner / `mode` |
| `shared/hooks/useTransaksi.js` | `addTransaksi` tidak punya cabang mode | arahkan berdasarkan `mode` |
| `shared/hooks/usePelanggan.js` | `create`/`update` tidak punya cabang mode | arahkan berdasarkan `mode` |
| `shared/hooks/useBarangMasuk.js` | `createNew`/`createExisting` tidak punya cabang mode | arahkan berdasarkan `mode` |

### 6.2 Halaman dan komponen

| Fitur | Yang dikerjakan | Dipakai ulang |
|---|---|---|
| **Buat Transaksi** (menu owner baru + route `/owner/buat-transaksi`) | `TransaksiFormPage` menulis permanen `mode: "kasir"` di tiga hook; terima prop `mode` | `TransaksiFormPage` kasir |
| **Barang Masuk** (ganti "Riwayat Barang Masuk" yang hanya-baca dengan tab: Barang Baru / Barang Existing / Riwayat) | `FormBarangMasukBaru`/`Existing` menulis permanen `mode: "admin"`; terima prop `mode`. Halaman admin juga memanggil `adminClient.get("/barang")` langsung; arahkan lewat `mode` | form admin |
| **Daftar Pelanggan**: tambah "Tambah" dan "Edit" | tambah tombol dan state modal | `PelangganForm` kasir |
| **Navigasi owner**: `SidebarOwner` + `OwnerRoutes` | tambah "Buat Transaksi", ubah nama "Riwayat Barang Masuk" menjadi "Barang Masuk" | yang sudah ada |
| Tampilan | komponen yang dipakai ulang memakai kelas Tailwind hijau (kasir) dan biru (admin); tema owner adalah violet. Terima tampilan campuran untuk rilis pertama atau tambahkan prop tema | opsional |

Tidak perlu perubahan untuk: login, `ProtectedRoute`, auth store, logika axios/refresh (tiap role sudah punya client dan path refresh sendiri), laporan, notifikasi, dashboard owner.

### 6.3 Perbaiki sebelum memakai ulang form penjualan

Owner akan mewarisi bug yang sudah ada di form penjualan (lihat `fe-pos-web-app/FRONTEND_NOTES.md` §14.1): `addTransaksi` menelan error, sehingga penjualan yang gagal tetap mengosongkan keranjang. Perbaiki itu **lebih dulu**, kalau tidak bug tersebut mendapat pintu masuk kedua. Terkait: kartu histori kasir di mobile menampilkan teks placeholder yang ditulis permanen (§14.2); histori owner tidak mengalami ini, tetapi datanya sama-sama dipakai kasir.

### 6.4 Opsional (Fase 3)

- Halaman **Kelola Pengguna** (daftar pengguna, ubah username/password) memakai `GET /users` dan `PATCH /users/:id` yang sudah ada. Backend sudah mendukungnya; hanya belum ada UI.
- Halaman daftar/cabut sesi (`/auth/me/sessions`, khusus owner, saat ini tanpa UI).
- Kesetaraan dashboard owner: tampilkan "barang masuk hari ini" seperti dashboard admin (store owner menulis permanen nilainya 0).

## 7. Ringkasan dampak

| Area | Dampak |
|---|---|
| Database | tidak ada (tanpa migrasi) |
| Backend | perubahan `authorize` ditambah 4 edit kecil di controller/route. Admin dan kasir tidak terpengaruh. |
| Frontend | 3 file service, 3 hook, 4 file halaman/komponen yang diparameterkan lewat `mode`, 2 file navigasi owner. Layar admin dan kasir tidak berubah selama default `mode` dipertahankan. |
| Auth/sesi | tidak ada, tetapi **setiap penulisan oleh owner harus lewat `ownerClient`** (path cookie) |
| Notifikasi | penjualan yang dibuat owner memicu notifikasi ke owner (diputuskan di no. 4) |
| Data/pelaporan | penjualan yang dibuat owner tampil dengan username owner di kolom `kasir`; laporan dan total ikut menghitungnya |
| Keamanan | Fase 0 menutup tiga celah yang sudah ada; poin keempat (owner melewati `authorize`) memperluas apa yang bisa dilakukan jika sesi owner dicuri |

## 8. Keputusan (sudah dikonfirmasi)

1. **Apakah owner boleh membuat penjualan?** **Ya** ("akses penuh"), dicatat atas `id_user` owner sendiri.
2. **Sertakan aksi yang dinonaktifkan untuk semua role?** (tambah/hapus barang, hapus pelanggan, hapus barang masuk, hapus transaksi.) **Tidak**; aksi ini merusak, dan baris `detail_transaksi` menunjuk barang lewat `id_barang` (dump skema mencantumkan index di sana tetapi tidak ada foreign key), sehingga menghapus barang akan membuat penjualan lama merujuk barang yang hilang. Jika ya, itu perubahan terpisah yang juga mengaktifkan kembali route backend untuk semua role.
3. **Apakah UI manajemen pengguna masuk cakupan?** **Belum sekarang.** Pertahankan pembuatan pengguna sebagai API khusus owner (dipindahkan, lihat §11); halaman kecil "Kelola Pengguna" (buat + reset password) bisa menyusul.
4. **Apakah owner diberi notifikasi atas penjualannya sendiri?** **Ya, dipertahankan** (feed ini sekaligus menjadi log audit), dengan label "Owner". Fitur bisukan bisa ditambahkan nanti bila terasa mengganggu.
5. **Apakah admin dan kasir tetap persis seperti akses mereka sekarang?** **Ya**, dengan satu pengecualian yang disengaja: admin tidak lagi bisa mengubah akun owner.
6. **Username owner tampil sebagai kasir pada penjualannya sendiri?** **Ya**; label di layar "Kasir" diganti menjadi "Petugas".

## 9. Daftar verifikasi

Frontend belum punya test otomatis, jadi verifikasinya manual. Backend sekarang punya 4 test untuk `authorize` (lihat §11), tetapi belum ada test tingkat route atau yang menyentuh database, jadi daftar di bawah tetap harus dijalankan manual.

Backend (curl atau Postman, satu sesi per role):

- [ ] owner: `POST /api/owner/barang-masuk/new` dan `/existing` mengembalikan 201; `POST /api/owner/pelanggan`, `PATCH …/pelanggan/:id`, `POST /api/owner/transaksi`, `PATCH /api/owner/transaksi/:id` berhasil
- [ ] admin dan kasir: panggilan yang sebelumnya dilarang tetap mengembalikan **403** (misalnya kasir ke `/barang-masuk/new`, admin ke `/transaksi`)
- [ ] `POST /api/auth/register` tanpa autentikasi ditolak; pengguna terautentikasi bukan owner ditolak
- [ ] `POST /api/owner/transaksi` dengan `id_user` diisi pengguna lain menyimpan id **pemanggil**
- [ ] admin `PATCH /users/<id owner>` mengembalikan 403; owner tetap bisa mengubah akunnya sendiri
- [ ] teks notifikasi untuk penjualan owner berbunyi `Owner <username> …`, bukan "Kasir"

Frontend (login sebagai owner):

- [ ] DevTools Network: setiap penulisan baru oleh owner menuju `/api/owner/…` dan membawa cookie (tidak ada yang ke `/api/kasir` atau `/api/admin`)
- [ ] selesaikan satu penjualan dari awal sampai akhir: stok berkurang, histori menampilkannya, invoice PDF terunduh, owner menerima notifikasi
- [ ] tambah barang baru dan tambah stok barang yang ada; keduanya muncul di Daftar Barang dan di riwayat barang masuk
- [ ] tambah dan ubah pelanggan
- [ ] penjualan yang **gagal** (matikan backend) membuat keranjang tetap utuh (setelah perbaikan 6.3)
- [ ] login admin dan kasir tetap menampilkan menu yang persis sama seperti sebelumnya dan berperilaku sama
- [ ] sesi kedaluwarsa di halaman owner tetap mengarahkan ke login (jalur refresh tidak berubah)

## 10. Urutan kerja yang disarankan

1. Fase 0 (perbaikan keamanan B3, B4, B5), bisa dirilis sendiri.
2. B1 + B2 + verifikasi backend.
3. Perbaikan frontend 6.3, lalu service/hook 6.1, lalu halaman 6.2 (Barang Masuk → Pelanggan → Buat Transaksi).
4. Regresi manual pada ketiga role (§9).
5. Fase 3 hanya bila diinginkan.

## 11. Status implementasi

### Selesai

Backend (`be-pos-web-app/`)

- `middlewares/auth.middleware.js`: `authorize` sekarang meloloskan `SUPER_ROLES = ["owner"]` di semua route (B1).
- `controllers/transaksi/addTransaksi.js`: penjualan selalu diatasnamakan `req.user.id_user`; `id_user` kiriman klien diabaikan (B3). Label pelaku di notifikasi adalah `Admin` / `Owner` / `Kasir` (B2).
- `controllers/auth/updateUser.js`: hanya owner yang boleh mengubah akun owner (B4). Sekalian: satu UPDATE, bukan dua; tidak lagi mengembalikan hash password; username ganda menghasilkan 409.
- `POST /api/auth/register` (publik) dihapus. Pembuatan pengguna kini `POST /api/owner/users`, khusus owner (B5). `registerUser` memvalidasi `role`, mengembalikan `{ id_user, username, role }` (sebelumnya tidak mengembalikan apa pun), dan menjawab 409 untuk username ganda.
- `src/middlewares/auth.middleware.test.js` + `npm test` (test runner bawaan Node, tanpa dependency baru): 4 test yang mencakup owner melewati `authorize`, admin/kasir tetap terbatas, isi respons 403, role kosong/tidak dikenal.

Frontend (`fe-pos-web-app/`)

- Service menerima `mode` opsional dan memakai `ownerClient` untuk owner: `createTransaksi`, `createPelanggan`, `updatePelanggan`, `createBarangMasukNew`, `createBarangMasukExisting`. Default mempertahankan perilaku admin/kasir yang ada.
- Hook meneruskan `mode`: `useTransaksi`, `usePelanggan`, `useBarangMasuk`. `useBarang` mendapat opsi `catalog` agar owner bisa membangun daftar produk untuk form penjualan.
- `addTransaksi` kini mengembalikan respons (atau `null` bila gagal) dan menampilkan pesan error dari server; `TransaksiFormPage` berhenti saat menerima `null`, sehingga **penjualan yang gagal tidak lagi mengosongkan keranjang** (memperbaiki FRONTEND_NOTES §14.1).
- `TransaksiFormPage` menerima prop `mode` (default `kasir`). Route owner `/owner/buat-transaksi` memakai `mode="owner"`.
- "Barang Masuk" owner kini bertab (Barang Baru / Barang Existing / Riwayat) memakai form admin dengan `mode="owner"`. Route-nya `/owner/barang-masuk`; `/owner/riwayat-barang-masuk` yang lama dialihkan ke sana.
- "Daftar Pelanggan" owner punya Tambah dan Edit (memakai ulang `PelangganForm` kasir).
- Sidebar: ditambah "Buat Transaksi", "Riwayat Barang Masuk" diganti nama menjadi "Barang Masuk".
- Halaman detail menampilkan "Petugas:" menggantikan "Kasir:".

### Berbeda dari rencana

- **Register dipindahkan, bukan sekadar dikunci.** Cookie owner dibatasi path ke `/api/owner`, jadi route khusus owner di `/api/auth/register` tidak akan pernah menerimanya dari browser. Sekarang route-nya ada di `POST /api/owner/users`. Apa pun yang memanggil `/api/auth/register` akan berhenti bekerja (tidak ada yang melakukannya di repo ini). Untuk membuat pengguna pertama di database baru, masukkan lewat SQL.
- Tambahan kecil di luar rencana: opsi `catalog` di `useBarang`, `updateUser` tidak lagi membocorkan hash password, `npm test`.

### Belum dikerjakan

- Fase 3 (halaman Kelola Pengguna, halaman sesi, kesetaraan dashboard).
- Warna tema owner pada komponen yang dipakai ulang: form penjualan dan modal pelanggan tetap berwarna hijau, form barang masuk tetap biru.
- Invoice PDF masih mencetak label apa pun yang dipakai template-nya untuk kasir; saya tidak menemukan atau mengubah template-nya.
- Masalah lama yang tidak disentuh: placeholder histori kasir di mobile (§14.2 di catatan), 3 error lint di `TransaksiFormPage` (`navigate`, `successData`, `handleTransaksiBaru` yang tidak dipakai; ada juga di versi yang sudah di-commit).

### Sudah diverifikasi

- Backend: semua file yang diedit lolos `node --check`; `npm test` lolos 4/4.
- Frontend: `npm run build` berhasil; ESLint tidak menunjukkan error baru (3 error di atas sudah ada sebelumnya); peringatan baru mengikuti pola `useEffect` yang sudah ada di basis kode.

### Belum diverifikasi (perlu database yang berjalan dan browser)

Saya tidak bisa memuat modul route secara penuh (membutuhkan kredensial Firebase) dan belum ada yang dicoba terhadap PostgreSQL maupun di browser. Daftar di §9 masih harus dijalankan manual, terutama: panggilan tulis owner membawa cookie owner, admin/kasir tetap mendapat 403 di tempat yang semestinya, `PATCH /users/<id owner>` oleh admin ditolak, `POST /api/auth/register` kini mengembalikan 404, penjualan yang gagal menyimpan keranjang, dan penjualan yang dibuat owner menampilkan "Owner" di notifikasi.
