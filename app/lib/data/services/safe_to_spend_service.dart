import 'dart:async';

import 'package:drift/drift.dart';

import '../../engine/common/local_date.dart';
import '../../engine/cycle/holiday_calendar.dart';
import '../../engine/cycle/pay_cycle.dart';
import '../../engine/forecast/risk_tier0.dart';
import '../../engine/safe_to_spend/safe_to_spend.dart';
import '../../engine/safe_to_spend/savings_goal.dart';
import '../db/app_database.dart';
import '../repositories/account_repository.dart';
import '../repositories/obligation_repository.dart';
import '../repositories/pay_cycle_repository.dart';
import '../repositories/savings_repository.dart';
import '../repositories/transaction_repository.dart';
import 'salary_share_service.dart';

/// Semua angka kartu Safe-to-Spend untuk satu hari.
final class SafeToSpendSnapshot {
  const SafeToSpendSnapshot({
    required this.today,
    required this.cycle,
    required this.safeToSpend,
    required this.risk,
    required this.reservedDues,
  });

  final LocalDate today;
  final PayCycle cycle;
  final SafeToSpend safeToSpend;
  final RiskAssessment risk;

  /// Jatuh tempo yang uangnya sedang dicadangkan: belum lunas, paling lambat
  /// di hari gajian berikutnya, urut dari yang terdekat.
  final List<ObligationDueView> reservedDues;

  /// "Rp 2,2 jt diamankan untuk 3 kewajiban".
  int get protectedCount => reservedDues.length;
}

/// Rencana [goal] untuk [cycle]: kebutuhan setoran dan yang dicadangkan.
///
/// Target "Sisa gaji" menyisihkan persen dari [expectedIncome] tiap siklus.
SavingsGoalPlan planGoal(
  SavingsGoalProgress goal, {
  required PayCycleCalculator calculator,
  required PayCycle cycle,
  required int expectedIncome,
}) {
  final deadline = goal.deadline;
  final salaryBasisPoints = goal.goal.salaryBasisPoints;
  return planSavingsGoal(
    target: goal.goal.targetAmount,
    cyclesLeft: deadline == null ? null : cyclesUntil(calculator, cycle, deadline),
    amountPerCycle: salaryBasisPoints == null
        ? goal.goal.amountPerCycle
        : salaryShare(expectedIncome, salaryBasisPoints),
    savedBeforeCycle: goal.savedBeforeCycle,
    savedThisCycle: goal.savedThisCycle,
    keptInSafeToSpend: goal.keptInSafeToSpend,
  );
}

/// Menggabungkan isi database dengan engine (PRD §10.1: engine tetap pure Dart).
class SafeToSpendService {
  SafeToSpendService({
    required this._db,
    required this._holidays,
    required this._accounts,
    required this._transactions,
    required this._obligations,
    required this._payCycles,
    required this._savings,
    this.riskSettings = const RiskSettings(),
  });

  final AppDatabase _db;
  final HolidayCalendar _holidays;
  final AccountRepository _accounts;
  final TransactionRepository _transactions;
  final ObligationRepository _obligations;
  final PayCycleRepository _payCycles;
  final SavingsRepository _savings;
  final RiskSettings riskSettings;

  late final _salaryShare = SalaryShareService(
    holidays: _holidays,
    accounts: _accounts,
    obligations: _obligations,
    payCycles: _payCycles,
    savings: _savings,
  );

  /// `null` kalau pengguna belum menyelesaikan onboarding (belum ada aturan gajian).
  Future<SafeToSpendSnapshot?> compute(LocalDate today) async {
    final config = await _payCycles.current();
    if (config == null) return null;

    final calculator = PayCycleCalculator(PayCycleRepository.ruleOf(config), holidays: _holidays);
    await _obligations.ensureInstances(calculator: calculator, today: today);
    await _salaryShare.settle(today);
    final cycle = calculator.cycleContaining(today);

    final balances = await _accounts.balances();
    final available = balances
        .where((entry) => entry.account.includeInSafeToSpend)
        .fold<int>(0, (sum, entry) => sum + entry.balance);

    final dues = [
      for (final due in await _obligations.unpaidThrough(cycle.nextPayday))
        if (due.remaining > 0) due,
    ];

    final safeToSpend = calculateSafeToSpend(
      availableBalance: available,
      obligationsReserved: reservedForObligations(
        dues.map((due) => due.toEngine()),
        cycle.nextPayday,
      ),
      savingsReserved: [
        for (final goal in await _savings.progress(cycle.start))
          planGoal(
            goal,
            calculator: calculator,
            cycle: cycle,
            expectedIncome: config.expectedIncome,
          ),
      ].fold(0, (sum, plan) => sum + plan.reserved),
      daysLeft: cycle.daysLeft(today),
      bufferBasisPoints: config.bufferBasisPoints,
    );

    final projectionStart = today.addDays(1 - riskSettings.projectionWindowDays);
    final spending = await _transactions.spending(
      from: cycle.start < projectionStart ? cycle.start : projectionStart,
      to: today,
    );
    final risk = assessRiskTier0(
      cycle: cycle,
      today: today,
      trackingSince: LocalDate.fromDateTime(config.trackingSince),
      safeToSpend: safeToSpend,
      spending: spending,
      settings: riskSettings,
    );

    return SafeToSpendSnapshot(
      today: today,
      cycle: cycle,
      safeToSpend: safeToSpend,
      risk: risk,
      reservedDues: dues,
    );
  }

  /// Snapshot yang dihitung ulang setiap kali data yang memengaruhinya berubah.
  ///
  /// Perubahan yang datang beruntun saat perhitungan masih berjalan digabung
  /// menjadi satu perhitungan ulang.
  Stream<SafeToSpendSnapshot?> watch(LocalDate Function() today) {
    StreamSubscription<Set<TableUpdate>>? updates;
    var running = false;
    var dirty = false;
    late final StreamController<SafeToSpendSnapshot?> output;

    Future<void> recompute() async {
      if (running) {
        dirty = true;
        return;
      }
      running = true;
      try {
        do {
          dirty = false;
          final snapshot = await compute(today());
          if (!output.isClosed) output.add(snapshot);
        } while (dirty);
      } catch (error, stackTrace) {
        if (!output.isClosed) output.addError(error, stackTrace);
      } finally {
        running = false;
      }
    }

    output = StreamController<SafeToSpendSnapshot?>(
      onListen: () {
        updates = _db
            .tableUpdates(
              TableUpdateQuery.onAllTables([
                _db.accounts,
                _db.transactions,
                _db.payCycleConfigs,
                _db.obligations,
                _db.obligationInstances,
                _db.savingsGoals,
                _db.goalContributions,
              ]),
            )
            .listen((_) => unawaited(recompute()));
        unawaited(recompute());
      },
      onCancel: () => updates?.cancel(),
    );
    return output.stream;
  }
}
