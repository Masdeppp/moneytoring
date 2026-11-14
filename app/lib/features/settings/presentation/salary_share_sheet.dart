import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/money.dart';
import '../../../data/db/app_database.dart';
import '../../../data/providers.dart';
import '../../../engine/common/local_date.dart';
import 'pay_cycle_sheet.dart';
import 'settings_widgets.dart';

sealed class _SalaryResult {
  const _SalaryResult();
}

/// Sheet ditutup setelah menyimpan; [message] tampil sebagai snackbar.
final class _Done extends _SalaryResult {
  const _Done(this.message);

  final String message;
}

/// Pengguna ingin mengubah persen; sheet Siklus gajian dibuka setelahnya.
final class _EditShare extends _SalaryResult {
  const _EditShare(this.config, this.basisPoints);

  final PayCycleConfigRecord config;
  final int basisPoints;
}

/// Target "Sisa gaji": persen gaji yang disisihkan, tabungan yang terkumpul
/// dari siklus lalu, dan riwayatnya. Tabungannya bisa dilepas supaya kembali
/// dihitung aman dibelanjakan.
Future<void> showSalaryShareSheet(BuildContext context) async {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  final result = await showModalBottomSheet<_SalaryResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => const SalaryShareSheet(),
  );
  if (result == null || !context.mounted) return;
  switch (result) {
    case _Done(:final message):
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    case _EditShare(:final config, :final basisPoints):
      await showPayCycleSheet(context, config, salaryBasisPoints: basisPoints);
  }
}

class SalaryShareSheet extends ConsumerStatefulWidget {
  const SalaryShareSheet({super.key});

  @override
  ConsumerState<SalaryShareSheet> createState() => _SalaryShareSheetState();
}

class _SalaryShareSheetState extends ConsumerState<SalaryShareSheet>
    with SheetSaver<SalaryShareSheet> {
  static const _historyLimit = 8;

  @override
  Object resultFor(String message) => _Done(message);

  Future<void> _release({GoalContributionRecord? contribution, required int amount}) async {
    final confirmed = await confirmAction(
      context,
      title: 'Lepas ${formatRupiah(amount)}?',
      body: contribution == null
          ? 'Semua tabungan Sisa gaji kembali dihitung aman dibelanjakan. Sisihan siklus '
                'ini tetap dikunci.'
          : 'Uangnya kembali dihitung aman dibelanjakan.',
      confirmLabel: 'Lepas',
    );
    if (!confirmed || !mounted) return;
    await saveAndClose('Sisa gaji', () async {
      await ref.read(salaryShareServiceProvider).release(contributionId: contribution?.id);
      return '${formatRupiah(amount)} dilepas dari Sisa gaji.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final entry = ref
        .watch(savingsGoalsProvider)
        .value
        ?.where((entry) => entry.goal.isSalaryShare)
        .firstOrNull;
    // Target baru saja dihapus; sheet sedang menutup.
    if (entry == null) return const SizedBox(height: 160);

    final (:goal, :plan) = entry;
    final record = goal.goal;
    final basisPoints = record.salaryBasisPoints ?? 0;
    final config = ref.watch(payCycleConfigProvider).value;
    final calculator = ref.watch(payCycleCalculatorProvider);
    final cycle = ref.watch(currentCycleProvider).value;
    final contributions =
        ref.watch(goalContributionsProvider(record.id)).value ?? const <GoalContributionRecord>[];
    final actionStyle = TextButton.styleFrom(foregroundColor: context.colors.textSecondary);

    // Tabungan otomatis bertanggal hari terakhir siklusnya.
    String cycleLabel(GoalContributionRecord contribution) {
      final lastDay = LocalDate.fromDateTime(contribution.date);
      if (calculator == null) return formatDayMonthYear(lastDay);
      return 'Sisa ${formatDateRange(calculator.cycleContaining(lastDay).start, lastDay)}';
    }

    return SheetBody(
      title: record.name,
      subtitle: basisPoints == 0
          ? 'Tidak lagi menyisihkan dari gaji.'
          : '${formatBasisPoints(basisPoints)} dari perkiraan gaji · '
                '${formatRupiah(plan.need)} per siklus',
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ValueRow(label: 'Terkumpul', value: formatRupiah(plan.saved)),
                const SizedBox(height: AppSpacing.s12),
                ValueRow(
                  label: cycle == null
                      ? 'Dikunci siklus ini'
                      : 'Dikunci sampai gajian ${formatDayMonth(cycle.nextPayday)}',
                  value: formatRupiah(plan.need),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s8),
        const SheetNote(
          'Saat gajian, sisihan yang benar-benar tersisa (setelah kewajiban dan target lain) '
          'otomatis ditabung di sini dan tetap tidak dihitung aman dibelanjakan.',
        ),
        if (contributions.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.s24),
          const SheetLabel('Riwayat'),
          for (final contribution in contributions.take(_historyLimit))
            HistoryRow(
              label: cycleLabel(contribution),
              amount: contribution.amount,
              deleteTooltip: 'Lepas tabungan ini',
              onDelete: saving
                  ? null
                  : () => unawaited(
                      _release(contribution: contribution, amount: contribution.amount),
                    ),
            ),
          if (contributions.length > _historyLimit)
            SheetNote('dan ${contributions.length - _historyLimit} siklus lebih lama'),
        ],
        const SizedBox(height: AppSpacing.s16),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSpacing.s8,
          children: [
            if (config != null)
              TextButton(
                style: actionStyle,
                onPressed: saving
                    ? null
                    : () => Navigator.pop(context, _EditShare(config, basisPoints)),
                child: const Text('Ubah persen'),
              ),
            if (plan.saved > 0)
              TextButton(
                style: actionStyle,
                onPressed: saving ? null : () => unawaited(_release(amount: plan.saved)),
                child: const Text('Lepas semua'),
              ),
          ],
        ),
      ],
    );
  }
}
