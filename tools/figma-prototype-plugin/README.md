# Plugin Figma: Moneytoring — Prototype MVP

Plugin development lokal yang mengubah **11 layar MVP** (01–11) di file Figma
[Moneytoring — App Design (MVP)](https://www.figma.com/design/kvkQ06T5yRbUwYJQo7QOgA), halaman `Screens — MVP`, dari tampilan statis menjadi **prototype interaktif**. Plugin memasang:

- **Flow**: "Onboarding" (mulai di 01) dan "Beranda" (mulai di 04).
- **Navigasi antar layar**: tap untuk pindah layar, overlay bottom sheet, dan tombol kembali.
- **Behavior komponen** (interactive components): chip, NavBar, toggle Pengeluaran/Pemasukan, dan tombol 👍/👎.
- **Scroll**: isi layar bisa di-scroll, sedangkan StatusBar, NavBar, Footer, dan FAB tetap di tempat.

Plugin ini memakai pola yang sama dengan [figma-screens-plugin](../figma-screens-plugin/README.md): dijalankan sendiri di Figma Desktop, jadi **tidak memakai kuota Figma MCP**.

## Prasyarat

- Layar 01–03 sudah ada (dibuat lewat MCP), dan layar 04–11 sudah dibangun dengan `figma-screens-plugin` (hasil 8/8).
- **Figma Desktop**, karena plugin development tidak bisa dijalankan dari browser.

## Cara menjalankan plugin (± 1 menit)

1. Buka **Figma Desktop**, lalu buka file *Moneytoring — App Design (MVP)*.
2. Klik kanan di canvas → **Plugins → Development → Import plugin from manifest…**
3. Pilih `tools/figma-prototype-plugin/manifest.json` di folder project ini.
4. Jalankan: klik kanan di canvas → **Plugins → Development → Moneytoring — Prototype MVP**.
5. Tunggu notifikasi di bawah layar, misalnya
   **"Moneytoring prototype: 68 koneksi terpasang · 0 gagal · scroll 15 frame · 2 flow"**.

Kalau ada yang gagal, buka **Plugins → Development → Show/Hide console**. Semua pesan diawali `Moneytoring prototype:`:

- daftar semua frame yang ditemukan di halaman beserta pemetaan nomor layar → frame;
- setiap koneksi yang gagal beserta alasannya, mis. `gagal · 05 AlertBanner A1 → 11 — node sumber tidak ditemukan`;
- daftar lengkap koneksi yang terpasang.

Plugin **toleran**: kalau sebuah layar atau node tidak ditemukan, koneksi itu dicatat sebagai gagal lalu plugin lanjut ke koneksi berikutnya.

## Cara mencoba prototype

1. Buka halaman **Screens — MVP**, lalu klik area kosong di canvas supaya tidak ada yang terpilih.
2. Di panel kanan, buka tab **Prototype**. Bagian **Flows** berisi **Onboarding** dan **Beranda**.
3. Klik ikon ▶ di samping nama flow, atau klik tombol **Present** (▶) di kanan atas toolbar. Di presentation view, pilih flow lewat daftar **Flows** di sidebar kiri.
4. Klik elemen untuk berinteraksi. Kalau kamu klik area yang tidak interaktif, area yang bisa diklik akan berkedip biru.
5. Tekan **R** untuk mengulang flow dari awal.

Untuk demo cepat dari Beranda: tekan **B** di layar 04 untuk melihat kartu berubah menjadi Berisiko (05), lalu tekan **A** di layar 05 untuk kembali Aman.

### Langkah manual opsional (2 klik, membuat bottom sheet lebih realistis)

Plugin API tidak bisa mengatur latar overlay, jadi atur sendiri: klik salah satu panah koneksi dari FAB (atau pilih frame `Proto · 06 Sheet Overlay`) → panel **Prototype → Overlay** → centang **Add background behind overlay** → warna `#0C100F` dengan opacity **48%** (sama dengan token `bg/scrim`). Hasilnya, layar di belakang sheet ikut meredup.

## Daftar interaksi

Durasi animasi: 0,15–0,5 detik. *Smart animate* dipakai jika susunan layer kedua layar mirip (04 ↔ 05, 01 → 02 → 03 → 04, perubahan varian). Untuk perpindahan tab dipakai *Dissolve*, untuk drill-down *Push dari kanan*, dan untuk bottom sheet *Move in dari bawah*.

### Flow & onboarding

| Layar | Elemen | Trigger | Aksi | Animasi |
|---|---|---|---|---|
| — | Flow **Onboarding** | — | mulai di 01 | — |
| — | Flow **Beranda** | — | mulai di 04 | — |
| 01 | Tombol "Lanjut" | Tap | → 02 | Smart animate (stepper bar 2 terisi) |
| 02 | Tombol "Lanjut" | Tap | → 03 | Smart animate |
| 02, 03 | Ikon ‹ di stepper | Tap | Kembali (BACK) | — |
| 03 | Tombol "Mulai pakai Moneytoring" | Tap | → 04 | Smart animate (kartu Safe-to-Spend pindah ke Beranda) |

### Beranda (04 Aman, 05 Berisiko)

| Layar | Elemen | Trigger | Aksi | Animasi |
|---|---|---|---|---|
| 04, 05 | FAB (+) | Tap | Buka **Tambah Transaksi** sebagai overlay | Move in dari bawah |
| 04, 05 | NavBar Transaksi / Kewajiban / Insight | Tap | → 07 / 08 / 09 | Dissolve |
| 04, 05 | "Lihat semua" (Kewajiban terdekat) | Tap | → 08 | Dissolve |
| 04 | "Lihat semua" (Transaksi terakhir) | Tap | → 07 | Dissolve |
| 04, 05 | Kartu Safe-to-Spend | Tap | → 10 Simulasi What-If ("Kalau aku beli…") | Push dari kanan |
| 04 | Ikon lonceng | Tap | → 09 Insight (daftar peringatan) | Dissolve |
| 05 | AlertBanner A1 "Cicilan motor berisiko…" | Tap | → 11 Detail Peringatan | Push dari kanan |
| 05 | Ikon lonceng (ada titik merah) | Tap | → 11 | Push dari kanan |
| 05 | Item kewajiban "Cicilan motor" (AtRisk) | Tap | → 11 | Push dari kanan |
| 04 | Keyboard **B** | Tekan | → 05 (simulasi transaksi besar: Aman → Berisiko) | Smart animate (kartu hijau → merah) |
| 05 | Keyboard **A** | Tekan | → 04 (kembali Aman) | Smart animate |

### Tambah Transaksi (06)

| Layar | Elemen | Trigger | Aksi | Animasi |
|---|---|---|---|---|
| Overlay | Tombol "Simpan" | Tap | Tutup overlay → kembali ke Beranda asal | kebalikan Move in |
| Overlay | Area di atas sheet | Tap | Tutup overlay | — |
| Overlay | Sheet | Drag | Tutup overlay | — |
| 06 (frame statis) | Tombol "Simpan" | Tap | → 04 Beranda | Dissolve |
| 06 (frame statis) | Scrim | Tap | Kembali (BACK) | — |
| 06 (frame statis) | Sheet | Drag | Kembali (BACK) | — |
| 07 | FAB (+) | Tap | Buka overlay Tambah Transaksi | Move in dari bawah |

### Transaksi, Kewajiban, Insight (07–09)

| Layar | Elemen | Trigger | Aksi | Animasi |
|---|---|---|---|---|
| 07, 08, 09 | NavBar (tab selain yang aktif) | Tap | → 04 / 07 / 08 / 09 | Dissolve |
| 09 | Tombol "Coba Premium" (teaser Premium) | Tap | → 10 Simulasi What-If (fitur 💎, "2 dari 3 gratis") | Push dari kanan |

### What-If (10) & Detail Peringatan (11)

| Layar | Elemen | Trigger | Aksi | Animasi |
|---|---|---|---|---|
| 10 | Ikon ‹ di AppBar | Tap | Kembali (BACK) | — |
| 10 | "Tunda & ingatkan saya" | Tap | Kembali (BACK) | — |
| 10 | "Tetap beli & catat" | Tap | → 05 (beli sepatu Rp 800rb: **Aman → Berisiko**) | Dissolve |
| 11 | Ikon ‹ di AppBar | Tap | Kembali (BACK) | — |
| 11 | 3 baris "Cara mengamankan" | Tap | → 04 (risiko teratasi, Beranda kembali **Aman**) | Dissolve |

### Behavior komponen (interactive components)

| Komponen | Di mana | Behavior |
|---|---|---|
| **Chip** (`State`) | 01 aturan gajian, 02 template kewajiban, 06 akun/tanggal, 07 filter, 10 "Kapan?" | Tap: Default ↔ Selected (smart animate 0,15 dtk). Reaction dipasang di main component, jadi semua instance ikut. |
| **NavBar** (`Active`) | 04, 05, 07, 08, 09 | Main component: tap tab mengganti varian `Active` (CHANGE_TO). Di layar, tab yang sama di-*override* menjadi navigasi ke layar tab tersebut, dan tab aktif di layar tujuan sudah sesuai. |
| **Proto/TypeToggle** (`Type`) | 06 (dan overlay) | Tap "Pemasukan" ↔ "Pengeluaran": segmen putih berpindah (smart animate 0,2 dtk). |
| **Proto/FeedbackButton** (`Vote` × `State`) | 09 "Peringatan terakhir", 11 "Peringatan ini berguna?" | Tap 👍 atau 👎: Off ↔ On. 👍 aktif memakai warna brand. 👎 aktif sengaja netral (abu), bukan merah, karena merah hanya untuk risiko nyata (DESIGN.md §1.3). |
| **SafeToSpendCard** Aman → Berisiko | 04 → 05 | Dua frame terpisah dengan smart animate, karena teks nominal/harian berbeda per kondisi. Dipicu dari 10 "Tetap beli & catat" atau tombol **B**. |

### Scroll

| Layar | Frame | Arah |
|---|---|---|
| 01–05, 07–11 | `Body` | Vertikal |
| 07 | `Filters` (chip filter) | Horizontal |
| 06 + overlay | `Categories`, `Meta` | Horizontal |

StatusBar, NavBar, Footer, dan FAB berada **di luar** frame `Body` (FAB memakai posisi absolute di frame layar), sehingga otomatis tetap di tempat saat Body di-scroll. Karena itu `numberOfFixedChildren` di frame layar **tidak perlu diubah**, dan susunan layer tetap sama.

## Apa saja yang diubah plugin di file Figma

Tampilan visual layar **tidak berubah**. Plugin mengubah hal-hal berikut:

| Perubahan | Keterangan |
|---|---|
| Reaction (interaksi) | Dipasang di node layar dan di varian Chip/NavBar (halaman Components). |
| `overflowDirection` | Diset di frame Body/Filters/Categories/Meta. |
| Flow starting points | Ditambah di halaman Screens — MVP. Flow lain yang sudah ada tetap disimpan. |
| Section **Prototype Components** (halaman Components) | Berisi 2 component set baru: `Proto/TypeToggle` dan `Proto/FeedbackButton`. Varian default-nya adalah salinan persis frame asli. |
| Frame di layar 06, 09, 11 | `TypeToggle` di 06 dan `IconButton/thumbs-up` / `thumbs-down` di 09 dan 11 diganti **instance** komponen di atas, dengan nama, posisi, dan ukuran yang sama. Kalau ukurannya tidak cocok, penggantian dilewati dan dicatat di console. |
| Frame bantu **`Proto · 06 Sheet Overlay`** | Diletakkan di bawah layar 06. Isinya salinan `Sheet` di atas latar transparan, dipakai sebagai overlay bottom sheet. Frame 06 asli tidak bisa dipakai sebagai overlay karena berisi gambar latar Beranda + scrim, sehingga seluruh layar akan ikut naik. |

## Aman dijalankan ulang (idempotent)

- Setiap reaction yang dipasang plugin dicatat di **registry** (pluginData dokumen, key `moneytoring-prototype-registry`). Pada run berikutnya, reaction lama itu dihapus dulu lalu dipasang ulang, sehingga tidak ada duplikat.
- Reaction buatan tangan **tetap dipertahankan**. Pengecualiannya: kalau kamu membuat reaction dengan trigger yang sama di node yang sama (mis. *On click* di FAB), reaction itu diganti oleh reaction plugin.
- Frame overlay dibuat ulang di setiap run. Component set `Proto/*` dipakai ulang kalau sudah ada.
- **Setelah menjalankan ulang `figma-screens-plugin`**, layar 04–11 dibuat baru dan interaksinya hilang. Jalankan plugin ini sekali lagi.
- Untuk membuat ulang komponen `Proto/*` (mis. setelah tampilan toggle diubah), hapus section *Prototype Components* lalu jalankan plugin lagi.

## Pengaturan (`CONFIG` di awal `code.js`)

| Opsi | Default | Kalau `false` |
|---|---|---|
| `sheetOverlay` | `true` | FAB pindah ke frame 06 biasa (navigate + Move in dari bawah). Frame bantu overlay dihapus. |
| `keyboardShortcuts` | `true` | Pintasan B/A di 04/05 dihapus. |
| `navBarVariants` | `true` | Reaction CHANGE_TO di main component NavBar dihapus; navigasi antar tab tetap ada. |
| `toggleComponents` | `true` | Toggle 06 dan 👍/👎 tidak interaktif. Komponen yang sudah dibuat tetap ada. |

Setelah mengubah `CONFIG`, simpan `code.js` lalu jalankan plugin lagi. Reaction dari opsi yang dimatikan akan dibersihkan.

## Fitur prototyping berbayar: tidak dipakai

Plugin ini hanya memakai fitur yang tersedia di paket **Starter**: flow, navigate/overlay/back, smart animate, interactive components (CHANGE_TO), scroll overflow, dan trigger keyboard.

Fitur **advanced prototyping** (variabel, conditional, *set variable*, multiple actions) **tidak dipakai** karena bisa jadi khusus paket berbayar. Sebagai gantinya:

- Perubahan Safe-to-Spend (Aman → Berisiko) ditampilkan dengan **navigasi biasa** antara frame 04 dan 05 (smart animate). Versi variabel/conditional bisa saja mengurangi angka berdasarkan input keypad, tapi tidak diperlukan untuk menunjukkan perilakunya.
- Keypad 06 tidak mengubah nominal. Nominal di prototype tetap "Rp 25.000".

## Batasan yang diketahui

- Hasil plugin belum diverifikasi visual langsung di Figma (kuota MCP habis). Logika plugin sudah dites dengan mock Figma API: 68 koneksi, run kedua tidak menambah duplikat, dan node yang hilang dicatat lalu dilewati. Cek hasilnya lewat Present.
- Chip di baris akun/tanggal (06) juga ikut bisa di-toggle, karena behavior Chip dipasang di main component.
- Filter chip (07) dan pilihan aturan gajian (01) bisa terpilih lebih dari satu, karena interactive component tidak bisa membuat grup "pilih satu" tanpa variabel.
- Arah animasi memakai konvensi Figma: *Push* `LEFT` = layar baru masuk dari kanan, *Move in* `TOP` = sheet naik dari bawah. Kalau terasa terbalik di versi Figma-mu, ubah `direction` di objek `TR` dalam `code.js`.

## Catatan

- ID halaman dan komponen di `code.js` khusus untuk file ini (`Screens — MVP` = `4:3`, `Components` = `4:2`). Kalau ID tidak cocok, plugin mencari berdasarkan nama.
- Layar dicari lewat nama yang diketahui, lalu lewat prefiks nomor ("01 ", "02 ", …). Jadi layar 01–03 buatan MCP tetap ketemu meskipun format namanya berbeda.
