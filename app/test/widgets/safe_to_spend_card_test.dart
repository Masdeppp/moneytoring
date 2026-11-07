import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keuangan_app/core/model/enums.dart';
import 'package:keuangan_app/core/theme/app_theme.dart';
import 'package:keuangan_app/core/widgets/safe_to_spend_card.dart';

void main() {
  Widget card() => MaterialApp(
    theme: AppTheme.light(),
    home: const Scaffold(
      body: SafeToSpendCard(
        risk: RiskLevel.safe,
        amount: 1190000,
        dailyAllowance: 85000,
        daysLeft: 14,
        spentFraction: 0.42,
        cycleFraction: 0.55,
        protectedAmount: 2200000,
        protectedCount: 3,
      ),
    ),
  );

  // Android memberi frame pertama dengan viewport 0×0 sebelum ukuran layar
  // diketahui. Dulu ini membuat `clamp(0, width - 2)` melempar ArgumentError.
  testWidgets('kartu tidak error saat viewport masih 0×0', (tester) async {
    tester.view.physicalSize = Size.zero;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(card());

    expect(tester.takeException(), isNull);
  });
}
