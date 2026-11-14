import 'dart:math' as math;

import '../common/local_date.dart';
import '../cycle/pay_cycle.dart';

/// Rencana satu target tabungan untuk siklus berjalan (docs/FASE1.md,
/// "Target tabungan bernama").
final class SavingsGoalPlan {
  const SavingsGoalPlan({
    required this.saved,
    required this.savedThisCycle,
    required this.need,
    required this.reserved,
    this.cyclesLeft,
  });

  /// Total setoran sejauh ini.
  final int saved;
  final int savedThisCycle;

  /// Setoran yang dibutuhkan siklus ini.
  final int need;

  /// Yang dikurangkan dari Safe-to-Spend siklus ini.
  final int reserved;

  /// Siklus tersisa sampai tenggat (ikut siklus berjalan); `null` tanpa tenggat.
  final int? cyclesLeft;

  /// Setoran siklus ini yang belum dipenuhi.
  int get dueThisCycle => math.max(0, need - savedThisCycle);
}

/// Jumlah siklus dari [current] sampai siklus yang memuat [deadline], ikut
/// keduanya. Siklus yang memuat tenggat dihitung karena gajiannya masuk
/// sebelum tenggat. Tenggat yang sudah lewat menghasilkan 1: sisanya
/// dibutuhkan sekarang.
int cyclesUntil(PayCycleCalculator calculator, PayCycle current, LocalDate deadline) {
  var cycle = current;
  var count = 1;
  // Batas 600 siklus (50 tahun) supaya tenggat yang tidak masuk akal tidak
  // membuat perulangan panjang.
  while (deadline >= cycle.nextPayday && count < 600) {
    cycle = calculator.nextCycle(cycle);
    count++;
  }
  return count;
}

/// Menghitung kebutuhan dan cadangan satu target.
///
/// - Bertenggat ([target] + [cyclesLeft]): sisa target sebelum siklus ini
///   dibagi siklus tersisa, dibulatkan ke atas.
/// - Tanpa tenggat: [amountPerCycle], tidak melebihi sisa [target] (kalau ada).
/// - [keptInSafeToSpend]: uangnya tetap di akun yang dihitung Safe-to-Spend
///   (tanpa rekening tujuan, atau rekeningnya ikut dihitung). Semua setoran
///   tetap dicadangkan supaya tidak terlihat "aman dibelanjakan". Kalau
///   uangnya sudah dipindah ke rekening yang dikecualikan, cukup sisa
///   setoran siklus ini yang dicadangkan.
///
/// Dengan begitu, menyetor tidak pernah mengubah angka Safe-to-Spend.
SavingsGoalPlan planSavingsGoal({
  int? target,
  int? cyclesLeft,
  int? amountPerCycle,
  required int savedBeforeCycle,
  required int savedThisCycle,
  required bool keptInSafeToSpend,
}) {
  final saved = savedBeforeCycle + savedThisCycle;
  final rest = target == null ? null : math.max(0, target - savedBeforeCycle);
  final int need;
  if (rest != null && cyclesLeft != null) {
    need = _ceilDiv(rest, math.max(1, cyclesLeft));
  } else {
    final perCycle = amountPerCycle ?? 0;
    need = rest == null ? perCycle : math.min(perCycle, rest);
  }
  final open = math.max(0, need - savedThisCycle);
  return SavingsGoalPlan(
    saved: saved,
    savedThisCycle: savedThisCycle,
    need: need,
    reserved: (keptInSafeToSpend ? saved : 0) + open,
    cyclesLeft: cyclesLeft,
  );
}

/// Bagian perkiraan gaji yang disisihkan tiap siklus: [basisPoints]
/// (1000 = 10%) dari [expectedIncome], dibulatkan ke atas.
int salaryShare(int expectedIncome, int basisPoints) {
  RangeError.checkValueInInterval(basisPoints, 0, 10000, 'basisPoints');
  return _ceilDiv(math.max(0, expectedIncome) * basisPoints, 10000);
}

/// Sisihan gaji yang benar-benar tersisa di akhir siklus, untuk ditabung
/// otomatis saat gajian.
///
/// [available] = saldo akun yang dihitung di akhir siklus − kewajiban yang
/// masih dicadangkan − cadangan target lain − tabungan sisa gaji yang sudah
/// terkumpul. Kalau belanja sempat memakai sisihan, yang ditabung hanya
/// sisanya; tidak pernah lebih dari [share].
int salaryLeftover({required int available, required int share}) =>
    math.min(share, math.max(0, available));

int _ceilDiv(int a, int b) => a <= 0 ? 0 : (a + b - 1) ~/ b;
