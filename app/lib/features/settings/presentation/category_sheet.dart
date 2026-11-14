import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/model/enums.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/widgets/status_widgets.dart';
import '../../../data/db/app_database.dart';
import '../../../data/providers.dart';
import 'settings_widgets.dart';

/// Nama warna kategori untuk pembaca layar dan tooltip.
String toneLabel(Tone tone) => switch (tone) {
  Tone.brand => 'Hijau',
  Tone.amber => 'Kuning',
  Tone.blue => 'Biru',
  Tone.violet => 'Ungu',
  Tone.red => 'Merah',
  Tone.neutral => 'Abu-abu',
};

/// Tambah kategori bertipe [type] ([category] kosong), atau ubah dan arsipkan
/// kategori yang ada.
///
/// [siblings] adalah kategori aktif bertipe sama, termasuk [category] sendiri.
Future<void> showCategorySheet(
  BuildContext context, {
  CategoryRecord? category,
  required CategoryType type,
  required List<CategoryRecord> siblings,
}) => showMessageSheet(
  context,
  (context) => CategorySheet(category: category, type: type, siblings: siblings),
);

class CategorySheet extends ConsumerStatefulWidget {
  const CategorySheet({super.key, this.category, required this.type, required this.siblings});

  final CategoryRecord? category;
  final CategoryType type;
  final List<CategoryRecord> siblings;

  @override
  ConsumerState<CategorySheet> createState() => _CategorySheetState();
}

class _CategorySheetState extends ConsumerState<CategorySheet> with SheetSaver<CategorySheet> {
  late final _name = TextEditingController(text: widget.category?.name ?? '');
  late String _icon = widget.category?.icon ?? 'ellipsis';
  late Tone _tone = widget.category?.tone ?? Tone.brand;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  /// Kewajiban dan onboarding mencari kategori lewat namanya, jadi dua
  /// kategori aktif bertipe sama tidak boleh bernama sama.
  bool get _duplicate {
    final name = _name.text.trim().toLowerCase();
    return widget.siblings.any(
      (other) => other.id != widget.category?.id && other.name.trim().toLowerCase() == name,
    );
  }

  Future<void> _save() => saveAndClose('Kategori', () async {
    final categories = ref.read(categoryRepositoryProvider);
    final name = _name.text.trim();
    final category = widget.category;
    if (category == null) {
      await categories.create(name: name, type: widget.type, icon: _icon, tone: _tone);
      return '$name ditambahkan.';
    }
    await categories.update(category.id, name: name, icon: _icon, tone: _tone);
    return 'Perubahan $name disimpan.';
  });

  Future<void> _archive(CategoryRecord category) async {
    final confirmed = await confirmAction(
      context,
      title: 'Arsipkan ${category.name}?',
      body:
          'Kategori tidak lagi muncul di pilihan. Transaksi dan kewajiban yang sudah '
          'memakainya tidak berubah.',
      confirmLabel: 'Arsipkan',
    );
    if (!confirmed || !mounted) return;
    await saveAndClose('Kategori', () async {
      await ref.read(categoryRepositoryProvider).archive(category.id);
      return '${category.name} diarsipkan.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final category = widget.category;
    final duplicate = _duplicate;
    final currentIcon = category?.icon;
    // Ikon bawaan yang tidak ada di daftar pilihan tetap bisa dipertahankan.
    final icons = [
      if (currentIcon != null && !AppIcons.categoryIconNames.contains(currentIcon)) currentIcon,
      ...AppIcons.categoryIconNames,
    ];
    return SheetBody(
      title: switch ((category, widget.type)) {
        (null, CategoryType.expense) => 'Kategori pengeluaran baru',
        (null, CategoryType.income) => 'Kategori pemasukan baru',
        _ => 'Ubah kategori',
      },
      children: [
        Row(
          children: [
            CategoryTile(icon: AppIcons.named(_icon), tone: _tone, size: 48),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: TextField(
                controller: _name,
                autofocus: category == null,
                maxLength: 40,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Nama kategori',
                  counterText: '',
                  errorText: duplicate ? 'Sudah ada kategori dengan nama ini.' : null,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s16),
        const SheetLabel('Warna'),
        Wrap(
          spacing: AppSpacing.s8,
          runSpacing: AppSpacing.s8,
          children: [
            for (final tone in Tone.values)
              _ToneChoice(
                tone: tone,
                selected: _tone == tone,
                onTap: () => setState(() => _tone = tone),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.s16),
        const SheetLabel('Ikon'),
        Wrap(
          spacing: AppSpacing.s8,
          runSpacing: AppSpacing.s8,
          children: [
            for (final name in icons)
              _IconChoice(
                name: name,
                tone: _tone,
                selected: _icon == name,
                onTap: () => setState(() => _icon = name),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.s24),
        SaveButton(
          label: 'Simpan',
          saving: saving,
          onPressed: _name.text.trim().isEmpty || duplicate ? null : () => unawaited(_save()),
        ),
        if (category != null) ...[
          const SizedBox(height: AppSpacing.s8),
          // Tiap tipe selalu punya minimal satu kategori untuk dipilih.
          if (widget.siblings.length > 1)
            TextButton(
              style: TextButton.styleFrom(foregroundColor: c.textSecondary),
              onPressed: saving ? null : () => unawaited(_archive(category)),
              child: const Text('Arsipkan kategori'),
            )
          else
            const SheetNote('Kategori terakhir tidak bisa diarsipkan.', center: true),
        ],
      ],
    );
  }
}

/// Lingkaran warna; yang terpilih bercentang.
class _ToneChoice extends StatelessWidget {
  const _ToneChoice({required this.tone, required this.selected, required this.onTap});

  final Tone tone;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors.tone(tone);
    return Semantics(
      button: true,
      selected: selected,
      child: Tooltip(
        message: toneLabel(tone),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.bg,
              border: Border.all(color: selected ? colors.fg : colors.bg, width: 2),
            ),
            child: selected ? Icon(AppIcons.check, size: 20, color: colors.fg) : null,
          ),
        ),
      ),
    );
  }
}

/// Satu pilihan ikon; yang terpilih memakai warna kategori.
class _IconChoice extends StatelessWidget {
  const _IconChoice({
    required this.name,
    required this.tone,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final Tone tone;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final colors = c.tone(tone);
    final background = selected ? colors.bg : c.bgSurfaceMuted;
    return Semantics(
      button: true,
      selected: selected,
      label: 'Ikon $name',
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: selected ? colors.fg : background, width: 2),
          ),
          child: Icon(
            AppIcons.named(name),
            size: 20,
            color: selected ? colors.fg : c.iconSecondary,
          ),
        ),
      ),
    );
  }
}
