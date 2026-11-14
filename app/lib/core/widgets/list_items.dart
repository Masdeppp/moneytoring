import 'package:flutter/material.dart';

import '../model/enums.dart';
import '../theme/app_tokens.dart';
import '../theme/app_typography.dart';
import '../theme/theme_context.dart';
import 'status_widgets.dart';

/// Judul seksi dengan tautan di kanan (Figma `Section`, mis. "Kewajiban
/// terdekat · Lihat semua").
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final label = actionLabel;
    return Row(
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Text(title, style: AppTypography.titleMedium.copyWith(color: c.textPrimary)),
          ),
        ),
        if (label != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8),
            ),
            child: Text(label),
          ),
      ],
    );
  }
}

/// Baris kewajiban (DESIGN.md §4 `ListItem/Obligation`).
class ObligationListItem extends StatelessWidget {
  const ObligationListItem({
    super.key,
    required this.name,
    required this.due,
    required this.amount,
    required this.icon,
    required this.tone,
    this.badge,
    this.onTap,
  });

  final String name;

  /// Mis. "Tiap tanggal 25" atau "20 Nov · 9 hari lagi".
  final String due;
  final String amount;
  final IconData icon;
  final Tone tone;
  final Widget? badge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final trailingBadge = badge;
    return _RowShell(
      onTap: onTap,
      leading: CategoryTile(icon: icon, tone: tone),
      title: Text(name, style: AppTypography.titleSmall.copyWith(color: c.textPrimary)),
      subtitle: Text(due, style: AppTypography.bodySmall.copyWith(color: c.textTertiary)),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(amount, style: AppTypography.amountMedium.copyWith(color: c.textPrimary)),
          if (trailingBadge != null) ...[const SizedBox(height: AppSpacing.s4), trailingBadge],
        ],
      ),
    );
  }
}

/// Baris transaksi (DESIGN.md §4 `ListItem/Transaction`). Pengeluaran ditulis
/// dengan warna netral, bukan merah (DESIGN.md §1.3).
class TransactionListItem extends StatelessWidget {
  const TransactionListItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.amountColor,
    required this.icon,
    required this.tone,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String amount;
  final Color amountColor;
  final IconData icon;
  final Tone tone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return _RowShell(
      onTap: onTap,
      leading: CategoryTile(icon: icon, tone: tone),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.titleSmall.copyWith(color: c.textPrimary),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.bodySmall.copyWith(color: c.textTertiary),
      ),
      trailing: Text(amount, style: AppTypography.amountMedium.copyWith(color: amountColor)),
    );
  }
}

class _RowShell extends StatelessWidget {
  const _RowShell({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
  });

  final Widget leading;
  final Widget title;
  final Widget subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s12),
          child: Row(
            children: [
              leading,
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title,
                    const SizedBox(height: AppSpacing.s2),
                    subtitle,
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}

/// Kartu berisi teks keterangan saat daftar kosong, dengan aksi opsional.
class EmptyNote extends StatelessWidget {
  const EmptyNote(this.text, {super.key, this.actionLabel, this.onAction});

  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final label = actionLabel;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: AppTypography.bodyMedium.copyWith(color: context.colors.textSecondary),
            ),
            if (label != null) ...[
              const SizedBox(height: AppSpacing.s8),
              TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8),
                ),
                child: Text(label),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Kartu berisi daftar baris dengan garis pemisah sejajar teks.
class ListCard extends StatelessWidget {
  const ListCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (final (index, child) in children.indexed) ...[
            if (index > 0) const Divider(indent: AppSpacing.s16 + 40 + AppSpacing.s12),
            child,
          ],
        ],
      ),
    );
  }
}
