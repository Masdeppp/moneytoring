import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_icons.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/theme_context.dart';

/// Kerangka layar utama: NavigationBar 4 tab + FAB tambah transaksi.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _destinations = [
    (icon: AppIcons.house, label: 'Beranda'),
    (icon: AppIcons.arrowLeftRight, label: 'Transaksi'),
    (icon: AppIcons.calendarCheck, label: 'Kewajiban'),
    (icon: AppIcons.chartPie, label: 'Insight'),
  ];

  @override
  Widget build(BuildContext context) {
    // FAB hanya di Beranda dan Transaksi (DESIGN.md §6).
    final showFab = navigationShell.currentIndex <= 1;
    return Scaffold(
      body: navigationShell,
      floatingActionButton: showFab
          ? FloatingActionButton(
              tooltip: 'Tambah transaksi',
              onPressed: () => _showAddTransactionSheet(context),
              child: const Icon(AppIcons.plus),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          // Ketuk tab yang sedang aktif = kembali ke awal tab itu.
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: [
          for (final d in _destinations) NavigationDestination(icon: Icon(d.icon), label: d.label),
        ],
      ),
    );
  }

  void _showAddTransactionSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.s24, 0, AppSpacing.s24, AppSpacing.s32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tambah transaksi', style: context.textStyles.headlineSmall),
            const SizedBox(height: AppSpacing.s8),
            Text(
              'Keypad, kategori, dan "Sisa aman setelah ini" dibangun di Fase 1.',
              style: context.textStyles.bodyMedium?.copyWith(color: context.colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
