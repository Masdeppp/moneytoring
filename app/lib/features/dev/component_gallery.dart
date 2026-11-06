import 'package:flutter/material.dart';

import '../../core/model/enums.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/theme_context.dart';
import '../../core/widgets/safe_to_spend_card.dart';
import '../../core/widgets/status_widgets.dart';

/// Semua komponen inti dalam satu layar, untuk membandingkan dengan Figma
/// dan untuk golden test (Light & Dark).
class ComponentGallery extends StatelessWidget {
  const ComponentGallery({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Galeri komponen')),
      body: const ComponentGalleryBody(),
    );
  }
}

class ComponentGalleryBody extends StatelessWidget {
  const ComponentGalleryBody({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screen),
      children: [
        const _Section('Safe-to-Spend'),
        const SafeToSpendCard(
          risk: RiskLevel.safe,
          amount: 1190000,
          dailyAllowance: 85000,
          daysLeft: 14,
          spentFraction: 0.42,
          cycleFraction: 0.55,
          protectedAmount: 2200000,
          protectedCount: 3,
        ),
        const SizedBox(height: AppSpacing.s12),
        const SafeToSpendCard(
          risk: RiskLevel.warning,
          amount: 540000,
          dailyAllowance: 38500,
          daysLeft: 14,
          spentFraction: 0.72,
          cycleFraction: 0.55,
          protectedAmount: 2200000,
          protectedCount: 3,
        ),
        const SizedBox(height: AppSpacing.s12),
        const SafeToSpendCard(
          risk: RiskLevel.danger,
          amount: -150000,
          dailyAllowance: 0,
          daysLeft: 14,
          spentFraction: 1,
          cycleFraction: 0.55,
          protectedAmount: 2200000,
          protectedCount: 3,
        ),
        const _Section('AlertBanner'),
        AlertBanner(
          tone: AlertTone.danger,
          title: 'Cicilan motor berisiko',
          body: 'Saldo diperkirakan kurang Rp 150.000 saat jatuh tempo 25 Nov.',
          actionLabel: 'Lihat cara mengamankan',
          onAction: () {},
        ),
        const SizedBox(height: AppSpacing.s8),
        const AlertBanner(
          tone: AlertTone.warning,
          title: 'Belanja lebih cepat dari biasa',
          body: '72% jatah sudah terpakai, padahal siklus baru berjalan 55%.',
        ),
        const SizedBox(height: AppSpacing.s8),
        const AlertBanner(
          tone: AlertTone.info,
          title: 'Listrik sudah dibayar?',
          body: 'Ada transaksi Rp 312.000 yang mirip tagihan listrik.',
        ),
        const _Section('Badge & kategori'),
        const Wrap(
          spacing: AppSpacing.s8,
          runSpacing: AppSpacing.s8,
          children: [
            AppBadge(label: 'Lunas', tone: BadgeTone.success),
            AppBadge(label: 'Belum', tone: BadgeTone.neutral),
            AppBadge(label: 'Berisiko', tone: BadgeTone.warning),
            AppBadge(label: 'Terlambat', tone: BadgeTone.danger),
            AppBadge(label: 'Info', tone: BadgeTone.info),
          ],
        ),
        const SizedBox(height: AppSpacing.s12),
        const Wrap(
          spacing: AppSpacing.s8,
          children: [
            CategoryTile(icon: AppIcons.utensils, tone: Tone.amber),
            CategoryTile(icon: AppIcons.bus, tone: Tone.blue),
            CategoryTile(icon: AppIcons.shoppingBag, tone: Tone.violet),
            CategoryTile(icon: AppIcons.house, tone: Tone.brand),
            CategoryTile(icon: AppIcons.receipt, tone: Tone.neutral),
            CategoryTile(icon: AppIcons.triangleAlert, tone: Tone.red),
          ],
        ),
        const _Section('Tombol'),
        FilledButton(onPressed: () {}, child: const Text('Simpan')),
        const SizedBox(height: AppSpacing.s8),
        FilledButton.tonal(onPressed: () {}, child: const Text('Lewati dulu')),
        const SizedBox(height: AppSpacing.s8),
        OutlinedButton(onPressed: () {}, child: const Text('Pindah dana')),
        const SizedBox(height: AppSpacing.s8),
        TextButton(onPressed: () {}, child: const Text('Lihat semua')),
        const _Section('Chip & input'),
        Wrap(
          spacing: AppSpacing.s8,
          children: [
            FilterChip(label: const Text('Semua'), selected: true, onSelected: (_) {}),
            FilterChip(label: const Text('Pengeluaran'), selected: false, onSelected: (_) {}),
            FilterChip(label: const Text('Pemasukan'), selected: false, onSelected: (_) {}),
          ],
        ),
        const SizedBox(height: AppSpacing.s12),
        const TextField(decoration: InputDecoration(hintText: 'Catatan, mis. makan siang')),
        const _Section('Tipografi'),
        Text('Rp 1.190.000', style: AppTypography.displayAmount.copyWith(color: c.textPrimary)),
        Text('Headline Large', style: context.textStyles.headlineLarge),
        Text('Headline Small', style: context.textStyles.headlineSmall),
        Text('Title Medium', style: context.textStyles.titleMedium),
        Text('Body Medium: teks isi biasa.', style: context.textStyles.bodyMedium),
        Text('−Rp 25.000', style: AppTypography.amountMedium.copyWith(color: c.textPrimary)),
        Text('+Rp 7.500.000', style: AppTypography.amountMedium.copyWith(color: c.textIncome)),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.s24, bottom: AppSpacing.s12),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.overline.copyWith(color: context.colors.textTertiary),
      ),
    );
  }
}
