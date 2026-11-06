import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keuangan_app/app.dart';
import 'package:keuangan_app/data/db/database_provider.dart';

void main() {
  Widget app() => ProviderScope(
    overrides: [
      // Database asli butuh plugin Android; di test cukup status tiruan.
      databaseStatusProvider.overrideWith((ref) async => (cipher: 'chacha20', categoryCount: 13)),
    ],
    child: const MoneytoringApp(),
  );

  testWidgets('aplikasi terbuka di Beranda dengan kartu Safe-to-Spend', (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.text('AMAN DIBELANJAKAN'), findsOneWidget);
    expect(find.text('Rp 1.190.000'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    for (final label in ['Beranda', 'Transaksi', 'Kewajiban', 'Insight']) {
      expect(find.widgetWithText(NavigationDestination, label), findsOneWidget);
    }
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

    expect(find.text('Terbuka · cipher chacha20 · 13 kategori'), findsOneWidget);
  });
}
