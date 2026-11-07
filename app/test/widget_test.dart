import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keuangan_app/app.dart';
import 'package:keuangan_app/core/model/enums.dart';
import 'package:keuangan_app/data/db/database_provider.dart';
import 'package:keuangan_app/data/providers.dart';
import 'package:keuangan_app/data/services/safe_to_spend_service.dart';
import 'package:keuangan_app/engine/common/local_date.dart';
import 'package:keuangan_app/engine/cycle/pay_cycle.dart';
import 'package:keuangan_app/engine/forecast/risk_tier0.dart';
import 'package:keuangan_app/engine/safe_to_spend/safe_to_spend.dart';

/// Snapshot tiruan dengan skenario DESIGN.md: 11 Nov, gajian 25 Nov.
SafeToSpendSnapshot snapshot({
  RiskLevel level = RiskLevel.safe,
  int amount = 1190000,
  bool obligationsAtRisk = false,
  int projectedShortfall = 0,
}) => SafeToSpendSnapshot(
  today: LocalDate(2026, 11, 11),
  cycle: PayCycle(start: LocalDate(2026, 10, 25), nextPayday: LocalDate(2026, 11, 25)),
  safeToSpend: SafeToSpend(
    availableBalance: 3500000,
    obligationsReserved: 2200000,
    savingsReserved: 0,
    buffer: 0,
    amount: amount,
    dailyAllowance: amount > 0 ? amount ~/ 14 : 0,
    daysLeft: 14,
  ),
  risk: RiskAssessment(
    level: level,
    spentThisCycle: 860000,
    spentFraction: 0.42,
    cycleFraction: 0.55,
    averageDailySpend: 50000,
    projectedSpend: 700000,
    projectedShortfall: projectedShortfall,
    obligationsAtRisk: obligationsAtRisk,
    paceTooFast: false,
  ),
  reservedDues: const [],
);

void main() {
  // Database asli butuh plugin Android; di test semua angka dari provider tiruan.
  Widget app({bool onboarded = true, SafeToSpendSnapshot? summary}) => ProviderScope(
    overrides: [
      databaseStatusProvider.overrideWith(
        (ref) async => (cipher: 'chacha20', schemaVersion: 2, categoryCount: 13),
      ),
      onboardingStatusProvider.overrideWith((ref) => Stream.value(onboarded)),
      safeToSpendProvider.overrideWith((ref) => Stream.value(summary ?? snapshot())),
    ],
    child: const MoneytoringApp(),
  );

  testWidgets('aplikasi terbuka di Beranda dengan kartu Safe-to-Spend', (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.text('AMAN DIBELANJAKAN'), findsOneWidget);
    expect(find.text('Rp 1.190.000'), findsOneWidget);
    expect(find.text('Jatah harian Rp 85.000'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    for (final label in ['Beranda', 'Transaksi', 'Kewajiban', 'Insight']) {
      expect(find.widgetWithText(NavigationDestination, label), findsOneWidget);
    }
  });

  testWidgets('pengguna baru diarahkan ke onboarding', (tester) async {
    await tester.pumpWidget(app(onboarded: false));
    await tester.pumpAndSettle();

    expect(find.text('Kapan kamu gajian?'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('kewajiban berisiko memunculkan peringatan di bawah kartu', (tester) async {
    await tester.pumpWidget(
      app(
        summary: snapshot(
          level: RiskLevel.danger,
          amount: 300000,
          obligationsAtRisk: true,
          projectedShortfall: 430000,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kewajiban berisiko'), findsOneWidget);
    expect(find.textContaining('kurang Rp 430.000'), findsOneWidget);
  });

  testWidgets('pindah tab Kewajiban menyembunyikan FAB', (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(NavigationDestination, 'Kewajiban'));
    await tester.pumpAndSettle();

    expect(find.text('Layar Kewajiban dibangun di Fase 1'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('tile debug menampilkan status database', (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.text('Terbuka · cipher chacha20 · skema v2 · 13 kategori'), findsOneWidget);
  });
}
