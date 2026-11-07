import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_icons.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/theme_context.dart';
import '../../data/providers.dart';

/// Tampil sebentar saat database dibuka, sebelum router tahu pengguna sudah
/// onboarding atau belum. Kalau database gagal dibuka, alasannya ditampilkan.
class LoadingScreen extends ConsumerWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final status = ref.watch(onboardingStatusProvider);
    return Scaffold(
      body: Center(
        child: status.hasError
            ? Padding(
                padding: const EdgeInsets.all(AppSpacing.screenOnboarding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(AppIcons.octagonAlert, size: 32, color: c.textDanger),
                    const SizedBox(height: AppSpacing.s12),
                    Text(
                      'Database tidak bisa dibuka',
                      style: AppTypography.titleMedium.copyWith(color: c.textPrimary),
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    Text(
                      '${status.error}',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall.copyWith(color: c.textSecondary),
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
