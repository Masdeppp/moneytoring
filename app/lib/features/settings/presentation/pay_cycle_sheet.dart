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
import '../../../core/widgets/day_of_month_grid.dart';
import '../../../core/widgets/rupiah_field.dart';
import '../../../core/widgets/switch_row.dart';
import '../../../data/db/app_database.dart';
import '../../../data/providers.dart';
import '../../../engine/common/local_date.dart';
import '../../../engine/cycle/pay_cycle.dart';
import '../../../engine/safe_to_spend/savings_goal.dart';
import 'settings_widgets.dart';

/// Basis poin sebagai persen: `5%` atau `7,5%`.
String formatBasisPoints(int basisPoints) {
  final whole = basisPoints ~/ 100;
  final rest = basisPoints % 100;
  if (rest == 0) return '$whole%';
  final decimals = rest % 10 == 0 ? '${rest ~/ 10}' : '$rest'.padLeft(2, '0');
  return '$whole,$decimals%';
}

/// `Gajian tiap tanggal 25` atau `Gajian di hari kerja terakhir`.
String payCycleRuleLabel(PayCycleConfigRecord config) => switch (config.paydayRule) {
  PaydayRule.fixedDate => 'Gajian tiap tanggal ${config.day}',
  PaydayRule.lastWorkday => 'Gajian di hari kerja terakhir',
};

/// Ubah aturan gajian, perkiraan gaji, sisihan gaji, dan dana cadangan.
/// [salaryBasisPoints] adalah persen sisihan yang berlaku sekarang.
Future<void> showPayCycleSheet(
  BuildContext context,
  PayCycleConfigRecord config, {
  int salaryBasisPoints = 0,
}) => showMessageSheet(
  context,
  (context) => PayCycleSheet(config: config, salaryBasisPoints: salaryBasisPoints),
);

class PayCycleSheet extends ConsumerStatefulWidget {
  const PayCycleSheet({super.key, required this.config, this.salaryBasisPoints = 0});

  final PayCycleConfigRecord config;
  final int salaryBasisPoints;

  @override
  ConsumerState<PayCycleSheet> createState() => _PayCycleSheetState();
}

class _PayCycleSheetState extends ConsumerState<PayCycleSheet> with SheetSaver<PayCycleSheet> {
  static const _shareChoices = [0, 500, 1000, 1500, 2000, 2500, 3000];
  static const _bufferChoices = [0, 500, 1000, 1500, 2000];

  late PaydayRule _rule = widget.config.paydayRule;
  late int _day = widget.config.day ?? 25;
  late bool _shiftOnHoliday = widget.config.shiftOnHoliday;
  late int _income = widget.config.expectedIncome;
  late int _share = widget.salaryBasisPoints;
  late int _buffer = widget.config.bufferBasisPoints;

  PayCycleRule get _draft => switch (_rule) {
    PaydayRule.fixedDate => PayCycleRule.fixedDate(_day, shiftOnHoliday: _shiftOnHoliday),
    PaydayRule.lastWorkday => const PayCycleRule.lastWorkday(),
  };

  Future<void> _save() => saveAndClose('Siklus gajian', () async {
    final rule = _draft;
    final today = LocalDate.fromDateTime(ref.read(clockProvider)());
    final salary = ref.read(salaryShareServiceProvider);
    // Sisihan siklus yang sudah lewat ditabung dulu dengan aturan dan persen
    // lama, supaya perubahan ini hanya berlaku mulai siklus berjalan.
    await salary.settle(today);
    await ref
        .read(payCycleRepositoryProvider)
        .save(rule: rule, expectedIncome: _income, bufferBasisPoints: _buffer);
    await salary.setShare(_share, today: today);
    // Batas siklus bisa bergeser. Jatuh tempo siklus yang baru dibuat sekarang
    // supaya layar Kewajiban tidak menunggu Beranda menghitung ulang.
    await ref
        .read(obligationRepositoryProvider)
        .ensureInstances(
          calculator: PayCycleCalculator(rule, holidays: ref.read(holidayCalendarProvider)),
          today: today,
        );
    return 'Siklus gajian disimpan.';
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fixedDate = _rule == PaydayRule.fixedDate;
    final today = LocalDate.fromDateTime(ref.watch(clockProvider)());
    final cycle = PayCycleCalculator(
      _draft,
      holidays: ref.watch(holidayCalendarProvider),
    ).cycleContaining(today);
    // Nilai tersimpan yang bukan salah satu pilihan tetap bisa dipertahankan.
    final buffers = {..._bufferChoices, widget.config.bufferBasisPoints}.toList()..sort();
    final shares = {..._shareChoices, widget.salaryBasisPoints}.toList()..sort();

    return SheetBody(
      title: 'Siklus gajian',
      subtitle: 'Mengubah tanggal gajian ikut menggeser batas siklus berjalan.',
      children: [
        Wrap(
          spacing: AppSpacing.s8,
          runSpacing: AppSpacing.s8,
          children: [
            ChoiceChip(
              label: const Text('Tanggal tetap'),
              selected: fixedDate,
              onSelected: (_) => setState(() => _rule = PaydayRule.fixedDate),
            ),
            ChoiceChip(
              label: const Text('Hari kerja terakhir'),
              selected: !fixedDate,
              onSelected: (_) => setState(() => _rule = PaydayRule.lastWorkday),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s16),
        if (fixedDate) ...[
          DayOfMonthGrid(selected: _day, onSelected: (day) => setState(() => _day = day)),
          const SizedBox(height: AppSpacing.s8),
          SwitchRow(
            title: 'Geser jika jatuh di hari libur',
            subtitle: 'Gajian dimajukan ke hari kerja sebelumnya',
            value: _shiftOnHoliday,
            onChanged: (value) => setState(() => _shiftOnHoliday = value),
          ),
        ] else
          Text(
            'Gajian di hari kerja terakhir tiap bulan. Akhir pekan dan libur nasional '
            'otomatis dilewati.',
            style: AppTypography.bodyMedium.copyWith(color: c.textSecondary),
          ),
        const SizedBox(height: AppSpacing.s12),
        Row(
          children: [
            Icon(AppIcons.calendarCheck, size: 18, color: c.iconSecondary),
            const SizedBox(width: AppSpacing.s8),
            Expanded(
              child: Text(
                'Gajian berikutnya ${formatWeekdayDayMonth(cycle.nextPayday)} · '
                '${cycle.daysLeft(today)} hari lagi',
                style: AppTypography.bodySmall.copyWith(color: c.textSecondary),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s16),
        RupiahField(
          label: 'Perkiraan gaji bersih per bulan',
          value: _income,
          onChanged: (value) => setState(() => _income = value),
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: AppSpacing.s16),
        const SheetLabel('Sisihkan dari gaji'),
        Wrap(
          key: const ValueKey('salaryShare'),
          spacing: AppSpacing.s8,
          runSpacing: AppSpacing.s8,
          children: [
            for (final basisPoints in shares)
              ChoiceChip(
                label: Text(basisPoints == 0 ? 'Tanpa' : formatBasisPoints(basisPoints)),
                selected: _share == basisPoints,
                onSelected: (_) => setState(() => _share = basisPoints),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.s8),
        SheetNote(
          _share == 0
              ? 'Semua gaji boleh dipakai sampai gajian berikutnya.'
              : '${formatRupiah(salaryShare(_income, _share))} per siklus dikunci dari '
                    'Safe-to-Spend. Yang tersisa saat gajian otomatis ditabung ke "Sisa gaji".',
        ),
        const SizedBox(height: AppSpacing.s16),
        const SheetLabel('Dana cadangan'),
        Wrap(
          key: const ValueKey('buffer'),
          spacing: AppSpacing.s8,
          runSpacing: AppSpacing.s8,
          children: [
            for (final basisPoints in buffers)
              ChoiceChip(
                label: Text(basisPoints == 0 ? 'Tanpa' : formatBasisPoints(basisPoints)),
                selected: _buffer == basisPoints,
                onSelected: (_) => setState(() => _buffer = basisPoints),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.s8),
        const SheetNote(
          'Jaga-jaga dari sisa uang setelah kewajiban dan tabungan. Ikut mengecil saat uang '
          'dipakai, jadi tidak ditabung.',
        ),
        const SizedBox(height: AppSpacing.s24),
        SaveButton(
          label: 'Simpan',
          saving: saving,
          onPressed: _income > 0 ? () => unawaited(_save()) : null,
        ),
      ],
    );
  }
}
