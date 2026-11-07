import 'package:flutter/material.dart';

import '../model/enums.dart';
import '../theme/app_icons.dart';
import '../theme/app_tokens.dart';
import '../theme/app_typography.dart';
import '../theme/theme_context.dart';
import '../utils/money.dart';

/// Kartu inti produk (DESIGN.md §4): berapa uang yang aman dibelanjakan
/// sampai gajian, dengan warna yang ditentukan engine risiko.
///
/// - Bar = porsi Safe-to-Spend yang sudah terpakai.
/// - Garis tipis = posisi hari dalam siklus. Bar melewati garis berarti
///   belanja lebih cepat dari waktu.
/// - Baris bawah = uang kewajiban yang sudah diamankan.
class SafeToSpendCard extends StatelessWidget {
  const SafeToSpendCard({
    super.key,
    required this.risk,
    required this.amount,
    required this.dailyAllowance,
    required this.daysLeft,
    required this.spentFraction,
    required this.cycleFraction,
    required this.protectedAmount,
    required this.protectedCount,
    this.onTap,
    this.showPace = true,
  });

  final RiskLevel risk;

  /// Safe-to-Spend dalam Rupiah. Bisa negatif saat kewajiban tidak tertutup.
  final int amount;
  final int dailyAllowance;
  final int daysLeft;

  /// 0–1: porsi Safe-to-Spend awal siklus yang sudah dibelanjakan.
  final double spentFraction;

  /// 0–1: porsi siklus gajian yang sudah berjalan.
  final double cycleFraction;
  final int protectedAmount;
  final int protectedCount;
  final VoidCallback? onTap;

  /// Bar pace disembunyikan di layar aha onboarding, saat belum ada belanja
  /// yang bisa dibandingkan dengan waktu (Figma layar 03).
  final bool showPace;

  String get _paceText => switch (risk) {
    RiskLevel.safe => 'Belanja masih sejalan dengan waktu',
    RiskLevel.warning => 'Belanja lebih cepat dari waktu',
    RiskLevel.danger => 'Kewajiban terancam tidak tertutup',
  };

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final onHero = c.textOnHero;
    final muted = c.textOnHeroMuted;

    return Semantics(
      container: true,
      label:
          'Aman dibelanjakan ${formatRupiah(amount)}, $daysLeft hari lagi sampai gajian. '
          'Jatah harian ${formatRupiah(dailyAllowance)}. $_paceText.',
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: c.heroFor(risk),
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'AMAN DIBELANJAKAN',
                          style: AppTypography.overline.copyWith(color: muted),
                        ),
                      ),
                      _Pill(
                        color: c.bgHeroOverlay,
                        child: Text(
                          '$daysLeft hari lagi',
                          style: AppTypography.labelMedium.copyWith(color: onHero),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  FittedBox(
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.scaleDown,
                    child: Text(
                      formatRupiah(amount),
                      style: AppTypography.displayAmount.copyWith(color: onHero),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s2),
                  Text(
                    'Jatah harian ${formatRupiah(dailyAllowance)}',
                    style: AppTypography.bodyMedium.copyWith(color: muted),
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  if (showPace) ...[
                    _PaceBar(
                      spent: spentFraction,
                      cycle: cycleFraction,
                      track: c.bgHeroOverlay,
                      fill: onHero,
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    Text(_paceText, style: AppTypography.labelSmall.copyWith(color: muted)),
                    const SizedBox(height: AppSpacing.s16),
                  ],
                  _Pill(
                    color: c.bgHeroOverlay,
                    radius: AppRadius.md,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s12,
                      vertical: AppSpacing.s8,
                    ),
                    child: Row(
                      children: [
                        Icon(AppIcons.shieldCheck, size: 18, color: c.iconOnHero),
                        const SizedBox(width: AppSpacing.s8),
                        Expanded(
                          child: Text(
                            '${formatRupiahCompact(protectedAmount)} diamankan untuk '
                            '$protectedCount kewajiban',
                            style: AppTypography.labelMedium.copyWith(color: onHero),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.color,
    required this.child,
    this.radius = AppRadius.full,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.s8, vertical: AppSpacing.s2),
  });

  final Color color;
  final Widget child;
  final double radius;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(radius)),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _PaceBar extends StatelessWidget {
  const _PaceBar({
    required this.spent,
    required this.cycle,
    required this.track,
    required this.fill,
  });

  final double spent;
  final double cycle;
  final Color track;
  final Color fill;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 14,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          // Frame pertama di Android bisa berlebar 0; batas atas clamp tidak
          // boleh di bawah batas bawah, jadi minimal 0.
          final markerMaxLeft = width > 2 ? width - 2 : 0.0;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 3,
                height: 8,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: track,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 3,
                height: 8,
                width: width * spent.clamp(0.0, 1.0),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: fill,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
              ),
              Positioned(
                left: (width * cycle.clamp(0.0, 1.0) - 1).clamp(0.0, markerMaxLeft),
                top: 0,
                width: 2,
                height: 14,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: fill.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
