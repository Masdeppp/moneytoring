import '../../engine/common/local_date.dart';
import '../../engine/cycle/holiday_calendar.dart';
import '../../engine/cycle/pay_cycle.dart';
import '../../engine/safe_to_spend/savings_goal.dart';
import '../db/app_database.dart';
import '../repositories/account_repository.dart';
import '../repositories/obligation_repository.dart';
import '../repositories/pay_cycle_repository.dart';
import '../repositories/savings_repository.dart';
import 'safe_to_spend_service.dart';

/// Sisihan persen gaji (docs/FASE1.md, "Sisihkan dari gaji").
///
/// Selama siklus berjalan, sisihannya dicadangkan lewat target "Sisa gaji"
/// (lihat [planGoal]). Saat gajian, sisihan yang benar-benar tersisa dari
/// siklus yang baru berakhir ditabung ke target itu, sehingga tetap tidak
/// dihitung aman dibelanjakan di siklus berikutnya.
class SalaryShareService {
  SalaryShareService({
    required this._holidays,
    required this._accounts,
    required this._obligations,
    required this._payCycles,
    required this._savings,
  });

  final HolidayCalendar _holidays;
  final AccountRepository _accounts;
  final ObligationRepository _obligations;
  final PayCycleRepository _payCycles;
  final SavingsRepository _savings;

  PayCycleCalculator _calculator(PayCycleConfigRecord config) =>
      PayCycleCalculator(PayCycleRepository.ruleOf(config), holidays: _holidays);

  /// Menabung sisihan setiap siklus yang sudah berakhir sebelum [today] dan
  /// belum ditabung. Tiap siklus hanya ditabung sekali, saat pertama kali
  /// dihitung setelah gajian.
  Future<void> settle(LocalDate today) async {
    final config = await _payCycles.current();
    final goal = await _savings.salaryGoal();
    if (config == null || goal == null) return;
    final calculator = _calculator(config);

    final settledThrough = goal.settledThrough;
    if (settledThrough == null) {
      // Mulai menabung dari siklus berjalan.
      await _savings.recordSalaryLeftover(
        goal.id,
        lastDay: calculator.cycleContaining(today).start.addDays(-1),
        amount: 0,
      );
      return;
    }
    final settled = LocalDate.fromDateTime(settledThrough);
    var cycle = calculator.cycleContaining(settled.addDays(1));
    // Setelah aturan gajian berubah, siklus ini bisa tumpang tindih dengan
    // siklus yang sudah ditabung; lewati supaya tidak terhitung dua kali.
    if (cycle.start <= settled) cycle = calculator.nextCycle(cycle);
    for (var count = 0; cycle.nextPayday <= today && count < 600; count++) {
      await _savings.recordSalaryLeftover(
        goal.id,
        lastDay: cycle.nextPayday.addDays(-1),
        amount: await _leftover(goal, config, calculator, cycle),
      );
      cycle = calculator.nextCycle(cycle);
    }
  }

  /// Sisihan [cycle] yang tersisa tepat sebelum gajian penutupnya: saldo akun
  /// yang dihitung − kewajiban yang masih dicadangkan − cadangan target lain −
  /// tabungan sisa gaji sebelumnya, paling banyak sebesar sisihannya.
  Future<int> _leftover(
    SavingsGoalRecord goal,
    PayCycleConfigRecord config,
    PayCycleCalculator calculator,
    PayCycle cycle,
  ) async {
    final share = salaryShare(config.expectedIncome, goal.salaryBasisPoints ?? 0);
    if (share == 0) return 0;
    final before = cycle.nextPayday.toDateTime();
    final balance = await _accounts.spendableBalanceBefore(before);
    final obligations = await _obligations.reservedAsOf(through: cycle.nextPayday, before: before);
    var otherGoals = 0;
    var savedBefore = 0;
    for (final progress in await _savings.progressThrough(
      cycle.start,
      cycle.nextPayday.addDays(-1),
    )) {
      if (progress.goal.id == goal.id) {
        savedBefore = progress.savedBeforeCycle;
      } else if (!progress.isSalaryShare) {
        otherGoals += planGoal(
          progress,
          calculator: calculator,
          cycle: cycle,
          expectedIncome: config.expectedIncome,
        ).reserved;
      }
    }
    return salaryLeftover(
      available: balance - obligations - otherGoals - savedBefore,
      share: share,
    );
  }

  /// Mengatur persen gaji yang disisihkan. Sisihan baru berlaku mulai siklus
  /// yang memuat [today].
  ///
  /// Kalau aturan gajian ikut berubah, panggil [settle] sebelum menyimpan
  /// aturan baru supaya siklus yang sudah lewat ditabung dengan aturan lama.
  Future<void> setShare(int basisPoints, {required LocalDate today}) async {
    final config = await _payCycles.current();
    if (config == null) return;
    await _savings.setSalaryShare(
      basisPoints,
      settledThrough: _calculator(config).cycleContaining(today).start.addDays(-1),
    );
  }

  /// Melepas tabungan sisa gaji supaya kembali dihitung aman dibelanjakan:
  /// satu setoran ([contributionId]) atau semuanya. Target yang sudah tidak
  /// menyisihkan dan tidak punya tabungan lagi ikut dihapus.
  Future<void> release({int? contributionId}) async {
    final goal = await _savings.salaryGoal();
    if (goal == null) return;
    if (contributionId == null) {
      await _savings.deleteContributions(goal.id);
    } else {
      await _savings.deleteContribution(contributionId);
    }
    if (goal.salaryBasisPoints == 0 && !await _savings.hasContributions(goal.id)) {
      await _savings.delete(goal.id);
    }
  }
}
