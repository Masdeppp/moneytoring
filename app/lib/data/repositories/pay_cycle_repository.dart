import 'package:drift/drift.dart';

import '../../engine/common/local_date.dart';
import '../../engine/cycle/pay_cycle.dart';
import '../db/app_database.dart';

/// Aturan siklus gajian (satu baris, id = 1). Baris ini dibuat saat onboarding
/// selesai, jadi keberadaannya sekaligus menandai pengguna sudah onboarding.
class PayCycleRepository {
  PayCycleRepository(this._db);

  final AppDatabase _db;

  Future<PayCycleConfigRecord?> current() => _db.select(_db.payCycleConfigs).getSingleOrNull();

  Stream<PayCycleConfigRecord?> watch() => _db.select(_db.payCycleConfigs).watchSingleOrNull();

  /// Simpan aturan gajian. [trackingSince] wajib saat pertama kali disimpan
  /// (onboarding) dan tidak berubah sesudahnya kecuali diisi lagi.
  Future<void> save({
    required PayCycleRule rule,
    required int expectedIncome,
    LocalDate? trackingSince,
    int? bufferBasisPoints,
  }) {
    if (expectedIncome < 0) {
      throw ArgumentError.value(expectedIncome, 'expectedIncome', 'tidak boleh negatif');
    }
    if (bufferBasisPoints != null) {
      RangeError.checkValueInInterval(bufferBasisPoints, 0, 10000, 'bufferBasisPoints');
    }
    final values = PayCycleConfigsCompanion(
      paydayRule: Value(rule.rule),
      day: Value(rule.day),
      shiftOnHoliday: Value(rule.shiftOnHoliday),
      expectedIncome: Value(expectedIncome),
      bufferBasisPoints: Value.absentIfNull(bufferBasisPoints),
      trackingSince: trackingSince == null
          ? const Value.absent()
          : Value(trackingSince.toUtcMidnight()),
    );
    return _db.transaction(() async {
      if (await current() == null) {
        if (trackingSince == null) throw ArgumentError.notNull('trackingSince');
        await _db.into(_db.payCycleConfigs).insert(values.copyWith(id: const Value(1)));
      } else {
        await _db.update(_db.payCycleConfigs).write(values);
      }
    });
  }

  static PayCycleRule ruleOf(PayCycleConfigRecord config) => PayCycleRule.fromConfig(
    rule: config.paydayRule,
    day: config.day,
    shiftOnHoliday: config.shiftOnHoliday,
  );
}
