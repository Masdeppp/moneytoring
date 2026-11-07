import 'package:flutter/material.dart';

import '../../../core/model/enums.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/widgets/day_of_month_grid.dart';
import '../../../core/widgets/rupiah_field.dart';
import '../../../core/widgets/switch_row.dart';
import '../../../data/db/app_database.dart';
import '../application/onboarding_draft.dart';

sealed class ObligationEditorResult {
  const ObligationEditorResult();
}

final class ObligationSaved extends ObligationEditorResult {
  const ObligationSaved(this.obligation);

  final ObligationDraft obligation;
}

final class ObligationDeleted extends ObligationEditorResult {
  const ObligationDeleted();
}

/// Bottom sheet untuk menambah atau mengubah satu kewajiban. `null` kalau
/// ditutup tanpa menyimpan.
Future<ObligationEditorResult?> showObligationEditor(
  BuildContext context, {
  required ObligationDraft initial,
  required bool isNew,
  required List<CategoryRecord> categories,
}) => showModalBottomSheet<ObligationEditorResult>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (context) => _ObligationEditor(initial: initial, isNew: isNew, categories: categories),
);

class _ObligationEditor extends StatefulWidget {
  const _ObligationEditor({required this.initial, required this.isNew, required this.categories});

  final ObligationDraft initial;
  final bool isNew;
  final List<CategoryRecord> categories;

  @override
  State<_ObligationEditor> createState() => _ObligationEditorState();
}

class _ObligationEditorState extends State<_ObligationEditor> {
  late final _name = TextEditingController(text: widget.initial.name);
  late var _draft = widget.initial;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _update(ObligationDraft draft) => setState(() => _draft = draft);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final estimated = _draft.amountType == ObligationAmountType.estimated;
    final hasName = widget.initial.name.isNotEmpty;
    Widget label(String text) =>
        Text(text, style: AppTypography.labelMedium.copyWith(color: c.textSecondary));

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenOnboarding,
          0,
          AppSpacing.screenOnboarding,
          AppSpacing.s24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.isNew ? 'Tambah kewajiban' : 'Ubah kewajiban',
              style: AppTypography.headlineSmall.copyWith(color: c.textPrimary),
            ),
            const SizedBox(height: AppSpacing.s16),
            TextField(
              controller: _name,
              autofocus: !hasName,
              maxLength: 40,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Nama kewajiban', counterText: ''),
              onChanged: (name) => _update(_draft.copyWith(name: name)),
            ),
            const SizedBox(height: AppSpacing.s16),
            RupiahField(
              label: estimated ? 'Perkiraan nominal per bulan' : 'Nominal per bulan',
              value: _draft.amount,
              autofocus: hasName && widget.initial.amount == 0,
              onChanged: (amount) => _update(_draft.copyWith(amount: amount)),
            ),
            const SizedBox(height: AppSpacing.s8),
            SwitchRow(
              title: 'Nominal berubah-ubah',
              subtitle: 'Mis. listrik atau air. Kami cadangkan sesuai perkiraanmu.',
              value: estimated,
              onChanged: (value) => _update(
                _draft.copyWith(
                  amountType: value ? ObligationAmountType.estimated : ObligationAmountType.fixed,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            label('Jatuh tempo tiap tanggal'),
            const SizedBox(height: AppSpacing.s8),
            DayOfMonthGrid(
              selected: _draft.dueDay,
              onSelected: (day) => _update(_draft.copyWith(dueDay: day)),
            ),
            if (widget.categories.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.s16),
              label('Kategori'),
              const SizedBox(height: AppSpacing.s8),
              Wrap(
                spacing: AppSpacing.s8,
                runSpacing: AppSpacing.s8,
                children: [
                  for (final category in widget.categories)
                    ChoiceChip(
                      avatar: Icon(AppIcons.named(category.icon), size: 18),
                      label: Text(category.name),
                      selected: category.name == _draft.categoryName,
                      onSelected: (_) => _update(_draft.copyWith(categoryName: category.name)),
                    ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.s24),
            FilledButton(
              onPressed: _draft.isValid
                  ? () => Navigator.pop(
                      context,
                      ObligationSaved(_draft.copyWith(name: _draft.name.trim())),
                    )
                  : null,
              child: const Text('Simpan'),
            ),
            if (!widget.isNew) ...[
              const SizedBox(height: AppSpacing.s8),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: c.textSecondary),
                onPressed: () => Navigator.pop(context, const ObligationDeleted()),
                child: const Text('Hapus kewajiban'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
