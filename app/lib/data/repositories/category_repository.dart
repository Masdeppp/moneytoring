import 'package:drift/drift.dart';

import '../../core/model/enums.dart';
import '../db/app_database.dart';

/// Kategori pemasukan/pengeluaran (bawaan + custom).
class CategoryRepository {
  CategoryRepository(this._db);

  final AppDatabase _db;

  SimpleSelectStatement<$CategoriesTable, CategoryRecord> _active(CategoryType? type) =>
      _db.select(_db.categories)
        ..where((c) => c.archived.equals(false))
        ..where((c) => type == null ? const Constant(true) : c.type.equalsValue(type))
        ..orderBy([
          (c) => OrderingTerm(expression: c.sortOrder),
          (c) => OrderingTerm(expression: c.id),
        ]);

  Future<List<CategoryRecord>> active({CategoryType? type}) => _active(type).get();

  Stream<List<CategoryRecord>> watchActive({CategoryType? type}) => _active(type).watch();

  /// Semua kategori, termasuk yang diarsipkan, supaya transaksi dan kewajiban
  /// lama tetap tampil dengan ikon dan warnanya.
  Stream<List<CategoryRecord>> watchAll() =>
      (_db.select(_db.categories)..orderBy([
            (c) => OrderingTerm(expression: c.sortOrder),
            (c) => OrderingTerm(expression: c.id),
          ]))
          .watch();

  Future<int> create({
    required String name,
    required CategoryType type,
    required String icon,
    required Tone tone,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw ArgumentError.value(name, 'name', 'tidak boleh kosong');
    final max = _db.categories.sortOrder.max();
    final row = await (_db.selectOnly(_db.categories)..addColumns([max])).getSingle();
    return _db
        .into(_db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: trimmed,
            type: type,
            icon: icon,
            tone: tone,
            sortOrder: Value((row.read(max) ?? -1) + 1),
          ),
        );
  }

  /// Ubah nama, ikon, atau warna. Jenisnya tetap, supaya transaksi lama tidak
  /// berpindah antara pemasukan dan pengeluaran.
  Future<void> update(int id, {String? name, String? icon, Tone? tone}) async {
    final trimmed = name?.trim();
    if (trimmed != null && trimmed.isEmpty) {
      throw ArgumentError.value(name, 'name', 'tidak boleh kosong');
    }
    final updated = await (_db.update(_db.categories)..where((c) => c.id.equals(id))).write(
      CategoriesCompanion(
        name: Value.absentIfNull(trimmed),
        icon: Value.absentIfNull(icon),
        tone: Value.absentIfNull(tone),
      ),
    );
    if (updated == 0) throw StateError('Kategori $id tidak ditemukan');
  }

  /// Kategori diarsipkan, bukan dihapus, supaya transaksi lama tetap berkategori.
  Future<void> archive(int id) => (_db.update(
    _db.categories,
  )..where((c) => c.id.equals(id))).write(const CategoriesCompanion(archived: Value(true)));
}
