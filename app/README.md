# keuangan_app

Aplikasi Flutter untuk Moneytoring (working title). Nama package dan `applicationId` sengaja netral (lihat PRD §10.5).

## Prasyarat

- Flutter stable (dicoba dengan 3.47.9 / Dart 3.13.7)
- Android Studio (Android SDK + emulator) untuk menjalankan dan build APK

## Perintah sehari-hari

```bash
flutter pub get                        # pasang paket + buat file l10n
dart run build_runner build            # buat ulang kode Drift setelah tabel berubah
flutter analyze
flutter test                           # semua test, termasuk golden
flutter test --update-goldens --tags golden   # perbarui gambar golden setelah ubah tampilan
flutter run
```

## Struktur

```
lib/
├─ core/
│  ├─ model/      enum domain (pure Dart)
│  ├─ theme/      token desain → ThemeData Light/Dark (DESIGN.md)
│  ├─ router/     go_router: 4 tab + galeri komponen
│  ├─ utils/      format Rupiah
│  └─ widgets/    SafeToSpendCard, AppBadge, CategoryTile, AlertBanner
├─ data/db/       skema Drift, koneksi terenkripsi, provider
├─ features/      home, shell (NavigationBar + FAB), dev (galeri komponen)
└─ l10n/          app_id.arb (nama aplikasi)
```

## Database

- **Drift + SQLite3MultipleCiphers.** Enkripsi diaktifkan oleh blok `hooks` di `pubspec.yaml`. `connection.dart` menolak membuka database kalau enkripsi tidak aktif.
- Kunci acak 32 byte disimpan di Android Keystore. Auto backup Android dimatikan supaya kunci tidak dipulihkan ke HP lain.
- Nominal selalu `int` Rupiah dan selalu positif. Arah uang ditentukan oleh `type`.
- **Mengubah tabel:** naikkan `schemaVersion` di `app_database.dart`, lalu jalankan:

  ```bash
  dart run build_runner build
  dart run drift_dev make-migrations
  ```

  Setelah itu tulis langkah migrasinya. Snapshot skema tersimpan di `drift_schemas/`.

## Cek di HP (debug)

Beranda punya bagian **Developer**:
- **Database** menampilkan cipher yang aktif dan jumlah kategori, sebagai bukti database terenkripsi bisa dibuka.
- **Galeri komponen** menampilkan semua komponen untuk dibandingkan dengan Figma.
