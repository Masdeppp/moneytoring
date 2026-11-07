// Pola check() Drift merujuk kolomnya sendiri, mis.
// `integer().check(amount.isBiggerThanValue(0))`. Itu memang cara yang
// didokumentasikan Drift, bukan rekursi sungguhan.
// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';

import '../../core/model/enums.dart';

// Skema MVP dari PRD §10.4.
//
// Aturan:
// - Nominal selalu `integer` dalam Rupiah dan selalu positif. Arah uang
//   (masuk/keluar) ditentukan oleh `type`, bukan tanda minus.
// - Enum disimpan sebagai teks (`textEnum`) supaya tahan terhadap urutan.
// - Setiap perubahan tabel: naikkan `schemaVersion`, lalu jalankan
//   `dart run drift_dev make-migrations`.
// - Data class diberi akhiran `Record` supaya tidak bentrok dengan kelas
//   Flutter/Dart (mis. `Category` di flutter/foundation).

@DataClassName('AccountRecord')
class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 40)();
  TextColumn get type => textEnum<AccountType>()();
  IntColumn get initialBalance => integer().withDefault(const Constant(0))();
  TextColumn get tone => textEnum<Tone>().withDefault(const Constant('brand'))();
  TextColumn get icon => text()();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  /// `false` untuk rekening yang tidak boleh dibelanjakan, mis. dana darurat.
  /// Saldonya tidak ikut dihitung di Safe-to-Spend. (v2)
  BoolColumn get includeInSafeToSpend => boolean().withDefault(const Constant(true))();
}

@DataClassName('CategoryRecord')
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 40)();
  TextColumn get type => textEnum<CategoryType>()();

  /// Nama ikon Lucide, mis. `utensils`.
  TextColumn get icon => text()();
  TextColumn get tone => textEnum<Tone>()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

@DataClassName('TransactionRecord')
@TableIndex(name: 'idx_transactions_date', columns: {#date})
@TableIndex(name: 'idx_transactions_account', columns: {#accountId})
@TableIndex(name: 'idx_transactions_category', columns: {#categoryId})
@TableIndex(name: 'idx_transactions_obligation_instance', columns: {#obligationInstanceId})
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => textEnum<TransactionType>()();
  IntColumn get amount => integer().check(amount.isBiggerThanValue(0))();
  @ReferenceName('transactions')
  IntColumn get accountId => integer().references(Accounts, #id)();

  /// Hanya untuk transfer: akun tujuan.
  @ReferenceName('incomingTransfers')
  IntColumn get toAccountId => integer().nullable().references(Accounts, #id)();

  /// Kosong untuk transfer.
  IntColumn get categoryId => integer().nullable().references(Categories, #id)();

  /// Tanggal transaksi menurut pengguna (waktu lokal).
  DateTimeColumn get date => dateTime()();
  TextColumn get note => text().withDefault(const Constant(''))();

  /// Pembayaran kewajiban. Satu kewajiban bisa dibayar beberapa kali (cicil).
  IntColumn get obligationInstanceId =>
      integer().nullable().references(ObligationInstances, #id, onDelete: KeyAction.setNull)();

  /// Langkah auto-kategori yang memberi kategori (untuk mengukur akurasi).
  TextColumn get categorySource => textEnum<CategorySource>().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Aturan siklus gajian. Hanya ada satu baris (id = 1).
@DataClassName('PayCycleConfigRecord')
class PayCycleConfigs extends Table {
  IntColumn get id => integer().withDefault(const Constant(1)).check(id.equals(1))();
  TextColumn get paydayRule => textEnum<PaydayRule>()();

  /// Tanggal gajian (1–31) untuk aturan `fixedDate`.
  IntColumn get day => integer().nullable()();
  BoolColumn get shiftOnHoliday => boolean().withDefault(const Constant(true))();
  IntColumn get expectedIncome => integer().withDefault(const Constant(0))();

  /// Hari pertama pengguna mencatat (selesai onboarding). Pace dan proyeksi
  /// dihitung mulai tanggal ini. (v2)
  DateTimeColumn get trackingSince => dateTime()();

  /// Dana cadangan Safe-to-Spend dalam basis poin: 500 = 5%. (v2)
  IntColumn get bufferBasisPoints => integer()
      .withDefault(const Constant(500))
      .check(bufferBasisPoints.isBetweenValues(0, 10000))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ObligationRecord')
class Obligations extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 40)();
  TextColumn get amountType => textEnum<ObligationAmountType>()();
  IntColumn get amount => integer().check(amount.isBiggerThanValue(0))();
  IntColumn get dueDay => integer().check(dueDay.isBetweenValues(1, 31))();
  IntColumn get categoryId => integer().references(Categories, #id)();
  IntColumn get accountId => integer().nullable().references(Accounts, #id)();
  TextColumn get recurrence => textEnum<Recurrence>().withDefault(const Constant('monthly'))();
  BoolColumn get active => boolean().withDefault(const Constant(true))();

  /// Kata kunci tambahan untuk auto-match, dipisah koma.
  TextColumn get autoMatchKeywords => text().withDefault(const Constant(''))();

  /// Jatuh tempo sebelum tanggal ini dianggap sudah diurus sebelum kewajiban
  /// dicatat, jadi tidak dibuatkan instance. (v2)
  DateTimeColumn get startsOn => dateTime()();
}

/// Satu jatuh tempo kewajiban.
///
/// Dibuat per tanggal jatuh tempo, bukan per siklus: siklus yang bergeser
/// karena libur bisa memuat dua jatuh tempo atau tidak sama sekali
/// (docs/FASE1.md §2). Siklusnya dihitung dari `dueDate` + aturan gajian. (v2)
@DataClassName('ObligationInstanceRecord')
@TableIndex(name: 'idx_obligation_instances_due', columns: {#dueDate})
class ObligationInstances extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get obligationId =>
      integer().references(Obligations, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get dueDate => dateTime()();
  IntColumn get expectedAmount => integer()();
  TextColumn get status => textEnum<ObligationStatus>().withDefault(const Constant('pending'))();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {obligationId, dueDate},
  ];
}

@DataClassName('SavingsTargetRecord')
class SavingsTargets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get amountPerCycle => integer()();
  IntColumn get accountId => integer().nullable().references(Accounts, #id)();
}

@DataClassName('AlertRecord')
@TableIndex(name: 'idx_alerts_created', columns: {#createdAt})
class Alerts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => textEnum<AlertType>()();

  /// Detail alert dalam JSON, mis. `{"obligationId": 3, "shortfall": 150000}`.
  TextColumn get payload => text().withDefault(const Constant('{}'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get readAt => dateTime().nullable()();
  TextColumn get feedback => textEnum<AlertFeedback>().nullable()();
}

/// Ambang alert hasil Alert Tuner (per jenis alert).
@DataClassName('AlertThresholdRecord')
class AlertThresholds extends Table {
  TextColumn get type => textEnum<AlertType>()();
  RealColumn get value => real()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {type};
}

/// Cache lokal status Premium. Sumber kebenaran tetap Google Play.
@DataClassName('EntitlementRecord')
class Entitlements extends Table {
  TextColumn get productId => text()();
  TextColumn get purchaseToken => text()();
  TextColumn get status => textEnum<EntitlementStatus>()();
  DateTimeColumn get verifiedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {productId};
}
