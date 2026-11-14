import 'package:flutter/material.dart';

import '../../../core/model/enums.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/list_items.dart';
import '../../../data/repositories/transaction_repository.dart';

/// Satu transaksi sebagai baris daftar (Figma `ListItem/Transaction`):
/// catatan sebagai judul kalau ada, kategori dan akun sebagai subjudul.
TransactionListItem transactionListItem(
  BuildContext context,
  TransactionView view, {
  VoidCallback? onTap,
}) {
  final c = context.colors;
  final t = view.transaction;
  final note = t.note.trim();
  switch (t.type) {
    case TransactionType.transfer:
      return TransactionListItem(
        title: note.isEmpty ? 'Transfer' : note,
        subtitle: '${view.account.name} → ${view.toAccount?.name ?? '?'}',
        amount: formatRupiah(t.amount),
        amountColor: c.textSecondary,
        icon: AppIcons.arrowLeftRight,
        tone: Tone.neutral,
        onTap: onTap,
      );
    case TransactionType.expense:
    case TransactionType.income:
      final category = view.category;
      final categoryName = category?.name ?? 'Tanpa kategori';
      final expense = t.type == TransactionType.expense;
      return TransactionListItem(
        title: note.isEmpty ? categoryName : note,
        subtitle: note.isEmpty ? view.account.name : '$categoryName · ${view.account.name}',
        amount: expense ? formatRupiah(-t.amount) : formatRupiah(t.amount, signed: true),
        amountColor: expense ? c.textPrimary : c.textIncome,
        icon: AppIcons.named(category?.icon ?? 'ellipsis'),
        tone: category?.tone ?? Tone.neutral,
        onTap: onTap,
      );
  }
}
