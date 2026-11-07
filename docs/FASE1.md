# Fase 1 — MVP

> Turunan dari [PRD.md](PRD.md) §14: semua fitur **P0**, gratis penuh, Android dulu.
> Dokumen ini membagi Fase 1 menjadi irisan kecil yang masing-masing bisa dites dan dipakai,
> lalu mencatat keputusan perhitungan yang tidak dirinci di PRD.

## 1. Irisan kerja

Urutan dipilih supaya setiap irisan memakai hasil irisan sebelumnya. Engine dibuat lebih dulu karena
semua layar menampilkan angka darinya.

| # | Irisan | Isi | Selesai kalau |
|---|---|---|---|
| 1 | **Engine inti** | Pure Dart di `lib/engine/`: siklus gajian, jadwal kewajiban, Safe-to-Spend, risiko Tier 0 (pace + proyeksi) | Contoh Lampiran A PRD terhitung persis; coverage `engine/` ≥ 90% |
| 2 | **Lapisan data** | Skema v2 + migrasi, repository akun/kategori/transaksi/kewajiban/siklus, saldo per akun, pembuat instance kewajiban per siklus, provider Riverpod yang menggabungkan DB + engine, data libur nasional | Safe-to-Spend dihitung dari isi DB dan ter-update saat transaksi disimpan |
| 3 | **Onboarding** (layar 01–03) | Siklus gajian, akun + saldo awal, kewajiban dari template, aha moment "Dari mana angka ini?" | Pengguna baru sampai ke Beranda dengan angka asli dalam < 2 menit |
| 4 | **Tambah transaksi + Beranda** (04–06) | Bottom sheet keypad, kategori terakhir dipakai, akun & tanggal; Beranda memakai data asli | Quick Add ≤ 3 tap; snackbar menampilkan Safe-to-Spend baru |
| 5 | **Transaksi** (07) | List per hari, filter tipe/akun/kategori, pencarian, edit/hapus | |
| 6 | **Kewajiban** (08) | Timeline siklus, progres "x dari y lunas", CRUD, tandai lunas → transaksi otomatis | |
| 7 | **Pengaturan** | Siklus gajian, akun, kategori custom (ikon + warna), sesuaikan saldo | |
| 8 | **Alert Tier 0** | A1–A4, notifikasi lokal, job harian (workmanager), batas 1/hari + jam tenang | |
| 9 | **Insight dasar** (09) | Donut kategori, tren, pemasukan vs pengeluaran per siklus | |
| 10 | **App lock** | PIN + biometrik | |
| 11 | **Backup/restore** | File terenkripsi dengan password pengguna | Restore di HP lain menghasilkan data yang sama |
| 12 | **Siap beta** | `applicationId` final, ikon, build rilis < 25 MB, text scaling 1.3×, label semantics | Bisa diunggah ke closed testing Play Console |

## 2. Keputusan perhitungan

Keputusan ini mengisi detail yang tidak ada di PRD. Semuanya ada di `lib/engine/` dan dites;
kalau mau diubah, cukup ubah engine dan test-nya.

### Siklus gajian
- Siklus dimulai **pada** hari gajian dan berakhir sehari sebelum gajian berikutnya.
- Tanggal 29–31 di bulan yang lebih pendek dipakai sebagai **hari terakhir bulan itu**.
- "Geser kalau libur": gajian yang jatuh di Sabtu, Minggu, atau libur nasional dipindah **maju ke
  hari kerja sebelumnya** (kebiasaan payroll di Indonesia). Aturan "hari kerja terakhir" otomatis
  melewati akhir pekan dan libur.
- **Sisa hari** = jarak hari ini ke gajian berikutnya. Contoh: 11 Nov → 25 Nov = 14 hari.
- **Waktu berjalan** = hari yang sudah lewat sejak awal siklus ÷ panjang siklus.

### Kewajiban
- Satu kewajiban bulanan menghasilkan satu instance per tanggal jatuh tempo (bukan per siklus),
  karena siklus yang bergeser bisa memuat dua jatuh tempo atau tidak sama sekali.
- Kewajiban dicadangkan dari siklus berjalan kalau jatuh temponya **paling lambat tepat di hari
  gajian berikutnya**. Ini sesuai Lampiran A PRD (Cicilan motor dan Kos 25 Nov dicadangkan sebelum
  gajian 25 Nov), dan aman kalau gaji masuk sore sementara tagihan ditarik pagi.
- Kewajiban dari siklus sebelumnya yang belum dibayar tetap dicadangkan.
- Pembayaran sebagian (cicil) mengurangi sisa yang dicadangkan.

### Safe-to-Spend
```
Sisa         = saldo akun yang dihitung − kewajiban belum dibayar − sisa target tabungan siklus ini
Buffer       = 5% × Sisa (dibulatkan ke atas, 0 kalau Sisa ≤ 0)
Safe-to-Spend = Sisa − Buffer
Jatah harian = Safe-to-Spend ÷ sisa hari (dibulatkan ke bawah, 0 kalau Safe-to-Spend ≤ 0)
```
- Semua nominal `int` Rupiah; persen buffer disimpan dalam basis poin (500 = 5%).
- Akun bisa dikecualikan dari Safe-to-Spend (mis. rekening dana darurat), lewat kolom baru di
  skema v2. Tanpa ini, tabungan yang menumpuk akan terlihat "aman dibelanjakan".
- **Target tabungan**: transfer ke rekening tujuan hanya dihitung "sudah disisihkan" kalau
  rekening itu dikecualikan dari Safe-to-Spend. Kalau ikut dihitung, uangnya masih ada di saldo,
  jadi target tetap dicadangkan penuh. Dengan begitu, menabung tidak pernah mengubah angka
  Safe-to-Spend.

### Libur nasional
- Data dari SKB 3 Menteri: 2026 (17 hari) dan 2027 (18 hari), di
  `lib/engine/cycle/indonesia_holidays.dart`. Tambah tahun berikutnya tiap SKB terbit (±September).
- Cuti bersama tidak dimasukkan: gajian yang tetap di tanggal aslinya membuat siklus lebih panjang,
  jadi Safe-to-Spend lebih konservatif.

### Onboarding
- Alurnya 4 langkah: Gajian → **Saldo** → Kewajiban → Aha. Langkah Saldo belum ada di Figma
  (Figma 3 layar); ditambahkan karena PRD §8.1 mewajibkan saldo awal per akun.
- Tidak ada yang disimpan sampai pengguna menekan "Mulai pakai". Semuanya ditulis dalam satu
  transaksi, aturan gajian paling akhir, jadi Beranda tidak pernah melihat data setengah jadi.
- Angka di layar Aha dihitung dengan aturan yang sama seperti Beranda; test memastikan keduanya
  identik setelah data disimpan.
- Kewajiban yang jatuh tempo sebelum hari onboarding dianggap sudah dibayar (tidak dicadangkan).
- Ikon kewajiban mengikuti kategorinya (mis. Kos → Tempat tinggal), bukan ikon khusus per template
  seperti di Figma, supaya tampilannya sama di semua layar tanpa kolom ikon baru.
- Pengguna tanpa kewajiban rutin tetap bisa lanjut lewat "Saya belum punya kewajiban rutin".
- Target tabungan (opsional di PRD §8.1) dipindah ke Pengaturan (irisan 7) supaya onboarding tetap
  < 2 menit. PIN dipasang di irisan 10 (app lock).

### Penyimpanan tanggal (skema v2)
- Kolom yang hanya berisi **tanggal** (`due_date`, `starts_on`, `tracking_since`) disimpan sebagai
  UTC tengah malam (`…T00:00:00.000Z`) lewat `LocalDate.toUtcMidnight()`, supaya tanggalnya tidak
  bergeser walau zona waktu HP berubah.
- **Waktu transaksi** disimpan sebagai waktu lokal (teks ISO dengan offset). Query rentang memakai
  `unixepoch(date)` supaya tetap benar walau offset-nya berbeda.
- Jatuh tempo dibuat per tanggal (unik per kewajiban + tanggal). Jatuh tempo sebelum kewajiban
  dicatat (`starts_on`) tidak dibuat, karena dianggap sudah diurus sebelum memakai aplikasi.

### Risiko Tier 0
- **Belanja** = pengeluaran yang bukan pembayaran kewajiban. Transfer tidak dihitung.
- **Pace terpakai** = belanja siklus ini ÷ (belanja siklus ini + Safe-to-Spend sekarang).
  Kalau pengguna baru mulai mencatat di tengah siklus, pace dan waktu berjalan dihitung dari
  tanggal mulai mencatat, bukan dari awal siklus.
- **Proyeksi** = rata-rata belanja harian 7 hari terakhir (termasuk hari ini) × sisa hari.
  Kalau data baru beberapa hari, rata-ratanya dari hari yang ada.
- **Berisiko (merah, A1)**: Safe-to-Spend < 0, atau proyeksi > Safe-to-Spend setelah minimal
  3 hari data (supaya belanja besar di hari pertama tidak langsung memicu merah).
- **Waspada (kuning, A4)**: pace terpakai > waktu berjalan + 10 poin, setelah minimal 3 hari data.
- Selain itu **Aman (hijau)**.

## 3. Status

| Irisan | Status |
|---|---|
| 1. Engine inti | ✅ Selesai: `lib/engine/` + `test/engine/`, coverage 100%, Lampiran A PRD terhitung persis |
| 2. Lapisan data | ✅ Selesai: skema v2 + migrasi teruji (data v1 utuh), repository di `lib/data/repositories/`, `SafeToSpendService` + `safeToSpendProvider`, libur nasional 2026–2027; coverage data 99,5% |
| 3. Onboarding | ✅ Selesai: `lib/features/onboarding/`, router mengarahkan pengguna baru ke onboarding, Beranda memakai angka asli + peringatan A1/A4; test end-to-end lewat UI |
| 4. Tambah transaksi + Beranda | Berikutnya |
| 5–12 | Belum |
