import 'package:flutter_test/flutter_test.dart';
import 'package:keuangan_app/core/model/enums.dart';
import 'package:keuangan_app/engine/common/local_date.dart';
import 'package:keuangan_app/engine/cycle/pay_cycle.dart';
import 'package:keuangan_app/engine/forecast/risk_tier0.dart';
import 'package:keuangan_app/engine/safe_to_spend/safe_to_spend.dart';

LocalDate d(int y, int m, int day) => LocalDate(y, m, day);

/// Safe-to-Spend sederhana untuk test: hanya [amount] yang dipakai engine risiko.
SafeToSpend sts(int amount) => SafeToSpend(
  availableBalance: amount,
  obligationsReserved: 0,
  savingsReserved: 0,
  buffer: 0,
  amount: amount,
  dailyAllowance: amount > 0 ? amount ~/ 14 : 0,
  daysLeft: 14,
);

/// Belanja [amount] setiap hari dari [from] sampai [to].
List<SpendEntry> daily(LocalDate from, LocalDate to, int amount) => [
  for (var day = from; day <= to; day = day.addDays(1)) SpendEntry(day, amount),
];

void main() {
  // Skenario PRD: siklus 25 Okt – 24 Nov, hari ini Rabu 11 Nov, 14 hari lagi.
  final cycle = PayCycle(start: d(2026, 10, 25), nextPayday: d(2026, 11, 25));
  final today = d(2026, 11, 11);
  final longAgo = d(2026, 10, 1);

  test('Lampiran A PRD: proyeksi Rp 1.190.000 > Safe-to-Spend → kurang Rp 430.000', () {
    final safeToSpend = calculateSafeToSpend(
      availableBalance: 3000000,
      obligationsReserved: 2200000,
      daysLeft: cycle.daysLeft(today),
    );
    final result = assessRiskTier0(
      cycle: cycle,
      today: today,
      trackingSince: longAgo,
      safeToSpend: safeToSpend,
      spending: [
        ...daily(d(2026, 10, 25), d(2026, 11, 4), 40000),
        ...daily(d(2026, 11, 5), d(2026, 11, 11), 85000),
      ],
    );

    expect(safeToSpend.amount, 760000);
    expect(result.averageDailySpend, 85000);
    expect(result.projectedSpend, 1190000);
    expect(result.projectedShortfall, 430000);
    expect(result.obligationsAtRisk, isTrue);
    expect(result.level, RiskLevel.danger);
    expect(result.spentThisCycle, 11 * 40000 + 7 * 85000);
  });

  test('aman: belanja sejalan dengan waktu', () {
    final result = assessRiskTier0(
      cycle: cycle,
      today: today,
      trackingSince: longAgo,
      safeToSpend: sts(1190000),
      spending: [
        ...daily(d(2026, 10, 25), d(2026, 11, 10), 30000),
        // Transaksi bertanggal masa depan tidak dihitung.
        SpendEntry(d(2026, 11, 20), 999999),
      ],
    );

    expect(result.level, RiskLevel.safe);
    expect(result.spentThisCycle, 510000);
    expect(result.spentFraction, closeTo(0.3, 1e-9));
    expect(result.cycleFraction, closeTo(17 / 31, 1e-9));
    expect(result.averageDailySpend, 25714);
    expect(result.projectedSpend, 360000);
    expect(result.projectedShortfall, 0);
    expect(result.paceTooFast, isFalse);
  });

  final fastPace = [
    SpendEntry(d(2026, 10, 26), 1000000),
    SpendEntry(d(2026, 11, 5), 50000),
    SpendEntry(d(2026, 11, 8), 50000),
  ];

  test('waspada: pace terpakai melewati waktu berjalan + 10 poin', () {
    final result = assessRiskTier0(
      cycle: cycle,
      today: today,
      trackingSince: longAgo,
      safeToSpend: sts(400000),
      spending: fastPace,
    );

    expect(result.spentFraction, closeTo(1100000 / 1500000, 1e-9));
    expect(result.projectedSpend, 200000);
    expect(result.paceTooFast, isTrue);
    expect(result.obligationsAtRisk, isFalse);
    expect(result.level, RiskLevel.warning);
  });

  test('margin pace bisa disetel', () {
    final result = assessRiskTier0(
      cycle: cycle,
      today: today,
      trackingSince: longAgo,
      safeToSpend: sts(400000),
      spending: fastPace,
      settings: const RiskSettings(paceMargin: 0.3),
    );
    expect(result.level, RiskLevel.safe);
  });

  test('berisiko langsung saat Safe-to-Spend negatif, walau baru mulai mencatat', () {
    final result = assessRiskTier0(
      cycle: cycle,
      today: today,
      trackingSince: today,
      safeToSpend: sts(-150000),
      spending: const [],
    );

    expect(result.level, RiskLevel.danger);
    expect(result.spentFraction, 1);
    expect(result.cycleFraction, 0);
    expect(result.projectedShortfall, 150000);
  });

  test('data kurang dari 3 hari: belanja besar tidak langsung memicu merah atau kuning', () {
    final result = assessRiskTier0(
      cycle: cycle,
      today: today,
      trackingSince: d(2026, 11, 10),
      safeToSpend: sts(500000),
      spending: [SpendEntry(d(2026, 11, 10), 1000000)],
    );

    expect(result.projectedSpend, 7000000);
    expect(result.projectedShortfall, greaterThan(0));
    expect(result.obligationsAtRisk, isFalse);
    expect(result.paceTooFast, isFalse);
    expect(result.level, RiskLevel.safe);
  });

  test('mulai mencatat di tengah siklus: pace dihitung dari tanggal mulai', () {
    final result = assessRiskTier0(
      cycle: cycle,
      today: today,
      trackingSince: d(2026, 11, 4),
      safeToSpend: sts(900000),
      spending: [SpendEntry(d(2026, 11, 3), 500000), SpendEntry(d(2026, 11, 5), 100000)],
    );

    expect(result.spentThisCycle, 100000);
    expect(result.cycleFraction, closeTo(7 / 21, 1e-9));
    expect(result.level, RiskLevel.safe);
  });

  test('tanpa belanja dan Safe-to-Spend nol: pace 0, tidak berisiko', () {
    final result = assessRiskTier0(
      cycle: cycle,
      today: today,
      trackingSince: longAgo,
      safeToSpend: sts(0),
      spending: const [],
    );

    expect(result.spentFraction, 0);
    expect(result.projectedShortfall, 0);
    expect(result.level, RiskLevel.safe);
  });

  test('tanggal mulai mencatat di masa depan dianggap hari ini', () {
    final result = assessRiskTier0(
      cycle: cycle,
      today: today,
      trackingSince: d(2026, 11, 20),
      safeToSpend: sts(500000),
      spending: const [],
    );
    expect(result.cycleFraction, 0);
  });

  test('hari ini harus di dalam siklus', () {
    expect(
      () => assessRiskTier0(
        cycle: cycle,
        today: d(2026, 11, 25),
        trackingSince: longAgo,
        safeToSpend: sts(0),
        spending: const [],
      ),
      throwsArgumentError,
    );
  });
}
