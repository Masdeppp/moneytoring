import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/model/enums.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/status_widgets.dart';
import '../../../data/db/app_database.dart';
import '../../../data/providers.dart';
import '../application/onboarding_controller.dart';
import '../application/onboarding_draft.dart';
import 'obligation_editor_sheet.dart';
import 'onboarding_scaffold.dart';

/// Langkah 3 (Figma layar 02): kewajiban rutin dari template atau isian sendiri.
class ObligationsStep extends ConsumerWidget {
  const ObligationsStep({super.key, required this.onBack, required this.onNext});

  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final draft = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);
    final categories = ref.watch(expenseCategoriesProvider).value ?? const <CategoryRecord>[];
    CategoryRecord? categoryNamed(String name) =>
        categories.where((category) => category.name == name).firstOrNull;
    final defaultDueDay = draft.paydayRule == PaydayRule.fixedDate ? draft.payday : 1;
    final obligations = draft.obligations;

    Future<void> edit(int? index, ObligationDraft initial) async {
      final result = await showObligationEditor(
        context,
        initial: initial,
        isNew: index == null,
        categories: categories,
      );
      switch (result) {
        case ObligationSaved(:final obligation):
          if (index == null) {
            controller.addObligation(obligation);
          } else {
            controller.replaceObligation(index, obligation);
          }
        case ObligationDeleted():
          if (index != null) controller.removeObligation(index);
        case null:
          break;
      }
    }

    void openTemplate(ObligationTemplate template) {
      final index = obligations.indexWhere((o) => o.name == template.name);
      unawaited(
        index >= 0
            ? edit(index, obligations[index])
            : edit(
                null,
                ObligationDraft(
                  name: template.name,
                  amount: 0,
                  dueDay: defaultDueDay,
                  categoryName: template.categoryName,
                  amountType: template.amountType,
                ),
              ),
      );
    }

    return OnboardingScaffold(
      step: 3,
      onBack: onBack,
      title: 'Apa saja kewajiban rutinmu?',
      subtitle: 'Uang untuk kewajiban akan “dikunci” dulu sebelum kami menghitung jatah belanjamu.',
      sections: [
        Wrap(
          spacing: AppSpacing.s8,
          runSpacing: AppSpacing.s8,
          children: [
            for (final template in obligationTemplates)
              FilterChip(
                label: Text(template.name),
                selected: obligations.any((o) => o.name == template.name),
                onSelected: (_) => openTemplate(template),
              ),
            ActionChip(
              avatar: const Icon(AppIcons.plus, size: 18),
              label: const Text('Lainnya'),
              onPressed: () => unawaited(
                edit(
                  null,
                  ObligationDraft(
                    name: '',
                    amount: 0,
                    dueDay: defaultDueDay,
                    categoryName: fallbackObligationCategory,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (obligations.isEmpty)
          Text(
            'Ketuk kewajiban di atas, lalu isi nominal dan tanggal jatuh temponya.',
            style: AppTypography.bodySmall.copyWith(color: c.textTertiary),
          )
        else ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  'DIPILIH (${obligations.length})',
                  style: AppTypography.overline.copyWith(color: c.textTertiary),
                ),
              ),
              Text(
                'Ketuk untuk ubah',
                style: AppTypography.labelSmall.copyWith(color: c.textBrand),
              ),
            ],
          ),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (final (index, obligation) in obligations.indexed) ...[
                  if (index > 0) const Divider(indent: AppSpacing.s16 + 40 + AppSpacing.s12),
                  _ObligationRow(
                    obligation: obligation,
                    category: categoryNamed(obligation.categoryName),
                    onTap: () => unawaited(edit(index, obligation)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (obligations.isNotEmpty) ...[
            OnboardingTotalRow(
              label: 'Total kewajiban / bulan',
              value: formatRupiah(draft.monthlyObligations),
            ),
            const SizedBox(height: AppSpacing.s12),
          ],
          FilledButton(
            onPressed: obligations.isNotEmpty ? onNext : null,
            child: const Text('Lanjut'),
          ),
          if (obligations.isEmpty) ...[
            const SizedBox(height: AppSpacing.s4),
            TextButton(onPressed: onNext, child: const Text('Saya belum punya kewajiban rutin')),
          ],
        ],
      ),
    );
  }
}

/// Satu baris kewajiban (DESIGN.md §4 `ListItem/Obligation`, status Pending).
class _ObligationRow extends StatelessWidget {
  const _ObligationRow({required this.obligation, required this.category, required this.onTap});

  final ObligationDraft obligation;
  final CategoryRecord? category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final estimated = obligation.amountType == ObligationAmountType.estimated;
    final amount = formatRupiah(obligation.amount);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s12),
        child: Row(
          children: [
            CategoryTile(
              icon: AppIcons.named(category?.icon ?? 'ellipsis'),
              tone: category?.tone ?? Tone.neutral,
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    obligation.name,
                    style: AppTypography.titleSmall.copyWith(color: c.textPrimary),
                  ),
                  const SizedBox(height: AppSpacing.s2),
                  Text(
                    'Tiap tanggal ${obligation.dueDay}${estimated ? ' · estimasi' : ''}',
                    style: AppTypography.bodySmall.copyWith(color: c.textTertiary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
            Text(
              estimated ? '±$amount' : amount,
              style: AppTypography.amountMedium.copyWith(color: c.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
