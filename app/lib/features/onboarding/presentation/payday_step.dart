import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/model/enums.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/day_of_month_grid.dart';
import '../../../core/widgets/rupiah_field.dart';
import '../../../core/widgets/switch_row.dart';
import '../../../data/providers.dart';
import '../../../engine/common/local_date.dart';
import '../../../engine/cycle/pay_cycle.dart';
import '../application/onboarding_controller.dart';
import 'onboarding_scaffold.dart';

/// Langkah 1 (Figma layar 01): aturan gajian dan perkiraan gaji bersih.
class PaydayStep extends ConsumerWidget {
  const PaydayStep({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final draft = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);
    final fixedDate = draft.paydayRule == PaydayRule.fixedDate;

    final today = LocalDate.fromDateTime(ref.watch(clockProvider)());
    final cycle = PayCycleCalculator(
      draft.rule,
      holidays: ref.watch(holidayCalendarProvider),
    ).cycleContaining(today);

    return OnboardingScaffold(
      step: 1,
      title: 'Kapan kamu gajian?',
      subtitle: 'Semua hitungan Moneytoring berjalan per siklus gajian, bukan per bulan kalender.',
      sections: [
        Wrap(
          spacing: AppSpacing.s8,
          runSpacing: AppSpacing.s8,
          children: [
            ChoiceChip(
              label: const Text('Tanggal tetap'),
              selected: fixedDate,
              onSelected: (_) => controller.setPaydayRule(PaydayRule.fixedDate),
            ),
            ChoiceChip(
              label: const Text('Hari kerja terakhir'),
              selected: !fixedDate,
              onSelected: (_) => controller.setPaydayRule(PaydayRule.lastWorkday),
            ),
          ],
        ),
        if (fixedDate) ...[
          DayOfMonthGrid(selected: draft.payday, onSelected: controller.setPayday),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s16,
                vertical: AppSpacing.s8,
              ),
              child: SwitchRow(
                title: 'Geser jika jatuh di hari libur',
                subtitle: 'Gajian dimajukan ke hari kerja sebelumnya',
                value: draft.shiftOnHoliday,
                onChanged: controller.setShiftOnHoliday,
              ),
            ),
          ),
        ] else
          Text(
            'Gajian di hari kerja terakhir tiap bulan. Akhir pekan dan libur nasional '
            'otomatis dilewati.',
            style: AppTypography.bodyMedium.copyWith(color: c.textSecondary),
          ),
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
        RupiahField(
          label: 'Perkiraan gaji bersih per bulan',
          value: draft.expectedIncome,
          onChanged: controller.setExpectedIncome,
          textInputAction: TextInputAction.done,
        ),
      ],
      footer: FilledButton(
        onPressed: draft.isPaydayStepValid ? onNext : null,
        child: const Text('Lanjut'),
      ),
    );
  }
}
