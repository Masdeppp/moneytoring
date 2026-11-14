import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/rupiah_field.dart';
import '../../../data/db/app_database.dart';
import '../../../data/providers.dart';
import '../../../data/repositories/account_repository.dart';
import '../../../data/repositories/savings_repository.dart';
import '../../../engine/common/local_date.dart';
import '../../../engine/safe_to_spend/savings_goal.dart';
import 'savings_goal_sheet.dart';
import 'settings_widgets.dart';

sealed class _DetailResult {
  const _DetailResult();
}

/// Sheet ditutup setelah menyimpan; [message] tampil sebagai snackbar.
final class _Done extends _DetailResult {
  const _Done(this.message);

  final String message;
}

/// Pengguna memilih mengubah target; editornya dibuka setelah sheet tertutup.
final class _Edit extends _DetailResult {
  const _Edit(this.goal);

  final SavingsGoalProgress goal;
}

/// Detail satu target tabungan: progres, setor, riwayat setoran, lalu ubah,
/// tandai selesai, atau hapus.
Future<void> showSavingsGoalDetail(BuildContext context, int goalId) async {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  final result = await showModalBottomSheet<_DetailResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => SavingsGoalDetailSheet(goalId: goalId),
  );
  if (result == null || !context.mounted) return;
  switch (result) {
    case _Done(:final message):
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    case _Edit(:final goal):
      await showSavingsGoalEditor(context, goal: goal);
  }
}

class SavingsGoalDetailSheet extends ConsumerStatefulWidget {
  const SavingsGoalDetailSheet({super.key, required this.goalId});

  final int goalId;

  @override
  ConsumerState<SavingsGoalDetailSheet> createState() => _SavingsGoalDetailSheetState();
}

class _SavingsGoalDetailSheetState extends ConsumerState<SavingsGoalDetailSheet>
    with SheetSaver<SavingsGoalDetailSheet> {
  static const _historyLimit = 8;

  /// Nominal setoran. Selama belum diubah (`null`), isinya kekurangan setoran
  /// siklus ini.
  int? _amount;
  late LocalDate _date = _today;

  /// Akun sumber pilihan pengguna; `null` berarti uangnya sudah ada di
  /// rekening tujuan. Baru berlaku setelah [_sourceChosen].
  int? _sourceId;
  bool _sourceChosen = false;

  LocalDate get _today => LocalDate.fromDateTime(ref.read(clockProvider)());

  @override
  Object resultFor(String message) => _Done(message);

  Future<void> _pickDate() async {
    final today = _today;
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.toDateTime(),
      firstDate: today.addDays(-365).toDateTime(),
      lastDate: today.toDateTime(),
    );
    if (picked != null) setState(() => _date = LocalDate.fromDateTime(picked));
  }

  Future<void> _contribute(SavingsGoalRecord goal, int amount, int? fromAccountId) =>
      saveAndClose('Setoran', () async {
        final now = ref.read(clockProvider)();
        final date = _date;
        await ref
            .read(savingsRepositoryProvider)
            .contribute(
              goalId: goal.id,
              amount: amount,
              date: date == LocalDate.fromDateTime(now)
                  ? now
                  : DateTime(date.year, date.month, date.day, 12),
              fromAccountId: fromAccountId,
            );
        return 'Setoran ${formatRupiah(amount)} ke ${goal.name} dicatat.';
      });

  Future<void> _deleteContribution(GoalContributionRecord contribution) async {
    final confirmed = await confirmAction(
      context,
      title: 'Hapus setoran ${formatRupiah(contribution.amount)}?',
      body: contribution.transactionId == null
          ? 'Setoran ini dihapus dari catatan target.'
          : 'Transfernya ke rekening tujuan ikut dihapus.',
      confirmLabel: 'Hapus',
    );
    if (!confirmed || !mounted) return;
    try {
      await ref.read(savingsRepositoryProvider).deleteContribution(contribution.id);
    } on Object catch (error, stackTrace) {
      debugPrint('Setoran gagal dihapus: $error\n$stackTrace');
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Belum terhapus. Coba sekali lagi.')));
    }
  }

  Future<void> _finish(SavingsGoalRecord goal) async {
    final confirmed = await confirmAction(
      context,
      title: 'Tandai ${goal.name} selesai?',
      body:
          'Target tidak lagi dicadangkan dari Safe-to-Spend. Riwayat setorannya tetap '
          'tersimpan.',
      confirmLabel: 'Selesai',
    );
    if (!confirmed || !mounted) return;
    await saveAndClose('Target tabungan', () async {
      await ref.read(savingsRepositoryProvider).archive(goal.id);
      return '${goal.name} ditandai selesai.';
    });
  }

  Future<void> _delete(SavingsGoalRecord goal) async {
    final confirmed = await confirmAction(
      context,
      title: 'Hapus ${goal.name}?',
      body:
          'Target dan catatan setorannya dihapus. Transfer yang sudah tercatat tetap ada '
          'di Transaksi.',
      confirmLabel: 'Hapus',
    );
    if (!confirmed || !mounted) return;
    await saveAndClose('Target tabungan', () async {
      await ref.read(savingsRepositoryProvider).delete(goal.id);
      return '${goal.name} dihapus.';
    });
  }

  String _summary(SavingsGoalProgress goal, SavingsGoalPlan plan) {
    final deadline = goal.deadline;
    final accountName = goal.accountName;
    return [
      if (deadline != null)
        'Tenggat ${formatDayMonthYear(deadline)} · ${plan.cyclesLeft} siklus lagi'
      else
        '${formatRupiah(goal.goal.amountPerCycle ?? 0)} per siklus',
      if (accountName != null) 'disimpan di $accountName',
    ].join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final entry = ref
        .watch(savingsGoalsProvider)
        .value
        ?.where((entry) => entry.goal.goal.id == widget.goalId)
        .firstOrNull;
    // Target baru saja diarsipkan atau dihapus; sheet sedang menutup.
    if (entry == null) return const SizedBox(height: 160);

    final c = context.colors;
    final (:goal, :plan) = entry;
    final record = goal.goal;
    final accountName = goal.accountName;
    final amount = _amount ?? plan.dueThisCycle;
    final today = LocalDate.fromDateTime(ref.watch(clockProvider)());

    final accounts = ref.watch(accountBalancesProvider).value ?? const <AccountBalance>[];
    final sources = [
      for (final account in accounts)
        if (account.account.id != record.accountId) account,
    ];
    final defaultSource =
        sources.where((source) => source.account.includeInSafeToSpend).firstOrNull ??
        sources.firstOrNull;
    final sourceId = _sourceChosen ? _sourceId : defaultSource?.account.id;

    final contributions =
        ref.watch(goalContributionsProvider(widget.goalId)).value ??
        const <GoalContributionRecord>[];
    final actionStyle = TextButton.styleFrom(foregroundColor: c.textSecondary);

    return SheetBody(
      title: record.name,
      subtitle: _summary(goal, plan),
      children: [
        _ProgressCard(plan: plan, target: record.targetAmount),
        const SizedBox(height: AppSpacing.s24),
        const SheetLabel('Setoran baru'),
        RupiahField(
          value: amount,
          onChanged: (value) => setState(() => _amount = value),
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: AppSpacing.s12),
        Align(
          alignment: Alignment.centerLeft,
          child: ActionChip(
            avatar: const Icon(AppIcons.calendar, size: 18),
            label: Text(formatRelativeDay(_date, today)),
            onPressed: () => unawaited(_pickDate()),
          ),
        ),
        if (accountName != null) ...[
          const SizedBox(height: AppSpacing.s16),
          const SheetLabel('Dari akun'),
          Wrap(
            spacing: AppSpacing.s8,
            runSpacing: AppSpacing.s8,
            children: [
              for (final source in sources)
                ChoiceChip(
                  avatar: Icon(AppIcons.named(source.account.icon), size: 18),
                  label: Text(source.account.name),
                  selected: sourceId == source.account.id,
                  onSelected: (_) => setState(() {
                    _sourceChosen = true;
                    _sourceId = source.account.id;
                  }),
                ),
              ChoiceChip(
                label: Text('Sudah di $accountName'),
                selected: sourceId == null,
                onSelected: (_) => setState(() {
                  _sourceChosen = true;
                  _sourceId = null;
                }),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s8),
          SheetNote(
            sourceId == null
                ? 'Hanya dicatat sebagai setoran, tanpa transfer.'
                : 'Dicatat sebagai transfer ke $accountName.',
          ),
        ] else ...[
          const SizedBox(height: AppSpacing.s8),
          const SheetNote('Uangnya tetap di akunmu; setoran menandainya untuk target ini.'),
        ],
        const SizedBox(height: AppSpacing.s16),
        SaveButton(
          label: 'Setor',
          saving: saving,
          onPressed: amount > 0
              ? () => unawaited(_contribute(record, amount, accountName == null ? null : sourceId))
              : null,
        ),
        if (contributions.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.s24),
          const SheetLabel('Riwayat setoran'),
          for (final contribution in contributions.take(_historyLimit))
            HistoryRow(
              label: formatDayMonthYear(LocalDate.fromDateTime(contribution.date)),
              amount: contribution.amount,
              deleteTooltip: 'Hapus setoran',
              onDelete: saving ? null : () => unawaited(_deleteContribution(contribution)),
            ),
          if (contributions.length > _historyLimit)
            SheetNote('dan ${contributions.length - _historyLimit} setoran lebih lama'),
        ],
        const SizedBox(height: AppSpacing.s16),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSpacing.s8,
          children: [
            TextButton(
              style: actionStyle,
              onPressed: saving ? null : () => Navigator.pop(context, _Edit(goal)),
              child: const Text('Ubah target'),
            ),
            TextButton(
              style: actionStyle,
              onPressed: saving ? null : () => unawaited(_finish(record)),
              child: const Text('Tandai selesai'),
            ),
            TextButton(
              style: actionStyle,
              onPressed: saving ? null : () => unawaited(_delete(record)),
              child: const Text('Hapus target'),
            ),
          ],
        ),
      ],
    );
  }
}

/// Yang sudah terkumpul (dengan batang progres kalau ada nominal target) dan
/// setoran siklus ini.
class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.plan, required this.target});

  final SavingsGoalPlan plan;
  final int? target;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final target = this.target;
    final fraction = target == null || target <= 0
        ? 0.0
        : (plan.saved / target).clamp(0.0, 1.0).toDouble();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (target != null) ...[
              Semantics(
                label: 'Progres target',
                value: '${(fraction * 100).round()}%',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    height: 8,
                    child: ColoredBox(
                      color: c.bgSurfaceMuted,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: fraction,
                          heightFactor: 1,
                          child: ColoredBox(color: c.bgBrand),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s12),
            ],
            ValueRow(
              label: 'Terkumpul',
              value: target == null
                  ? formatRupiah(plan.saved)
                  : '${formatRupiah(plan.saved)} dari ${formatRupiah(target)}',
            ),
            const SizedBox(height: AppSpacing.s12),
            ValueRow(
              label: 'Disisihkan siklus ini',
              value: '${formatRupiah(plan.savedThisCycle)} dari ${formatRupiah(plan.need)}',
            ),
          ],
        ),
      ),
    );
  }
}
