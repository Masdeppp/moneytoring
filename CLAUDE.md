# Moneytoring — catatan untuk Claude Code

Aplikasi keuangan pribadi (Flutter, Android dulu) dengan Safe-to-Spend sampai gajian.
Pemilik proyek menulis dalam **Bahasa Indonesia**; balas dan tulis teks UI dalam Bahasa Indonesia.

## Dokumen acuan

| File | Isi |
|---|---|
| `docs/PRD.md` | Produk: USP, fitur & prioritas, arsitektur, Lampiran A (contoh hitungan) |
| `docs/DESIGN.md` | Token desain Light/Dark, komponen, layar 01–11, interaksi |
| `docs/FASE1.md` | Rencana Fase 1 per irisan, **tabel status** (mulai dari sini), keputusan perhitungan |
| `docs/SETUP.md` | Menyiapkan laptop baru (Flutter, JDK, Android SDK tanpa Android Studio) |

Figma (`kvkQ06T5yRbUwYJQo7QOgA`) memakai paket Starter dan kuota MCP-nya habis. Perubahan desain
dibuat lewat plugin lokal di `tools/` yang dijalankan pemilik di Figma Desktop.

## Lingkungan

- Flutter **tidak ada di PATH**: panggil `C:\dev\flutter\bin\flutter.bat` / `dart.bat`.
  `adb` ada di `C:\dev\android-sdk\platform-tools\adb.exe`. Kalau folder itu belum ada di
  perangkat ini, ikuti `docs/SETUP.md`.
- Tanpa Android Studio dan emulator; aplikasi diuji di HP lewat USB debugging.
  `flutter run -d <id> --no-resident` memasang dan menjalankan tanpa sesi interaktif.

## Perintah (dari `app/`)

```bash
flutter pub get
flutter analyze
flutter test                       # termasuk golden; CI memakai --exclude-tags golden
dart run build_runner build        # setelah tabel Drift berubah

# Format (page_width 100) TANPA file hasil generate, sama seperti CI.
# Jangan `dart format lib test`: itu memformat ulang *.g.dart ke lebar 100,
# padahal build_runner menulisnya dengan lebar 80, sehingga CI gagal di
# langkah "Generated files are committed".
dart format $(git ls-files --cached --others --exclude-standard '*.dart' | grep -vE '\.g\.dart$|^lib/l10n/')
dart run drift_dev make-migrations # setelah schemaVersion naik
```

## Aturan kode

- Nominal selalu `int` Rupiah, tidak pernah `double`.
- `lib/engine/` pure Dart (tanpa Flutter); `test/engine/engine_purity_test.dart` menegakkannya.
- Tanggal tanpa jam memakai `LocalDate`. Kolom tanggal-saja disimpan lewat `toUtcMidnight()`;
  waktu transaksi disimpan sebagai waktu lokal dan rentangnya di-query dengan `unixepoch`.
- Ubah tabel: naikkan `schemaVersion`, jalankan build_runner + make-migrations, tulis langkah di
  `_migrationSteps`, lalu tambah test data di `test/drift/keuangan/migration_test.dart`.
- UI: warna dari `context.colors`, teks dari `AppTypography`, ikon dari `AppIcons`; teks overline
  ditulis UPPERCASE oleh pemanggil.
- Riverpod 3 menjeda stream provider yang tidak punya listener: di test, `container.listen(...)`
  dulu sebelum membaca `.future`.
- Widget test dengan Drift: setelah `pumpWidget(const SizedBox())`, jalankan
  `pump(const Duration(seconds: 1))` lalu `runAsync(db.close)`; tanpa itu test menggantung.

## Git

- Repo publik `Masdeppp/moneytoring`. Author diset per repo:
  `Masdeppp <114462924+Masdeppp@users.noreply.github.com>`. Jangan pernah commit dengan email
  global pemilik.
- Jangan commit `.claude/settings.local.json`.
- CI (`.github/workflows/app-ci.yml`): kode generate Drift harus bersih, format, analyze, test.
