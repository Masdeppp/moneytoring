import '../../../core/model/enums.dart';
import '../../../data/repositories/obligation_repository.dart';
import '../../../engine/common/local_date.dart';
import '../../../engine/cycle/pay_cycle.dart';

/// Timeline kewajiban satu siklus (layar 08) beserta angka kartu progresnya.
final class ObligationTimeline {
  /// [dues] dari `ObligationRepository.watchCycle`: jatuh tempo siklus
  /// [cycle] ditambah tunggakan siklus sebelumnya, urut tanggal.
  factory ObligationTimeline(
    List<ObligationDueView> dues, {
    required PayCycle cycle,
    required LocalDate today,
  }) {
    final late = <ObligationDueView>[];
    final upcoming = <ObligationDueView>[];
    final done = <ObligationDueView>[];
    var count = 0;
    var paidCount = 0;
    var perCycle = 0;
    var paid = 0;
    var remaining = 0;
    for (final due in dues) {
      switch (due.status) {
        case ObligationStatus.paid || ObligationStatus.skipped:
          done.add(due);
        case _ when due.dueDate < today:
          late.add(due);
        case _:
          upcoming.add(due);
      }
      paid += due.paidAmount;
      remaining += due.remaining;
      if (due.status == ObligationStatus.skipped) continue;
      count++;
      if (due.status == ObligationStatus.paid) paidCount++;
      if (due.dueDate > cycle.start && due.dueDate <= cycle.nextPayday) {
        perCycle += due.instance.expectedAmount;
      }
    }
    return ObligationTimeline._(
      late: late,
      upcoming: upcoming,
      done: done,
      count: count,
      paidCount: paidCount,
      perCycle: perCycle,
      paid: paid,
      remaining: remaining,
    );
  }

  const ObligationTimeline._({
    required this.late,
    required this.upcoming,
    required this.done,
    required this.count,
    required this.paidCount,
    required this.perCycle,
    required this.paid,
    required this.remaining,
  });

  /// Belum lunas dan sudah lewat jatuh tempo (termasuk dari siklus lalu).
  final List<ObligationDueView> late;

  /// Belum lunas, jatuh tempo hari ini atau sesudahnya.
  final List<ObligationDueView> upcoming;

  /// Lunas atau dilewati.
  final List<ObligationDueView> done;

  /// Jatuh tempo yang dihitung di "x dari y lunas" (tanpa yang dilewati).
  final int count;
  final int paidCount;

  /// Total nominal jatuh tempo milik siklus ini, tanpa tunggakan siklus lalu.
  final int perCycle;

  /// Total pembayaran yang sudah tercatat.
  final int paid;

  /// Yang masih dicadangkan sampai gajian; sama dengan angka "diamankan" di
  /// kartu Safe-to-Spend.
  final int remaining;

  bool get isEmpty => late.isEmpty && upcoming.isEmpty && done.isEmpty;

  /// Jatuh tempo terlambat paling awal yang belum ada pembayarannya sama
  /// sekali, untuk pertanyaan "Sudah dibayar?" (alert A3 di layar).
  ObligationDueView? get unrecorded => late.where((due) => due.paidAmount == 0).firstOrNull;
}
