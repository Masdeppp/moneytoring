import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/model/enums.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/list_items.dart';
import '../../../core/widgets/status_widgets.dart';
import '../../../data/db/app_database.dart';
import '../../../data/providers.dart';
import '../../../data/repositories/obligation_repository.dart';
import '../../../engine/common/local_date.dart';
import '../../../engine/cycle/pay_cycle.dart';
import '../../onboarding/application/onboarding_draft.dart';
import '../../onboarding/presentation/obligation_editor_sheet.dart';
import '../application/obligation_service.dart';
import '../application/obligation_timeline.dart';
import 'payment_sheet.dart';

/// Layar Kewajiban (DESIGN.md layar 08): progres siklus, jatuh tempo yang
/// terlambat, akan datang, dan lunas, lalu daftar semua kewajiban.
///
/// Ketuk jatuh tempo yang belum lunas untuk mencatat pembayarannya; ketuk
/// kewajiban (atau yang sudah lunas) untuk mengubah atau menghapusnya.
class ObligationsScreen extends ConsumerWidget {
  const ObligationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(cycleObligationsProvider);
    final today = LocalDate.fromDateTime(ref.watch(clockProvider)());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kewajiban'),
        actions: [
          IconButton(
            tooltip: 'Tambah kewajiban',
            onPressed: () => unawaited(_editObligation(context, ref)),
            icon: const Icon(AppIcons.plus),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.s8,
          AppSpacing.screen,
          AppSpacing.s32,
        ),
        children: switch (data) {
          AsyncData(:final value?) => _content(
            context,
            ref,
            ObligationTimeline(value.dues, cycle: value.cycle, today: today),
            value.cycle,
            today,
          ),
          AsyncError() => const [EmptyNote('Kewajiban gagal dimuat. Coba buka lagi layar ini.')],
          _ => const [SizedBox(height: 160)],
        },
      ),
    );
  }

  List<Widget> _content(
    BuildContext context,
    WidgetRef ref,
    ObligationTimeline timeline,
    PayCycle cycle,
    LocalDate today,
  ) {
    final categories = {
      for (final c in ref.watch(allCategoriesProvider).value ?? const <CategoryRecord>[]) c.id: c,
    };
    final obligations = ref.watch(activeObligationsProvider).value ?? const <ObligationRecord>[];
    final unrecorded = timeline.unrecorded;

    ObligationListItem dueItem(ObligationDueView due) => _dueItem(
      due,
      categories[due.categoryId],
      today,
      onTap: switch (due.status) {
        ObligationStatus.paid || ObligationStatus.skipped => () {
          final obligation = obligations.where((o) => o.id == due.obligationId).firstOrNull;
          if (obligation != null) unawaited(_editObligation(context, ref, existing: obligation));
        },
        _ => () => unawaited(showObligationPaymentSheet(context, due)),
      },
    );

    return [
      if (timeline.count > 0) _ProgressCard(timeline: timeline, cycle: cycle),
      if (unrecorded != null) ...[
        const SizedBox(height: AppSpacing.s16),
        AlertBanner(
          tone: AlertTone.warning,
          title: '${unrecorded.obligationName} sudah dibayar?',
          body:
              'Lewat ${today.differenceInDays(unrecorded.dueDate)} hari dari jatuh tempo dan '
              'belum ada transaksi yang cocok.',
          actionLabel: 'Tandai lunas',
          onAction: () => unawaited(showObligationPaymentSheet(context, unrecorded)),
        ),
      ],
      if (obligations.isEmpty && timeline.isEmpty)
        const EmptyNote(
          'Belum ada kewajiban rutin. Ketuk + untuk menambah kos, cicilan, atau tagihan.',
        )
      else if (timeline.isEmpty)
        const EmptyNote('Tidak ada jatuh tempo di siklus ini.'),
      _Group(title: 'Terlambat', children: [for (final due in timeline.late) dueItem(due)]),
      _Group(title: 'Akan datang', children: [for (final due in timeline.upcoming) dueItem(due)]),
      _Group(title: 'Lunas', children: [for (final due in timeline.done) dueItem(due)]),
      _Group(
        title: 'Semua kewajiban',
        children: [
          for (final obligation in obligations)
            _obligationItem(
              obligation,
              categories[obligation.categoryId],
              onTap: () => unawaited(_editObligation(context, ref, existing: obligation)),
            ),
        ],
      ),
    ];
  }

  static ObligationListItem _dueItem(
    ObligationDueView due,
    CategoryRecord? category,
    LocalDate today, {
    required VoidCallback onTap,
  }) {
    final estimated = due.amountType == ObligationAmountType.estimated;
    final open = '${estimated ? '±' : ''}${formatRupiah(due.remaining)}';
    final (String text, String amount, Widget? badge) = switch (due.status) {
      ObligationStatus.paid => (
        _paidText(due),
        formatRupiah(due.paidAmount > 0 ? due.paidAmount : due.instance.expectedAmount),
        const AppBadge(label: 'Lunas', tone: BadgeTone.success),
      ),
      ObligationStatus.skipped => (
        'Dilewati · ${formatDayMonth(due.dueDate)}',
        formatRupiah(due.instance.expectedAmount),
        const AppBadge(label: 'Dilewati'),
      ),
      _ when due.dueDate < today => (
        'Jatuh tempo ${formatDue(due.dueDate, today)}',
        open,
        const AppBadge(label: 'Terlambat', tone: BadgeTone.danger),
      ),
      _ => (
        formatDue(due.dueDate, today),
        open,
        due.paidAmount > 0 ? const AppBadge(label: 'Dicicil') : null,
      ),
    };
    return ObligationListItem(
      name: due.obligationName,
      due: text,
      amount: amount,
      icon: AppIcons.named(category?.icon ?? 'ellipsis'),
      tone: category?.tone ?? Tone.neutral,
      badge: badge,
      onTap: onTap,
    );
  }

  /// "Dibayar 3 Nov · BCA".
  static String _paidText(ObligationDueView due) {
    final paidAt = due.lastPaidAt;
    if (paidAt == null) return 'Lunas · ${formatDayMonth(due.dueDate)}';
    final account = due.lastPaidAccountName;
    return 'Dibayar ${formatDayMonth(LocalDate.fromDateTime(paidAt.toLocal()))}'
        '${account == null ? '' : ' · $account'}';
  }

  static ObligationListItem _obligationItem(
    ObligationRecord obligation,
    CategoryRecord? category, {
    required VoidCallback onTap,
  }) {
    final estimated = obligation.amountType == ObligationAmountType.estimated;
    return ObligationListItem(
      name: obligation.name,
      due: 'Tiap tanggal ${obligation.dueDay}',
      amount: '${estimated ? '±' : ''}${formatRupiah(obligation.amount)}',
      icon: AppIcons.named(category?.icon ?? 'ellipsis'),
      tone: category?.tone ?? Tone.neutral,
      onTap: onTap,
    );
  }

  /// Tambah ([existing] kosong) atau ubah/hapus kewajiban lewat editor yang
  /// sama dengan onboarding.
  Future<void> _editObligation(
    BuildContext context,
    WidgetRef ref, {
    ObligationRecord? existing,
  }) async {
    // Kategori yang diarsipkan dari Pengaturan tetap bisa dipilih oleh
    // kewajiban yang sudah memakainya, supaya mengubah nominal tidak diam-diam
    // memindahkan kategorinya.
    final categories = [
      for (final c in ref.read(allCategoriesProvider).value ?? const <CategoryRecord>[])
        if (c.type == CategoryType.expense && (!c.archived || c.id == existing?.categoryId)) c,
    ];
    final byId = {for (final c in categories) c.id: c};
    final defaultDueDay = ref.read(currentCycleProvider).value?.nextPayday.day ?? 1;
    final initial = existing == null
        ? ObligationDraft(
            name: '',
            amount: 0,
            dueDay: defaultDueDay,
            categoryName: fallbackObligationCategory,
          )
        : ObligationDraft(
            name: existing.name,
            amount: existing.amount,
            dueDay: existing.dueDay,
            categoryName: byId[existing.categoryId]?.name ?? fallbackObligationCategory,
            amountType: existing.amountType,
          );
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    final result = await showObligationEditor(
      context,
      initial: initial,
      isNew: existing == null,
      categories: categories,
    );
    if (result == null || !context.mounted) return;

    final service = ref.read(obligationServiceProvider);
    final today = LocalDate.fromDateTime(ref.read(clockProvider)());
    String message;
    try {
      switch (result) {
        case ObligationSaved(:final obligation):
          // "Lainnya" bisa saja sudah diganti nama atau diarsipkan.
          final category =
              categories.where((c) => c.name == obligation.categoryName).firstOrNull ??
              categories.where((c) => c.name == fallbackObligationCategory).firstOrNull ??
              categories.first;
          final input = (
            name: obligation.name,
            amountType: obligation.amountType,
            amount: obligation.amount,
            dueDay: obligation.dueDay,
            categoryId: category.id,
          );
          if (existing == null) {
            await service.create(input, today: today);
            message = '${obligation.name} ditambahkan.';
          } else {
            await service.update(existing.id, input, today: today);
            message = 'Perubahan ${obligation.name} disimpan.';
          }
        case ObligationDeleted():
          if (existing == null || !await _confirmDelete(context, existing.name)) return;
          await service.delete(existing.id);
          message = '${existing.name} dihapus.';
      }
    } on Object catch (error, stackTrace) {
      debugPrint('Kewajiban gagal disimpan: $error\n$stackTrace');
      message = 'Belum tersimpan. Coba sekali lagi.';
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<bool> _confirmDelete(BuildContext context, String name) async {
    if (!context.mounted) return false;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus $name?'),
        content: const Text(
          'Jatuh temponya tidak lagi dicadangkan. Riwayat pembayarannya tetap ada di Transaksi.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );
    return confirmed ?? false;
  }
}

/// "2 dari 6 lunas", total per siklus, bar progres, sudah dibayar, dan sisa
/// yang dicadangkan sampai gajian (Figma `CycleProgress`).
class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.timeline, required this.cycle});

  final ObligationTimeline timeline;
  final PayCycle cycle;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    const tabular = [FontFeature.tabularFigures()];
    final fraction = timeline.count == 0 ? 0.0 : timeline.paidCount / timeline.count;

    Widget row(String label, String value, {Color? valueColor}) => MergeSemantics(
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: AppTypography.bodyMedium.copyWith(color: c.textSecondary)),
          ),
          Text(
            value,
            style: AppTypography.titleSmall.copyWith(
              color: valueColor ?? c.textPrimary,
              fontFeatures: tabular,
            ),
          ),
        ],
      ),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Siklus ${formatDateRange(cycle.start, cycle.end)}',
              style: AppTypography.labelMedium.copyWith(color: c.textTertiary),
            ),
            const SizedBox(height: AppSpacing.s12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${timeline.paidCount} dari ${timeline.count} lunas',
                    style: AppTypography.titleMedium.copyWith(color: c.textPrimary),
                  ),
                ),
                Text(
                  '${formatRupiah(timeline.perCycle)} / siklus',
                  style: AppTypography.labelMedium.copyWith(
                    color: c.textTertiary,
                    fontFeatures: tabular,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s12),
            Semantics(
              label: 'Progres kewajiban lunas',
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
            row('Sudah dibayar', formatRupiah(timeline.paid), valueColor: c.textIncome),
            const SizedBox(height: AppSpacing.s8),
            row('Sisa sampai gajian', formatRupiah(timeline.remaining)),
          ],
        ),
      ),
    );
  }
}

/// Judul kelompok dengan jumlahnya ("TERLAMBAT 1"), lalu kartu berisi
/// barisnya. Tidak tampil kalau kosong.
class _Group extends StatelessWidget {
  const _Group({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    final style = AppTypography.overline.copyWith(color: context.colors.textTertiary);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.s24, bottom: AppSpacing.s8),
          child: Row(
            children: [
              Expanded(
                child: Semantics(header: true, child: Text(title.toUpperCase(), style: style)),
              ),
              Text('${children.length}', style: style),
            ],
          ),
        ),
        ListCard(children: children),
      ],
    );
  }
}
