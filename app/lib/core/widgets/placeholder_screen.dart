import 'package:flutter/material.dart';

import '../theme/app_icons.dart';
import '../theme/app_tokens.dart';
import '../theme/theme_context.dart';

/// Layar sementara untuk tab yang belum dibangun.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title, required this.phase});

  final String title;
  final String phase;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(AppIcons.hammer, size: 40, color: c.iconSecondary),
              const SizedBox(height: AppSpacing.s16),
              Text(
                'Layar $title dibangun di $phase',
                textAlign: TextAlign.center,
                style: context.textStyles.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
