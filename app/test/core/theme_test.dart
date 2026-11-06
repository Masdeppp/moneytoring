import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keuangan_app/core/model/enums.dart';
import 'package:keuangan_app/core/theme/app_colors.dart';
import 'package:keuangan_app/core/theme/app_theme.dart';

void main() {
  test('Light dan Dark memakai token dari DESIGN.md', () {
    final light = AppTheme.light();
    final dark = AppTheme.dark();

    expect(light.extension<AppColors>(), same(AppColors.light));
    expect(dark.extension<AppColors>(), same(AppColors.dark));

    // bg/canvas: neutral/50 vs neutral/950
    expect(light.scaffoldBackgroundColor, const Color(0xFFF6F8F7));
    expect(dark.scaffoldBackgroundColor, const Color(0xFF0C100F));

    // bg/brand: brand/600 vs brand/400
    expect(light.colorScheme.primary, const Color(0xFF0A8763));
    expect(dark.colorScheme.primary, const Color(0xFF2CC290));
    expect(dark.brightness, Brightness.dark);
  });

  test('setiap tone punya pasangan warna di Light dan Dark', () {
    for (final tone in Tone.values) {
      expect(AppColors.light.tones, contains(tone));
      expect(AppColors.dark.tones, contains(tone));
    }
  });

  test('warna kartu hero mengikuti tingkat risiko', () {
    const c = AppColors.light;
    expect(c.heroFor(RiskLevel.safe), const Color(0xFF0D5643));
    expect(c.heroFor(RiskLevel.warning), const Color(0xFF9E6106));
    expect(c.heroFor(RiskLevel.danger), const Color(0xFFA1252C));
  });

  test('lerp di t=0 dan t=1 sama dengan ujung-ujungnya', () {
    final start = AppColors.light.lerp(AppColors.dark, 0);
    final end = AppColors.light.lerp(AppColors.dark, 1);

    expect(start.bgCanvas, AppColors.light.bgCanvas);
    expect(end.bgCanvas, AppColors.dark.bgCanvas);
    expect(end.tone(Tone.amber), AppColors.dark.tone(Tone.amber));
  });
}
