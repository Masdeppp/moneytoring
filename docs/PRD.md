# PRD — Moneytoring

> **"Bukan cuma mencatat uang yang sudah keluar, tapi menjaga uang yang *harus* keluar."**

| | |
|---|---|
| **Versi dokumen** | 0.2 |
| **Tanggal** | 4 November 2026 |
| **Status** | Keputusan produk sudah diambil (lihat bagian 16); siap masuk tahap desain |
| **Platform** | Mobile (Flutter): **Android dulu**, iOS di Fase 3 |
| **Model bisnis** | Freemium (lihat bagian 13) |
| **Nama** | "Moneytoring" (*working title*, belum final) |
| **Desain** | [DESIGN.md](DESIGN.md) · [File Figma](https://www.figma.com/design/kvkQ06T5yRbUwYJQo7QOgA) |

---

## 1. Ringkasan Eksekutif

Moneytoring adalah aplikasi pencatat keuangan pribadi yang **melihat ke depan**. Aplikasi pencatat pada umumnya hanya merekam dan merangkum transaksi yang sudah terjadi, jadi pengguna baru tahu uangnya kurang setelah terlambat.

Moneytoring berpusat pada **Kewajiban Rutin**, yaitu pengeluaran wajib tiap bulan (kos, cicilan, listrik, internet, BPJS, langganan, kiriman ke orang tua). Dari data itu aplikasi menghitung **berapa uang yang benar-benar aman dibelanjakan** sampai gajian berikutnya. Aplikasi juga **memperingatkan lebih awal** kalau pola belanja saat ini mengancam kewajiban tersebut.

Kecerdasannya dibangun **bertahap**. Hari pertama memakai aturan sederhana, lalu model statistik setelah data cukup, lalu ML on-device. Dengan begitu aplikasi sudah berguna sejak hari pertama, tanpa harus menunggu data berbulan-bulan.

---

## 2. Latar Belakang & Masalah

### 2.1 Masalah yang dialami pengguna

1. **"Saldo kelihatan banyak, padahal sebagian sudah 'milik' tagihan."** Pengguna melihat saldo Rp 3 juta lalu merasa aman, padahal Rp 2,2 juta harus dipakai bayar kos dan cicilan tanggal 25.
2. **Sadar boros setelah terlambat.** Laporan bulanan baru berguna setelah bulan selesai.
3. **Siklus keuangan orang Indonesia ikut tanggal gajian, bukan kalender.** Gajian tanggal 25 berarti "bulan keuangan" berjalan dari 25 ke 24. Kebanyakan aplikasi memakai tanggal 1–30/31.
4. **Lupa bayar tagihan rutin**, atau bayar tapi lupa dicatat, sehingga data jadi tidak akurat.
5. **Malas mencatat.** Ini alasan utama orang berhenti memakai aplikasi keuangan. Kalau input terasa berat, fitur secanggih apa pun tidak akan terpakai.

### 2.2 Posisi terhadap aplikasi sejenis

| Aspek | Aplikasi pencatat pada umumnya | **Moneytoring** |
|---|---|---|
| Sudut pandang | Ke belakang (apa yang sudah terjadi) | **Ke depan** (apa yang akan terjadi) |
| Angka utama di beranda | Total saldo | **Aman Dibelanjakan (Safe-to-Spend)** |
| Periode | Bulan kalender | **Siklus gajian** (bisa diatur) |
| Budget | Batas per kategori, statis | Budget + **kewajiban yang dilindungi** |
| Peringatan | "Budget kategori X habis" | **"Cicilan tgl 25 berisiko tidak tertutup"** (kontekstual dan prediktif) |
| Kecerdasan | Minim atau berbasis cloud | **On-device**, data tidak keluar dari HP |

---

## 3. Visi, Tujuan & Non-Tujuan

### 3.1 Visi
Pengguna **tidak pernah lagi kekurangan uang untuk kewajibannya** dan tahu setiap hari berapa yang boleh dibelanjakan tanpa rasa bersalah.

### 3.2 Tujuan produk (MVP)
- G1: Pengguna bisa mencatat transaksi dalam **≤ 5 detik** (3 tap).
- G2: Pengguna paham posisi keuangannya dari **satu angka** di beranda (Safe-to-Spend).
- G3: Pengguna mendapat peringatan **sebelum** kewajiban terancam, bukan sesudahnya.
- G4: Semua data dan komputasi berjalan **offline dan on-device**.

### 3.3 Non-tujuan (sengaja TIDAK dikerjakan di MVP)
- Integrasi langsung ke rekening bank atau open banking.
- Fitur investasi, saham, atau kripto.
- Rekomendasi atau saran investasi finansial.
- Keuangan bersama atau keluarga (multi-user).
- Versi web/desktop.
- Akun/login pengguna dan backend sendiri (paling cepat Fase 3, bersama cloud sync).
- Rilis iOS (Fase 3).
- Mode penghasilan tidak tetap untuk freelancer (Fase 3).

---

## 4. Target Pengguna & Persona

**Segmen utama:** karyawan muda dan fresh graduate usia 20–35 tahun dengan penghasilan tetap bulanan, yang punya beberapa kewajiban rutin dan sering "kering" di akhir bulan.

| Persona | Profil | Pain point utama | Fitur yang paling dibutuhkan |
|---|---|---|---|
| **Raka, 24 th**, staf IT, ngekos | Gaji Rp 6 jt tgl 25. Kos, cicilan motor, langganan streaming. | Tanggal 15-an uang tinggal sedikit, cicilan hampir telat. | Safe-to-Spend, Risk Alert |
| **Dinda, 29 th**, sudah menikah | Gaji + freelance. KPR, listrik, sekolah anak, kiriman ke orang tua. | Banyak tagihan, jatuh tempo berbeda-beda, takut ada yang lupa. | Kalender Kewajiban, auto-match pembayaran |
| **Bayu, 22 th**, freelancer | Penghasilan tidak tetap. | Tidak tahu harus menyisihkan berapa. | Mode penghasilan tidak tetap (Fase 3) |

> MVP fokus ke **Raka dan Dinda** (penghasilan tetap). Persona Bayu butuh model siklus dan proyeksi yang berbeda, jadi digarap di **Fase 3** setelah inti produk tervalidasi.

---

## 5. Unique Selling Points (Pembeda Utama)

### USP 1 — Kewajiban Rutin dan **Safe-to-Spend** ⭐ (inti produk)
Pengguna mendaftarkan kewajiban bulanan: nominal, tanggal jatuh tempo, tetap atau berubah-ubah, dan akun sumber dana. Aplikasi lalu menghitung:

```
Safe-to-Spend = Saldo tersedia
              − Kewajiban yang BELUM dibayar sampai gajian berikutnya
              − Target tabungan siklus ini (opsional)
              − Dana cadangan (buffer, default 5%)

Jatah Harian  = Safe-to-Spend ÷ Sisa hari sampai gajian
```

Beranda **tidak** menampilkan "Saldo Rp 3.000.000". Yang ditampilkan:
> **Aman dibelanjakan: Rp 640.000** · ≈ Rp 45.700/hari selama 14 hari lagi

### USP 2 — **Smart Risk Alert** (prediktif, terkait kewajiban)
Peringatan tidak sekadar "budget habis". Aplikasi **memproyeksikan** belanja sampai akhir siklus lalu mengaitkannya dengan kewajiban:
> ⚠️ *"Dengan pola belanjamu minggu ini, uangmu diperkirakan kurang **Rp 350rb** untuk bayar **Cicilan Motor (25 Nov)**. Kurangi belanja ke Rp 30rb/hari supaya aman."*

Setiap peringatan selalu menyertakan **aksi konkret**, bukan cuma bikin panik.

### USP 3 — **Siklus Gajian**, bukan bulan kalender
Pengguna menentukan tanggal gajian (mis. 25, atau "hari kerja terakhir"). Semua laporan, budget, dan proyeksi mengikuti siklus ini. Ada penyesuaian otomatis kalau tanggal gajian jatuh di akhir pekan atau hari libur.

### USP 4 — **Simulasi "Kalau Aku Beli…" (What-If)**
Sebelum belanja besar, pengguna memasukkan nominal, lalu aplikasi menjawab:
> *"Kalau beli sepatu Rp 800rb hari ini, Safe-to-Spend jadi Rp −160rb. Kewajiban **Listrik (20 Nov)** jadi berisiko. Saran: tunda sampai setelah gajian (8 hari lagi)."*

Fitur ini memakai engine yang sama dengan USP 1–2, jadi biaya pengembangannya kecil tapi nilai pembedanya besar.

### USP 5 — **Auto-Match Pembayaran Kewajiban**
Saat pengguna mencatat "Bayar kos 1.500.000", aplikasi mengenalinya sebagai kewajiban "Kos" dan otomatis menandainya **lunas** untuk siklus ini. Kewajiban yang lewat jatuh tempo tanpa transaksi yang cocok akan memunculkan pengingat: *"Kos sudah dibayar belum?"*

### USP 6 — **Privasi-first, On-device Intelligence**
Semua prediksi dan kategorisasi berjalan di HP. Tanpa akun, tanpa server. Ini menjadi nilai jual tersendiri di tengah kekhawatiran soal kebocoran data.

---

## 6. Strategi Kecerdasan (ML) — Dibangun Bertahap

> **Catatan jujur dari sisi engineering:** ML untuk *satu pengguna* punya masalah **cold start**. Pengguna baru belum punya data, dan untuk time-series personal yang datanya sedikit, model statistik sederhana sering **lebih akurat dan lebih stabil** dibanding model ML yang kompleks. Karena itu kecerdasan dibangun bertingkat, dan tingkat berikutnya baru aktif kalau datanya cukup.

### 6.1 Tingkatan kecerdasan

| Tier | Aktif ketika | Metode | Contoh output |
|---|---|---|---|
| **Tier 0: Rules** | Hari ke-1 | Aritmatika dan aturan: Safe-to-Spend, jatuh tempo, pace sederhana (belanja ÷ hari berjalan) | "Kamu sudah memakai 60% Safe-to-Spend padahal siklus baru berjalan 30%." |
| **Tier 1: Statistik** | ≥ 14 hari data / ≥ 30 transaksi | Exponential smoothing per kategori, pola hari-dalam-minggu, deteksi anomali z-score/IQR | "Pengeluaran Makan minggu ini 45% di atas rata-ratamu." |
| **Tier 2: Probabilistik / ML** | ≥ 2 siklus penuh | **Simulasi Monte Carlo** dari distribusi belanja harian historis untuk menghitung *probabilitas* kewajiban tidak tertutup; model kategorisasi teks (TFLite) | "Peluang cicilan tidak tertutup: **32%**." |

### 6.2 Komponen kecerdasan

**a. Spending Forecaster (proyeksi akhir siklus)**
- Input: transaksi per hari per kategori, posisi hari dalam siklus, hari dalam minggu, pengeluaran besar yang sudah terjadwal.
- Tier 1: Holt's exponential smoothing + faktor musiman mingguan (weekend biasanya lebih boros).
- Tier 2: bootstrap Monte Carlo. Ambil sampel acak belanja harian dari riwayat sebanyak 1.000–5.000 simulasi, lalu hitung distribusi saldo di hari H-gajian. Murah dihitung di Dart isolate (< 100 ms).
- Output: proyeksi belanja (P50/P80) dan **risk score per kewajiban**.

**b. Anomaly Detector**
- Menandai transaksi yang tidak biasa (nominal jauh di atas median kategori, atau kategori yang jarang dipakai).
- Tujuannya **kesadaran, bukan menghakimi**: *"Transaksi Rp 1,2 jt di Belanja Online, 4× lebih besar dari biasanya. Sudah benar?"*

**c. Auto-Categorizer**
- Tahap 1: kamus kata kunci bahasa Indonesia (gofood, indomaret, pln, pulsa, dll) + riwayat pengguna (catatan yang sama ke kategori yang sama).
- Tahap 2: text classifier kecil (TFLite, < 2 MB) yang dilatih dari dataset catatan transaksi berbahasa Indonesia. Koreksi dari pengguna disimpan sebagai lapisan personal yang menimpa prediksi model.

**d. Alert Tuner (belajar dari feedback)**
- Setiap notifikasi punya tombol 👍 *Berguna* / 👎 *Tidak perlu*.
- Ambang (threshold) per jenis alert disesuaikan otomatis. Kalau pengguna terus menolak alert pace, ambangnya dinaikkan. Ini mencegah **alert fatigue**, yang membuat orang mematikan notifikasi lalu meninggalkan aplikasi.

### 6.3 Jenis peringatan (Alert Catalog)

| ID | Jenis | Pemicu | Prioritas |
|---|---|---|---|
| A1 | **Kewajiban Berisiko** | Proyeksi saldo < total kewajiban yang belum dibayar (atau risk ≥ 30% di Tier 2) | 🔴 Tinggi |
| A2 | Jatuh Tempo | H-3 dan H-1 sebelum kewajiban, kalau belum lunas | 🟠 Sedang |
| A3 | Belum Tercatat | Lewat jatuh tempo, tidak ada transaksi yang cocok | 🟠 Sedang |
| A4 | Pace Terlalu Cepat | % Safe-to-Spend terpakai > % siklus berjalan + margin | 🟡 Rendah |
| A5 | Anomali Transaksi | Transaksi menyimpang dari pola | 🟡 Rendah |
| A6 | Ringkasan Mingguan | Tiap Minggu malam | ⚪ Info |

**Aturan anti-spam:** maksimal 1 alert per hari untuk prioritas rendah dan sedang, ada jam tenang (default 21.00–07.00), dan A1 boleh menembus batas tersebut.

---

## 7. Fitur & Prioritas

**P0** = wajib ada di MVP · **P1** = sebaiknya ada di MVP atau segera sesudahnya · **P2** = fase berikutnya · 💎 = fitur Premium (lihat bagian 13)

### 7.1 Pencatatan dasar
| Fitur | Prioritas | Keterangan |
|---|---|---|
| Catat pemasukan/pengeluaran/transfer | P0 | Nominal, kategori, akun, tanggal, catatan |
| Quick Add (≤ 3 tap) + keypad nominal custom | P0 | Shortcut "000", kategori terakhir dipakai paling depan |
| Multi-akun/dompet (Tunai, BCA, GoPay, dll) | P0 | Saldo per akun |
| Kategori default + custom (ikon dan warna) | P0 | |
| Riwayat transaksi + filter + pencarian | P0 | |
| Input bahasa natural: "makan siang 25rb" | P1 | Parser rule-based, tanpa LLM |
| Widget home screen (Safe-to-Spend + tombol tambah) | P1 | Sangat membantu retensi |
| Scan struk (OCR on-device, ML Kit) | P2 | |
| Baca notifikasi e-wallet/m-banking (Android) | P2 | Sensitif dari sisi izin dan privasi, harus opt-in |

### 7.2 Kewajiban & siklus (inti)
| Fitur | Prioritas | Keterangan |
|---|---|---|
| Pengaturan siklus gajian | P0 | Tanggal tetap / hari kerja terakhir; geser kalau jatuh di hari libur |
| CRUD Kewajiban Rutin | P0 | Nominal tetap atau estimasi (mis. listrik ±Rp 300rb), tanggal jatuh tempo, akun |
| Kalender/timeline kewajiban per siklus | P0 | Status: Belum, Lunas, Terlambat |
| Tandai lunas (manual) | P0 | Otomatis membuat transaksi |
| Auto-match transaksi ke kewajiban | P1 | Berdasarkan kategori + nominal (±10%) + rentang tanggal |
| Estimasi nominal variabel dari histori | P1 | Listrik bulan lalu menjadi estimasi bulan ini |
| Kewajiban non-bulanan (tahunan, mingguan) | P2 | Mis. pajak kendaraan, dicicil per siklus |

### 7.3 Engine & insight
| Fitur | Prioritas |
|---|---|
| Safe-to-Spend + Jatah Harian | P0 |
| Alert A1–A4 (Tier 0) | P0 |
| Laporan per siklus: pie kategori, tren, pemasukan vs pengeluaran | P0 |
| Budget per kategori (opsional) | P1 |
| Forecaster Tier 1 + Anomali (A5) | P1 |
| 💎 Simulasi What-If | P1 |
| Feedback alert dan auto-tuning | P1 |
| 💎 Laporan multi-siklus (perbandingan antar siklus, tren 6–12 siklus) | P1 |
| 💎 Monte Carlo risk score (Tier 2) | P2 |
| Auto-categorizer TFLite | P2 |
| "Skor Kesehatan Keuangan" | P2 |

### 7.4 Sistem
| Fitur | Prioritas |
|---|---|
| App lock (PIN/biometrik) | P0 |
| Backup/restore file terenkripsi (lokal / share ke Drive) | P0 |
| 💎 Export CSV/PDF | P1 |
| Paywall + Google Play Billing + restore pembelian | P1 |
| Dark mode, Bahasa Indonesia + Inggris | P1 |
| 💎 Tema & ikon aplikasi custom | P2 |
| Cloud sync multi-device (opsional, butuh akun) | P2 |

---

## 8. User Flow Utama

### 8.1 Onboarding (target selesai < 2 menit)
Onboarding **wajib mengisi kewajiban**. Tanpa itu, USP utama tidak terasa dan aplikasi terlihat sama saja dengan aplikasi lain.

```
Welcome → Tanggal gajian & nominal gaji
        → Saldo awal per akun (minimal 1 akun)
        → Pilih kewajiban dari template (Kos, Cicilan, Listrik, Internet, BPJS, Langganan…)
          + isi nominal & tanggal
        → (opsional) Target tabungan per siklus
        → ✨ "Aman dibelanjakan: Rp xxx (≈ Rp yy/hari)"   ← aha moment
        → Set PIN
```

### 8.2 Harian
```
Buka app / widget → lihat Safe-to-Spend → [+] → nominal → kategori → Simpan
                  → Safe-to-Spend & jatah harian ter-update seketika
```

### 8.3 Saat alert risiko muncul
```
Notifikasi A1 → buka detail → lihat: kewajiban yang terancam, selisih, proyeksi grafik
             → aksi: [Lihat jatah harian baru] [Pindah dana dari akun lain] [Geser target tabungan]
             → feedback 👍/👎
```

---

## 9. Struktur Layar (MVP)

| # | Layar | Isi utama |
|---|---|---|
| 1 | **Beranda** | Kartu Safe-to-Spend + jatah harian, indikator risiko (hijau/kuning/merah), 3 kewajiban terdekat, transaksi terakhir, FAB tambah |
| 2 | **Tambah Transaksi** (bottom sheet) | Keypad nominal, grid kategori, akun, tanggal, catatan |
| 3 | **Transaksi** | List per hari, filter akun/kategori/tipe, search |
| 4 | **Kewajiban** | Timeline siklus berjalan, progress "x dari y lunas", CRUD |
| 5 | **Insight** | Laporan siklus, proyeksi akhir siklus, daftar alert |
| 6 | **Simulasi** | Input nominal, lalu dampak ke Safe-to-Spend dan kewajiban |
| 7 | **Pengaturan** | Siklus, akun, kategori, notifikasi, keamanan, backup |

Navigasi: bottom nav 4 tab (Beranda · Transaksi · Kewajiban · Insight) + FAB.

---

## 10. Arsitektur & Tech Stack

### 10.1 Prinsip
- **Offline-first.** SQLite adalah sumber kebenaran tunggal.
- **Uang disimpan sebagai `int`** (rupiah, atau satuan terkecil). **Jangan pernah pakai `double`** untuk nominal.
- **Engine terpisah dari UI.** Kalkulasi Safe-to-Spend, forecast, dan alert berupa *pure Dart* yang bisa di-unit-test tanpa Flutter.
- Komputasi berat dijalankan di **isolate** agar UI tetap 60 fps.

### 10.2 Stack yang direkomendasikan

| Kebutuhan | Pilihan | Alasan |
|---|---|---|
| Framework | Flutter (stable terbaru), Dart 3 | |
| State management | **Riverpod** (+ riverpod_generator) | Testable, reaktif, cocok dengan stream dari DB |
| Database lokal | **Drift** (SQLite) + SQLite3MultipleCiphers | Relasional, query agregasi kuat, migrasi jelas. Enkripsi diaktifkan lewat hooks paket `sqlite3` (`source: sqlite3mc`); sejak drift 2.32 ini yang direkomendasikan, menggantikan SQLCipher |
| Routing | go_router | |
| Model/immutability | freezed + json_serializable | |
| Chart | fl_chart | |
| Notifikasi lokal | flutter_local_notifications | |
| Background job | workmanager | Hitung ulang risiko harian dan jadwalkan alert |
| Keamanan | local_auth, flutter_secure_storage | Biometrik + kunci enkripsi DB |
| ML (Tier 2) | tflite_flutter; statistik pakai pure Dart | |
| Widget home screen | home_widget | |
| Pembayaran premium | in_app_purchase (Google Play Billing) | Tanpa backend: kepemilikan Premium terikat ke akun Google Play, bisa di-restore setelah reinstall |
| Feature gating | `EntitlementService` (Riverpod provider) | Satu titik cek Premium, supaya paywall tidak tersebar di banyak widget |
| i18n | flutter_localizations + intl (format Rupiah) | |
| Testing | flutter_test, mocktail, golden test untuk komponen kunci | |

### 10.3 Struktur folder (feature-first, clean architecture)

```
lib/
├── core/            # theme, router, utils (money formatter), constants, DI
├── data/
│   ├── db/          # drift database, tables, DAOs, migrations
│   └── repositories/
├── engine/          # ⭐ pure Dart — tidak boleh import Flutter
│   ├── cycle/       # perhitungan siklus gajian
│   ├── safe_to_spend/
│   ├── forecast/    # tier 0/1/2
│   ├── anomaly/
│   ├── matcher/     # auto-match transaksi ↔ kewajiban
│   └── alerts/      # rule evaluator + tuner
├── features/
│   ├── onboarding/
│   ├── home/
│   ├── transactions/
│   ├── obligations/
│   ├── insights/
│   ├── simulator/
│   └── settings/
│       └── (masing-masing: presentation/ + application/ (providers))
└── main.dart
```

### 10.4 Model data (inti)

```
Account          id, name, type(cash/bank/ewallet), initialBalance:int, color, icon, archived
Category         id, name, type(income/expense), icon, color, isDefault
Transaction      id, type(income/expense/transfer), amount:int, accountId, toAccountId?,
                 categoryId, date, note, obligationInstanceId?, createdAt
PayCycleConfig   paydayRule(fixedDate/lastWorkday), day, shiftOnHoliday, expectedIncome:int
Obligation       id, name, amountType(fixed/estimated), amount:int, dueDay, categoryId,
                 accountId, recurrence(monthly…), active, autoMatchKeywords
ObligationInstance id, obligationId, cycleStart, dueDate, expectedAmount:int,
                 status(pending/paid/late/skipped), paidTransactionId?
SavingsTarget    id, amountPerCycle:int, accountId
Alert            id, type, payload(json), createdAt, readAt, feedback(useful/notUseful/null)
AlertThreshold   type, value, updatedAt          # hasil auto-tuning
Entitlement      productId, purchaseToken, status(active/expired/refunded), verifiedAt
                 # cache lokal status Premium; sumber kebenaran tetap Google Play
```

### 10.5 Nama aplikasi masih *working title*
`applicationId` **tidak bisa diganti** setelah aplikasi terbit di Play Store, sedangkan nama tampilan bisa diganti kapan saja. Karena itu:
- Pakai `applicationId` yang netral dan tidak memuat nama brand, mis. `com.<namamu>.keuangan`.
- Simpan nama brand di **satu tempat** saja (file l10n `appName` + `android:label`), jangan di-hardcode di widget.
- Nama Dart package (`pubspec.yaml`) juga netral, mis. `keuangan_app`.

---

## 11. Kebutuhan Non-Fungsional

| Area | Target |
|---|---|
| Performa | Cold start < 2 dtk (mid-range Android); simpan transaksi → Safe-to-Spend ter-update < 100 ms |
| Ukuran APK | < 25 MB (sebelum model TFLite) |
| Offline | 100% fitur MVP jalan tanpa internet |
| Keamanan | DB terenkripsi, app lock, backup terenkripsi dengan password pengguna |
| Privasi | Tanpa analytics yang mengirim data finansial; crash report (opsional) tanpa PII |
| Aksesibilitas | Dukung text scaling hingga 1.3×, kontras WCAG AA, label semantics |
| Kompatibilitas | Android 8.0+ (API 26); iOS 14+ saat rilis iOS |
| Kualitas | Unit test coverage `engine/` ≥ 90%; keseluruhan ≥ 70% |

---

## 12. Metrik Keberhasilan

| Metrik | Target (3 bulan pasca rilis) |
|---|---|
| **Aktivasi**: pengguna yang menyelesaikan onboarding dengan ≥ 2 kewajiban | ≥ 70% |
| **Retensi D7 / D30** | ≥ 40% / ≥ 20% |
| **Kebiasaan**: rata-rata hari mencatat per minggu (pengguna aktif) | ≥ 4 hari |
| **Kegunaan alert**: rasio 👍 terhadap total feedback | ≥ 60% |
| **Akurasi forecast** (MAPE belanja akhir siklus, setelah 2 siklus) | ≤ 20% |
| **Outcome**: pengguna yang melaporkan semua kewajiban lunas tepat waktu | ≥ 85% |
| **Konversi Premium** (setelah paywall rilis di Fase 2) | 2–5% pengguna aktif bulanan |

> Karena aplikasinya privacy-first, metrik diambil dari **analytics anonim opt-in** (event agregat, tanpa nominal) dan survei in-app.

---

## 13. Model Bisnis: Freemium

### 13.1 Prinsip
**Nilai inti selalu gratis.** Fitur yang menjaga kewajiban pengguna (Safe-to-Spend, Kewajiban tanpa batas, alert risiko) **tidak boleh** dikunci. Kalau fitur itu dikunci, aplikasi kehilangan alasan untuk dipakai dan pengguna tidak sempat merasakan nilainya. Premium menjual **kedalaman analisis dan kenyamanan**, bukan fitur dasar.

### 13.2 Gratis vs Premium

| Fitur | Gratis | 💎 Premium |
|---|:---:|:---:|
| Pencatatan, akun & kategori **tanpa batas** | ✅ | ✅ |
| Kewajiban Rutin **tanpa batas** + kalender + auto-match | ✅ | ✅ |
| Safe-to-Spend + Jatah Harian | ✅ | ✅ |
| Alert A1–A6 (Tier 0 & Tier 1) | ✅ | ✅ |
| Laporan siklus berjalan & siklus sebelumnya | ✅ | ✅ |
| Backup/restore terenkripsi, app lock, widget | ✅ | ✅ |
| **Simulasi What-If** | Coba 3× gratis | ✅ Tanpa batas |
| **Risk score Tier 2** (peluang kewajiban tidak tertutup, proyeksi P50/P80) | Hanya label risiko (hijau/kuning/merah) | ✅ Angka peluang + grafik proyeksi |
| **Laporan multi-siklus** (perbandingan & tren 6–12 siklus) | — | ✅ |
| **Export CSV/PDF** | — | ✅ |
| Tema & ikon aplikasi custom | — | ✅ |

> What-If diberi 3× percobaan gratis supaya pengguna merasakan "aha"-nya dulu sebelum diminta membayar.

### 13.3 Implementasi
- **Google Play Billing** lewat package `in_app_purchase`. Tanpa backend dan tanpa akun: pembelian terikat ke akun Google Play pengguna, lalu di-restore lewat riwayat pembelian setelah reinstall atau ganti HP.
- Status Premium di-cache lokal (tabel `Entitlement`) supaya tetap jalan offline, lalu disinkronkan ulang dengan Play saat online.
- **Kapan paywall muncul:** MVP (Fase 1) sepenuhnya gratis, karena fitur premiumnya belum ada. Paywall rilis di Fase 2 bersama What-If.
- **Skema harga** (langganan bulanan/tahunan vs sekali bayar) diputuskan sebelum Fase 2 berdasarkan feedback beta.

---

## 14. Roadmap

| Fase | Durasi (estimasi, solo dev) | Cakupan |
|---|---|---|
| **0a: Desain (Figma)** | 2–3 minggu | Design system (warna, tipografi, spacing, komponen), wireframe → hi-fi untuk 7 layar MVP + onboarding, prototype alur onboarding & tambah transaksi, uji cepat ke 3–5 calon pengguna |
| **0b: Fondasi** | 1–2 minggu | Setup project Flutter (Android), arsitektur, DB schema + migrasi, implementasi design tokens dari Figma ke `ThemeData`, CI |
| **1: MVP** | 6–8 minggu | Semua **P0**: pencatatan, akun, kategori, siklus gajian, Kewajiban, Safe-to-Spend, alert Tier 0, laporan dasar, app lock, backup. **Gratis penuh** |
| **1.5: Beta tertutup** | 2–3 minggu | 20–50 tester lewat Play Console (closed testing), tuning threshold alert, perbaikan UX input, survei kesediaan membayar |
| **2: Smart + Premium** | 5–7 minggu | **P1**: auto-match, forecaster Tier 1, anomali, 💎 What-If, 💎 laporan multi-siklus, 💎 export, feedback alert, widget, input bahasa natural, budget kategori, **paywall + Play Billing** |
| **3: Intelligence & Ekspansi** | 8+ minggu | **P2**: 💎 Monte Carlo risk, TFLite categorizer, OCR struk, **mode penghasilan tidak tetap**, cloud sync + akun, **rilis iOS** |

> Desain Figma dikerjakan **sebelum** coding supaya keputusan UX (terutama Quick Add ≤ 3 tap dan tampilan Safe-to-Spend) teruji lebih dulu. Mengubah desain di Figma jauh lebih murah daripada refactor widget.

---

## 15. Risiko & Mitigasi

| Risiko | Dampak | Mitigasi |
|---|---|---|
| **Pengguna malas mencatat** (risiko #1 di kategori ini) | Data kosong, prediksi salah, pengguna churn | Quick Add ≤ 3 tap, widget, input bahasa natural, reminder harian yang bisa diatur, Safe-to-Spend sebagai "hadiah" langsung setelah mencatat |
| **Cold start ML** | Prediksi ngawur di awal sehingga pengguna tidak percaya | Kecerdasan bertingkat (bagian 6); fitur Tier 1/2 baru tampil setelah data cukup, disertai label "akurasi meningkat seiring waktu" |
| **Alert fatigue** | Notifikasi dimatikan | Batas frekuensi, jam tenang, feedback + auto-tuning, setiap alert punya aksi |
| **Data tidak akurat** (transaksi lupa dicatat, saldo meleset) | Safe-to-Spend salah | Fitur "Sesuaikan saldo" (rekonsiliasi cepat), prompt A3 untuk kewajiban yang belum tercatat |
| **Kehilangan data** (HP hilang/rusak) | Fatal untuk kepercayaan | Backup terenkripsi + pengingat backup berkala; cloud sync di Fase 3 |
| **Scope creep** | MVP molor | Patuh ke prioritas P0; fitur ML canggih baru masuk setelah MVP divalidasi |
| **Regulasi/izin notifikasi** (fitur baca notifikasi) | Penolakan Play Store | Ditunda ke P2, opt-in eksplisit, kebijakan privasi jelas |
| **Paywall terasa mengganggu** | Rating turun, pengguna pindah aplikasi | Nilai inti tetap gratis (bagian 13.1), percobaan What-If gratis, paywall hanya muncul saat pengguna membuka fitur premium (tanpa pop-up paksa) |
| **Pembelian dibajak** (APK mod) karena tanpa verifikasi server | Kehilangan sebagian pendapatan | Risiko diterima untuk tahap awal; tambahkan Play Integrity API / verifikasi server saat backend tersedia di Fase 3 |
| **Ganti nama setelah rilis** | Branding tidak konsisten | `applicationId` netral + nama brand di satu tempat (bagian 10.5) |
| **Solo dev: desain + coding sekaligus** | Timeline molor | Pakai komponen Material 3 sebagai dasar, desain Figma cukup untuk layar MVP (bukan semua fase), batasi scope ke P0 |

---

## 16. Keputusan Produk

Diputuskan pada 4 November 2026:

| # | Pertanyaan | Keputusan | Dampak ke rencana |
|---|---|---|---|
| 1 | Platform rilis pertama | **Android dulu** | iOS masuk Fase 3; belum perlu Mac/akun Apple Developer |
| 2 | Model bisnis | **Freemium** | Premium: What-If, risk score Tier 2, laporan & export lanjutan (bagian 13). Paywall rilis di Fase 2 |
| 3 | Akun pengguna | **Tanpa akun di MVP** | Offline-first, tanpa backend; pembelian di-restore lewat Google Play |
| 4 | Tim | **Solo dev + desain Figma dulu** | Ada Fase 0a (desain) sebelum coding |
| 5 | Mode penghasilan tidak tetap | **Fase 3** | MVP fokus ke persona penghasilan tetap |
| 6 | Nama | **"Moneytoring" masih working title** | `applicationId` & package name netral (bagian 10.5) |

### Masih terbuka (bisa diputuskan nanti, tidak menghambat Fase 0–1)
- Skema harga Premium (langganan vs sekali bayar) dan nominalnya. Diputuskan sebelum Fase 2.
- Nama final & identitas visual (logo, warna brand). Idealnya sebelum desain hi-fi di Fase 0a selesai.

---

## Lampiran A — Contoh Perhitungan Safe-to-Spend

```
Tanggal hari ini : 11 Nov · Gajian berikutnya: 25 Nov (14 hari lagi)
Saldo semua akun : Rp 3.000.000

Kewajiban belum dibayar sebelum 25 Nov:
  - Listrik (20 Nov, estimasi)   Rp   350.000
  - Cicilan motor (25 Nov)       Rp   850.000
  - Kos (25 Nov)                 Rp 1.000.000
                                 ─────────────
                                 Rp 2.200.000
Target tabungan siklus ini       Rp         0 (sudah disisihkan)
Buffer 5% dari sisa              Rp    40.000

Safe-to-Spend = 3.000.000 − 2.200.000 − 0 − 40.000 = Rp 760.000
Jatah harian  = 760.000 ÷ 14                        ≈ Rp 54.300/hari

Rata-rata belanja harian 7 hari terakhir: Rp 85.000
Proyeksi 14 hari: Rp 1.190.000 > Safe-to-Spend Rp 760.000
→ Kekurangan proyeksi: Rp 430.000 → trigger Alert A1 (Kewajiban Berisiko)
```

## Lampiran B — Glosarium

| Istilah | Arti |
|---|---|
| **Siklus** | Periode dari tanggal gajian ke tanggal gajian berikutnya |
| **Kewajiban** | Pengeluaran rutin yang wajib dibayar tiap siklus |
| **Safe-to-Spend** | Uang yang aman dibelanjakan setelah kewajiban, tabungan, dan buffer dikurangkan |
| **Jatah Harian** | Safe-to-Spend dibagi sisa hari dalam siklus |
| **Pace** | Kecepatan belanja dibandingkan waktu yang sudah berjalan dalam siklus |
