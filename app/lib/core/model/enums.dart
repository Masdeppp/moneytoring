// Enum domain yang dipakai bersama oleh database, engine, dan UI.
// File ini pure Dart (tanpa import Flutter) supaya engine bisa memakainya.
//
// Semua enum disimpan di database sebagai teks (`textEnum`), jadi
// JANGAN mengganti nama nilai enum yang sudah dirilis tanpa migrasi.

/// Nada warna dari design system (DESIGN.md §1.2 `tone/*`).
enum Tone { brand, amber, blue, violet, red, neutral }

enum AccountType { cash, bank, ewallet }

enum CategoryType { income, expense }

enum TransactionType { income, expense, transfer }

/// Sumber tebakan kategori, untuk mengukur akurasi auto-kategori.
enum CategorySource { history, dictionary, model, user }

/// Aturan tanggal gajian (PRD §7, siklus gajian).
enum PaydayRule { fixedDate, lastWorkday }

enum ObligationAmountType { fixed, estimated }

enum Recurrence { monthly }

enum ObligationStatus { pending, paid, late, skipped }

/// Katalog alert PRD §6 (A1–A6).
enum AlertType {
  obligationAtRisk('A1'),
  dueSoon('A2'),
  unrecorded('A3'),
  fastPace('A4'),
  anomaly('A5'),
  weeklySummary('A6');

  const AlertType(this.code);

  /// Kode alert seperti di PRD, mis. `A1`.
  final String code;
}

enum AlertFeedback { useful, notUseful }

enum EntitlementStatus { active, expired, refunded }

/// Status risiko yang menentukan warna kartu Safe-to-Spend.
enum RiskLevel { safe, warning, danger }
