import 'package:flutter/material.dart';

import 'accounts_step.dart';
import 'aha_step.dart';
import 'obligations_step.dart';
import 'payday_step.dart';

/// Alur onboarding (PRD §8.1): Gajian → Saldo → Kewajiban → Aha.
///
/// Satu route saja; langkahnya disimpan di state supaya isian tidak hilang
/// saat kembali. Tombol Back Android mundur satu langkah.
class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  var _step = 0;

  void _next() => setState(() => _step++);

  void _back() => setState(() => _step--);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _step > 0) _back();
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: switch (_step) {
          0 => PaydayStep(key: const ValueKey(0), onNext: _next),
          1 => AccountsStep(key: const ValueKey(1), onBack: _back, onNext: _next),
          2 => ObligationsStep(key: const ValueKey(2), onBack: _back, onNext: _next),
          _ => AhaStep(key: const ValueKey(3), onBack: _back),
        },
      ),
    );
  }
}
