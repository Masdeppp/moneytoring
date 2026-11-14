import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/model/enums.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/rupiah_field.dart';
import '../../../core/widgets/switch_row.dart';
import '../../../data/providers.dart';
import '../../../data/repositories/account_repository.dart';
import '../../../data/repositories/obligation_repository.dart';
import '../../../engine/common/local_date.dart';

/// Mencatat pembayaran satu jatuh tempo ("Tandai lunas"). Pembayarannya
/// menjadi transaksi pengeluaran yang terhubung ke kewajiban, lalu snackbar
/// menampilkan hasilnya.
Future<void> showObligationPaymentSheet(BuildContext context, ObligationDueView due) async {
  // Snackbar pembayaran sebelumnya jangan sampai menutupi tombol Simpan.
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  final message = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => ObligationPaymentSheet(due: due),
  );
  if (message != null && context.mounted) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class ObligationPaymentSheet extends ConsumerStatefulWidget {
  const ObligationPaymentSheet({super.key, required this.due});

  final ObligationDueView due;

  @override
  ConsumerState<ObligationPaymentSheet> createState() => _ObligationPaymentSheetState();
}

class _ObligationPaymentSheetState extends ConsumerState<ObligationPaymentSheet> {
  late int _amount = widget.due.remaining;
  late int? _accountId = widget.due.accountId;
  late LocalDate _date = _today;

  /// Untuk nominal di bawah sisa: lunas (tagihan ternyata lebih kecil) atau
  /// cicilan. Kewajiban berubah-ubah biasanya lunas.
  late bool _settle = widget.due.amountType == ObligationAmountType.estimated;
  var _saving = false;

  LocalDate get _today => LocalDate.fromDateTime(ref.read(clockProvider)());

  @override
  void initState() {
    super.initState();
    if (_accountId == null) unawaited(_loadLastAccount());
  }

  Future<void> _loadLastAccount() async {
    final last = await ref
        .read(transactionRepositoryProvider)
        .lastUsedAccountId(TransactionType.expense);
    if (mounted && _accountId == null && last != null) setState(() => _accountId = last);
  }

  bool get _short => _amount > 0 && _amount < widget.due.remaining;

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

  Future<void> _save(int accountId) async {
    setState(() => _saving = true);
    final due = widget.due;
    final settles = !_short || _settle;
    try {
      final now = ref.read(clockProvider)();
      await ref
          .read(obligationRepositoryProvider)
          .recordPayment(
            instanceId: due.instanceId,
            accountId: accountId,
            amount: _amount,
            date: _date == LocalDate.fromDateTime(now)
                ? now
                : DateTime(_date.year, _date.month, _date.day, 12),
            markPaid: _short && _settle,
          );
      if (!mounted) return;
      Navigator.pop(
        context,
        settles
            ? '${due.obligationName} tercatat lunas.'
            : 'Pembayaran ${due.obligationName} tercatat. '
                  'Sisa ${formatRupiah(due.remaining - _amount)} tetap dicadangkan.',
      );
    } on Object catch (error, stackTrace) {
      debugPrint('Pembayaran kewajiban gagal disimpan: $error\n$stackTrace');
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Belum tersimpan. Coba sekali lagi.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final due = widget.due;
    final today = LocalDate.fromDateTime(ref.watch(clockProvider)());
    final accounts = ref.watch(accountBalancesProvider).value ?? const <AccountBalance>[];
    final selected = accounts.any((entry) => entry.account.id == _accountId)
        ? _accountId
        : accounts.firstOrNull?.account.id;
    Widget label(String text) =>
        Text(text, style: AppTypography.labelMedium.copyWith(color: c.textSecondary));

    final subtitle = [
      'Jatuh tempo ${formatDue(due.dueDate, today)}',
      if (due.paidAmount > 0) 'sudah dibayar ${formatRupiah(due.paidAmount)}',
    ].join(' · ');
    final rest = formatRupiah(due.remaining - _amount);

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
            Text(
              'Bayar ${due.obligationName}',
              style: AppTypography.headlineSmall.copyWith(color: c.textPrimary),
            ),
            const SizedBox(height: AppSpacing.s4),
            Text(subtitle, style: AppTypography.bodyMedium.copyWith(color: c.textSecondary)),
            const SizedBox(height: AppSpacing.s16),
            RupiahField(
              label: 'Nominal dibayar',
              value: _amount,
              onChanged: (amount) => setState(() => _amount = amount),
            ),
            if (_short) ...[
              const SizedBox(height: AppSpacing.s8),
              SwitchRow(
                title: 'Tandai lunas',
                subtitle: _settle
                    ? 'Sisa $rest tidak dicadangkan lagi, mis. tagihan ternyata lebih kecil.'
                    : 'Dicatat sebagai cicilan; sisa $rest tetap dicadangkan.',
                value: _settle,
                onChanged: (value) => setState(() => _settle = value),
              ),
            ],
            const SizedBox(height: AppSpacing.s16),
            label('Dibayar dari'),
            const SizedBox(height: AppSpacing.s8),
            Wrap(
              spacing: AppSpacing.s8,
              runSpacing: AppSpacing.s8,
              children: [
                for (final entry in accounts)
                  ChoiceChip(
                    avatar: Icon(AppIcons.named(entry.account.icon), size: 18),
                    label: Text(entry.account.name),
                    selected: entry.account.id == selected,
                    onSelected: (_) => setState(() => _accountId = entry.account.id),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.s16),
            label('Tanggal bayar'),
            const SizedBox(height: AppSpacing.s8),
            Align(
              alignment: Alignment.centerLeft,
              child: ActionChip(
                avatar: const Icon(AppIcons.calendar, size: 18),
                label: Text(formatRelativeDay(_date, today)),
                onPressed: () => unawaited(_pickDate()),
              ),
            ),
            const SizedBox(height: AppSpacing.s24),
            FilledButton(
              onPressed: _saving || _amount <= 0 || selected == null
                  ? null
                  : () => unawaited(_save(selected)),
              child: _saving
                  ? SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: c.textOnBrand),
                    )
                  : const Text('Simpan pembayaran'),
            ),
          ],
        ),
      ),
    );
  }
}
