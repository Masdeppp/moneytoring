import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/model/enums.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/safe_to_spend_card.dart';
import '../../../data/providers.dart';
import '../../../engine/common/local_date.dart';
import '../../../engine/safe_to_spend/safe_to_spend.dart';
import '../application/onboarding_controller.dart';
import 'onboarding_scaffold.dart';

/// Langkah 4 (Figma layar 03): Safe-to-Spend pertama + rinciannya, lalu simpan.
class AhaStep extends ConsumerStatefulWidget {
  const AhaStep({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  ConsumerState<AhaStep> createState() => _AhaStepState();
}

class _AhaStepState extends ConsumerState<AhaStep> {
  var _saving = false;

  Future<void> _finish() async {
    setState(() => _saving = true);
    try {
      final today = LocalDate.fromDateTime(ref.read(clockProvider)());
      await ref
          .read(onboardingServiceProvider)
          .complete(ref.read(onboardingControllerProvider), today: today);
      // Router pindah ke Beranda begitu aturan gajian tersimpan.
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal menyimpan: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final draft = ref.watch(onboardingControllerProvider);
    final preview = ref.watch(onboardingPreviewProvider);
    final sts = preview.safeToSpend;
    final shortfall = sts.isNegative;

    return OnboardingScaffold(
      step: 4,
      onBack: _saving ? null : widget.onBack,
      badge: shortfall ? null : const _ReadyBadge(),
      title: shortfall ? 'Kewajibanmu belum tertutup' : 'Ini uang yang aman kamu belanjakan',
      subtitle: shortfall
          ? 'Saldo sekarang kurang ${formatRupiah(-sts.amount)} untuk kewajiban sebelum gajian. '
                'Kamu tetap bisa mulai; kami bantu pantau setiap hari.'
          : 'Sampai gajian berikutnya, setelah semua kewajiban diamankan.',
      sections: [
        SafeToSpendCard(
          risk: shortfall ? RiskLevel.danger : RiskLevel.safe,
          amount: sts.amount,
          dailyAllowance: sts.dailyAllowance,
          daysLeft: sts.daysLeft,
          spentFraction: 0,
          cycleFraction: 0,
          protectedAmount: sts.obligationsReserved,
          protectedCount: preview.protectedCount,
          showPace: false,
        ),
        _Breakdown(
          safeToSpend: sts,
          balanceLabel: draft.hasExcludedAccount ? 'Saldo akun yang dihitung' : 'Saldo semua akun',
          nextPaydayLabel:
              'Gajian berikutnya ${formatWeekdayDayMonth(preview.cycle.nextPayday)} · '
              '${sts.daysLeft} hari lagi',
        ),
      ],
      footer: FilledButton(
        onPressed: _saving ? null : _finish,
        child: _saving
            ? SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: c.textOnBrand),
              )
            : const Text('Mulai pakai Moneytoring'),
      ),
    );
  }
}

class _ReadyBadge extends StatelessWidget {
  const _ReadyBadge();

  @override
  Widget build(BuildContext context) {
    final tone = context.colors.tone(Tone.brand);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tone.bg,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: AppSpacing.s4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(AppIcons.sparkles, size: 16, color: tone.fg),
            const SizedBox(width: 6),
            Text('Siap dipakai', style: AppTypography.labelMedium.copyWith(color: tone.fg)),
          ],
        ),
      ),
    );
  }
}

/// "Dari mana angka ini?" — rincian transparan Safe-to-Spend (Figma `Breakdown`).
class _Breakdown extends StatelessWidget {
  const _Breakdown({
    required this.safeToSpend,
    required this.balanceLabel,
    required this.nextPaydayLabel,
  });

  final SafeToSpend safeToSpend;
  final String balanceLabel;
  final String nextPaydayLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final sts = safeToSpend;
    final bufferPercent = defaultBufferBasisPoints / 100;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Dari mana angka ini?',
              style: AppTypography.titleSmall.copyWith(color: c.textPrimary),
            ),
            const SizedBox(height: 10),
            _Row(label: balanceLabel, value: formatRupiah(sts.availableBalance)),
            const SizedBox(height: 10),
            _Row(label: 'Kewajiban sebelum gajian', value: formatRupiah(-sts.obligationsReserved)),
            const SizedBox(height: 10),
            _Row(
              label: 'Dana cadangan (${bufferPercent.toStringAsFixed(0)}%)',
              value: formatRupiah(-sts.buffer),
            ),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 10),
            _Row(
              label: 'Aman dibelanjakan',
              value: formatRupiah(sts.amount),
              emphasized: true,
              valueColor: sts.isNegative ? c.textDanger : c.textBrand,
            ),
            const SizedBox(height: AppSpacing.s12),
            Text(nextPaydayLabel, style: AppTypography.bodySmall.copyWith(color: c.textTertiary)),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.emphasized = false, this.valueColor});

  final String label;
  final String value;
  final bool emphasized;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return MergeSemantics(
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: emphasized
                  ? AppTypography.titleSmall.copyWith(color: c.textPrimary)
                  : AppTypography.bodyMedium.copyWith(color: c.textSecondary),
            ),
          ),
          Text(
            value,
            style: (emphasized ? AppTypography.titleMedium : AppTypography.titleSmall).copyWith(
              color: valueColor ?? c.textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
