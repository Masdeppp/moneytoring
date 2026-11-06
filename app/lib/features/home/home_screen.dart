import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/model/enums.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/theme_context.dart';
import '../../core/widgets/safe_to_spend_card.dart';
import '../../core/widgets/status_widgets.dart';
import '../../data/db/database_provider.dart';

/// Beranda sementara (Fase 0b): kartu Safe-to-Spend dengan data contoh.
/// Engine dan data asli disambungkan di Fase 1.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          // Skenario contoh DESIGN.md: hari ini 11 Nov, gajian 25 Nov.
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
          const SizedBox(height: AppSpacing.s16),
          const AlertBanner(
            tone: AlertTone.info,
            title: 'Masih data contoh',
            body: 'Pencatatan transaksi dan engine Safe-to-Spend dibangun di Fase 1.',
          ),
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
          ],
        ],
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
          'Terbuka · cipher ${value.cipher} · ${value.categoryCount} kategori',
        AsyncError(:final error) => 'Gagal dibuka: $error',
        _ => 'Membuka…',
      }),
    );
  }
}
