import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';
import '../theme/app_typography.dart';
import '../theme/theme_context.dart';

/// Pilihan tanggal 1–31 dalam grid 7 kolom (Figma layar 01 `DateGrid`).
/// Dipakai untuk tanggal gajian dan tanggal jatuh tempo.
class DayOfMonthGrid extends StatelessWidget {
  const DayOfMonthGrid({super.key, required this.selected, required this.onSelected});

  final int? selected;
  final ValueChanged<int> onSelected;

  static const _columns = 7;
  static const _gap = AppSpacing.s8;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = ((constraints.maxWidth - _gap * (_columns - 1)) / _columns).floorToDouble();
        return Wrap(
          spacing: _gap,
          runSpacing: _gap,
          children: [
            for (var day = 1; day <= 31; day++)
              _DayCell(
                day: day,
                size: size,
                selected: day == selected,
                onTap: () => onSelected(day),
              ),
          ],
        );
      },
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.size,
    required this.selected,
    required this.onTap,
  });

  final int day;
  final double size;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      label: 'Tanggal $day',
      excludeSemantics: true,
      child: Material(
        color: selected ? c.bgBrand : c.bgSurface,
        shape: CircleBorder(side: selected ? BorderSide.none : BorderSide(color: c.borderDefault)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox.square(
            dimension: size,
            child: Center(
              child: Text(
                '$day',
                style: selected
                    ? AppTypography.labelLarge.copyWith(color: c.textOnBrand)
                    : AppTypography.bodyMedium.copyWith(color: c.textPrimary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
