@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keuangan_app/core/theme/app_theme.dart';
import 'package:keuangan_app/core/theme/app_typography.dart';
import 'package:keuangan_app/features/dev/component_gallery.dart';

// Golden = gambar referensi. Kalau tampilan sengaja diubah, perbarui dengan:
//   flutter test --update-goldens --tags golden
// Dibuat di Windows; CI (Linux) melewati tag ini karena render font berbeda.

Future<void> _loadFonts() async {
  final jakarta = FontLoader(AppTypography.fontFamily)
    ..addFont(rootBundle.load('assets/fonts/PlusJakartaSans-Variable.ttf'));
  final lucide = FontLoader('packages/lucide_icons_flutter/Lucide')
    ..addFont(rootBundle.load('packages/lucide_icons_flutter/assets/lucide.ttf'));
  await Future.wait([jakarta.load(), lucide.load()]);
}

void main() {
  setUpAll(_loadFonts);

  final themes = {'light': AppTheme.light(), 'dark': AppTheme.dark()};

  for (final MapEntry(key: name, value: theme) in themes.entries) {
    testWidgets('galeri komponen ($name)', (tester) async {
      // Lebar 360dp sesuai frame dasar Figma (DESIGN.md).
      tester.view.physicalSize = const Size(360 * 2, 2300 * 2);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme,
          home: const Scaffold(body: ComponentGalleryBody()),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(ComponentGalleryBody),
        matchesGoldenFile('goldens/component_gallery_$name.png'),
      );
    });
  }
}
