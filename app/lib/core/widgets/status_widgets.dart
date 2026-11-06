import 'package:flutter/material.dart';

import '../model/enums.dart';
import '../theme/app_icons.dart';
import '../theme/app_tokens.dart';
import '../theme/app_typography.dart';
import '../theme/theme_context.dart';

enum BadgeTone { success, warning, danger, info, neutral }

/// Label kecil untuk status (DESIGN.md §4 `Badge`).
class AppBadge extends StatelessWidget {
  const AppBadge({super.key, required this.label, this.tone = BadgeTone.neutral});

  final String label;
  final BadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (bg, fg) = switch (tone) {
      BadgeTone.success => (c.bgBrandSubtle, c.textBrand),
      BadgeTone.warning => (c.bgWarningSubtle, c.textWarning),
      BadgeTone.danger => (c.bgDangerSubtle, c.textDanger),
      BadgeTone.info => (c.bgInfoSubtle, c.textInfo),
      BadgeTone.neutral => (c.bgSurfaceMuted, c.textSecondary),
    };
    return DecoratedBox(
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadius.full)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8, vertical: AppSpacing.s2),
        child: Text(label, style: AppTypography.labelMedium.copyWith(color: fg)),
      ),
    );
  }
}

/// Ikon kategori dalam kotak berwarna (DESIGN.md §4 `CategoryTile`).
class CategoryTile extends StatelessWidget {
  const CategoryTile({super.key, required this.icon, required this.tone, this.size = 40});

  final IconData icon;
  final Tone tone;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors.tone(tone);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Icon(icon, size: size * 0.5, color: colors.fg),
    );
  }
}

enum AlertTone { warning, danger, info }

/// Peringatan di dalam layar (DESIGN.md §4 `AlertBanner`), mis. alert A1
/// di bawah kartu Safe-to-Spend.
class AlertBanner extends StatelessWidget {
  const AlertBanner({
    super.key,
    required this.tone,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
  });

  final AlertTone tone;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (bg, fg, icon) = switch (tone) {
      AlertTone.warning => (c.bgWarningSubtle, c.textWarning, AppIcons.triangleAlert),
      AlertTone.danger => (c.bgDangerSubtle, c.textDanger, AppIcons.octagonAlert),
      AlertTone.info => (c.bgInfoSubtle, c.textInfo, AppIcons.info),
    };
    return Semantics(
      container: true,
      liveRegion: tone == AlertTone.danger,
      child: DecoratedBox(
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadius.lg)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: fg),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.titleSmall.copyWith(color: c.textPrimary)),
                    const SizedBox(height: AppSpacing.s4),
                    Text(body, style: AppTypography.bodySmall.copyWith(color: c.textSecondary)),
                    if (actionLabel != null) ...[
                      const SizedBox(height: AppSpacing.s8),
                      InkWell(
                        onTap: onAction,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s4),
                          child: Text(
                            actionLabel!,
                            style: AppTypography.labelLarge.copyWith(color: fg),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
