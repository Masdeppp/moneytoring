import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/model/account_type_defaults.dart';
import '../../../core/model/enums.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/list_items.dart';
import '../../../core/widgets/status_widgets.dart';
import '../../../data/db/app_database.dart';
import '../../../data/providers.dart';
import '../../../data/repositories/account_repository.dart';
import '../../../data/repositories/savings_repository.dart';
import '../../../engine/common/local_date.dart';
import '../../../engine/safe_to_spend/savings_goal.dart';
import 'account_sheet.dart';
import 'pay_cycle_sheet.dart';
import 'salary_share_sheet.dart';
import 'savings_goal_detail_sheet.dart';
import 'savings_goal_sheet.dart';
import 'settings_widgets.dart';

typedef _GoalEntry = ({SavingsGoalProgress goal, SavingsGoalPlan plan});

/// Pengaturan: siklus gajian, akun, target tabungan, dan kategori.
///
/// Dibuka dari ikon roda gigi di Beranda. Tiap baris membuka sheet untuk
/// mengubahnya; kategori punya layarnya sendiri.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(payCycleConfigProvider).value;
    final cycle = ref.watch(currentCycleProvider).value;
    final accounts = ref.watch(accountBalancesProvider);
    final goals = ref.watch(savingsGoalsProvider);
    final categories = ref.watch(activeCategoriesProvider).value ?? const <CategoryRecord>[];
    final today = LocalDate.fromDateTime(ref.watch(clockProvider)());

    final accountList = accounts.value ?? const <AccountBalance>[];
    // "Sisa gaji" paling atas, lalu target buatan pengguna.
    final goalList = [
      for (final entry in goals.value ?? const <_GoalEntry>[])
        if (entry.goal.isSalaryShare) entry,
      for (final entry in goals.value ?? const <_GoalEntry>[])
        if (!entry.goal.isSalaryShare) entry,
    ];
    final salaryBasisPoints =
        goalList
            .where((entry) => entry.goal.isSalaryShare)
            .firstOrNull
            ?.goal
            .goal
            .salaryBasisPoints ??
        0;
    final expenseCount = categories.where((c) => c.type == CategoryType.expense).length;

    void addGoal() => unawaited(showSavingsGoalEditor(context));
    void editPayCycle(PayCycleConfigRecord config) =>
        unawaited(showPayCycleSheet(context, config, salaryBasisPoints: salaryBasisPoints));

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, AppSpacing.s32),
        children: [
          if (config != null)
            SettingsGroup(
              title: 'Siklus gajian',
              children: [
                SettingsRow(
                  icon: AppIcons.calendarCheck,
                  tone: Tone.brand,
                  title: payCycleRuleLabel(config),
                  subtitle: cycle == null
                      ? null
                      : 'Berikutnya ${formatWeekdayDayMonth(cycle.nextPayday)} · '
                            '${cycle.daysLeft(today)} hari lagi',
                  onTap: () => editPayCycle(config),
                ),
                SettingsRow(
                  icon: AppIcons.named('wallet'),
                  tone: Tone.blue,
                  title: 'Perkiraan gaji',
                  subtitle: [
                    if (salaryBasisPoints > 0) 'Sisihkan ${formatBasisPoints(salaryBasisPoints)}',
                    if (config.bufferBasisPoints == 0)
                      'Tanpa dana cadangan'
                    else
                      'Dana cadangan ${formatBasisPoints(config.bufferBasisPoints)}',
                  ].join(' · '),
                  trailing: formatRupiah(config.expectedIncome),
                  onTap: () => editPayCycle(config),
                ),
              ],
            ),
          SettingsGroup(
            title: 'Akun',
            addTooltip: 'Tambah akun',
            onAdd: () => unawaited(showAccountSheet(context)),
            empty: accounts.hasError
                ? const EmptyNote('Akun gagal dimuat. Coba buka lagi layar ini.')
                : null,
            children: [
              for (final entry in accountList)
                SettingsRow(
                  icon: AppIcons.named(entry.account.icon),
                  tone: entry.account.tone,
                  title: entry.account.name,
                  subtitle: entry.account.includeInSafeToSpend
                      ? entry.account.type.defaultName
                      : '${entry.account.type.defaultName} · tidak dihitung',
                  trailing: formatRupiah(entry.balance),
                  onTap: () => unawaited(
                    showAccountSheet(context, entry: entry, canArchive: accountList.length > 1),
                  ),
                ),
            ],
          ),
          SettingsGroup(
            title: 'Target tabungan',
            addTooltip: 'Tambah target',
            onAdd: addGoal,
            empty: switch (goals) {
              AsyncData() => EmptyNote(
                'Belum ada target. Sisihkan uang untuk dana darurat, liburan, atau rencana '
                'besar lain; jumlahnya dikurangkan dari Safe-to-Spend.',
                actionLabel: 'Tambah target',
                onAction: addGoal,
              ),
              AsyncError() => const EmptyNote('Target gagal dimuat. Coba buka lagi layar ini.'),
              _ => null,
            },
            children: [
              for (final entry in goalList)
                SettingsRow(
                  icon: AppIcons.named(entry.goal.goal.icon),
                  tone: entry.goal.goal.tone,
                  title: entry.goal.goal.name,
                  subtitle: entry.goal.isSalaryShare ? _salaryStatus(entry) : _goalStatus(entry),
                  trailing: formatRupiah(entry.plan.saved),
                  badge: _reached(entry)
                      ? const AppBadge(label: 'Tercapai', tone: BadgeTone.success)
                      : null,
                  onTap: () => unawaited(
                    entry.goal.isSalaryShare
                        ? showSalaryShareSheet(context)
                        : showSavingsGoalDetail(context, entry.goal.goal.id),
                  ),
                ),
            ],
          ),
          SettingsGroup(
            title: 'Kategori',
            children: [
              SettingsRow(
                icon: AppIcons.tag,
                tone: Tone.neutral,
                title: 'Kategori transaksi',
                subtitle:
                    '$expenseCount pengeluaran · ${categories.length - expenseCount} pemasukan',
                chevron: true,
                onTap: () => context.push(Routes.settingsCategories),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static bool _reached(_GoalEntry entry) {
    final target = entry.goal.goal.targetAmount;
    return target != null && entry.plan.saved >= target;
  }

  static String _salaryStatus(_GoalEntry entry) {
    final basisPoints = entry.goal.goal.salaryBasisPoints ?? 0;
    return basisPoints == 0
        ? 'Tidak menyisihkan lagi'
        : 'Sisihkan ${formatBasisPoints(basisPoints)} gaji · '
              '${formatRupiah(entry.plan.need)} siklus ini';
  }

  static String _goalStatus(_GoalEntry entry) {
    final target = entry.goal.goal.targetAmount;
    if (_reached(entry)) return 'dari ${formatRupiah(target!)}';
    final due = entry.plan.dueThisCycle;
    return due > 0
        ? 'Sisihkan ${formatRupiah(due)} lagi siklus ini'
        : 'Setoran siklus ini terpenuhi';
  }
}
