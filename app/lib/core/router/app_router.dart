import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers.dart';
import '../../features/dev/component_gallery.dart';
import '../../features/home/home_screen.dart';
import '../../features/obligations/presentation/obligations_screen.dart';
import '../../features/onboarding/presentation/onboarding_flow.dart';
import '../../features/settings/presentation/categories_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/shell/app_shell.dart';
import '../../features/shell/loading_screen.dart';
import '../../features/transactions/presentation/transactions_screen.dart';
import '../widgets/placeholder_screen.dart';

abstract final class Routes {
  static const home = '/home';
  static const transactions = '/transactions';
  static const obligations = '/obligations';
  static const insights = '/insights';
  static const onboarding = '/onboarding';

  /// Pengaturan dibuka dari Beranda, di atas tab (tanpa NavBar).
  static const settings = '/settings';
  static const settingsCategories = '/settings/categories';

  /// Layar kosong selama database dibuka.
  static const loading = '/loading';

  /// Galeri komponen untuk mengecek token desain di HP (debug).
  static const gallery = '/dev/gallery';
}

/// Pengguna baru selalu ke onboarding; pengguna yang sudah onboarding tidak
/// bisa kembali ke sana. Selama status belum diketahui, tampilkan layar
/// loading supaya Beranda tidak sempat berkedip.
@visibleForTesting
String? onboardingRedirect(AsyncValue<bool> status, String location) {
  final atOnboarding = location == Routes.onboarding;
  final atLoading = location == Routes.loading;
  final onboarded = status.value;
  if (onboarded == null) return atLoading ? null : Routes.loading;
  if (!onboarded) return atOnboarding ? null : Routes.onboarding;
  return atOnboarding || atLoading ? Routes.home : null;
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(onboardingStatusProvider, (_, _) => refresh.value++);

  final router = GoRouter(
    initialLocation: Routes.home,
    refreshListenable: refresh,
    redirect: (context, state) =>
        onboardingRedirect(ref.read(onboardingStatusProvider), state.matchedLocation),
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
                builder: (context, state) => const TransactionsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.obligations,
                builder: (context, state) => const ObligationsScreen(),
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
      GoRoute(path: Routes.onboarding, builder: (context, state) => const OnboardingFlow()),
      // Dua rute sejajar (bukan bertingkat) supaya `push` menumpuk tepat satu
      // halaman di atas layar sebelumnya.
      GoRoute(path: Routes.settings, builder: (context, state) => const SettingsScreen()),
      GoRoute(
        path: Routes.settingsCategories,
        builder: (context, state) => const CategoriesScreen(),
      ),
      GoRoute(path: Routes.loading, builder: (context, state) => const LoadingScreen()),
      GoRoute(path: Routes.gallery, builder: (context, state) => const ComponentGallery()),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});
