import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/model/account_type_defaults.dart';
import '../../../core/model/enums.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/rupiah_field.dart';
import '../../../core/widgets/switch_row.dart';
import '../../../data/db/database_provider.dart';
import '../../../data/providers.dart';
import '../../../data/repositories/account_repository.dart';
import 'settings_widgets.dart';

/// Tambah akun ([entry] kosong), atau ubah, sesuaikan saldo, dan arsipkan
/// akun yang ada. [canArchive] salah untuk akun aktif terakhir.
Future<void> showAccountSheet(
  BuildContext context, {
  AccountBalance? entry,
  bool canArchive = false,
}) => showMessageSheet(context, (context) => AccountSheet(entry: entry, canArchive: canArchive));

class AccountSheet extends ConsumerStatefulWidget {
  const AccountSheet({super.key, this.entry, this.canArchive = false});

  final AccountBalance? entry;
  final bool canArchive;

  @override
  ConsumerState<AccountSheet> createState() => _AccountSheetState();
}

class _AccountSheetState extends ConsumerState<AccountSheet> with SheetSaver<AccountSheet> {
  late final _name = TextEditingController(text: widget.entry?.account.name ?? '');
  late AccountType _type = widget.entry?.account.type ?? AccountType.bank;

  // Isian nominal tidak bisa negatif; saldo minus mulai dari kosong dan baru
  // disesuaikan kalau pengguna mengisinya.
  late int _balance = math.max(0, widget.entry?.balance ?? 0);
  bool _balanceTouched = false;
  late bool _includeInSafeToSpend = widget.entry?.account.includeInSafeToSpend ?? true;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  /// Selisih yang akan disesuaikan saat disimpan; 0 kalau saldo tidak diubah.
  int get _adjustment {
    final entry = widget.entry;
    return entry == null || !_balanceTouched ? 0 : _balance - entry.balance;
  }

  String? get _balanceNote {
    final entry = widget.entry;
    if (entry == null) return null;
    final adjustment = _adjustment;
    if (adjustment != 0) {
      return 'Saldo disesuaikan ${formatRupiah(adjustment, signed: true)} dari '
          '${formatRupiah(entry.balance)}, tanpa dicatat sebagai transaksi.';
    }
    return entry.balance < 0
        ? 'Saldo tercatat ${formatRupiah(entry.balance)}. Isi saldo sebenarnya untuk '
              'menyesuaikannya.'
        : 'Berbeda dengan saldo sebenarnya? Ubah angkanya; selisihnya tidak dicatat '
              'sebagai transaksi.';
  }

  Future<void> _save() => saveAndClose('Akun', () async {
    final accounts = ref.read(accountRepositoryProvider);
    final name = _name.text.trim();
    final entry = widget.entry;
    if (entry == null) {
      await accounts.create(
        name: name,
        type: _type,
        icon: _type.iconName,
        tone: _type.tone,
        initialBalance: _balance,
        includeInSafeToSpend: _includeInSafeToSpend,
      );
      return '$name ditambahkan.';
    }
    final id = entry.account.id;
    // Ikon dan warna mengikuti jenis akun, jadi ikut berganti dengannya.
    final typeChanged = _type != entry.account.type;
    final adjustment = _adjustment;
    await ref.read(appDatabaseProvider).transaction(() async {
      await accounts.update(
        id,
        name: name,
        type: _type,
        icon: typeChanged ? _type.iconName : null,
        tone: typeChanged ? _type.tone : null,
        includeInSafeToSpend: _includeInSafeToSpend,
      );
      if (adjustment != 0) await accounts.adjustBalance(id, _balance);
    });
    return 'Perubahan $name disimpan.';
  });

  Future<void> _archive(AccountBalance entry) async {
    final name = entry.account.name;
    final confirmed = await confirmAction(
      context,
      title: 'Arsipkan $name?',
      body: entry.balance == 0
          ? 'Akun tidak lagi muncul di pilihan. Riwayat transaksinya tetap ada.'
          : 'Saldo ${formatRupiah(entry.balance)} di akun ini tidak lagi dihitung. '
                'Riwayat transaksinya tetap ada.',
      confirmLabel: 'Arsipkan',
    );
    if (!confirmed || !mounted) return;
    await saveAndClose('Akun', () async {
      await ref.read(accountRepositoryProvider).archive(entry.account.id);
      return '$name diarsipkan.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final entry = widget.entry;
    final note = _balanceNote;
    return SheetBody(
      title: entry == null ? 'Akun baru' : 'Ubah akun',
      subtitle: entry == null ? 'Rekening, dompet, atau e-wallet tempat uangmu berada.' : null,
      children: [
        TextField(
          controller: _name,
          autofocus: entry == null,
          maxLength: 40,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Nama akun',
            hintText: 'mis. BCA',
            counterText: '',
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.s16),
        const SheetLabel('Jenis'),
        Wrap(
          spacing: AppSpacing.s8,
          runSpacing: AppSpacing.s8,
          children: [
            for (final type in AccountType.values)
              ChoiceChip(
                avatar: Icon(AppIcons.named(type.iconName), size: 18),
                label: Text(type.defaultName),
                selected: _type == type,
                onSelected: (_) => setState(() => _type = type),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.s16),
        RupiahField(
          label: 'Saldo sekarang',
          value: _balance,
          onChanged: (value) => setState(() {
            _balance = value;
            _balanceTouched = true;
          }),
          textInputAction: TextInputAction.done,
        ),
        if (note != null) ...[const SizedBox(height: AppSpacing.s8), SheetNote(note)],
        const SizedBox(height: AppSpacing.s8),
        SwitchRow(
          title: 'Hitung di Safe-to-Spend',
          subtitle: 'Matikan untuk dana darurat atau tabungan',
          value: _includeInSafeToSpend,
          onChanged: (value) => setState(() => _includeInSafeToSpend = value),
        ),
        const SizedBox(height: AppSpacing.s24),
        SaveButton(
          label: 'Simpan',
          saving: saving,
          onPressed: _name.text.trim().isEmpty ? null : () => unawaited(_save()),
        ),
        if (entry != null) ...[
          const SizedBox(height: AppSpacing.s8),
          if (widget.canArchive)
            TextButton(
              style: TextButton.styleFrom(foregroundColor: c.textSecondary),
              onPressed: saving ? null : () => unawaited(_archive(entry)),
              child: const Text('Arsipkan akun'),
            )
          else
            const SheetNote('Akun terakhir tidak bisa diarsipkan.', center: true),
        ],
      ],
    );
  }
}
