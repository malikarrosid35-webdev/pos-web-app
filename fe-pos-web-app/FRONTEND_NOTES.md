# Frontend POS (`fe-pos-web-app`) — Catatan Kerja

> **Pembaruan:** role owner kemudian diberi akses penuh (lihat `../PLAN_OWNER_FULL_ACCESS.md`, §11). Bagian 1, 5, 11, dan 14.1 di bawah menjelaskan kode **sebelum** perubahan itu. §15 sudah mencerminkan kondisi terbaru.

Catatan ini dibuat dari membaca seluruh kode `fe-pos-web-app` (sekitar 8.200 baris JSX di kurang lebih 90 file sumber). Semua path relatif terhadap `fe-pos-web-app/`. Bila sebuah klaim berasal dari membaca kode (bukan dari menjalankannya), saya sebutkan. Saya tidak menjalankan aplikasinya, dan memang belum ada test yang bisa dijalankan.

## 1. Apa ini

Aplikasi Point-of-Sale (kasir) berbasis web untuk toko kelontong kecil di Indonesia ("Toko Kelontong"). Semua teks antarmuka berbahasa Indonesia. Ini satu SPA React dengan **tiga area berbasis role**, masing-masing punya layout, tema warna, dan namespace API sendiri:

| Role | Prefix URL | Tema | Fungsi |
|---|---|---|---|
| `admin` | `/admin/*` | slate + biru | Mengelola stok: tambah barang baru, tambah stok barang yang sudah ada, ubah harga |
| `kasir` (cashier) | `/kasir/*` | hijau | Menjalankan penjualan, melihat histori transaksi, mengelola pelanggan member |
| `owner` | `/owner/*` | ungu (violet) | Dashboard dan laporan (hanya baca), notifikasi, ubah harga barang |

Aplikasi ini juga bisa dipasang sebagai **PWA**, dan role owner mendapat **push notification** (Firebase Cloud Messaging) serta aliran **SSE** langsung.

## 2. Tech stack

| Aspek | Pilihan |
|---|---|
| Build | Vite 7, `@vitejs/plugin-react` |
| UI | React 19, Tailwind CSS 4 (`@tailwindcss/vite`, cukup `@import "tailwindcss"` di `src/index.css`) |
| Routing | `react-router-dom` 7 (`BrowserRouter`, route tree tiap role di-lazy-load) |
| State | Zustand 5 |
| HTTP | Axios 1.x, autentikasi cookie (`withCredentials`) |
| Grafik | Recharts 3 |
| Dialog/toast | SweetAlert2 (dipakai di mana-mana, termasuk toast) |
| Ikon | `lucide-react` (ditambah beberapa SVG inline) |
| Push | Firebase 12 (`firebase/messaging`) |
| PWA | `vite-plugin-pwa` (Workbox, `autoUpdate`) |
| Lint | ESLint 9 flat config (react-hooks, react-refresh) |
| Bahasa | JavaScript biasa (tanpa TypeScript), tanpa test |

## 3. Menjalankan

```text
npm run dev       # vite --host (bisa diakses dari LAN), service worker PWA aktif saat dev
npm run build
npm run preview
npm run lint
```

Environment (`.env`, lihat `.env.example`):

- `VITE_API_ORIGIN` — origin backend (tanpa garis miring di akhir). Kosong berarti same-origin, itulah cara kerja dev proxy.
- `VITE_FIREBASE_*` (API key, auth domain, project id, storage bucket, messaging sender id, app id) dan `VITE_FIREBASE_VAPID_KEY`.
- `VITE_BACKEND_TARGET` — dibaca oleh `vite.config.js` untuk dev proxy (default `http://127.0.0.1:5000`). **Tidak tercantum di `.env.example`.**

Dev proxy: `/api` dan `/invoices` diteruskan ke backend (`vite.config.js`). Produksi di-deploy ke Vercel; [vercel.json](vercel.json) me-rewrite semua path kecuali `/api/*` dan `/invoices/*` ke `index.html` (fallback SPA).

## 4. Struktur direktori

```text
src/
├── main.jsx, App.jsx          # entry; route tingkat atas (/login, /admin/*, /kasir/*, /owner/*)
├── routes/                    # AdminRoutes / KasirRoutes / OwnerRoutes: layout + sub-route per role
├── auth/                      # LoginPage, ProtectedRoute, authService (login/logout)
├── lib/
│   ├── http/                  # axiosBase (interceptor), adminClient/kasirClient/ownerClient, apiOrigin
│   └── firebase/              # firebaseConfig (env → app, messaging)
├── stores/                    # store Zustand
├── shared/
│   ├── services/              # satu fungsi per endpoint API
│   ├── hooks/                 # useBarang, useTransaksi, ... + useFcmNotification, usePwaInstall
│   ├── components/            # OfflineBanner, PwaInstallBanner (PaginationControl sudah mati, lihat §13)
│   └── utils/                 # numberFormat, qtyFormat, subTotalPriceHelper, ownerNotificationHelper
├── admin/{pages,components}
├── kasir/{pages,components}
└── owner/{pages,components}
public/firebase-messaging-sw.js  # service worker FCM untuk pesan di background
```

## 5. Routing dan layout

`App.jsx` me-lazy-load halaman login dan route tree tiap role, dibungkus `Suspense`. Path `/` dan path yang tidak dikenal diarahkan ke `/login`. `OfflineBanner` dirender di atas semuanya.

Setiap `*Routes.jsx` membungkus route-nya dengan `<ProtectedRoute role="...">` dan merender sidebar plus area konten.

**Admin** (`/admin`, index → `dashboard`)

- `dashboard` — dua kartu statistik (total barang, barang masuk hari ini)
- `barang-masuk` — tab: Barang Baru / Barang Existing / Riwayat
- `daftar-barang` — tabel + modal edit
- Sidebar hanya bergaya desktop (bisa diciutkan). Tidak ada drawer untuk mobile.

**Kasir** (`/kasir`, index → `buat-transaksi`)

- `buat-transaksi` — form penjualan (§9)
- `histori-transaksi` — histori berhalaman dengan pencarian, unduh invoice PDF
- `detail-transaksi/:id`
- `daftar-pelanggan` — daftar member dengan tambah/edit
- Responsif: di bawah 1024px sidebar menjadi drawer overlay dengan bar hamburger hijau.

**Owner** (`/owner`, index → `dashboard`)

- `dashboard` — kartu statistik + grafik garis penjualan dengan rentang tanggal
- `laporan-toko` — tab laporan mingguan / bulanan / tahunan
- `riwayat-barang-masuk`, `daftar-barang`, `histori-transaksi`, `detail-transaksi/:id`, `daftar-pelanggan`
- `notifikasi`, `detail-notifikasi/:id`
- Pola drawer responsif yang sama seperti kasir, ditambah `OwnerTopbar` (judul halaman, lonceng notifikasi).
- Memasang `useFcmNotification({ enabled: role === "owner" })`.

Sidebar mengisi `useUIStore.activeTab` saat diklik, dan tiap halaman juga mengisinya saat dimuat. Nilai itu menyorot item sidebar dan menjadi judul topbar owner.

## 6. Autentikasi dan model sesi

**Login** ([auth/authService.js](src/auth/authService.js)): `POST {API_ORIGIN}/api/auth/login` dengan `withCredentials`. Respons berisi `user` (beserta `role`). `LoginPage` mengarahkan berdasarkan role dan memetakan kode error server (`USERNAME_NOT_FOUND`, `INVALID_PASSWORD`, `SERVER_ERROR`, HTTP 429 untuk rate limit) ke pesan SweetAlert berbahasa Indonesia. SweetAlert di-import secara dinamis di sana supaya chunk halaman login tetap kecil.

**Token** berupa cookie `httpOnly` yang diatur backend. Frontend tidak pernah menyentuh JWT. Dari kode backend (`loginUser.js:71,100`): cookie **dibatasi path per role** (`rolePathMap[user.role]`), sehingga sesi admin, kasir, dan owner bisa hidup berdampingan di satu browser tanpa saling menimpa.

**Sesi sisi klien** ([stores/useAuthStore.js](src/stores/useAuthStore.js)):

- `localStorage["authStore"]` menyimpan `{ admin, kasir, owner }`, masing-masing `{ user, role }` atau `null`.
- Saat halaman dimuat, role yang *aktif* ditentukan dari `window.location.pathname` (`/admin…`, `/kasir…`, `/owner…`). Jadi tiap tab bisa berbeda role.
- `setUser` (login) menulis slot role tersebut. `clearUser(role?)` mengosongkannya.
- `ProtectedRoute` hanya memeriksa bahwa `role` saat ini di store sama dengan role route; jika tidak, diarahkan ke `/login`. Ini hanya gerbang UI; otorisasi sebenarnya dilakukan server.

**Refresh dan kedaluwarsa** ([lib/http/axiosBase.js](src/lib/http/axiosBase.js)): `createAxios(roleBasePath)` membuat satu instance Axios per role (`/api/admin`, `/api/kasir`, `/api/owner`).

- Saat menerima 401 (sekali per request, flag `_retry`), ia memanggil `POST /api/{role}/auth/refresh`. 401 yang terjadi bersamaan berbagi satu promise refresh yang sedang berjalan (per instance).
- Jika refresh gagal dengan 401/403, `handleSessionExpired()` mengosongkan sesi role itu, menampilkan SweetAlert, lalu redirect paksa ke `/login`. Flag tingkat modul mencegah alert ganda.

**Logout**: `logout()` lebih dulu melepas token FCM perangkat ini (khusus owner, selagi cookie masih valid), lalu `POST /api/{role}/auth/logout`, dan selalu mengosongkan sesi lokal di `finally`.

## 7. Pola lapisan data

Setiap fitur mengikuti empat lapisan yang sama:

```text
page ──▶ hook (useX({ mode })) ──▶ service (getXAdmin / getXKasir / getXOwner) ──▶ axios client per role
            │
            └─ menaruh hasil ke store Zustand lewat setter yang dilewatkan, menampilkan SweetAlert saat error
```

- **Service** ([shared/services/](src/shared/services)) tipis: satu fungsi per endpoint, dengan varian `...Admin`, `...Kasir`, `...Owner` yang hanya berbeda pada client yang dipakai.
- **Hook** ([shared/hooks/](src/shared/hooks)) menerima `mode: "admin" | "kasir" | "owner"` (melempar error bila tidak diisi) dan bercabang berdasarkan itu. Hook memegang state `loading` / `error` / `meta` dan dialog sukses/error untuk pengguna. Beberapa menambahkan umpan balik notifikasi owner dari `ownerNotificationHelper` ke pesan sukses ("Notifikasi owner: …").
- **`useBarang` pada mode kasir berbeda perilakunya**: alih-alih memanggil `setBarang`, ia mengelompokkan barang berdasarkan `kategori_barang` ke `groupedProducts` dan memetakan ulang field menjadi `{ id, name, satuan_dasar, price, stock, category }`. Form kasir lalu meratakannya kembali.
- Bentuk respons yang diasumsikan di mana-mana: `res.data.data || res.data.rows`, dengan `res.data.meta = { page, limit, total_data, total_page }`.
- **Default paginasi berbeda tiap endpoint** (dicek di controller backend): `GET /barang` mengembalikan *semua* baris tanpa paginasi bila `limit` tidak diisi (`be-pos-web-app/src/controllers/barang/getBarang.js:8`). `GET /pelanggan` dan `GET /transaksi` default `limit=10`. Frontend mengandalkan kedua perilaku ini (lihat §9 dan §14.6).

### Store Zustand

| Store | Isi | Status |
|---|---|---|
| `useAuthStore` | sesi per role (disimpan permanen) | dipakai |
| `useUIStore` | `activeTab` (sorotan sidebar / judul topbar) | dipakai; `activeTabKasir` tidak dipakai |
| `useBarangStore` | daftar barang, query pencarian | dipakai Daftar Barang admin dan owner, `BarangModal` |
| `useBarangMasukStore` | daftar barang masuk | dipakai |
| `useDashboardStore` | statistik + penjualan per rentang tanggal | dipakai dashboard owner, kartu admin |
| `usePelangganStore` | daftar pelanggan | dipakai |
| `useTransaksiStore` | hanya `pelangganTerpilih` (field lain tidak dipakai) | dipakai `TransaksiFormPage` |
| `useCartStore` | keranjang dengan konversi gram/ons/kg | **mati**: hanya di-import oleh file yang dikomentari |

`useTransaksiStore` punya komentar panjang yang menjelaskan bahwa `pelangganTerpilih` sengaja *tidak lagi* disimpan ke `localStorage`, karena dulu refresh halaman membuat pelanggan sebelumnya masih terpilih tanpa disadari.

## 8. Satuan, uang, dan format angka

Kuantitas stok dan penjualan disimpan sebagai **bilangan bulat dalam satuan dasar barang** (`satuan_dasar`): `GRAM` untuk barang timbangan, `PCS` untuk lainnya.

- Kasir dan admin boleh *memasukkan* berat sebagai `GRAM`, `ONS` (1 ons = 100 g) atau `KG` (1 kg = 1000 g). Semuanya dikonversi ke gram sebelum dikirim. Barang PCS hanya menerima bilangan bulat (input memblokir `.`, `,`, `e`, `+`, `-`).
- Field harga adalah **per satuan dasar** (`harga_jual_per_sd`, `harga_modal_per_sd`, yaitu per gram atau per buah).
- **Pembulatan subtotal gram**: [roundKasirGramSubtotal](src/shared/utils/subTotalPriceHelper.js) membulatkan **ke atas** ke kelipatan Rp 500 berikutnya. Hanya barang gram yang dibulatkan; subtotal PCS tepat.
- [numberFormat.js](src/shared/utils/numberFormat.js): format Indonesia. `.` pemisah ribuan dan `,` desimal. `formatToRupiah(12500)` menghasilkan `Rp12.500`. `parseNumber` adalah kebalikannya.
- [qtyFormat.js](src/shared/utils/qtyFormat.js): `formatQty(1500, "GRAM")` menghasilkan `1.5 kg`, `500` menghasilkan `500 gr`, dan PCS menghasilkan `N pcs`. Nilai dipotong ke bilangan bulat lebih dulu.

## 9. Alur penjualan kasir (inti aplikasi)

[kasir/pages/TransaksiFormPage.jsx](src/kasir/pages/TransaksiFormPage.jsx), satu halaman tiga langkah:

1. **Pilih Pelanggan**: cari member (berdasarkan nama atau nomor HP) atau lanjut sebagai **Guest**. `pelangganStep` bernilai `idle | member_selected | guest`. "Ganti" mereset langkah, mengosongkan item dan pembayaran. Daftar member tanpa pencarian adalah halaman pertama dari backend (10 member), jadi kasir harus mencari untuk menemukan member di luar itu.
2. **Pilih Barang**: seluruh katalog diambil sekali (`fetchBarang()` tidak mengirim `limit`, sehingga backend mengembalikan semua barang) lalu disaring di sisi klien berdasarkan nama. Barang dengan stok nol tidak bisa dipilih (alert, ditambahkan di commit `7094840`). Untuk tiap baris: jumlah, satuan (hanya barang gram), dan pengecekan stok `sudah di daftar + baru > stok`. Baris dengan barang dan satuan yang sama digabung.
3. **Pembayaran**: input uang diformat langsung, dibatasi **Rp 500.000** (`MAX_BAYAR`). Tombol cepat: *Bayar Pas*, +10K, +20K, +50K, +100K. Kembalian (`kembalian`) = `max(bayar − total, 0)`. Tombol kirim nonaktif selama pembayaran kurang.

Payload yang dikirim ke `POST /api/kasir/transaksi`:

```js
{
  tipe_pelanggan: "member" | "guest",
  id_pelanggan: <id atau null>,
  id_user: null,
  jumlah_bayar: <number>,
  items: [{ id_barang, quantity /* satuan dasar */, subtotal /* dihitung di klien */ }]
}
```

Klien menghitung dan mengirim `subtotal` per baris. Saya tidak memeriksa apakah backend menghitung ulang atau mempercayainya.

Histori dan detail: [HistoriTransaksiPage](src/kasir/pages/HistoriTransaksiPage.jsx) men-debounce pencarian 400 ms dan bertanya ke server (bukan menyaring di klien). Tombol unduh mengambil invoice PDF sebagai blob (`/transaksi/:id/invoice/download`) dan menyimpannya sebagai `invoice-trx-<6 karakter terakhir id>.pdf`.

## 10. Alur admin

- **Barang Masuk → Barang Baru** ([FormBarangMasukBaru](src/admin/components/barangMasuk/FormBarangMasukBaru.jsx)): nama, satuan dasar (PCS/GRAM), stok awal (dengan bantuan gram/ons/kg), **total harga beli** dan harga jual per satuan dasar. Harga beli per satuan dasar diturunkan (`total / qty`). `POST /barang-masuk/new`.
- **Barang Existing** ([FormBarangMasukExisting](src/admin/components/barangMasuk/FormBarangMasukExisting.jsx)): pilih barang, jumlah, total harga; biaya per satuan diturunkan. `POST /barang-masuk/existing` dengan `{ id_barang, qty_dasar, harga_beli_per_sd }`.
- **Riwayat**: histori berhalaman dengan pencarian kata kunci.
- **Daftar Barang**: tabel dengan modal Edit. Hanya nama dan harga jual yang bisa diubah; stok dan harga beli hanya baca ("gunakan Barang Masuk"). Handler hapus ada di hook, tetapi tombol hapus di tabel dikomentari.

## 11. Fitur owner

- **Dashboard**: tiga kartu statistik (barang, transaksi, pelanggan) dan grafik garis penjualan harian pada rentang tanggal. Statistik dihitung dengan memanggil endpoint daftar lalu membaca `meta.total_data`.
- **Laporan Toko**: mingguan (`/reports/weekly`, 7 hari terakhir, grafik + tabel), bulanan (`/reports/monthly?year&month`, dua kartu statistik), tahunan (`/reports/yearly?year`).
- **Cermin hanya-baca** dari data role lain: Riwayat Barang Masuk, Histori Transaksi (+ detail + invoice PDF), Daftar Pelanggan.
- **Daftar Barang** bisa diedit (commit terbaru `81c3f7b`): memakai ulang `BarangModal` milik admin dengan `mode="owner"`, dan `updateBarang` diarahkan ke `ownerClient` untuk mode owner.

### Notifikasi (khusus owner)

1. **Daftar di dalam aplikasi**: `OwnerTopbar` memuat halaman pertama `/notifications` dan menampilkan badge belum dibaca serta dropdown. Halaman `/owner/notifikasi` adalah daftar berhalaman. `/owner/detail-notifikasi/:id` menandai notifikasi sudah dibaca saat dibuka.
2. **Pembaruan langsung**: `OwnerTopbar` membuka `EventSource` ke `{API}/api/owner/notifications/stream` (dengan credentials), mendengarkan event `notification`, membuang duplikat berdasarkan `id_notification`, menaruhnya di depan daftar (maksimal 10), dan menambah hitungan belum dibaca. `source.onerror` hanya mencatat log; reconnect otomatis bawaan browser yang menangani sisanya.
3. **Push** ([useFcmNotification](src/shared/hooks/useFcmNotification.js)): saat owner login, ia mendaftarkan `/firebase-messaging-sw.js` (scope `/firebase-cloud-messaging-push-scope`, konfigurasi Firebase dikirim lewat query string), meminta izin notifikasi, mengambil token, menyimpannya di `localStorage` (`owner_fcm_registration_id`) dan `POST /fcm-tokens/register`. Mendukung API baru `register/onRegistered` maupun `getToken` lama. Pesan foreground tampil sebagai toast SweetAlert. Pesan background ditampilkan oleh service worker, dan mengkliknya membuka `/owner/detail-notifikasi/:id`.
4. **Notifikasi laporan harian** (`notification_type === "REPORT_DAILY"`) menampilkan ringkasan, transaksi tertinggi, tabel per item, dan unduhan PDF.

## 12. PWA dan offline

[vite.config.js](vite.config.js) mengonfigurasi `vite-plugin-pwa`: tampilan standalone, `start_url: /owner/dashboard`, warna tema `#4c1d95`, `registerType: "autoUpdate"`, dan `registerSW({ immediate: true })` di `main.jsx`.

Runtime caching Workbox:

- `/api/*` → **NetworkFirst** (timeout 10 dtk, 64 entri, 1 jam)
- `/invoices/*` → **CacheFirst** (32 entri, 7 hari)
- Navigation fallback ke `/index.html`, dengan pengecualian `/api/` dan `/invoices/`

`OfflineBanner` menampilkan banner merah saat event `offline`. `PwaInstallBanner` (hanya di halaman login) menangkap `beforeinstallprompt` untuk tombol pasang kustom.

Output build dipecah menjadi chunk vendor manual: `vendor-react` (react, react-dom, router, scheduler), `vendor-charts` (recharts, d3), `vendor-firebase`, `vendor-ui` (sweetalert2, lucide).

## 13. Kode mati dan kode yang dikomentari

File yang isinya 100% komentar (nol baris aktif, tidak di-import oleh kode yang hidup):

| File | Keterangan |
|---|---|
| `kasir/pages/TransaksiBarangPage.jsx` | 887 baris, UI penjualan lama berbasis katalog dan keranjang |
| `kasir/pages/CartPage.jsx` | checkout keranjang lama |
| `kasir/components/ProductCard.jsx`, `ProductSlider.jsx` | kartu katalog produk |
| `shared/components/PaginationControl.jsx` | tidak pernah dipakai (lihat §14.6) |

Akibatnya: `useCartStore` dan logika pembulatan gramnya praktis tidak terpakai, dan repositori membawa desain alur checkout yang lama.

Sisa-sisa yang lebih kecil: blok lonceng notifikasi di `admin/components/Header.jsx` dikomentari; `useBarang.remove`, `useBarangMasuk.remove` dan `fetchBarangMasukById`, serta `deletePelanggan` tidak punya UI yang terhubung; cabang "create" di `BarangModal` tidak bisa dicapai (tidak ada tombol "tambah barang" di Daftar Barang).

## 14. Masalah dan hal yang perlu diwaspadai

Diurutkan kira-kira berdasarkan dampak. Semuanya berasal dari membaca kode; tidak ada yang direproduksi di aplikasi yang berjalan.

### 14.1 Transaksi yang gagal mengosongkan keranjang kasir (tinggi)

`addTransaksi` ([useTransaksi.js:135-148](src/shared/hooks/useTransaksi.js#L135-L148)) menangkap semua error, menampilkan dialog "Gagal", dan mengembalikan `undefined` tanpa melempar ulang. Pemanggilnya ([TransaksiFormPage.jsx:287-299](src/kasir/pages/TransaksiFormPage.jsx#L287-L299)) punya `try/catch` sendiri, tetapi tidak pernah melihat kegagalan itu, jadi ia melanjutkan seolah-olah penjualan berhasil: `setSuccessData(...)`, `setItems([])`, `setBayarInput("")`. Akibatnya kasir melihat "Transaksi gagal dibuat" sementara daftar barang dan nominal pembayaran terhapus dan harus dimasukkan ulang. `catch` di `handleBuatTransaksi` tidak pernah tercapai untuk kegagalan API.

Sisa-sisa terkait dari commit `1de77ee` ("remove second success modal"): `successData` di-set tetapi tidak pernah dirender ([:75](src/kasir/pages/TransaksiFormPage.jsx#L75), [:288](src/kasir/pages/TransaksiFormPage.jsx#L288)), `handleTransaksiBaru` ([:312](src/kasir/pages/TransaksiFormPage.jsx#L312)) tidak pernah dipanggil, dan `response` selalu `undefined` sehingga `ownerFeedback` selalu kosong. Karena `handleTransaksiBaru` tidak pernah dipanggil, **pelanggan yang terpilih tetap ada setelah penjualan berhasil**, dan penjualan berikutnya diam-diam memakai member sebelumnya kecuali kasir menekan "Ganti". Perlu dipastikan apakah ini disengaja.

### 14.2 Histori kasir di mobile menampilkan data palsu dan tanpa paginasi (tinggi)

[HistoriTransaksiPage.jsx:211-216](src/kasir/pages/HistoriTransaksiPage.jsx#L211-L216): daftar kartu mobile menulis permanen `TRX-1A2B3C` dan `01 Januari 2025` (`kode_transaksi` dan `formatDate(created_at)` yang asli dikomentari tepat di sebelahnya), sehingga setiap kartu di mobile menampilkan kode dan tanggal yang sama. Selain itu, kontrol paginasi ([:304](src/kasir/pages/HistoriTransaksiPage.jsx#L304)) berada di dalam container desktop `hidden md:block` ([:243](src/kasir/pages/HistoriTransaksiPage.jsx#L243)), sehingga di ponsel hanya halaman 1 yang bisa dijangkau.

### 14.3 Gagal diam-diam saat menyimpan edit barang (sedang)

[BarangModal.jsx:73-82](src/admin/components/barang/BarangModal.jsx#L73-L82) meng-`await update(...)`, tetapi `useBarang.update` tidak punya penanganan error dan `catch` di modal hanya memanggil `console.error`. Jika PATCH gagal, pengguna tidak melihat apa pun dan modal tetap terbuka. `create` punya celah yang sama.

### 14.4 Service worker menyimpan data API yang terautentikasi (sedang, perlu diverifikasi)

Aturan Workbox `NetworkFirst` untuk `/api/*` ([vite.config.js:67](vite.config.js#L67)) menyimpan respons per-pengguna yang terautentikasi cookie di Cache Storage, dengan kunci hanya URL. Tidak ada yang membersihkan cache itu saat logout. Di perangkat bersama, fallback offline bisa menyajikan data pengguna sebelumnya. Selain itu, `/api/owner/notifications/stream` cocok dengan pola URL yang sama; komentar "Do NOT cache SSE streams" ([:97](vite.config.js#L97)) tidak didukung oleh aturan pengecualian. Kedua poin ini adalah kesimpulan dari konfigurasi dan perlu diuji. `devOptions.enabled: true` juga berarti service worker berjalan saat `npm run dev`, yang bisa menimbulkan kebingungan aset basi.

### 14.5 Logging request yang berisik (rendah)

[axiosBase.js:47-49](src/lib/http/axiosBase.js#L47-L49) mencatat method, URL, `document.cookie`, dan `withCredentials` dari setiap request, dan alur refresh mencatat di baris 65, 79, dan 93. Ini berjalan di produksi. (Cookie `httpOnly` tidak muncul di `document.cookie`, jadi ini sekadar noise, bukan kebocoran token.) Backend juga mencatat cookie di `app.js:30`.

### 14.6 Fetch ganda dan kode hasil salin-tempel (rendah / pemeliharaan)

- Beberapa halaman melakukan fetch dua atau tiga kali saat dimuat karena beberapa effect masing-masing memicu fetch: `DaftarBarang` admin dan owner (tiga effect), `DaftarPelangganPage` kasir (dua), dan `TransaksiFormPage` (effect awal ditambah effect `custSearch` sama-sama memanggil `fetchPelanggan()`).
- Kedua dashboard memanggil `GET /barang` tanpa `limit` hanya untuk membaca jumlah, sehingga seluruh katalog barang diunduh setiap dashboard dimuat (kode kembali ke `rows.length` bila `meta.total_data` tidak ada). Panggilan dengan `limit=1` akan memberi angka yang sama dari `meta.total_data`.
- `getPageNumbers` disalin-tempel ke **9 file**: `admin/pages/DaftarBarang`, `admin/.../HistoriBarangMasuk`, `kasir/.../DaftarPelangganPage`, `kasir/.../HistoriTransaksiPage`, `owner/pages/{BarangMasuk, DaftarBarang, DaftarPelanggan, HistoriTransaksi, Notifikasi}`, beserta seluruh bar paginasinya. `PaginationControl` bersama yang dimaksudkan menggantikannya justru dikomentari seluruhnya.
- `ConfirmLogoutModal` didefinisikan inline di tiga sidebar (`Sidebar`, `SidebarKasir`, `SidebarOwner`), dan masing-masing mendefinisikannya di dalam komponen, sehingga dibuat ulang setiap render.

### 14.7 Keanehan tanggal default dashboard owner (rendah, kesimpulan)

[Dashboard.jsx:15-24](src/owner/pages/Dashboard.jsx#L15-L24) membuat awal rentang default sebagai `new Date(year, month, 2)` dan memformat dengan `toISOString()`. Di zona waktu UTC+7 (WIB) hasilnya jatuh pada tanggal **1** (tengah malam lokal tanggal 2 masih tanggal 1 di UTC); di UTC atau benua Amerika hasilnya tanggal **2**. Tanggal akhir mengalami pergeseran UTC yang sama, jadi sebelum pukul 07:00 WIB yang tampil adalah kemarin. Ini tampak seperti solusi sengaja untuk WIB, tetapi rapuh.

### 14.8 Kebersihan repositori (rendah)

- Tidak ada test sama sekali.
- `package-lock.json` tercantum di `.gitignore`, sehingga instalasi tidak bisa direproduksi.
- `README.md` masih template Vite tanpa perubahan; nama di `package.json` adalah `front-end-pa-app`.
- `.env.example` tidak memuat `VITE_BACKEND_TARGET`. `firebaseConfig.js` juga menyediakan fallback ke nama env tanpa `VITE_` yang tidak pernah diekspos Vite ke kode klien.
- `firebase-messaging-sw.js` mengimpor skrip compat Firebase **10.13.0** dari CDN gstatic sementara aplikasi bergantung pada `firebase@^12.17.0`. Mencampur versi mayor berbeda adalah risiko kompatibilitas yang tersembunyi.
- `ProtectedRoute` mengirim pengguna dengan role salah ke `/login`, bukan ke beranda role-nya sendiri.

## 15. Siapa boleh melakukan apa (izin di backend)

Otorisasi ditegakkan oleh backend, bukan UI. `app.js` memasang rangkaian route yang sama tiga kali (`/api/admin`, `/api/kasir`, `/api/owner`), dan setiap route menjalankan `authorize([...roles])` terhadap **role di dalam JWT**. Prefix URL saja tidak memberi izin apa pun. **Role `owner` lolos semua pengecekan `authorize`** (`SUPER_ROLES` di `auth.middleware.js`), jadi kolom "owner" di bawah berisi "ya" untuk setiap route yang ada; satu-satunya perbedaan antar role adalah apa yang diizinkan untuk admin dan kasir. Sumber: `be-pos-web-app/src/routes/**` dan `middlewares/auth.middleware.js`.

"Member" bukan role login. Itu adalah tipe pelanggan (`tipe_pelanggan: "member" | "guest"`) yang dipilih kasir pada tiap penjualan; member tidak pernah login.

| Area | Aksi (endpoint) | admin | kasir | owner |
|---|---|:-:|:-:|:-:|
| Barang | daftar / cari / ambil satu (`GET /barang…`) | ya | ya | ya |
| | ubah nama dan harga jual (`PATCH /barang/:id`) | ya | tidak | ya |
| | tambah / hapus (`POST`, `DELETE /barang`) | route dinonaktifkan (dikomentari di backend) |||
| Barang masuk (stok masuk) | tambah barang baru beserta stok (`POST /barang-masuk/new`) | ya | tidak | ya |
| | tambah stok barang yang ada (`POST /barang-masuk/existing`) | ya | tidak | ya |
| | daftar / cari riwayat (`GET /barang-masuk`, `/search`) | ya | tidak | ya |
| Pelanggan | daftar / cari / ambil satu | tidak | ya | ya |
| | tambah, ubah (`POST`, `PATCH /pelanggan`) | tidak | ya | ya |
| | hapus | route dinonaktifkan (dikomentari di backend) |||
| Transaksi (penjualan) | buat penjualan (`POST /transaksi`) | tidak | ya | ya |
| | daftar / cari / detail histori | tidak | ya | ya |
| | unduh invoice PDF | ya | ya | ya |
| | statistik penjualan per rentang tanggal (`/transaksi/stats/date-range`) | tidak | tidak | ya |
| | ubah transaksi (`PATCH /transaksi/:id`) | ya | ya | ya |
| Laporan | mingguan / bulanan / tahunan (`/reports/*`) | tidak | tidak | ya |
| Notifikasi | daftar, detail, tandai dibaca, PDF, stream langsung | tidak | tidak | ya |
| Push (FCM) | daftar / lepas token perangkat | tidak | tidak | ya |
| Pengguna | daftar pengguna, ubah pengguna (`GET /users`, `PATCH /users/:id`); admin tidak bisa mengubah akun owner | ya | tidak | ya |
| | buat pengguna (`POST /users`, menggantikan `/auth/register` publik yang lama) | tidak | tidak | ya |
| Sesi sendiri | daftar / cabut sesi login (`/auth/me/sessions`) | tidak | tidak | ya |
| Auth | login, refresh, logout | ya | ya | ya |

Yang benar-benar ditampilkan **UI** lebih sempit daripada yang diizinkan backend:

- **admin**: Dashboard (2 angka), Barang Masuk (baru / existing / riwayat), Daftar Barang (lihat, ubah nama dan harga jual). Tidak ada UI untuk transaksi, pelanggan, pengguna, atau ubah transaksi.
- **kasir**: Buat Transaksi, Histori Transaksi (+ detail, invoice PDF), Daftar Pelanggan (lihat, tambah, ubah). Tidak ada akses ke riwayat barang masuk, laporan, atau notifikasi.
- **owner**: Dashboard, Buat Transaksi (memakai ulang form penjualan kasir dengan `mode="owner"`), Laporan Toko, Barang Masuk (tab: Barang Baru / Barang Existing / Riwayat, memakai ulang form admin), Daftar Barang (lihat + ubah harga), Histori Transaksi, Daftar Pelanggan (lihat, tambah, ubah), Notifikasi.
- Kemampuan backend yang **sama sekali tanpa UI**: melihat, membuat, dan mengubah pengguna, mencabut sesi owner, `PATCH /transaksi/:id`.
- Penulisan data oleh owner harus lewat `ownerClient` karena cookie owner dibatasi path ke `/api/owner`. Service `createTransaksi`, `createPelanggan`, `updatePelanggan`, `createBarangMasukNew/Existing` menerima argumen `mode` untuk keperluan ini.

Fungsi service frontend yang memanggil route yang **tidak** disediakan backend atau tidak diizinkan untuk role itu (hasilnya 404 atau 403; tidak ada yang bisa dicapai dari UI saat ini):

- `createBarang`, `deleteBarang` (route dikomentari di backend)
- `deletePelanggan` (route dikomentari)
- `getBarangMasukById*`, `deleteBarangMasuk` (route-nya tidak ada)
- `getBarangMasukKasir` (kasir tidak diotorisasi untuk barang-masuk)
- `getDateRangeSalesAdmin` (route statistik hanya untuk owner)

## 16. Konvensi yang sebaiknya diikuti saat mengubah kode

- Panggilan API baru: tambahkan fungsi service, lalu ekspos lewat cabang hook `use*` yang sesuai untuk tiap `mode`. Jangan memanggil client Axios langsung dari halaman. (Beberapa tempat sudah melakukannya: halaman `BarangMasuk` admin, tab laporan owner, `useFcmNotification`.)
- Kuantitas dalam satuan dasar sebagai bilangan bulat; uang hanya diformat saat render dengan `formatToRupiah`.
- Setiap halaman daftar memakai `{ page, limit, keyword }` dan merender dari `meta.total_page` / `meta.total_data`.
- Tema warna per role: hijau (kasir), ungu/violet (owner), slate/biru (admin). Samakan pada komponen baru.
- String UI berbahasa Indonesia; komentar kode campuran Indonesia dan Inggris.
