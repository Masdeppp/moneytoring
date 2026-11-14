# Design System — Moneytoring

> Pendamping [PRD.md](PRD.md). Dokumen ini adalah **sumber kebenaran token desain** (termasuk Dark mode yang tidak bisa disimpan di Figma Starter) dan status desain layar.

| | |
|---|---|
| **File Figma** | [Moneytoring — App Design (MVP)](https://www.figma.com/design/kvkQ06T5yRbUwYJQo7QOgA) |
| **Halaman Figma** | `Foundations` (variabel & style) · `Components` · `Screens — MVP` |
| **Frame dasar** | 360 × 800 dp (Android compact; banyak HP budget di Indonesia memakai lebar 360dp) |
| **Font** | **Plus Jakarta Sans** (Google Fonts, karya Tokotype Jakarta) |
| **Basis** | Metrik Material 3 (tinggi tombol, NavigationBar 80dp, FAB 56dp) dengan token warna sendiri, supaya mudah dipetakan ke `ThemeData` Flutter |

### Batasan paket Figma Starter
- Maksimal **3 halaman** (karena itu cover digabung ke Foundations).
- Variabel hanya **1 mode**. Figma hanya menyimpan **Light**; nilai **Dark** tercatat di deskripsi tiap variabel dan di tabel bawah ini.
- Figma MCP sekitar **20 tool call/bulan**, sehingga layar 04–11 dibangun lewat **plugin lokal** yang dijalankan sendiri di Figma Desktop (lihat bagian 6).

---

## 1. Warna

### 1.1 Primitives (hex)

| Family | 50 | 100 | 200 | 300 | 400 | 500 | 600 | 700 | 800 | 900 | 950 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| **brand** | EAFBF4 | CDF5E3 | 9DEACB | 5FD8AE | 2CC290 | 12A679 | 0A8763 | 0B6C52 | 0D5643 | 0B4738 | 04281F |
| **neutral** (0 = FFFFFF) | F6F8F7 | EDF1EF | DCE2DF | BFC8C4 | 919D98 | 67736E | 4E5955 | 39423F | 242B29 | 161B1A | 0C100F |
| **amber** | FFF7E6 | FEEBC2 | – | – | F7BD4F | F0A020 | CC8008 | 9E6106 | 7B4C05 | 3A2604 | – |
| **red** | FEF1F1 | FDDCDC | – | – | F27A7D | E34A4F | C8323A | A1252C | – | 3B1215 | – |
| **blue** | EEF5FF | DCE9FE | – | – | 6FA0F5 | 3B7DF0 | 2461D2 | – | – | 10264D | – |
| **violet** | F4F0FF | E6DEFF | – | – | A48BF0 | 7C5CE6 | 6544CC | – | – | 261A52 | – |

Alpha: `alpha/white-72` = #FFFFFF @72% · `alpha/white-16` = #FFFFFF @16% · `alpha/scrim` = #0C100F @48%

### 1.2 Semantic tokens (Light / Dark)

Nama Dart mengikuti code syntax di Figma: `AppColors.<camelCase>`, mis. `bg/hero-safe` → `AppColors.bgHeroSafe`.

| Token | Light | Dark | Dipakai untuk |
|---|---|---|---|
| `bg/canvas` | neutral/50 | neutral/950 | Latar layar |
| `bg/surface` | neutral/0 | neutral/900 | Kartu, list |
| `bg/surface-muted` | neutral/100 | neutral/800 | Area sekunder, divider tebal |
| `bg/surface-raised` | neutral/0 | neutral/800 | Bottom sheet, dialog |
| `bg/brand` | brand/600 | brand/400 | Tombol utama, FAB |
| `bg/brand-pressed` | brand/700 | brand/300 | State ditekan |
| `bg/brand-subtle` | brand/50 | brand/950 | Tombol tonal, chip terpilih |
| `bg/hero-safe` | brand/800 | brand/900 | Kartu Safe-to-Spend: Aman |
| `bg/hero-warning` | amber/800 | amber/900 | Kartu Safe-to-Spend: Waspada |
| `bg/hero-danger` | red/700 | red/900 | Kartu Safe-to-Spend: Berisiko |
| `bg/hero-overlay` | alpha/white-16 | alpha/white-16 | Elemen di atas kartu hero |
| `bg/warning-subtle` | amber/50 | amber/900 | AlertBanner Warning |
| `bg/danger-subtle` | red/50 | red/900 | AlertBanner Danger |
| `bg/info-subtle` | blue/50 | blue/900 | AlertBanner Info |
| `bg/scrim` | alpha/scrim | alpha/scrim | Overlay bottom sheet |
| `text/primary` | neutral/900 | neutral/50 | Teks utama |
| `text/secondary` | neutral/600 | neutral/300 | Deskripsi |
| `text/tertiary` | neutral/500 | neutral/400 | Meta, caption |
| `text/on-brand` | neutral/0 | neutral/950 | Teks di atas `bg/brand` |
| `text/on-hero` | neutral/0 | neutral/0 | Teks di kartu hero |
| `text/on-hero-muted` | alpha/white-72 | alpha/white-72 | Teks sekunder di kartu hero |
| `text/brand` | brand/700 | brand/300 | Link, aksi teks |
| `text/income` | brand/700 | brand/400 | Nominal pemasukan |
| `text/warning` | amber/700 | amber/400 | |
| `text/danger` | red/600 | red/400 | |
| `text/info` | blue/600 | blue/400 | |
| `border/default` | neutral/200 | neutral/800 | Border kartu |
| `border/strong` | `#86908C` | `#6C7572` | Border chip/input (minimal 3:1, WCAG 1.4.11) |
| `border/focus` | brand/600 | brand/400 | Input aktif, chip terpilih |
| `icon/primary` | neutral/800 | neutral/100 | |
| `icon/secondary` | neutral/500 | neutral/400 | Ikon nav tidak aktif |
| `icon/on-brand` | neutral/0 | neutral/950 | |
| `icon/on-hero` | neutral/0 | neutral/0 | |
| `status/safe` · `status/warning` · `status/danger` | brand/500 · amber/500 · red/500 | brand/400 · amber/400 · red/400 | Indikator risiko |
| `tone/{brand,amber,blue,violet,red,neutral}/bg` | x/100 (neutral/100) | x/950 atau x/900 (neutral/800) | Tile kategori, badge |
| `tone/{…}/fg` | brand/700, amber/800, blue/600, violet/600, red/700, neutral/600 | x/300 atau x/400 (neutral/300) | Ikon/teks di tile & badge |

Kontras semua pasangan teks/latar Light & Dark lulus WCAG AA (88 pasangan, `replica/design/tokens.json`,
dicek 9 Nov 2026). Nilai neutral/500, amber/800, blue/600, text/income, tone fg amber/red, dan
border/strong diubah untuk itu; variabel Figma belum ikut diperbarui.

### 1.3 Aturan pemakaian warna
- **Pengeluaran ditulis dengan warna teks netral, bukan merah.** Merah hanya untuk risiko nyata (kewajiban terancam). Kalau setiap pengeluaran merah, pengguna merasa dihakimi dan alert berisiko diabaikan.
- Pemasukan memakai `text/income` (hijau).
- Warna kartu hero ditentukan **engine risiko** (Tier 0–2 di PRD), bukan dipilih manual.

---

## 2. Tipografi (Plus Jakarta Sans)

| Style | Weight | Size / Line height | Letter spacing | Pemakaian |
|---|---|---|---|---|
| `Display/Amount` | Bold | 34 / 42 | −2% | Angka Safe-to-Spend |
| `Headline/Large` | Bold | 26 / 34 | −1% | Judul onboarding |
| `Headline/Small` | Bold | 20 / 28 | −0.5% | Judul layar |
| `Title/Medium` | SemiBold | 16 / 24 | 0 | Judul kartu |
| `Title/Small` | SemiBold | 14 / 20 | 0 | Judul item list |
| `Body/Large` | Regular | 16 / 24 | 0 | |
| `Body/Medium` | Regular | 14 / 20 | 0 | Teks isi |
| `Body/Small` | Regular | 12 / 16 | 0 | Subtitle item list |
| `Label/Large` | SemiBold | 14 / 20 | +0.2% | Tombol, chip |
| `Label/Medium` | SemiBold | 12 / 16 | +0.2% | Badge, label field |
| `Label/Small` | Medium | 11 / 16 | +0.3% | Label navbar |
| `Overline` | Bold, UPPERCASE | 11 / 16 | +6% | Label seksi |
| `Amount/Medium` | Bold | 15 / 22 | −0.5% | Nominal di list |
| `Keypad` | Medium | 26 / 34 | 0 | Tombol keypad nominal |

Di Flutter, pakai `FontFeature.tabularFigures()` untuk semua nominal supaya angka tidak "goyang" saat berubah.

## 3. Spacing, Radius, Elevation

- **Spacing** (`AppSpacing.sN`): 0, 2, 4, 8, 12, 16, 20, 24, 32, 40, 48. Padding layar = 24 (onboarding) / 16 (layar utama).
- **Radius** (`AppRadius.*`): sm 8 · md 12 · lg 16 · xl 20 · xxl 28 · full 999. Kartu = lg, kartu hero = xl, tombol/chip = full, tile kategori = md.
- **Elevation**: `Elevation/1` (kartu: y1 b2 6% + y4 b12 5%) · `Elevation/2` (FAB, sheet: y4 b8 10% + y12 b32 −4 12%).

---

## 4. Komponen (halaman `Components`)

| Komponen | Varian / properti | Flutter |
|---|---|---|
| **Icon/** (37 ikon) | 24dp, stroke 2, gaya Lucide | `lucide_icons` atau SVG |
| **Button** | Style = Primary / Secondary / Ghost × Size = Large (52) / Medium (40); `Label` | `FilledButton`, `FilledButton.tonal`, `TextButton` |
| **CategoryTile** | Tone = Brand / Amber / Blue / Violet / Red / Neutral; `Icon` (instance swap) | Widget custom |
| **Badge** | Tone = Success / Warning / Danger / Info / Neutral; `Label` | Widget custom |
| **Chip** | State = Default / Selected; `Label` | `FilterChip` |
| **FAB** | 56dp, radius lg | `FloatingActionButton` |
| **ListItem/Transaction** | Type = Expense / Income; `Title`, `Subtitle`, `Amount` | `ListTile` custom |
| **ListItem/Obligation** | Status = Pending / Paid / AtRisk / Late; `Name`, `Due`, `Amount` | Widget custom |
| **AlertBanner** | Tone = Warning / Danger / Info; `Title`, `Body`, `Action` | Widget custom |
| **StatusBar** | 360 × 32 | (sistem) |
| **NavBar** | Active = Beranda / Transaksi / Kewajiban / Insight | `NavigationBar` (M3) |
| **SafeToSpendCard** ⭐ | Risk = Safe / Warning / Danger; `Amount`, `Daily`, `Protected` | Widget custom |

**Catatan:** setelah swap ikon di CategoryTile, warna stroke harus diset ulang ke `tone/<tone>/fg`. Di Flutter cukup kirim `color` ke widget ikon.

**SafeToSpendCard** adalah visual inti produk:
- **Bar** menunjukkan porsi Safe-to-Spend yang sudah terpakai.
- **Garis tipis** menunjukkan posisi hari dalam siklus. Kalau bar melewati garis, artinya belanja lebih cepat dari waktu (pace).
- **Baris bawah** ("Rp 2,2 jt diamankan · 3 kewajiban") mengingatkan bahwa uang kewajiban sudah dilindungi.

---

## 5. Layar yang sudah ada (halaman `Screens — MVP`)

| # | Layar | Isi |
|---|---|---|
| 01 | Onboarding — Siklus Gajian | Stepper 1/3, pilihan aturan gajian (tanggal tetap / hari kerja terakhir), grid tanggal, toggle geser saat libur, input gaji bersih |
| 02 | Onboarding — Kewajiban Rutin | Chip template kewajiban, daftar kewajiban terpilih, total per bulan |
| 03 | Onboarding — Aha Moment | Kartu Safe-to-Spend pertama + rincian transparan "Dari mana angka ini?" |

> Perbaikan layout terakhir di layar 01–03 (grid tanggal, kartu toggle, jarak baris rincian) **belum diverifikasi visual** karena kuota Figma MCP habis. Cek manual di Figma.

**Implementasi Flutter (Fase 1 irisan 3)** menambah satu langkah **Saldo** di antara 01 dan 02, sehingga stepper menjadi 1/4 … 4/4. Isinya kartu per akun (CategoryTile + nama + isian saldo + switch "Hitung di Safe-to-Spend") dan chip "+ Tunai / Rekening bank / E-wallet". Layar ini belum ada di Figma; kalau desainnya dibuat, ikuti komponen layar 01. Ikon kewajiban di layar 02 memakai ikon kategorinya, bukan ikon khusus template.

## 6. Layar 04–11 (dibangun lewat plugin lokal)

Spesifikasi di bawah sudah dituangkan ke plugin [tools/figma-screens-plugin](../tools/figma-screens-plugin/README.md). Kedelapan layar **sudah dibuat** di Figma (plugin dijalankan 6 Nov 2026, hasil 8/8), jadi tabel ini sekarang berfungsi sebagai dokumentasi layar. Hasilnya belum direview visual lewat MCP karena kuota habis. Skenario tanggal di semua layar: **hari ini Rabu 11 Nov**, gajian 25 Nov.

Pakai komponen di atas. Semua layar memakai StatusBar di atas; layar utama memakai NavBar di bawah dan FAB di kanan bawah (16dp dari tepi, di atas NavBar).

| # | Layar | Susunan |
|---|---|---|
| 04 | **Beranda (Aman)** | Header "Halo, Raka" + ikon bell · SafeToSpendCard Risk=Safe · seksi "Kewajiban terdekat" (3× ListItem/Obligation + "Lihat semua") · seksi "Transaksi terakhir" (3× ListItem/Transaction) · NavBar Active=Beranda · FAB |
| 05 | **Beranda (Berisiko)** | Sama seperti 04, tapi SafeToSpendCard Risk=Danger + AlertBanner Danger di bawah kartu (alert A1) |
| 06 | **Tambah Transaksi** (bottom sheet di atas `bg/scrim`) | Toggle Pengeluaran/Pemasukan · nominal besar (`Display/Amount`) · kategori terakhir dipakai (baris CategoryTile + label) · akun & tanggal (chip) · catatan · keypad 3×4 (`Keypad`, tombol "000" & hapus) · Button "Simpan". Setelah simpan: snackbar "Aman dibelanjakan kini Rp 735.000" |
| 07 | **Transaksi** | Search + filter chip (Semua/Pengeluaran/Pemasukan/akun) · ringkasan siklus (masuk/keluar) · list dikelompokkan per hari (header tanggal + total harian) |
| 08 | **Kewajiban** | Header siklus "25 Okt – 24 Nov" · progress "2 dari 5 lunas" · timeline per tanggal jatuh tempo (ListItem/Obligation semua status) · tombol tambah kewajiban |
| 09 | **Insight** | Proyeksi akhir siklus (grafik garis: aktual vs proyeksi P50/P80 vs batas Safe-to-Spend) · donut kategori · daftar alert dengan 👍/👎 · kartu 💎 Laporan multi-siklus (terkunci) |
| 10 | **Simulasi What-If** 💎 | Input nominal · tanggal beli (hari ini / setelah gajian) · hasil: Safe-to-Spend sebelum → sesudah, kewajiban yang jadi berisiko, saran ("Tunda 8 hari") · sisa kuota gratis "2 dari 3 percobaan" |
| 11 | **Detail Peringatan (A1)** | Kewajiban yang terancam · selisih dana · grafik proyeksi saldo sampai jatuh tempo · aksi: [Lihat jatah harian baru] [Pindah dana dari akun lain] [Geser target tabungan] · feedback 👍/👎 |

---

## 7. Pemetaan ke Flutter

```dart
// core/theme/app_colors.dart: ThemeExtension dengan dua instance (light, dark)
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color bgCanvas, bgSurface, bgHeroSafe, textPrimary /* ... semua token 1.2 ... */;
  // light: AppColors(bgCanvas: Color(0xFFF6F8F7), ...)
  // dark : AppColors(bgCanvas: Color(0xFF0C100F), ...)
}

// Akses: context.colors.bgHeroSafe  (extension on BuildContext)
```

- `ColorScheme` M3 diisi dari token: primary = `bg/brand`, onPrimary = `text/on-brand`, surface = `bg/surface`, dst. Token khusus (hero, tone, status) masuk `ThemeExtension`.
- `TextTheme` dibuat dari tabel tipografi (package `google_fonts`, atau bundle font di `assets/fonts` agar jalan offline, sesuai prinsip offline-first di PRD).
- Spacing & radius sebagai konstanta `AppSpacing` / `AppRadius`.

---

## 8. Prototype & interaksi

Interaksi dipasang oleh plugin lokal [tools/figma-prototype-plugin](../tools/figma-prototype-plugin/README.md), yang dijalankan sendiri di Figma Desktop. Plugin aman dijalankan ulang dan tidak mengubah tampilan layar. README plugin berisi daftar lengkap interaksi per elemen; bagian ini merangkum perilaku yang juga menjadi acuan implementasi Flutter. Plugin **belum dijalankan** di file Figma, jadi status di Figma perlu dicek lewat Present setelah plugin dijalankan.

### 8.1 Flow (Present → pilih flow)

| Flow | Mulai | Alur utama |
|---|---|---|
| **Onboarding** | 01 | 01 Siklus Gajian → 02 Kewajiban Rutin → 03 Aha Moment → 04 Beranda (smart animate; ‹ di stepper = kembali) |
| **Beranda** | 04 | Tab bar 04 · 07 · 08 · 09, FAB → Tambah Transaksi, drill-down ke 10 dan 11 |

### 8.2 Navigasi

| Dari | Elemen | Ke | Transisi |
|---|---|---|---|
| 04, 05, 07 | FAB | Bottom sheet Tambah Transaksi (overlay) | Move in dari bawah |
| Sheet 06 | "Simpan" / tap di luar / geser sheet | Tutup sheet, kembali ke Beranda | — |
| 04, 05, 07, 08, 09 | NavBar | 04 / 07 / 08 / 09 | Dissolve |
| 04, 05 | "Lihat semua" | 08 (kewajiban) / 07 (transaksi) | Dissolve |
| 04, 05 | Kartu Safe-to-Spend | 10 Simulasi What-If | Push dari kanan |
| 09 | "Coba Premium" | 10 Simulasi What-If | Push dari kanan |
| 05 | AlertBanner A1, lonceng, item "Cicilan motor" | 11 Detail Peringatan | Push dari kanan |
| 04 | Lonceng | 09 Insight | Dissolve |
| 10 | "Tunda & ingatkan saya" / ‹ | Kembali | — |
| 10 | "Tetap beli & catat" | 05 Beranda Berisiko | Dissolve |
| 11 | Salah satu "Cara mengamankan" | 04 Beranda Aman | Dissolve |
| 11 | ‹ | Kembali | — |

### 8.3 Behavior komponen

| Komponen | Behavior | Catatan Flutter |
|---|---|---|
| **Chip** | Tap: Default ↔ Selected | `FilterChip.selected`. Di Flutter, filter 07 dan aturan gajian 01 dibuat *single-select*, walaupun di prototype masih bisa multi-select. |
| **NavBar** | Tab aktif mengikuti layar; tap tab = pindah layar | `NavigationBar` + `StatefulShellRoute` |
| **Proto/TypeToggle** (06) | Pengeluaran ↔ Pemasukan | `SegmentedButton<TransactionType>` |
| **Proto/FeedbackButton** (09, 11) | 👍/👎 Off ↔ On. 👎 aktif berwarna netral, bukan merah (aturan §1.3) | `IconButton(isSelected:)`; kirim feedback ke engine alert |
| **SafeToSpendCard** | Aman → Berisiko setelah transaksi besar: frame 04 → 05 dengan smart animate (kartu hijau → merah + AlertBanner muncul). Dipicu "Tetap beli & catat" di 10, atau tombol **B** saat Present (**A** untuk kembali) | `AnimatedContainer` / `TweenAnimationBuilder` untuk warna hero saat tier risiko berubah |

`Proto/TypeToggle` dan `Proto/FeedbackButton` dibuat oleh plugin di section *Prototype Components* (halaman Components). Keduanya khusus prototype dan belum menjadi bagian design system di §4.

### 8.4 Scroll

- `Body` di semua layar (kecuali 06) scroll vertikal. StatusBar, NavBar, Footer, dan FAB berada di luar `Body`, jadi tetap di tempat.
- Baris chip filter (07) serta kategori dan akun/tanggal di sheet 06 scroll horizontal.

### 8.5 Tidak dipakai (paket Starter)

Variabel, conditional, dan multiple actions di prototype tidak dipakai. Perubahan state (Aman → Berisiko, nominal setelah transaksi) ditampilkan dengan frame terpisah + navigasi biasa. Keypad di 06 tidak mengubah nominal di prototype.
