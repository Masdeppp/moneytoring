import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

const databaseFileName = 'keuangan.db';

/// Membuka database terenkripsi (SQLite3MultipleCiphers) di folder privat
/// aplikasi. Enkripsi diaktifkan lewat blok `hooks` di `pubspec.yaml`.
QueryExecutor openEncryptedDatabase({DatabaseKeyStore keyStore = const DatabaseKeyStore()}) {
  return LazyDatabase(() async {
    final dir = await getApplicationSupportDirectory();
    final file = File(p.join(dir.path, databaseFileName));

    // Android melarang folder /tmp bawaan sqlite3.
    sqlite3.tempDirectory = (await getTemporaryDirectory()).path;

    // TODO(fase-1): kalau kunci hilang tapi file masih ada (mis. setelah
    // restore HP), pembukaan gagal dengan "file is not a database".
    // Tampilkan alur pulihkan-dari-backup, jangan hapus file diam-diam.
    final key = await keyStore.readOrCreate();
    return NativeDatabase.createInBackground(file, setup: (db) => applyEncryptionKey(db, key));
  });
}

/// Memasang kunci sebelum Drift menyentuh database.
///
/// Gagal keras kalau SQLite yang terpasang tidak mendukung enkripsi, supaya
/// data tidak pernah tersimpan tanpa enkripsi tanpa disadari.
void applyEncryptionKey(Database db, String hexKey) {
  if (!_hexKey.hasMatch(hexKey)) {
    throw ArgumentError.value('<redacted>', 'hexKey', 'harus 64 karakter hex');
  }
  if (!hasCipherSupport(db)) {
    throw StateError(
      'SQLite tidak mendukung enkripsi. Pastikan pubspec.yaml punya '
      'hooks: user_defines: sqlite3: source: sqlite3mc',
    );
  }
  // Aman disisipkan langsung: kunci sudah divalidasi hanya berisi hex.
  db.execute("PRAGMA key = '$hexKey';");
}

/// `PRAGMA cipher` hanya ada di build SQLite yang mendukung enkripsi.
bool hasCipherSupport(Database db) => db.select('PRAGMA cipher;').isNotEmpty;

final _hexKey = RegExp(r'^[0-9a-f]{64}$');

/// 32 byte acak dalam bentuk 64 karakter hex.
String generateHexKey([Random? random]) {
  final r = random ?? Random.secure();
  return List.generate(32, (_) => r.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
}

/// Menyimpan kunci database di Android Keystore (lewat flutter_secure_storage).
///
/// Kunci ini ikut hilang saat aplikasi di-uninstall, jadi fitur backup harus
/// memakai password pilihan pengguna, bukan kunci ini.
class DatabaseKeyStore {
  const DatabaseKeyStore({this._storage = const FlutterSecureStorage()});

  final FlutterSecureStorage _storage;

  static const _keyName = 'db_key_v1';

  Future<String> readOrCreate() async {
    final existing = await _storage.read(key: _keyName);
    if (existing != null) return existing;
    final key = generateHexKey();
    await _storage.write(key: _keyName, value: key);
    return key;
  }
}
