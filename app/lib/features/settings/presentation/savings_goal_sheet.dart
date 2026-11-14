import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/rupiah_field.dart';
import '../../../data/providers.dart';
import '../../../data/repositories/account_repository.dart';
import '../../../data/repositories/savings_repository.dart';
import '../../../engine/common/local_date.dart';
import '../../../engine/safe_to_spend/savings_goal.dart';
import 'settings_widgets.dart';

/// Tambah target tabungan ([goal] kosong) atau ubah yang ada.
///
/// Dua bentuk target: rutin (setoran tetap tiap siklus, nominal target
/// opsional) atau bertenggat (nominal target dibagi rata ke siklus tersisa).
Future<void> showSavingsGoalEditor(BuildContext context, {SavingsGoalProgress? goal}) =>
    showMessageSheet(context, (context) => SavingsGoalSheet(goal: goal));

class SavingsGoalSheet extends ConsumerStatefulWidget {
  const SavingsGoalSheet({super.key, this.goal});

  final SavingsGoalProgress? goal;

  @override
  ConsumerState<SavingsGoalSheet> createState() => _SavingsGoalSheetState();
}

class _SavingsGoalSheetState extends ConsumerState<SavingsGoalSheet>
    with SheetSaver<SavingsGoalSheet> {
  late final _name = TextEditingController(text: widget.goal?.goal.name ?? '');
  late bool _withDeadline = widget.goal?.deadline != null;
  late int _target = widget.goal?.goal.targetAmount ?? 0;
  late LocalDate? _deadline = widget.goal?.deadline;
  late int _perCycle = widget.goal?.goal.amountPerCycle ?? 0;
  late int? _accountId = widget.goal?.goal.accountId;

  LocalDate get _today => LocalDate.fromDateTime(ref.read(clockProvider)());

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  bool get _valid {
    if (_name.text.trim().isEmpty) return false;
    return _withDeadline ? _target > 0 && _deadline != null : _perCycle > 0;
  }

  /// Kebutuhan per siklus target bertenggat, begitu nominal dan tenggatnya
  /// terisi.
  String? _deadlinePreview() {
    final deadline = _deadline;
    final calculator = ref.watch(payCycleCalculatorProvider);
    if (!_withDeadline || deadline == null || _target <= 0 || calculator == null) return null;
    final cycles = cyclesUntil(calculator, calculator.cycleContaining(_today), deadline);
    final plan = planSavingsGoal(
      target: _target,
      cyclesLeft: cycles,
      savedBeforeCycle: widget.goal?.savedBeforeCycle ?? 0,
      savedThisCycle: widget.goal?.savedThisCycle ?? 0,
      keptInSafeToSpend: true,
    );
    return 'Perlu disisihkan ${formatRupiah(plan.need)} per siklus selama $cycles siklus.';
  }

  Future<void> _pickDeadline() async {
    final today = _today;
    final current = _deadline;
    final picked = await showDatePicker(
      context: context,
      // Tenggat lama yang sudah lewat tidak bisa jadi tanggal awal pemilih.
      initialDate: (current != null && current > today ? current : today.addDays(180)).toDateTime(),
      firstDate: today.addDays(1).toDateTime(),
      lastDate: LocalDate(today.year + 30, 12, 31).toDateTime(),
    );
    if (picked != null) setState(() => _deadline = LocalDate.fromDateTime(picked));
  }

  Future<void> _save() => saveAndClose('Target tabungan', () async {
    final savings = ref.read(savingsRepositoryProvider);
    final name = _name.text.trim();
    final SavingsGoalInput input = (
      name: name,
      targetAmount: _target > 0 ? _target : null,
      deadline: _withDeadline ? _deadline : null,
      amountPerCycle: _withDeadline ? null : _perCycle,
      accountId: _accountId,
    );
    final goal = widget.goal;
    if (goal == null) {
      await savings.create(input);
      return 'Target $name ditambahkan.';
    }
    await savings.update(goal.goal.id, input);
    return 'Perubahan $name disimpan.';
  });

  @override
  Widget build(BuildContext context) {
    final goal = widget.goal;
    final deadline = _deadline;
    final preview = _deadlinePreview();
    final accounts = ref.watch(accountBalancesProvider).value ?? const <AccountBalance>[];
    // Rekening tujuan harus di luar Safe-to-Spend, supaya setorannya benar-benar
    // keluar dari uang harian. Rekening yang sudah dipakai target ini tetap
    // tampil walau sekarang ikut dihitung.
    final savingsAccounts = [
      for (final entry in accounts)
        if (!entry.account.includeInSafeToSpend || entry.account.id == goal?.goal.accountId) entry,
    ];

    return SheetBody(
      title: goal == null ? 'Target tabungan baru' : 'Ubah target',
      subtitle: 'Jumlah yang disisihkan tiap siklus dikurangkan dari Safe-to-Spend.',
      children: [
        TextField(
          controller: _name,
          autofocus: goal == null,
          maxLength: 40,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Nama target',
            hintText: 'mis. Dana darurat',
            counterText: '',
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.s16),
        Wrap(
          spacing: AppSpacing.s8,
          runSpacing: AppSpacing.s8,
          children: [
            ChoiceChip(
              label: const Text('Rutin tiap siklus'),
              selected: !_withDeadline,
              onSelected: (_) => setState(() => _withDeadline = false),
            ),
            ChoiceChip(
              label: const Text('Sampai tenggat'),
              selected: _withDeadline,
              onSelected: (_) => setState(() => _withDeadline = true),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s16),
        if (_withDeadline) ...[
          RupiahField(
            key: const ValueKey('target'),
            label: 'Nominal target',
            value: _target,
            onChanged: (value) => setState(() => _target = value),
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: AppSpacing.s12),
          Align(
            alignment: Alignment.centerLeft,
            child: ActionChip(
              avatar: const Icon(AppIcons.calendar, size: 18),
              label: Text(
                deadline == null ? 'Pilih tenggat' : 'Tenggat ${formatDayMonthYear(deadline)}',
              ),
              onPressed: () => unawaited(_pickDeadline()),
            ),
          ),
          if (preview != null) ...[const SizedBox(height: AppSpacing.s8), SheetNote(preview)],
        ] else ...[
          RupiahField(
            key: const ValueKey('perCycle'),
            label: 'Setoran per siklus',
            value: _perCycle,
            onChanged: (value) => setState(() => _perCycle = value),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.s16),
          RupiahField(
            key: const ValueKey('target'),
            label: 'Nominal target (opsional)',
            value: _target,
            onChanged: (value) => setState(() => _target = value),
            textInputAction: TextInputAction.done,
          ),
        ],
        const SizedBox(height: AppSpacing.s16),
        const SheetLabel('Disimpan di'),
        Wrap(
          spacing: AppSpacing.s8,
          runSpacing: AppSpacing.s8,
          children: [
            ChoiceChip(
              label: const Text('Tetap di akun harian'),
              selected: _accountId == null,
              onSelected: (_) => setState(() => _accountId = null),
            ),
            for (final entry in savingsAccounts)
              ChoiceChip(
                avatar: Icon(AppIcons.named(entry.account.icon), size: 18),
                label: Text(entry.account.name),
                selected: _accountId == entry.account.id,
                onSelected: (_) => setState(() => _accountId = entry.account.id),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.s8),
        SheetNote(switch ((_accountId, savingsAccounts.isEmpty)) {
          (null, true) =>
            'Punya rekening tabungan terpisah? Tambahkan sebagai akun dengan "Hitung di '
                'Safe-to-Spend" dimatikan, lalu pilih di sini.',
          (null, false) => 'Uangnya tetap di akun harian dan dikurangkan dari Safe-to-Spend.',
          _ => 'Tiap setoran bisa dicatat sebagai transfer ke akun ini.',
        }),
        const SizedBox(height: AppSpacing.s24),
        SaveButton(
          label: 'Simpan',
          saving: saving,
          onPressed: _valid ? () => unawaited(_save()) : null,
        ),
      ],
    );
  }
}
