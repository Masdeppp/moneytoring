import 'dart:math' as math;

import '../../core/model/enums.dart';
import '../common/local_date.dart';

/// Satu jatuh tempo kewajiban yang mungkin perlu dicadangkan.
final class ObligationDue {
  const ObligationDue({
    required this.dueDate,
    required this.expectedAmount,
    this.paidAmount = 0,
    this.status = ObligationStatus.pending,
  });

  final LocalDate dueDate;
  final int expectedAmount;

  /// Total pembayaran yang sudah tercatat (bisa dicicil).
  final int paidAmount;
  final ObligationStatus status;

  /// Uang yang masih harus disiapkan untuk jatuh tempo ini.
  int get remaining => switch (status) {
    ObligationStatus.paid || ObligationStatus.skipped => 0,
    ObligationStatus.pending || ObligationStatus.late => math.max(0, expectedAmount - paidAmount),
  };
}

/// Total kewajiban yang dicadangkan sampai [nextPayday] (ikut).
///
/// Jatuh tempo yang sudah lewat tapi belum lunas tetap dihitung.
int reservedForObligations(Iterable<ObligationDue> dues, LocalDate nextPayday) =>
    dues.where((due) => due.dueDate <= nextPayday).fold(0, (sum, due) => sum + due.remaining);

/// Sisa target tabungan siklus ini yang belum disisihkan.
int remainingSavingsTarget({required int targetPerCycle, required int savedThisCycle}) =>
    math.max(0, targetPerCycle - savedThisCycle);

/// Hasil perhitungan Safe-to-Spend beserta rinciannya, untuk layar
/// "Dari mana angka ini?".
final class SafeToSpend {
  const SafeToSpend({
    required this.availableBalance,
    required this.obligationsReserved,
    required this.savingsReserved,
    required this.buffer,
    required this.amount,
    required this.dailyAllowance,
    required this.daysLeft,
  });

  /// Saldo semua akun yang dihitung di Safe-to-Spend.
  final int availableBalance;
  final int obligationsReserved;
  final int savingsReserved;
  final int buffer;

  /// Uang yang aman dibelanjakan sampai gajian. Negatif kalau kewajiban tidak tertutup.
  final int amount;

  /// [amount] dibagi [daysLeft], dibulatkan ke bawah; 0 kalau [amount] ≤ 0.
  final int dailyAllowance;
  final int daysLeft;

  bool get isNegative => amount < 0;
}

/// Basis poin buffer bawaan: 500 = 5% (PRD §5 USP 1).
const defaultBufferBasisPoints = 500;

/// Safe-to-Spend = saldo − kewajiban − tabungan − buffer (docs/FASE1.md §2).
SafeToSpend calculateSafeToSpend({
  required int availableBalance,
  required int obligationsReserved,
  int savingsReserved = 0,
  required int daysLeft,
  int bufferBasisPoints = defaultBufferBasisPoints,
}) {
  if (obligationsReserved < 0) {
    throw ArgumentError.value(obligationsReserved, 'obligationsReserved', 'tidak boleh negatif');
  }
  if (savingsReserved < 0) {
    throw ArgumentError.value(savingsReserved, 'savingsReserved', 'tidak boleh negatif');
  }
  RangeError.checkValueInInterval(bufferBasisPoints, 0, 10000, 'bufferBasisPoints');
  if (daysLeft < 1) throw RangeError.value(daysLeft, 'daysLeft', 'minimal 1');

  final remainder = availableBalance - obligationsReserved - savingsReserved;
  // Dibulatkan ke atas supaya buffer tidak pernah kurang dari persentasenya.
  final buffer = remainder > 0 ? (remainder * bufferBasisPoints + 9999) ~/ 10000 : 0;
  final amount = remainder - buffer;

  return SafeToSpend(
    availableBalance: availableBalance,
    obligationsReserved: obligationsReserved,
    savingsReserved: savingsReserved,
    buffer: buffer,
    amount: amount,
    dailyAllowance: amount > 0 ? amount ~/ daysLeft : 0,
    daysLeft: daysLeft,
  );
}
