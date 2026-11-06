# Moneytoring (working title)

Aplikasi keuangan pribadi untuk Android. Pembedanya ada di **kepastian sampai gajian**: aplikasi menghitung uang yang aman dibelanjakan (Safe-to-Spend) setelah kewajiban rutin diamankan, lalu memberi peringatan sebelum kewajiban terancam. Semua data tinggal di HP, dalam database terenkripsi, tanpa akun dan tanpa server.

## Isi repo

| Folder | Isi |
|---|---|
| [`docs/PRD.md`](docs/PRD.md) | Product requirements: USP, strategi ML, fitur, roadmap, model bisnis |
| [`docs/DESIGN.md`](docs/DESIGN.md) | Design system (token Light/Dark, tipografi, komponen) dan daftar layar |
| [`app/`](app/) | Aplikasi Flutter (package `keuangan_app`) |
| [`tools/`](tools/) | Plugin Figma lokal untuk membangun layar desain |

Desain: [Figma — Moneytoring App Design (MVP)](https://www.figma.com/design/kvkQ06T5yRbUwYJQo7QOgA)

## Status

- **Fase 0a (desain):** design system dan 11 layar MVP di Figma.
- **Fase 0b (fondasi):** project Flutter, tema Light/Dark dari token desain, skema database + enkripsi, widget inti, CI. **Sedang berjalan.**
- **Fase 1 (MVP):** pencatatan, kewajiban, engine Safe-to-Spend, alert Tier 0.

Cara menjalankan aplikasi ada di [`app/README.md`](app/README.md).
