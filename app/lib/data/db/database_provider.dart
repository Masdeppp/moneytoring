import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';
import 'connection.dart';

/// Satu instance database untuk seluruh aplikasi. Di test, override dengan
/// `AppDatabase(NativeDatabase.memory())`.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(openEncryptedDatabase());
  ref.onDispose(db.close);
  return db;
});

typedef DatabaseStatus = ({String cipher, int categoryCount});

/// Cek cepat bahwa database bisa dibuka dan enkripsinya aktif (dipakai di
/// tile debug Beranda untuk verifikasi di HP).
final databaseStatusProvider = FutureProvider<DatabaseStatus>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final cipher = await db.customSelect('PRAGMA cipher').getSingleOrNull();
  final count = await db.customSelect('SELECT COUNT(*) AS c FROM categories').getSingle();
  return (
    cipher: cipher?.data.values.first?.toString() ?? 'tidak ada',
    categoryCount: count.read<int>('c'),
  );
});
