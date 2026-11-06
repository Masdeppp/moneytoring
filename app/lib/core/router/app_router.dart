import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/dev/component_gallery.dart';
import '../../features/home/home_screen.dart';
import '../../features/shell/app_shell.dart';
import '../widgets/placeholder_screen.dart';

abstract final class Routes {
  static const home = '/home';
  static const transactions = '/transactions';
  static const obligations = '/obligations';
  static const insights = '/insights';

  /// Galeri komponen untuk mengecek token desain di HP (debug).
  static const gallery = '/dev/gallery';
}

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: Routes.home,
    routes: [
      // Empat tab utama (DESIGN.md §4 NavBar). Tiap tab menyimpan
      // posisi scroll & riwayatnya sendiri.
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.home, builder: (context, state) => const HomeScreen())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.transactions,
                builder: (context, state) =>
                    const PlaceholderScreen(title: 'Transaksi', phase: 'Fase 1'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.obligations,
                builder: (context, state) =>
                    const PlaceholderScreen(title: 'Kewajiban', phase: 'Fase 1'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.insights,
                builder: (context, state) =>
                    const PlaceholderScreen(title: 'Insight', phase: 'Fase 2'),
              ),
            ],
          ),
        ],
      ),
      GoRoute(path: Routes.gallery, builder: (context, state) => const ComponentGallery()),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
