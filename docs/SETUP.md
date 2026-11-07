# Setup perangkat baru

Panduan menyiapkan laptop **Windows** baru untuk mengembangkan Moneytoring, sama persis dengan
laptop pertama: semua alat dipasang portabel di `C:\dev`, **tanpa Android Studio**, tanpa
installer, dan tanpa mengubah PATH. Unduhan ±3 GB, ruang disk ±6 GB.

| Komponen | Versi | Lokasi |
|---|---|---|
| Flutter SDK | 3.47.9 stable (Dart 3.13.7) | `C:\dev\flutter` |
| JDK | Temurin 17.0.21+9 | `C:\dev\jdk-17` |
| Android SDK | cmdline-tools 22.0, platform-tools, platform 36, build-tools 36.0.0 | `C:\dev\android-sdk` |
| Android NDK | 28.2.13676358 (diunduh otomatis oleh Gradle) | `C:\dev\android-sdk\ndk` |

Perintah `bash` di bawah dijalankan di **Git Bash**; perintah `powershell` di PowerShell.

## 0. Ambil kode

Pasang [Git for Windows](https://git-scm.com/download/win) kalau belum ada, lalu:

```bash
git clone https://github.com/Masdeppp/moneytoring.git /c/Coding/Moneytoring
cd /c/Coding/Moneytoring
git config user.name "Masdeppp"
git config user.email "114462924+Masdeppp@users.noreply.github.com"
```

Author diset **per repo** dengan email noreply GitHub, supaya email asli tidak masuk riwayat
repo publik.

## 1. Flutter SDK

```bash
git clone --branch stable https://github.com/flutter/flutter.git /c/dev/flutter
git -C /c/dev/flutter checkout 3.47.9
/c/dev/flutter/bin/flutter.bat --disable-analytics
/c/dev/flutter/bin/flutter.bat --version
```

Pemanggilan pertama mengunduh Dart SDK dan engine (beberapa menit). Selesai kalau
`--version` mencetak `Flutter 3.47.9` dan `Dart 3.13.7`.

## 2. JDK 17

```powershell
New-Item -ItemType Directory -Force C:\dev\downloads | Out-Null
Invoke-WebRequest "https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.21%2B9/OpenJDK17U-jdk_x64_windows_hotspot_17.0.21_9.zip" -OutFile C:\dev\downloads\jdk17.zip
Expand-Archive C:\dev\downloads\jdk17.zip C:\dev\_jdk
Move-Item C:\dev\_jdk\jdk-17.0.21+9 C:\dev\jdk-17
Remove-Item C:\dev\_jdk
C:\dev\jdk-17\bin\java.exe -version
```

Cocokkan SHA-256 zip dengan yang tertera di halaman rilis Adoptium
(`Get-FileHash C:\dev\downloads\jdk17.zip`).

## 3. Android SDK (command line)

```powershell
Invoke-WebRequest "https://dl.google.com/android/repository/commandlinetools-win-15859902_latest.zip" -OutFile C:\dev\downloads\cmdline-tools.zip
Expand-Archive C:\dev\downloads\cmdline-tools.zip C:\dev\_clt
New-Item -ItemType Directory -Force C:\dev\android-sdk\cmdline-tools | Out-Null
Move-Item C:\dev\_clt\cmdline-tools C:\dev\android-sdk\cmdline-tools\latest
Remove-Item C:\dev\_clt
```

Pasang paket dan setujui lisensi (Git Bash, karena `yes |` tidak sampai ke sdkmanager dari
PowerShell):

```bash
export JAVA_HOME='C:\dev\jdk-17'
SDKM=/c/dev/android-sdk/cmdline-tools/latest/bin/sdkmanager.bat
yes | $SDKM --sdk_root='C:\dev\android-sdk' --licenses
$SDKM --sdk_root='C:\dev\android-sdk' "platform-tools" "platforms;android-36" "build-tools;36.0.0"
```

NDK tidak perlu dipasang manual: Gradle mengunduhnya saat build pertama (build pertama ±5–10
menit).

## 4. Sambungkan Flutter ke SDK dan JDK

```bash
/c/dev/flutter/bin/flutter.bat config --android-sdk 'C:\dev\android-sdk' --jdk-dir 'C:\dev\jdk-17'
/c/dev/flutter/bin/flutter.bat doctor
```

**Android toolchain** harus ✓. Tanda ✗ untuk Chrome dan Visual Studio boleh diabaikan (itu untuk
target web dan desktop Windows).

## 5. Cek proyek

```bash
cd /c/Coding/Moneytoring/app
/c/dev/flutter/bin/flutter.bat pub get
/c/dev/flutter/bin/flutter.bat analyze
/c/dev/flutter/bin/flutter.bat test
```

Semua test harus lulus. Kode hasil generate Drift ikut di repo, jadi `build_runner` hanya perlu
dijalankan setelah tabel diubah.

## 6. Jalankan di HP

1. Di HP: **Setelan → Tentang ponsel → ketuk Nomor build 7×**, lalu aktifkan **USB debugging**
   di Opsi pengembang.
2. Sambungkan kabel, lalu ketuk **Izinkan** saat muncul "Izinkan USB debugging?".
3. Jalankan:

   ```bash
   /c/dev/flutter/bin/flutter.bat devices
   /c/dev/flutter/bin/flutter.bat run -d <id-hp>
   ```

### Hal yang perlu diketahui

- **Data tidak ikut pindah.** Setiap HP punya database terenkripsi sendiri dengan kunci di
  Android Keystore HP itu. Di HP baru, onboarding diulang. Backup/restore baru ada di irisan 11.
- **HP yang sama dari laptop baru:** build debug ditandatangani kunci debug milik laptop
  (`%USERPROFILE%\.android\debug.keystore`). Kunci laptop baru berbeda, sehingga instalasi ke HP
  yang masih berisi app dari laptop lama gagal dengan `INSTALL_FAILED_UPDATE_INCOMPATIBLE`.
  Pilihannya:
  - Salin `debug.keystore` dari laptop lama ke folder yang sama di laptop baru (data di HP tetap
    utuh), atau
  - Hapus app dulu: `adb uninstall com.namamu.keuangan` (**data app di HP ikut terhapus**).
- **PATH tidak diubah.** Flutter dipanggil lewat path lengkap. Kalau ingin cukup mengetik
  `flutter`, tambahkan `C:\dev\flutter\bin` ke PATH pengguna (opsional).
- **Perangkat bukan Windows?** Komponennya sama (Flutter 3.47.9, JDK 17, Android SDK 36), tapi
  unduhan dan path-nya berbeda; ikuti versi di tabel atas.
