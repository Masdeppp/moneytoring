# Plugin Figma: Moneytoring — Build MVP Screens

Plugin development lokal yang membangun **layar 04–11** di file Figma
[Moneytoring — App Design (MVP)](https://www.figma.com/design/kvkQ06T5yRbUwYJQo7QOgA), di halaman `Screens — MVP`.

**Kenapa plugin lokal?** Kuota Figma MCP paket Starter (sekitar 20 tool call/bulan) habis. Plugin yang dijalankan sendiri di Figma Desktop **tidak terkena limit MCP** dan memakai Plugin API yang sama.

## Yang dibangun

| # | Layar |
|---|---|
| 04 | Beranda: Aman |
| 05 | Beranda: Berisiko (kartu merah + alert A1) |
| 06 | Tambah Transaksi (bottom sheet + keypad + "Sisa aman setelah ini") |
| 07 | Transaksi (ringkasan siklus, filter, grup per hari) |
| 08 | Kewajiban (progress siklus, alert "sudah dibayar?", Terlambat / Akan datang / Lunas) |
| 09 | Insight (grafik proyeksi + rentang, kategori, feedback alert, teaser Premium) |
| 10 | Simulasi What-If (sebelum → sesudah, saran tunda) |
| 11 | Detail Peringatan A1 (grafik proyeksi saldo, 3 cara mengamankan, feedback) |

Semua layar disusun dari **instance komponen** dan **variabel warna/spacing/radius** yang sudah ada di file, jadi tetap tersambung ke design system.

## Cara menjalankan (± 1 menit)

1. Buka **Figma Desktop** (plugin development tidak bisa dijalankan dari browser), lalu buka file *Moneytoring — App Design (MVP)*.
2. Klik kanan di canvas → **Plugins → Development → Import plugin from manifest…**
3. Pilih file `tools/figma-screens-plugin/manifest.json` di folder project ini.
4. Jalankan: klik kanan di canvas → **Plugins → Development → Moneytoring — Build MVP Screens**.
5. Tunggu notifikasi di bawah layar, misalnya **"Moneytoring: 8/8 layar dibuat"**. Viewport otomatis melompat ke layar baru.

## Kalau ada error

- Notifikasi akan menyebut jumlah error. Buka console lewat **Plugins → Development → Show/Hide console**, lalu salin pesan yang diawali `Moneytoring build errors:`.
- Setiap layar dibangun terpisah, jadi satu layar yang gagal tidak menghentikan layar lain.
- Plugin **aman dijalankan ulang**: frame dengan nama yang sama (mis. `04 Beranda — Aman`) dihapus dulu sebelum dibuat ulang. Frame lain tidak disentuh.

## Catatan

- ID node komponen, ikon, dan halaman di `code.js` khusus untuk file ini. Jangan jalankan di file lain.
- Tanggal contoh di semua layar disamakan ke skenario **"hari ini = Rabu, 11 Nov"** dengan gajian 25 Nov (14 hari lagi).
