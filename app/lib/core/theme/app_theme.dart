import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_palette.dart';
import 'app_tokens.dart';
import 'app_typography.dart';

/// ThemeData Light dan Dark yang dibangun dari token DESIGN.md.
///
/// `ColorScheme` diisi dari token semantik; token khusus (hero, tone,
/// status) ada di [AppColors] dan diakses lewat `context.colors`.
abstract final class AppTheme {
  static ThemeData light() => _build(AppColors.light, Brightness.light);

  static ThemeData dark() => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors c, Brightness brightness) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: c.bgBrand,
      onPrimary: c.textOnBrand,
      primaryContainer: c.bgBrandSubtle,
      onPrimaryContainer: c.textBrand,
      secondary: c.bgBrand,
      onSecondary: c.textOnBrand,
      secondaryContainer: c.bgBrandSubtle,
      onSecondaryContainer: c.textBrand,
      tertiary: c.textInfo,
      onTertiary: c.bgSurface,
      error: c.textDanger,
      onError: c.bgSurface,
      errorContainer: c.bgDangerSubtle,
      onErrorContainer: c.textDanger,
      surface: c.bgSurface,
      onSurface: c.textPrimary,
      onSurfaceVariant: c.textSecondary,
      surfaceContainerLowest: c.bgSurface,
      surfaceContainerLow: c.bgSurface,
      surfaceContainer: c.bgSurfaceMuted,
      surfaceContainerHigh: c.bgSurfaceRaised,
      surfaceContainerHighest: c.bgSurfaceMuted,
      outline: c.borderStrong,
      outlineVariant: c.borderDefault,
      shadow: Palette.neutral950,
      scrim: c.bgScrim,
      inverseSurface: c.textPrimary,
      onInverseSurface: c.bgSurface,
      inversePrimary: c.textBrand,
      surfaceTint: Colors.transparent,
    );

    final textTheme = AppTypography.textTheme(primary: c.textPrimary, secondary: c.textSecondary);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: AppTypography.fontFamily,
      textTheme: textTheme,
      scaffoldBackgroundColor: c.bgCanvas,
      canvasColor: c.bgCanvas,
      extensions: [c],
      iconTheme: IconThemeData(color: c.iconPrimary, size: 24),
      dividerTheme: DividerThemeData(color: c.borderDefault, thickness: 1, space: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: c.bgCanvas,
        foregroundColor: c.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.headlineSmall.copyWith(color: c.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: c.bgSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: c.borderDefault),
        ),
      ),
      // Ukuran Large (52dp) sebagai default; Medium (40dp) lewat style lokal.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
          shape: const StadiumBorder(),
          textStyle: AppTypography.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
          shape: const StadiumBorder(),
          side: BorderSide(color: c.borderStrong),
          foregroundColor: c.textPrimary,
          textStyle: AppTypography.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.textBrand,
          shape: const StadiumBorder(),
          textStyle: AppTypography.labelLarge,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.bgBrand,
        foregroundColor: c.iconOnBrand,
        elevation: 4,
        highlightElevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 80,
        elevation: 0,
        backgroundColor: c.bgSurface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: c.bgBrandSubtle,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => AppTypography.labelSmall.copyWith(
            color: states.contains(WidgetState.selected) ? c.textPrimary : c.textTertiary,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected) ? c.textBrand : c.iconSecondary,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.bgSurface,
        selectedColor: c.bgBrandSubtle,
        disabledColor: c.bgSurfaceMuted,
        showCheckmark: false,
        shape: const StadiumBorder(),
        side: WidgetStateBorderSide.resolveWith(
          (states) => BorderSide(
            color: states.contains(WidgetState.selected) ? c.borderFocus : c.borderStrong,
          ),
        ),
        labelStyle: AppTypography.labelLarge.copyWith(color: c.textPrimary),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: AppSpacing.s8),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: c.bgSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: AppSpacing.s12,
        ),
        hintStyle: AppTypography.bodyLarge.copyWith(color: c.textTertiary),
        labelStyle: AppTypography.labelMedium.copyWith(color: c.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: c.borderStrong),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: c.borderStrong),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: c.borderFocus, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: c.textDanger),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.bgSurfaceRaised,
        modalBackgroundColor: c.bgSurfaceRaised,
        surfaceTintColor: Colors.transparent,
        modalBarrierColor: c.bgScrim,
        showDragHandle: true,
        dragHandleColor: c.borderStrong,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.bgSurfaceRaised,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.textPrimary,
        contentTextStyle: AppTypography.bodyMedium.copyWith(color: c.bgSurface),
        actionTextColor: c.bgBrandSubtle,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.bgBrand,
        linearTrackColor: c.bgSurfaceMuted,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: c.iconPrimary,
        titleTextStyle: AppTypography.titleSmall.copyWith(color: c.textPrimary),
        subtitleTextStyle: AppTypography.bodySmall.copyWith(color: c.textTertiary),
      ),
    );
  }
}
