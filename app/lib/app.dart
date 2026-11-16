import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';

class MoneytoringApp extends ConsumerWidget {
  const MoneytoringApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      // Nama brand hanya di ARB + android:label (PRD §10.5, working title).
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      locale: const Locale('id'),
      supportedLocales: AppLocalizations.supportedLocales,
      // Teks bawaan Material, Cupertino, dan widget (mis. pemilih tanggal)
      // diambil dari material_ui. Daftar di AppLocalizations masih memakai
      // flutter_localizations versi lama, yang tidak dikenali widget material_ui.
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      routerConfig: ref.watch(routerProvider),
      debugShowCheckedModeBanner: false,
    );
  }
}
