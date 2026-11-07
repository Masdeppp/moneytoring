import 'package:flutter/material.dart';

import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_context.dart';

/// Gajian → Saldo → Kewajiban → Aha. Figma baru punya 3 layar (tanpa saldo);
/// layar saldo ditambahkan karena PRD §8.1 mewajibkan saldo awal per akun.
const onboardingStepCount = 4;

/// Kerangka layar onboarding (Figma layar 01–03): stepper, judul, isi yang
/// bisa di-scroll dengan jarak 20, lalu footer yang tetap di bawah.
class OnboardingScaffold extends StatelessWidget {
  const OnboardingScaffold({
    super.key,
    required this.step,
    required this.title,
    required this.subtitle,
    required this.sections,
    required this.footer,
    this.onBack,
    this.badge,
  });

  /// Nomor langkah, mulai dari 1.
  final int step;
  final String title;
  final String subtitle;

  /// Bagian isi di bawah judul, masing-masing berjarak 20.
  final List<Widget> sections;
  final Widget footer;
  final VoidCallback? onBack;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      body: SafeArea(
        child: Column(
          // Tombol di footer selebar layar (Figma: Button Large, FILL).
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenOnboarding,
                  AppSpacing.s16,
                  AppSpacing.screenOnboarding,
                  AppSpacing.s16,
                ),
                children: [
                  _Stepper(step: step, onBack: onBack),
                  const SizedBox(height: AppSpacing.s20),
                  if (badge case final badge?) ...[
                    Align(alignment: Alignment.centerLeft, child: badge),
                    const SizedBox(height: AppSpacing.s8),
                  ],
                  Semantics(
                    header: true,
                    child: Text(
                      title,
                      style: AppTypography.headlineLarge.copyWith(color: c.textPrimary),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  Text(subtitle, style: AppTypography.bodyMedium.copyWith(color: c.textSecondary)),
                  for (final section in sections) ...[
                    const SizedBox(height: AppSpacing.s20),
                    section,
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenOnboarding,
                AppSpacing.s12,
                AppSpacing.screenOnboarding,
                AppSpacing.s24,
              ),
              child: footer,
            ),
          ],
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.step, required this.onBack});

  final int step;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final back = onBack;
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          if (back != null) ...[
            IconButton(
              tooltip: 'Kembali',
              onPressed: back,
              icon: const Icon(AppIcons.chevronLeft),
              color: c.iconPrimary,
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: AppSpacing.s4),
          ],
          Expanded(
            child: Semantics(
              label: 'Langkah $step dari $onboardingStepCount',
              excludeSemantics: true,
              child: Row(
                children: [
                  for (var i = 1; i <= onboardingStepCount; i++) ...[
                    if (i > 1) const SizedBox(width: 6),
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: i <= step ? c.bgBrand : c.bgSurfaceMuted,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          ExcludeSemantics(
            child: Text(
              '$step/$onboardingStepCount',
              style: AppTypography.labelMedium.copyWith(color: c.textTertiary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Baris "label ........ nilai" di atas tombol footer (mis. total kewajiban).
class OnboardingTotalRow extends StatelessWidget {
  const OnboardingTotalRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return MergeSemantics(
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: AppTypography.bodyMedium.copyWith(color: c.textSecondary)),
          ),
          Text(
            value,
            style: AppTypography.titleMedium.copyWith(
              color: c.textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
