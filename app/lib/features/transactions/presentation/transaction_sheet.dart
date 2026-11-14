import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/model/account_type_defaults.dart';
import '../../../core/model/enums.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/status_widgets.dart';
import '../../../data/db/app_database.dart';
import '../../../data/providers.dart';
import '../../../data/repositories/account_repository.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../engine/common/local_date.dart';
import '../../../engine/safe_to_spend/safe_to_spend.dart';
import '../application/keypad.dart';

/// Membuka sheet tambah transaksi (Figma layar 06), atau ubah kalau [editing]
/// diisi. Setelah tersimpan, snackbar menampilkan Safe-to-Spend terbaru.
Future<void> showTransactionSheet(BuildContext context, {TransactionView? editing}) async {
  final message = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => TransactionSheet(editing: editing),
  );
  if (message != null && context.mounted) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class TransactionSheet extends ConsumerStatefulWidget {
  const TransactionSheet({super.key, this.editing});

  final TransactionView? editing;

  @override
  ConsumerState<TransactionSheet> createState() => _TransactionSheetState();
}

class _TransactionSheetState extends ConsumerState<TransactionSheet> {
  late TransactionType _type;
  late int _amount;
  late LocalDate _date;
  late String _note;
  int? _categoryId;
  int? _accountId;
  int? _toAccountId;

  /// Kategori yang dipilih sendiri oleh pengguna (bukan saran "terakhir dipakai").
  var _categoryChosen = false;
  var _saving = false;
  var _recentCategories = const <TransactionType, List<int>>{};

  TransactionRecord? get _original => widget.editing?.transaction;
  bool get _isEdit => widget.editing != null;

  /// Pembayaran kewajiban: jenis dan kategorinya mengikuti kewajiban.
  bool get _locked => _original?.obligationInstanceId != null;

  LocalDate get _today => LocalDate.fromDateTime(ref.read(clockProvider)());

  @override
  void initState() {
    super.initState();
    final original = _original;
    _type = original?.type ?? TransactionType.expense;
    _amount = original?.amount ?? 0;
    _date = original == null ? _today : LocalDate.fromDateTime(original.date.toLocal());
    _note = original?.note ?? '';
    _categoryId = original?.categoryId;
    _accountId = original?.accountId;
    _toAccountId = original?.toAccountId;
    _categoryChosen = original != null;
    unawaited(_loadDefaults());
  }

  /// Kategori dan akun yang terakhir dipakai, untuk Quick Add ≤ 3 tap.
  Future<void> _loadDefaults() async {
    final repo = ref.read(transactionRepositoryProvider);
    final recent = {
      TransactionType.expense: await repo.recentCategoryIds(TransactionType.expense),
      TransactionType.income: await repo.recentCategoryIds(TransactionType.income),
    };
    final lastAccount = _isEdit ? null : await repo.lastUsedAccountId(_type);
    if (!mounted) return;
    setState(() {
      _recentCategories = recent;
      _accountId ??= lastAccount;
    });
  }

  void _changeType(TransactionType type) => setState(() {
    _type = type;
    _categoryId = null;
    _categoryChosen = false;
    _toAccountId = null;
  });

  /// Kategori aktif untuk jenis ini: yang terakhir dipakai di depan.
  List<CategoryRecord> _categoriesFor(List<CategoryRecord> all) {
    final wanted = _type == TransactionType.income ? CategoryType.income : CategoryType.expense;
    final active = {
      for (final c in all)
        if (!c.archived && c.type == wanted) c.id: c,
    };
    final recent = [for (final id in _recentCategories[_type] ?? const <int>[]) ?active[id]];
    return [
      ...recent,
      for (final category in active.values)
        if (!recent.contains(category)) category,
    ];
  }

  /// Perubahan saldo yang dihitung di Safe-to-Spend kalau transaksi ini
  /// disimpan (dikurangi efek versi lamanya saat mengubah).
  int _balanceDelta(List<AccountBalance> accounts, int? from, int? to) {
    bool counted(int? id) =>
        accounts.where((a) => a.account.id == id).firstOrNull?.account.includeInSafeToSpend ??
        false;
    int effect(TransactionType type, int amount, int? from, int? to) => switch (type) {
      TransactionType.expense => counted(from) ? -amount : 0,
      TransactionType.income => counted(from) ? amount : 0,
      TransactionType.transfer => (counted(from) ? -amount : 0) + (counted(to) ? amount : 0),
    };
    final original = _original;
    final before = original == null
        ? 0
        : effect(original.type, original.amount, original.accountId, original.toAccountId);
    return effect(_type, _amount, from, to) - before;
  }

  String _pillText(SafeToSpend current, int delta) {
    if (_amount == 0 && !_isEdit) return 'Aman dibelanjakan ${formatRupiah(current.amount)}';
    if (delta == 0) return 'Tidak mengubah Safe-to-Spend';
    final after = formatRupiah(current.withBalanceChange(delta).amount);
    return _type == TransactionType.expense
        ? 'Sisa aman setelah ini $after'
        : 'Aman dibelanjakan jadi $after';
  }

  DateTime _transactionDate() {
    final original = _original;
    if (original != null && LocalDate.fromDateTime(original.date.toLocal()) == _date) {
      return original.date;
    }
    final now = ref.read(clockProvider)();
    if (_date == LocalDate.fromDateTime(now)) return now;
    return DateTime(_date.year, _date.month, _date.day, 12);
  }

  Future<String> _resultMessage(String? prefix) async {
    final snapshot = await ref.read(safeToSpendServiceProvider).compute(_today);
    final sts = snapshot == null
        ? null
        : 'Aman dibelanjakan kini ${formatRupiah(snapshot.safeToSpend.amount)}';
    return [?prefix, ?sts].join(' · ');
  }

  Future<void> _save({required int accountId, int? categoryId, int? toAccountId}) async {
    setState(() => _saving = true);
    try {
      final date = _transactionDate();
      final source = _categoryChosen ? CategorySource.user : CategorySource.history;
      final transaction = switch (_type) {
        TransactionType.expense => NewTransaction.expense(
          amount: _amount,
          accountId: accountId,
          categoryId: categoryId!,
          date: date,
          note: _note,
          categorySource: source,
        ),
        TransactionType.income => NewTransaction.income(
          amount: _amount,
          accountId: accountId,
          categoryId: categoryId!,
          date: date,
          note: _note,
          categorySource: source,
        ),
        TransactionType.transfer => NewTransaction.transfer(
          amount: _amount,
          fromAccountId: accountId,
          toAccountId: toAccountId!,
          date: date,
          note: _note,
        ),
      };
      final repo = ref.read(transactionRepositoryProvider);
      final original = _original;
      if (original == null) {
        await repo.add(transaction);
      } else {
        await repo.replace(original.id, transaction);
      }
      final message = await _resultMessage(_isEdit ? 'Transaksi diperbarui' : null);
      if (mounted) Navigator.pop(context, message);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      debugPrint('Transaksi gagal disimpan: $error');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Belum tersimpan. Coba sekali lagi.')));
    }
  }

  Future<void> _delete() async {
    final original = _original;
    if (original == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus transaksi ini?'),
        content: Text(
          original.obligationInstanceId == null
              ? 'Saldo akun dan Safe-to-Spend akan dihitung ulang.'
              : 'Ini pembayaran kewajiban; kewajibannya akan kembali belum lunas.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _saving = true);
    await ref.read(transactionRepositoryProvider).delete(original.id);
    final message = await _resultMessage('Transaksi dihapus');
    if (mounted) Navigator.pop(context, message);
  }

  Future<void> _pickAccount(List<AccountBalance> accounts, int? selected) async {
    final id = await showModalBottomSheet<int>(
      context: context,
      builder: (context) => _AccountPicker(accounts: accounts, selected: selected),
    );
    if (id != null) setState(() => _accountId = id);
  }

  Future<void> _pickDate() async {
    final today = _today;
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.toDateTime(),
      firstDate: today.addDays(-365).toDateTime(),
      lastDate: today.toDateTime(),
    );
    if (picked != null) setState(() => _date = LocalDate.fromDateTime(picked));
  }

  Future<void> _editNote() async {
    final note = await showDialog<String>(
      context: context,
      builder: (context) => _NoteDialog(initial: _note),
    );
    if (note != null) setState(() => _note = note.trim());
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final accounts = ref.watch(accountBalancesProvider).value ?? const <AccountBalance>[];
    final categories = _categoriesFor(
      ref.watch(allCategoriesProvider).value ?? const <CategoryRecord>[],
    );
    final current = ref.watch(safeToSpendProvider).value?.safeToSpend;

    final accountId = _accountId ?? accounts.firstOrNull?.account.id;
    final account = accounts.where((a) => a.account.id == accountId).firstOrNull?.account;
    final categoryId = _categoryId ?? categories.firstOrNull?.id;
    final targets = [
      for (final a in accounts)
        if (a.account.id != accountId) a.account,
    ];
    final toAccountId = _toAccountId ?? targets.firstOrNull?.id;
    final transfer = _type == TransactionType.transfer;
    final delta = _balanceDelta(accounts, accountId, toAccountId);
    final canSave =
        !_saving &&
        _amount > 0 &&
        accountId != null &&
        (transfer ? toAccountId != null : categoryId != null);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.s16, 0, AppSpacing.s16, AppSpacing.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TypeToggle(value: _type, onChanged: _locked ? null : _changeType),
            const SizedBox(height: AppSpacing.s16),
            Semantics(
              liveRegion: true,
              label: 'Nominal ${formatRupiah(_amount)}',
              excludeSemantics: true,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  formatRupiah(_amount),
                  style: AppTypography.displayAmount.copyWith(color: c.textPrimary),
                ),
              ),
            ),
            if (current != null) ...[
              const SizedBox(height: AppSpacing.s4),
              Center(
                child: _SafeAfterPill(
                  text: _pillText(current, delta),
                  danger: _amount > 0 && current.withBalanceChange(delta).isNegative,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.s16),
            SizedBox(
              height: 76,
              child: transfer
                  ? _TileStrip(
                      items: [
                        for (final a in targets)
                          (
                            label: a.name,
                            icon: AppIcons.named(a.icon),
                            tone: a.tone,
                            selected: a.id == toAccountId,
                            onTap: () => setState(() => _toAccountId = a.id),
                          ),
                      ],
                      emptyText: 'Tambah akun kedua di Pengaturan untuk transfer.',
                    )
                  : _TileStrip(
                      items: [
                        for (final category in categories)
                          (
                            label: category.name,
                            icon: AppIcons.named(category.icon),
                            tone: category.tone,
                            selected: category.id == categoryId,
                            onTap: _locked
                                ? null
                                : () => setState(() {
                                    _categoryId = category.id;
                                    _categoryChosen = true;
                                  }),
                          ),
                      ],
                      emptyText: 'Belum ada kategori.',
                    ),
            ),
            const SizedBox(height: AppSpacing.s12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ActionChip(
                    avatar: Icon(
                      AppIcons.named(account?.icon ?? AccountType.bank.iconName),
                      size: 18,
                    ),
                    label: Text(
                      transfer ? 'Dari ${account?.name ?? '…'}' : account?.name ?? 'Pilih akun',
                    ),
                    onPressed: () => unawaited(_pickAccount(accounts, accountId)),
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  ActionChip(
                    avatar: const Icon(AppIcons.calendar, size: 18),
                    label: Text(formatRelativeDay(_date, _today)),
                    onPressed: () => unawaited(_pickDate()),
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  ActionChip(
                    avatar: const Icon(AppIcons.pencil, size: 18),
                    label: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 160),
                      child: Text(
                        _note.isEmpty ? 'Catatan' : _note,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    onPressed: () => unawaited(_editNote()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            _Keypad(
              onKey: (key) => setState(() => _amount = applyKeypadKey(_amount, key)),
              onClear: () => setState(() => _amount = 0),
            ),
            const SizedBox(height: AppSpacing.s16),
            FilledButton(
              onPressed: canSave
                  ? () => unawaited(
                      _save(accountId: accountId, categoryId: categoryId, toAccountId: toAccountId),
                    )
                  : null,
              child: _saving
                  ? SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: c.textOnBrand),
                    )
                  : const Text('Simpan'),
            ),
            if (_isEdit) ...[
              const SizedBox(height: AppSpacing.s4),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: c.textSecondary),
                onPressed: _saving ? null : () => unawaited(_delete()),
                child: const Text('Hapus transaksi'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Pengeluaran / Pemasukan / Transfer (Figma `Proto/TypeToggle`).
class _TypeToggle extends StatelessWidget {
  const _TypeToggle({required this.value, required this.onChanged});

  final TransactionType value;
  final ValueChanged<TransactionType>? onChanged;

  static const _labels = {
    TransactionType.expense: 'Pengeluaran',
    TransactionType.income: 'Pemasukan',
    TransactionType.transfer: 'Transfer',
  };

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final changed = onChanged;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.bgSurfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s4),
        child: Row(
          children: [
            for (final MapEntry(key: type, value: label) in _labels.entries)
              Expanded(
                child: Semantics(
                  button: true,
                  selected: type == value,
                  child: GestureDetector(
                    onTap: changed == null ? null : () => changed(type),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
                      decoration: BoxDecoration(
                        color: type == value ? c.bgSurface : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        boxShadow: type == value ? AppShadows.elevation1 : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        label,
                        style: AppTypography.labelLarge.copyWith(
                          color: type == value ? c.textPrimary : c.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SafeAfterPill extends StatelessWidget {
  const _SafeAfterPill({required this.text, required this.danger});

  final String text;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (bg, fg) = danger ? (c.bgDangerSubtle, c.textDanger) : (c.bgBrandSubtle, c.textBrand);
    return DecoratedBox(
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadius.full)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: AppSpacing.s4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(AppIcons.shieldCheck, size: 14, color: fg),
            const SizedBox(width: 6),
            Flexible(
              child: Text(text, style: AppTypography.labelMedium.copyWith(color: fg)),
            ),
          ],
        ),
      ),
    );
  }
}

typedef _TileItem = ({String label, IconData icon, Tone tone, bool selected, VoidCallback? onTap});

/// Deretan kategori (atau akun tujuan) yang bisa di-scroll ke samping;
/// yang terpilih diberi cincin (Figma `Categories`).
class _TileStrip extends StatelessWidget {
  const _TileStrip({required this.items, required this.emptyText});

  final List<_TileItem> items;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    if (items.isEmpty) {
      return Center(
        child: Text(emptyText, style: AppTypography.bodySmall.copyWith(color: c.textTertiary)),
      );
    }
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.s8),
      itemBuilder: (context, index) {
        final item = items[index];
        return Semantics(
          button: true,
          selected: item.selected,
          label: item.label,
          excludeSemantics: true,
          child: InkWell(
            onTap: item.onTap,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: SizedBox(
              width: 64,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: item.selected ? c.borderFocus : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: CategoryTile(icon: item.icon, tone: item.tone),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: item.selected
                        ? AppTypography.labelMedium.copyWith(color: c.textPrimary)
                        : AppTypography.labelSmall.copyWith(color: c.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Keypad nominal 3 × 4 (Figma `Keypad`). Tahan tombol hapus untuk mengosongkan.
class _Keypad extends StatelessWidget {
  const _Keypad({required this.onKey, required this.onClear});

  final ValueChanged<String> onKey;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      children: [
        for (var row = 0; row < 4; row++) ...[
          if (row > 0) const SizedBox(height: AppSpacing.s8),
          Row(
            children: [
              for (var col = 0; col < 3; col++) ...[
                if (col > 0) const SizedBox(width: AppSpacing.s8),
                Expanded(
                  child: _KeypadKey(
                    keyLabel: keypadKeys[row * 3 + col],
                    background: c.bgCanvas,
                    onTap: onKey,
                    onLongPress: keypadKeys[row * 3 + col] == 'del' ? onClear : null,
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _KeypadKey extends StatelessWidget {
  const _KeypadKey({
    required this.keyLabel,
    required this.background,
    required this.onTap,
    this.onLongPress,
  });

  final String keyLabel;
  final Color background;
  final ValueChanged<String> onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isDelete = keyLabel == 'del';
    return Semantics(
      button: true,
      label: isDelete ? 'Hapus satu angka' : keyLabel,
      excludeSemantics: true,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: () => onTap(keyLabel),
          onLongPress: onLongPress,
          child: SizedBox(
            height: 52,
            child: Center(
              child: isDelete
                  ? Icon(AppIcons.backspace, color: c.iconPrimary)
                  : Text(keyLabel, style: AppTypography.keypad.copyWith(color: c.textPrimary)),
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountPicker extends StatelessWidget {
  const _AccountPicker({required this.accounts, required this.selected});

  final List<AccountBalance> accounts;
  final int? selected;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: AppSpacing.s16),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.s24, 0, AppSpacing.s24, AppSpacing.s8),
            child: Text(
              'Pilih akun',
              style: AppTypography.headlineSmall.copyWith(color: c.textPrimary),
            ),
          ),
          for (final entry in accounts)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
              leading: CategoryTile(
                icon: AppIcons.named(entry.account.icon),
                tone: entry.account.tone,
              ),
              title: Text(entry.account.name),
              subtitle: Text(formatRupiah(entry.balance)),
              trailing: entry.account.id == selected
                  ? Icon(AppIcons.check, color: c.textBrand)
                  : null,
              onTap: () => Navigator.pop(context, entry.account.id),
            ),
        ],
      ),
    );
  }
}

class _NoteDialog extends StatefulWidget {
  const _NoteDialog({required this.initial});

  final String initial;

  @override
  State<_NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<_NoteDialog> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Catatan'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 80,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(hintText: 'Mis. makan siang'),
        onSubmitted: (value) => Navigator.pop(context, value),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
