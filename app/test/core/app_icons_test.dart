import 'package:flutter_test/flutter_test.dart';
import 'package:keuangan_app/core/theme/app_icons.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

void main() {
  test('semua ikon pilihan kategori dikenal dan tidak ada yang kembar', () {
    const names = AppIcons.categoryIconNames;
    for (final name in names) {
      expect(AppIcons.named(name), isNot(LucideIcons.circle), reason: name);
    }
    expect(names.toSet(), hasLength(names.length));
  });

  test('nama ikon yang tidak dikenal memakai lingkaran', () {
    expect(AppIcons.named('tidak-ada'), LucideIcons.circle);
  });
}
