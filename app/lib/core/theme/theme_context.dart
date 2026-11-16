import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';

/// Jalan pintas ke token desain: `context.colors.bgHeroSafe`.
extension ThemeContextX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;

  TextTheme get textStyles => Theme.of(this).textTheme;
}
