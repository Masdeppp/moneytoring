import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/model/enums.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/theme_context.dart';
import '../../core/utils/money.dart';
import '../../core/widgets/safe_to_spend_card.dart';
import '../../core/widgets/status_widgets.dart';
import '../../data/db/database_provider.dart';
import '../../data/db/dev_reset.dart';
import '../../data/providers.dart';
import '../../data/services/safe_to_spend_service.dart';
import '../onboarding/application/onboarding_controller.dart';

/// Beranda (DESIGN.md layar 04/05): kartu Safe-to-Spend dari data asli dan
/// peringatan risiko di bawahnya. Kewajiban terdekat dan transaksi terakhir
/// menyusul di irisan 4.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(safeToSpendProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda'),
        actions: [
          IconButton(tooltip: 'Notifikasi', onPressed: () {}, icon: const Icon(AppIcons.bell)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.s8,
          AppSpacing.screen,
          AppSpacing.s48 * 2,
        ),
        children: [
          ...switch (snapshot) {
            AsyncData(:final value?) => _summary(value),
            AsyncError(:final error) => [
              AlertBanner(
                tone: AlertTone.danger,
                title: 'Safe-to-Spend gagal dihitung',
                body: '$error',
              ),
            ],
            _ => [const _CardPlaceholder()],
          },
          if (kDebugMode) ...[
            const SizedBox(height: AppSpacing.s24),
            Text('DEVELOPER', style: context.textStyles.labelSmall?.copyWith(letterSpacing: 0.66)),
            const SizedBox(height: AppSpacing.s8),
            const _DatabaseStatusTile(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(AppIcons.palette),
              title: const Text('Galeri komponen'),
              subtitle: const Text('Cek token warna, tipografi, dan komponen'),
              onTap: () => context.push(Routes.gallery),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(AppIcons.rotateCcw),
              title: const Text('Ulangi onboarding'),
              subtitle: const Text('Hapus semua data kecuali kategori'),
              onTap: () => unawaited(_confirmReset(context, ref)),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _summary(SafeToSpendSnapshot s) {
    final sts = s.safeToSpend;
    final risk = s.risk;
    return [
      SafeToSpendCard(
        risk: risk.level,
        amount: sts.amount,
        dailyAllowance: sts.dailyAllowance,
        daysLeft: sts.daysLeft,
        spentFraction: risk.spentFraction,
        cycleFraction: risk.cycleFraction,
        protectedAmount: sts.obligationsReserved,
        protectedCount: s.protectedCount,
      ),
      if (risk.level != RiskLevel.safe) ...[
        const SizedBox(height: AppSpacing.s16),
        if (sts.isNegative)
          AlertBanner(
            tone: AlertTone.danger,
            title: 'Kewajiban belum tertutup',
            body:
                'Saldo kurang ${formatRupiah(-sts.amount)} untuk kewajiban sebelum gajian. '
                'Tahan belanja yang bisa ditunda dulu.',
          )
        else if (risk.obligationsAtRisk)
          AlertBanner(
            tone: AlertTone.danger,
            title: 'Kewajiban berisiko',
            body:
                'Dengan pola belanja 7 hari terakhir, uangmu diperkirakan kurang '
                '${formatRupiah(risk.projectedShortfall)} sebelum gajian.',
          )
        else
          AlertBanner(
            tone: AlertTone.warning,
            title: 'Belanja lebih cepat dari biasa',
            body:
                '${(risk.spentFraction * 100).round()}% jatah sudah terpakai, padahal siklus '
                'baru berjalan ${(risk.cycleFraction * 100).round()}%.',
          ),
      ],
    ];
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus semua data?'),
        content: const Text(
          'Akun, transaksi, kewajiban, dan aturan gajian dihapus, lalu onboarding '
          'dimulai lagi. Kategori tetap ada. Menu ini hanya ada di build debug.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (confirmed != true) return;
    await resetUserData(ref.read(appDatabaseProvider));
    ref.invalidate(onboardingControllerProvider);
  }
}

/// Ruang kartu selama angka pertama dihitung, supaya isi layar tidak melompat.
class _CardPlaceholder extends StatelessWidget {
  const _CardPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 248,
      decoration: BoxDecoration(
        color: context.colors.bgSurfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
    );
  }
}

class _DatabaseStatusTile extends ConsumerWidget {
  const _DatabaseStatusTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(databaseStatusProvider);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(AppIcons.database),
      title: const Text('Database'),
      subtitle: Text(switch (status) {
        AsyncData(:final value) =>
          'Terbuka · cipher ${value.cipher} · skema v${value.schemaVersion} · '
              '${value.categoryCount} kategori',
        AsyncError(:final error) => 'Gagal dibuka: $error',
        _ => 'Membuka…',
      }),
    );
  }
}
