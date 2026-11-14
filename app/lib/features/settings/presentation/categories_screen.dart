import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/model/enums.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/list_items.dart';
import '../../../data/db/app_database.dart';
import '../../../data/providers.dart';
import 'category_sheet.dart';
import 'settings_widgets.dart';

/// Pengaturan → Kategori: kategori pengeluaran dan pemasukan yang aktif.
/// Ketuk untuk mengubah nama, ikon, dan warnanya, atau mengarsipkannya.
class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(activeCategoriesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Kategori')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, AppSpacing.s32),
        children: switch (categories) {
          AsyncData(:final value) => [
            for (final type in const [CategoryType.expense, CategoryType.income])
              _TypeGroup(
                type: type,
                categories: [
                  for (final category in value)
                    if (category.type == type) category,
                ],
              ),
          ],
          AsyncError() => const [
            SizedBox(height: AppSpacing.s16),
            EmptyNote('Kategori gagal dimuat. Coba buka lagi layar ini.'),
          ],
          _ => const [SizedBox(height: 160)],
        },
      ),
    );
  }
}

class _TypeGroup extends StatelessWidget {
  const _TypeGroup({required this.type, required this.categories});

  final CategoryType type;
  final List<CategoryRecord> categories;

  @override
  Widget build(BuildContext context) {
    final label = type == CategoryType.expense ? 'pengeluaran' : 'pemasukan';
    return SettingsGroup(
      title: label,
      addTooltip: 'Tambah kategori $label',
      onAdd: () => unawaited(showCategorySheet(context, type: type, siblings: categories)),
      children: [
        for (final category in categories)
          SettingsRow(
            icon: AppIcons.named(category.icon),
            tone: category.tone,
            title: category.name,
            subtitle: category.isDefault ? null : 'Buatan sendiri',
            onTap: () => unawaited(
              showCategorySheet(context, category: category, type: type, siblings: categories),
            ),
          ),
      ],
    );
  }
}
