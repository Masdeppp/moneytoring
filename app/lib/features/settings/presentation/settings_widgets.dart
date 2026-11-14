import 'package:flutter/material.dart';

import '../../../core/model/enums.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/list_items.dart';
import '../../../core/widgets/status_widgets.dart';

/// Kelompok baris di Pengaturan: judul, tombol tambah opsional, lalu kartu
/// berisi barisnya. Kalau [children] kosong, [empty] tampil sebagai gantinya.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({
    super.key,
    required this.title,
    required this.children,
    this.addTooltip,
    this.onAdd,
    this.empty,
  });

  final String title;
  final List<Widget> children;
  final String? addTooltip;
  final VoidCallback? onAdd;
  final Widget? empty;

  @override
  Widget build(BuildContext context) {
    final onAdd = this.onAdd;
    final empty = this.empty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.s16, bottom: AppSpacing.s4),
          child: Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    title.toUpperCase(),
                    style: AppTypography.overline.copyWith(color: context.colors.textTertiary),
                  ),
                ),
              ),
              // Tinggi baris judul sama dengan atau tanpa tombol tambah.
              if (onAdd != null)
                IconButton(
                  tooltip: addTooltip,
                  visualDensity: VisualDensity.compact,
                  onPressed: onAdd,
                  icon: const Icon(AppIcons.plus),
                )
              else
                const SizedBox(height: 40),
            ],
          ),
        ),
        if (children.isNotEmpty) ListCard(children: children) else ?empty,
      ],
    );
  }
}

/// Satu baris Pengaturan: ikon berwarna, judul, keterangan, dan nilai di kanan.
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.icon,
    required this.tone,
    required this.title,
    this.subtitle,
    this.trailing,
    this.badge,
    this.chevron = false,
    this.onTap,
  });

  final IconData icon;
  final Tone tone;
  final String title;
  final String? subtitle;

  /// Nilai di kanan (nominal atau persen).
  final String? trailing;
  final Widget? badge;

  /// Panah kanan untuk baris yang membuka layar lain.
  final bool chevron;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final subtitle = this.subtitle;
    final trailing = this.trailing;
    final badge = this.badge;
    return MergeSemantics(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s12),
          child: Row(
            children: [
              CategoryTile(icon: icon, tone: tone),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.titleSmall.copyWith(color: c.textPrimary)),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppSpacing.s2),
                      Text(
                        subtitle,
                        style: AppTypography.bodySmall.copyWith(color: c.textTertiary),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null || badge != null) ...[
                const SizedBox(width: AppSpacing.s12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (trailing != null)
                      Text(
                        trailing,
                        style: AppTypography.amountMedium.copyWith(color: c.textPrimary),
                      ),
                    if (trailing != null && badge != null) const SizedBox(height: AppSpacing.s4),
                    ?badge,
                  ],
                ),
              ],
              if (chevron) ...[
                const SizedBox(width: AppSpacing.s8),
                Icon(AppIcons.chevronRight, size: 20, color: c.iconSecondary),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Isi bottom sheet Pengaturan: judul, keterangan, lalu isian yang bisa
/// digulir dan naik mengikuti keyboard.
class SheetBody extends StatelessWidget {
  const SheetBody({super.key, required this.title, this.subtitle, required this.children});

  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final subtitle = this.subtitle;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenOnboarding,
          0,
          AppSpacing.screenOnboarding,
          AppSpacing.s24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: AppTypography.headlineSmall.copyWith(color: c.textPrimary)),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.s4),
              Text(subtitle, style: AppTypography.bodyMedium.copyWith(color: c.textSecondary)),
            ],
            const SizedBox(height: AppSpacing.s16),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// Judul kecil di atas sekelompok pilihan dalam sheet.
class SheetLabel extends StatelessWidget {
  const SheetLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s8),
      child: Text(
        text,
        style: AppTypography.labelMedium.copyWith(color: context.colors.textSecondary),
      ),
    );
  }
}

/// Keterangan kecil di bawah isian.
class SheetNote extends StatelessWidget {
  const SheetNote(this.text, {super.key, this.center = false});

  final String text;
  final bool center;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: center ? TextAlign.center : TextAlign.start,
      style: AppTypography.bodySmall.copyWith(color: context.colors.textTertiary),
    );
  }
}

/// Label kecil dengan nilai di bawahnya, untuk kartu ringkasan di sheet.
/// Nilai seperti "Rp 12.500.000 dari Rp 60.000.000" tidak muat sejajar
/// dengan labelnya di layar sempit.
class ValueRow extends StatelessWidget {
  const ValueRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.bodySmall.copyWith(color: c.textSecondary)),
          const SizedBox(height: AppSpacing.s2),
          Text(
            value,
            style: AppTypography.titleSmall.copyWith(
              color: c.textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

/// Satu baris riwayat setoran: keterangan, nominal, dan tombol hapus.
class HistoryRow extends StatelessWidget {
  const HistoryRow({
    super.key,
    required this.label,
    required this.amount,
    required this.deleteTooltip,
    required this.onDelete,
  });

  final String label;
  final int amount;
  final String deleteTooltip;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        Expanded(
          child: Text(label, style: AppTypography.bodyMedium.copyWith(color: c.textSecondary)),
        ),
        Text(
          formatRupiah(amount),
          style: AppTypography.titleSmall.copyWith(
            color: c.textPrimary,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        IconButton(
          tooltip: deleteTooltip,
          visualDensity: VisualDensity.compact,
          onPressed: onDelete,
          icon: Icon(AppIcons.trash, size: 18, color: c.iconSecondary),
        ),
      ],
    );
  }
}

/// Tombol utama sheet; berputar selama menyimpan.
class SaveButton extends StatelessWidget {
  const SaveButton({super.key, required this.label, required this.saving, this.onPressed});

  final String label;
  final bool saving;

  /// `null` selama isian belum lengkap.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: saving ? null : onPressed,
      child: saving
          ? SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.textOnBrand),
            )
          : Text(label),
    );
  }
}

/// Untuk sheet yang menyimpan sendiri: jalankan aksinya, tutup sheet dengan
/// pesan suksesnya, atau biarkan terbuka dan beri tahu kalau gagal.
mixin SheetSaver<T extends StatefulWidget> on State<T> {
  bool saving = false;

  /// Nilai yang dikembalikan sheet saat berhasil; bawaannya pesan itu sendiri.
  Object resultFor(String message) => message;

  Future<void> saveAndClose(String what, Future<String> Function() action) async {
    setState(() => saving = true);
    try {
      final message = await action();
      if (!mounted) return;
      Navigator.pop(context, resultFor(message));
    } on Object catch (error, stackTrace) {
      debugPrint('$what gagal disimpan: $error\n$stackTrace');
      if (!mounted) return;
      setState(() => saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Belum tersimpan. Coba sekali lagi.')));
    }
  }
}

/// Membuka sheet yang menyimpan sendiri, lalu menampilkan pesan yang
/// dikembalikannya sebagai snackbar.
Future<void> showMessageSheet(BuildContext context, WidgetBuilder builder) async {
  // Snackbar sebelumnya jangan sampai menutupi tombol Simpan.
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  final message = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: builder,
  );
  if (message != null && context.mounted) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

/// Dialog konfirmasi untuk aksi yang tidak bisa dibatalkan dari layar ini.
Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(confirmLabel)),
      ],
    ),
  );
  return confirmed ?? false;
}
