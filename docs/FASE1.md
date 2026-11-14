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
| 7 | **Pengaturan** | Siklus gajian, akun, kategori custom (ikon + warna), sesuaikan saldo, **target tabungan bernama** (skema v3) | Target bertenggat mengurangi Safe-to-Spend sebesar kebutuhan per siklusnya |
| 8 | **Alert Tier 0** | A1–A4, notifikasi lokal, job harian (workmanager), batas 1/hari + jam tenang | |
| 9 | **Insight dasar** (09) | Donut kategori, tren, pemasukan vs pengeluaran per siklus | |
| 10 | **App lock** | PIN + biometrik | |
| 11 | **Backup/restore** | File terenkripsi dengan password pengguna | Restore di HP lain menghasilkan data yang sama |
| 12 | **Siap beta** | `applicationId` final, ikon, build rilis < 25 MB, text scaling 1.3×, label semantics | Bisa diunggah ke closed testing Play Console |

Fitur tambahan PRD v0.3 (langganan, kewajiban tahunan/mingguan/sekali, kalender siklus, A7)
semuanya P1 dan **tidak masuk Fase 1**; irisan 6 dan 8 cukup memakai kewajiban bulanan yang sudah
ada. Satu pengecualian, diputuskan 9 Nov 2026: **target tabungan bernama** dibuat langsung di
irisan 7, menggantikan target tunggal per siklus, supaya tidak dikerjakan dua kali. Keputusannya ada
di bagian 2, "Target tabungan bernama".

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
- Semua nominal `int` Rupiah; persen buffer disimpan dalam basis poin (500 = 5%). Bawaannya 5%
  dan bisa diubah di Pengaturan (Tanpa, 5%, 10%, 15%, 20%); di layar disebut "Dana cadangan".
- Akun bisa dikecualikan dari Safe-to-Spend (mis. rekening dana darurat), lewat kolom baru di
  skema v2. Tanpa ini, tabungan yang menumpuk akan terlihat "aman dibelanjakan".
- **Target tabungan**: lihat "Target tabungan bernama" di bawah. Intinya, uang yang sudah disetor
  tetapi masih berada di akun yang dihitung tetap dicadangkan, jadi menyetor tidak pernah mengubah
  angka Safe-to-Spend.
- **Sisihan gaji** (persen perkiraan gaji) ikut "sisa target tabungan siklus ini", lewat target
  sistem "Sisa gaji"; lihat "Sisihkan dari gaji" di bawah. Buffer dihitung dari sisa setelahnya.

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

### Tambah transaksi (layar 06)
- Toggle punya tiga jenis: Pengeluaran, Pemasukan, dan **Transfer** (Figma hanya dua). Untuk
  transfer, deretan kategori diganti deretan akun tujuan.
- Kategori yang terakhir dipakai ada paling depan dan langsung terpilih; akun mengikuti yang
  terakhir dipakai. Quick Add: FAB → ketik nominal → Simpan.
- Pil "Sisa aman setelah ini" dihitung engine (`SafeToSpend.withBalanceChange`); transaksi dari
  akun yang dikecualikan menampilkan "Tidak mengubah Safe-to-Spend".
- Snackbar setelah simpan memakai Safe-to-Spend yang dihitung ulang dari database, bukan
  perkiraan.
- Transaksi bisa diubah dan dihapus dengan mengetuknya di Beranda atau di layar Transaksi.
  Pembayaran kewajiban tidak bisa diganti jenis atau kategorinya.

### Transaksi (layar 07)
- **Ringkasan siklus** = pemasukan dan pengeluaran siklus berjalan dari semua akun, dihitung dengan
  agregat SQL. Transfer tidak dihitung, dan ringkasan tidak ikut filter supaya angkanya selalu bisa
  dibandingkan.
- **Filter** ada tiga kelompok: jenis (Pengeluaran/Pemasukan/Transfer), kategori, dan akun. Tiap
  kelompok satu pilihan (DESIGN.md §8.3), dan kelompoknya bisa digabung. Chip Transfer ditambahkan
  karena sheet 06 punya tiga jenis. Memilih kategori ikut memilih jenisnya; memilih jenis yang tidak
  cocok melepas kategori. Filter akun juga menampilkan transfer yang masuk ke akun itu.
- **Pencarian** mencari di catatan, nama kategori, dan nama akun asal/tujuan, tanpa membedakan huruf
  besar/kecil. Isian yang hanya angka (boleh dengan "Rp" dan titik) juga dicocokkan dengan nominal.
  `%` dan `_` dicari apa adanya. Query dijalankan 250 ms setelah berhenti mengetik.
- **Daftar dimuat per 100 baris**; halaman berikutnya dimuat saat scroll mendekati akhir.
- **Total harian** = pemasukan − pengeluaran hari itu, tanpa transfer. Hari terakhir yang terpotong
  batas halaman tidak diberi total sampai halamannya lengkap.
- Judul hari: "Hari ini · Rab, 11 Nov", "Kemarin · Sel, 10 Nov", lalu "Sen, 9 Nov"; tahun ditulis
  kalau berbeda dari tahun ini.

### Kewajiban (layar 08)
- **Timeline** = jatuh tempo yang dicadangkan siklus berjalan (setelah gajian pembuka sampai tepat
  di gajian berikutnya) ditambah tunggakan siklus lalu yang belum lunas. Dikelompokkan
  Terlambat (lewat jatuh tempo), Akan datang, dan Lunas. Kelompok "Semua kewajiban" di bawahnya
  memuat kewajiban yang jatuh temponya belum masuk siklus ini, supaya tetap bisa diubah.
- **Kartu progres**: "x dari y lunas" (jatuh tempo yang dilewati tidak dihitung), total per siklus
  (tanpa tunggakan), sudah dibayar, dan sisa sampai gajian. Sisa ini sama dengan angka "diamankan"
  di kartu Safe-to-Spend.
- **"Sudah dibayar?"** (A3 di layar): jatuh tempo terlambat paling awal yang belum ada
  pembayarannya sama sekali, dengan aksi Tandai lunas.
- **Tandai lunas** membuka sheet pembayaran: nominal (awalnya sisa), akun (akun kewajiban, lalu akun
  terakhir dipakai), dan tanggal. Pembayarannya menjadi transaksi pengeluaran yang terhubung.
  Nominal di bawah sisa bisa dicatat sebagai **cicilan** (sisa tetap dicadangkan) atau **lunas**
  (mis. tagihan lebih kecil dari estimasi); defaultnya lunas untuk nominal berubah-ubah dan
  cicilan untuk nominal tetap.
- **Tambah kewajiban** memakai editor onboarding. Jatuh tempo sebelum hari ini dianggap sudah
  diurus (sama seperti onboarding), lalu jatuh temponya langsung dibuat tanpa menunggu Beranda.
- **Ubah nominal** berlaku untuk semua jatuh tempo yang belum lunas; yang sudah lunas tidak berubah.
- **Ubah tanggal**: jatuh tempo mulai hari ini yang belum ada pembayarannya dipindah ke tanggal baru.
  Tanggal baru berlaku mulai bulan setelah jatuh tempo terakhir yang tersisa, jadi bulan yang sudah
  lunas tidak tertagih dua kali.
- **Hapus** meminta konfirmasi; riwayat pembayarannya tetap ada di Transaksi.

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

### Target tabungan bernama (irisan 7)
Diputuskan 9 Nov 2026 (PRD v0.3 §7.3 dan §10.4), dibangun di irisan 7. Hitungannya ada di
`lib/engine/safe_to_spend/savings_goal.dart`.
- **Dua bentuk target**: *rutin* (setoran tetap per siklus; nominal target opsional) dan
  *bertenggat* (nominal target + tanggal tenggat).
- **Kebutuhan per siklus** target bertenggat = sisa target sebelum siklus ini ÷ jumlah siklus dari
  siklus berjalan sampai siklus yang memuat tenggat, dibulatkan ke atas. Siklus yang memuat tenggat
  ikut dihitung karena gajiannya masuk sebelum tenggat; tenggat yang sudah lewat dihitung 1 siklus.
  Target rutin memakai nominal per siklusnya, tidak melebihi sisa target kalau nominal target diisi.
- **Dicadangkan** per target = (setoran yang masih berada di akun yang dihitung) + kekurangan
  setoran siklus ini (kebutuhan − setoran siklus ini, minimal 0). Jumlah semua target aktif mengisi
  `savingsReserved` di engine, jadi rumus Safe-to-Spend tidak berubah.
- **Setoran dicatat lewat tombol Setor**, bukan ditebak dari transfer. Aturan lama ("transfer ke
  akun tabungan otomatis dihitung") diganti, karena transfer ke akun yang sama bisa punya tujuan
  lain. Tiap setoran menjadi satu baris `goal_contributions`.
- **Rekening tujuan** opsional dan hanya bisa akun yang dikecualikan dari Safe-to-Spend. Dengan
  rekening tujuan, setoran dari akun lain dicatat sebagai transaksi transfer (catatan
  "Tabungan <nama target>"); pilihan "Sudah di <rekening>" mencatat setoran tanpa transfer. Tanpa
  rekening tujuan, uangnya tetap di akun harian dan hanya ditandai untuk target itu.
- **Hapus setoran** ikut menghapus transfernya. **Tandai selesai** mengarsipkan target: riwayatnya
  tetap ada dan dananya tidak lagi dicadangkan (dipakai saat uangnya sudah dibelanjakan atau target
  dihentikan). Kolom `achievedAt` di rencana awal tidak jadi dibuat; `archived` sudah cukup. Target
  yang terkumpul penuh diberi tanda "Tercapai" tetapi tetap dicadangkan sampai ditandai selesai.
- **Hapus target** menghapus target dan catatan setorannya; transfer yang sudah tercatat tetap ada
  sebagai transfer biasa.
- **Skema v3**: tabel `savings_goals` dan `goal_contributions` menggantikan `savings_targets`. Baris
  lama (kalau ada) dimigrasi menjadi satu target tanpa tenggat bernama "Tabungan" dengan nominal per
  siklus yang sama.
- Alert A7 (target tertinggal) belum masuk; menyusul di Fase 2. Ikon dan warna target masih bawaan
  (celengan hijau).

### Sisihkan dari gaji (irisan 7, skema v4)
Diminta pengguna 10 Nov 2026: gaji tidak harus habis tiap siklus, jadi sebagian bisa disisakan.
Keputusan pengguna: dana cadangan tetap ada ("pakai keduanya"), dan sisihan yang tersisa ditabung
otomatis.
- **Sisihan per siklus** = persen × perkiraan gaji, dibulatkan ke atas. Pilihannya Tanpa, 5%, 10%,
  15%, 20%, 25%, 30% di sheet Siklus gajian. Contoh: gaji Rp 2.000.000 dengan 10% → Rp 200.000.
- Sisihan dikunci dari Safe-to-Spend sepanjang siklus lewat target sistem **"Sisa gaji"** (kolom
  `salary_basis_points`), jadi rumus engine tidak berubah. Dana cadangan dihitung dari sisa
  setelahnya, sehingga ikut mengecil saat uang dipakai dan tidak ditabung.
- **Ditabung otomatis saat gajian**: saat Safe-to-Spend pertama kali dihitung setelah gajian,
  sisihan siklus yang baru berakhir dicatat sebagai setoran "Sisa gaji" bertanggal hari terakhir
  siklus itu. Setoran itu tetap dikunci di siklus berikutnya, jadi tabungannya menumpuk.
- **Yang ditabung** = saldo akun yang dihitung tepat sebelum gajian − kewajiban yang masih
  dicadangkan saat itu − cadangan target lain − tabungan sisa gaji sebelumnya, paling banyak
  sebesar sisihannya dan minimal 0. Kalau belanja sempat memakai sisihan, hanya sisanya yang
  ditabung; kewajiban dan target lain didahulukan. Pembayaran yang dicatat di hari gajian tidak
  mengurangi siklus yang sudah berakhir.
- Tiap siklus ditabung **sekali** (kolom `settled_through`). Belanja siklus lalu yang baru dicatat
  setelahnya mengurangi siklus berjalan, bukan tabungannya.
- Mengubah aturan gajian atau persen: siklus yang sudah lewat ditabung dulu dengan aturan lama;
  persen baru berlaku mulai siklus berjalan.
- **Lepas** per siklus atau semuanya dari sheet "Sisa gaji": uangnya kembali dihitung aman
  dibelanjakan. Persen "Tanpa" menghentikan sisihan baru; target "Sisa gaji" hilang kalau
  tabungannya juga kosong.
- Uangnya tetap di akun harian. Untuk memindahkannya ke rekening tabungan, pakai target bernama
  dengan rekening tujuan.

### Pengaturan (irisan 7)
DESIGN.md belum memuat layar Pengaturan, jadi tata letaknya memakai komponen yang sudah ada.
- **Masuk** dari ikon roda gigi di Beranda. Layarnya di luar empat tab (tanpa NavBar), dengan
  kelompok Siklus gajian, Akun, Target tabungan, dan Kategori. Kategori punya layar sendiri.
- **Siklus gajian**: aturan, tanggal, geser-saat-libur, perkiraan gaji, sisihan gaji, dan dana
  cadangan diubah dalam satu sheet dengan pratinjau gajian berikutnya. Batas siklus berjalan langsung mengikuti
  aturan baru, dan jatuh tempo kewajiban untuk siklus itu dibuat saat disimpan.
- **Akun**: nama, jenis, dan "Hitung di Safe-to-Spend". Mengganti jenis ikut mengganti ikon dan
  warnanya ke bawaan jenis itu.
- **Sesuaikan saldo**: mengubah angka "Saldo sekarang" di sheet akun menyamakan saldo dengan saldo
  sebenarnya. Selisihnya masuk ke saldo awal, **bukan transaksi**, supaya pemasukan, pengeluaran,
  dan pace risiko siklus tidak ikut berubah.
- **Arsipkan akun**: akun tidak dihapus supaya riwayat transaksinya utuh. Konfirmasinya menyebut
  saldo yang tidak lagi dihitung. Akun aktif terakhir tidak bisa diarsipkan.
- **Kategori**: nama, ikon (45 pilihan Lucide), dan warna (6 tone). Jenisnya (pengeluaran/pemasukan)
  ditentukan saat dibuat dan tidak bisa diganti. Dua kategori aktif berjenis sama tidak boleh
  bernama sama (huruf besar/kecil diabaikan), karena kewajiban dan onboarding mencari kategori
  lewat namanya.
- **Arsipkan kategori**: transaksi dan kewajiban yang sudah memakainya tidak berubah. Kategori
  terakhir tiap jenis tidak bisa diarsipkan. Kewajiban yang kategorinya diarsipkan tetap bisa
  memilih kategori itu di editornya; kewajiban baru memakai "Lainnya", atau kategori pengeluaran
  pertama kalau "Lainnya" sudah diganti nama atau diarsipkan.
- Belum ada: memulihkan akun/kategori yang diarsipkan, mengurutkan ulang, dan ikon khusus akun.

## 3. Status

| Irisan | Status |
|---|---|
| 1. Engine inti | ✅ Selesai: `lib/engine/` + `test/engine/`, coverage 100%, Lampiran A PRD terhitung persis |
| 2. Lapisan data | ✅ Selesai: skema v2 + migrasi teruji (data v1 utuh), repository di `lib/data/repositories/`, `SafeToSpendService` + `safeToSpendProvider`, libur nasional 2026–2027; coverage data 99,5% |
| 3. Onboarding | ✅ Selesai: `lib/features/onboarding/`, router mengarahkan pengguna baru ke onboarding, Beranda memakai angka asli + peringatan A1/A4; test end-to-end lewat UI |
| 4. Tambah transaksi + Beranda | ✅ Selesai (belum dicek di HP): sheet layar 06 dengan keypad, kategori terakhir dipakai, akun/tanggal/catatan, transfer, ubah & hapus; Beranda menampilkan kewajiban terdekat dan transaksi terakhir |
| 5. Transaksi | ✅ Selesai (belum dicek di HP): `lib/features/transactions/presentation/transactions_screen.dart`, ringkasan siklus, filter jenis/kategori/akun, pencarian, grup per hari, muat per halaman, ubah & hapus lewat sheet |
| 6. Kewajiban | ✅ Selesai (belum dicek di HP): `lib/features/obligations/`, kartu progres siklus, kelompok terlambat/akan datang/lunas, "Sudah dibayar?", tandai lunas & cicilan, tambah/ubah/hapus kewajiban |
| 7. Pengaturan | ✅ Selesai (terpasang di HP 10 Nov, belum dicoba lengkap): `lib/features/settings/`, skema v3–v4 + migrasi teruji, siklus gajian & dana cadangan, sisihan persen gaji yang ditabung otomatis ke "Sisa gaji", akun (tambah/ubah/sesuaikan saldo/arsip), kategori custom dengan ikon & warna, target tabungan bernama (rutin & bertenggat, setor, riwayat, selesai/hapus) |
| 8. Alert Tier 0 | Berikutnya |
| 9–12 | Belum |
