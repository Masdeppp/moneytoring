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

typedef DatabaseStatus = ({String cipher, int schemaVersion, int categoryCount});

/// Cek cepat bahwa database bisa dibuka, enkripsinya aktif, dan migrasinya
/// sudah jalan (dipakai di tile debug Beranda untuk verifikasi di HP).
final databaseStatusProvider = FutureProvider<DatabaseStatus>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final cipher = await db.customSelect('PRAGMA cipher').getSingleOrNull();
  final version = await db.customSelect('PRAGMA user_version').getSingle();
  final count = await db.customSelect('SELECT COUNT(*) AS c FROM categories').getSingle();
  return (
    cipher: cipher?.data.values.first?.toString() ?? 'tidak ada',
    schemaVersion: version.data.values.first as int,
    categoryCount: count.read<int>('c'),
  );
});
