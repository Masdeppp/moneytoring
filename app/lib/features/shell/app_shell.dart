import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_icons.dart';
import '../transactions/presentation/transaction_sheet.dart';

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
              onPressed: () => unawaited(showTransactionSheet(context)),
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
}
