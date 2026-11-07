import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';
import '../theme/app_typography.dart';
import '../theme/theme_context.dart';

/// Judul + keterangan + switch dalam satu baris (Figma layar 01 `HolidayShift`).
/// Seluruh baris bisa diketuk, dan dibaca screen reader sebagai satu kontrol.
class SwitchRow extends StatelessWidget {
  const SwitchRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return MergeSemantics(
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s4),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.titleSmall.copyWith(color: c.textPrimary)),
                    const SizedBox(height: AppSpacing.s2),
                    Text(subtitle, style: AppTypography.bodySmall.copyWith(color: c.textTertiary)),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Switch(
                value: value,
                onChanged: onChanged,
                activeTrackColor: c.bgBrand,
                activeThumbColor: c.bgSurface,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
