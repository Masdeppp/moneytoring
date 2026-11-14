import '../../../core/model/enums.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../engine/common/local_date.dart';

/// Transaksi pada satu hari, untuk daftar layar 07.
final class TransactionDay {
  const TransactionDay({required this.date, required this.items, required this.complete});

  final LocalDate date;

  /// Terbaru dulu, sama seperti urutan dari database.
  final List<TransactionView> items;

  /// `false` kalau daftar terpotong batas halaman di hari ini, jadi total
  /// harinya belum bisa ditampilkan.
  final bool complete;

  /// Pemasukan − pengeluaran hari itu. Transfer tidak dihitung.
  int get net => items.fold(0, (sum, view) {
    final t = view.transaction;
    return switch (t.type) {
      TransactionType.income => sum + t.amount,
      TransactionType.expense => sum - t.amount,
      TransactionType.transfer => sum,
    };
  });

  /// Ada pemasukan atau pengeluaran (bukan hanya transfer).
  bool get hasCashFlow => items.any((view) => view.transaction.type != TransactionType.transfer);
}

/// Mengelompokkan [views] (sudah urut terbaru dulu) per tanggal lokal.
/// [truncated] berarti masih ada transaksi lebih lama yang belum dimuat,
/// sehingga hari terakhir mungkin belum lengkap.
List<TransactionDay> groupByDay(List<TransactionView> views, {required bool truncated}) {
  final days = <TransactionDay>[];
  var current = <TransactionView>[];
  LocalDate? date;
  for (final view in views) {
    final day = LocalDate.fromDateTime(view.transaction.date.toLocal());
    if (day != date && date != null) {
      days.add(TransactionDay(date: date, items: current, complete: true));
      current = [];
    }
    date = day;
    current.add(view);
  }
  if (date != null) days.add(TransactionDay(date: date, items: current, complete: !truncated));
  return days;
}
