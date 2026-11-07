import 'dart:async';

import 'package:drift/drift.dart';

import '../../engine/common/local_date.dart';
import '../../engine/cycle/holiday_calendar.dart';
import '../../engine/cycle/pay_cycle.dart';
import '../../engine/forecast/risk_tier0.dart';
import '../../engine/safe_to_spend/safe_to_spend.dart';
import '../db/app_database.dart';
import '../repositories/account_repository.dart';
import '../repositories/obligation_repository.dart';
import '../repositories/pay_cycle_repository.dart';
import '../repositories/savings_repository.dart';
import '../repositories/transaction_repository.dart';

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

  /// `null` kalau pengguna belum menyelesaikan onboarding (belum ada aturan gajian).
  Future<SafeToSpendSnapshot?> compute(LocalDate today) async {
    final config = await _payCycles.current();
    if (config == null) return null;

    final calculator = PayCycleCalculator(PayCycleRepository.ruleOf(config), holidays: _holidays);
    await _obligations.ensureInstances(calculator: calculator, today: today);
    final cycle = calculator.cycleContaining(today);

    final balances = await _accounts.balances();
    final available = balances
        .where((entry) => entry.account.includeInSafeToSpend)
        .fold<int>(0, (sum, entry) => sum + entry.balance);
    final protectedAccounts = {
      for (final entry in balances)
        if (!entry.account.includeInSafeToSpend) entry.account.id,
    };

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
      savingsReserved: await _savingsReserved(cycle, today, protectedAccounts),
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

  /// Target tabungan yang belum disisihkan siklus ini.
  ///
  /// Transfer hanya dihitung sebagai "sudah disisihkan" kalau rekening
  /// tujuannya tidak ikut Safe-to-Spend. Kalau ikut, uangnya masih terhitung di
  /// saldo, jadi target tetap dicadangkan penuh.
  Future<int> _savingsReserved(PayCycle cycle, LocalDate today, Set<int> protectedAccounts) async {
    var total = 0;
    for (final target in await _savings.targets()) {
      final accountId = target.accountId;
      final saved = accountId != null && protectedAccounts.contains(accountId)
          ? await _transactions.transferredInto(
              accountIds: {accountId},
              from: cycle.start,
              to: today,
            )
          : 0;
      total += remainingSavingsTarget(targetPerCycle: target.amountPerCycle, savedThisCycle: saved);
    }
    return total;
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
                _db.savingsTargets,
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
