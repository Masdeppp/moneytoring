import 'dart:math' as math;

import '../../core/model/enums.dart';
import '../common/local_date.dart';
import '../cycle/pay_cycle.dart';
import '../safe_to_spend/safe_to_spend.dart';

/// Satu pengeluaran harian yang bukan pembayaran kewajiban.
///
/// Transfer antar akun dan pembayaran kewajiban tidak termasuk, karena
/// keduanya tidak mengurangi uang yang aman dibelanjakan.
final class SpendEntry {
  const SpendEntry(this.date, this.amount);

  final LocalDate date;
  final int amount;
}

/// Ambang risiko Tier 0. Nanti disetel oleh Alert Tuner (tabel `alert_thresholds`).
final class RiskSettings {
  const RiskSettings({
    this.paceMargin = 0.10,
    this.minObservedDays = 3,
    this.projectionWindowDays = 7,
  }) : assert(paceMargin >= 0),
       assert(minObservedDays >= 1),
       assert(projectionWindowDays >= 1);

  /// A4 menyala kalau pace terpakai melebihi waktu berjalan + margin ini.
  final double paceMargin;

  /// Hari mencatat minimum sebelum proyeksi dan pace dipakai.
  final int minObservedDays;

  /// Jumlah hari terakhir untuk rata-rata belanja harian.
  final int projectionWindowDays;
}

/// Hasil penilaian risiko Tier 0 (PRD §6.1).
final class RiskAssessment {
  const RiskAssessment({
    required this.level,
    required this.spentThisCycle,
    required this.spentFraction,
    required this.cycleFraction,
    required this.averageDailySpend,
    required this.projectedSpend,
    required this.projectedShortfall,
    required this.obligationsAtRisk,
    required this.paceTooFast,
  });

  /// Menentukan warna kartu Safe-to-Spend.
  final RiskLevel level;

  final int spentThisCycle;

  /// 0–1: porsi anggaran siklus yang sudah dibelanjakan (bar di kartu).
  final double spentFraction;

  /// 0–1: porsi siklus yang sudah lewat (garis tipis di kartu).
  final double cycleFraction;

  final int averageDailySpend;

  /// Perkiraan belanja sampai gajian berikutnya.
  final int projectedSpend;

  /// Kekurangan yang diproyeksikan; 0 kalau aman.
  final int projectedShortfall;

  /// Pemicu A1: kewajiban terancam tidak tertutup.
  final bool obligationsAtRisk;

  /// Pemicu A4: belanja lebih cepat dari waktu.
  final bool paceTooFast;
}

/// Menilai risiko dengan aturan sederhana (Tier 0, docs/FASE1.md §2).
///
/// [trackingSince] adalah hari pertama pengguna mencatat. Kalau jatuh di
/// tengah siklus, pace dihitung dari tanggal itu supaya belanja yang tidak
/// tercatat sebelum mulai memakai aplikasi tidak membuat pace terlihat lambat.
RiskAssessment assessRiskTier0({
  required PayCycle cycle,
  required LocalDate today,
  required LocalDate trackingSince,
  required SafeToSpend safeToSpend,
  required Iterable<SpendEntry> spending,
  RiskSettings settings = const RiskSettings(),
}) {
  if (!cycle.contains(today)) {
    throw ArgumentError.value(today, 'today', 'harus di dalam $cycle');
  }
  final since = trackingSince > today ? today : trackingSince;
  final trackedStart = since > cycle.start ? since : cycle.start;
  final daysTracked = today.differenceInDays(since) + 1;
  final enoughData = daysTracked >= settings.minObservedDays;

  final spentThisCycle = _sumBetween(spending, trackedStart, today);
  final sts = safeToSpend.amount;
  final double spentFraction;
  if (sts < 0) {
    spentFraction = 1;
  } else if (spentThisCycle + sts == 0) {
    spentFraction = 0;
  } else {
    spentFraction = spentThisCycle / (spentThisCycle + sts);
  }
  final cycleFraction =
      today.differenceInDays(trackedStart) / cycle.nextPayday.differenceInDays(trackedStart);

  final observedDays = math.min(settings.projectionWindowDays, daysTracked);
  final recentSpend = _sumBetween(spending, today.addDays(1 - observedDays), today);
  final daysLeft = cycle.daysLeft(today);
  final projectedSpend = recentSpend * daysLeft ~/ observedDays;
  final projectedShortfall = math.max(0, projectedSpend - sts);

  final obligationsAtRisk = sts < 0 || (enoughData && projectedShortfall > 0);
  final paceTooFast = enoughData && spentFraction > cycleFraction + settings.paceMargin;

  return RiskAssessment(
    level: obligationsAtRisk
        ? RiskLevel.danger
        : paceTooFast
        ? RiskLevel.warning
        : RiskLevel.safe,
    spentThisCycle: spentThisCycle,
    spentFraction: spentFraction,
    cycleFraction: cycleFraction,
    averageDailySpend: recentSpend ~/ observedDays,
    projectedSpend: projectedSpend,
    projectedShortfall: projectedShortfall,
    obligationsAtRisk: obligationsAtRisk,
    paceTooFast: paceTooFast,
  );
}

int _sumBetween(Iterable<SpendEntry> spending, LocalDate from, LocalDate to) => spending
    .where((entry) => entry.date >= from && entry.date <= to)
    .fold(0, (sum, entry) => sum + entry.amount);
