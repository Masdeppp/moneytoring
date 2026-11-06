import 'dart:io';
import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keuangan_app/data/db/app_database.dart';
import 'package:keuangan_app/data/db/connection.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('SQLite yang terpasang mendukung enkripsi (hooks sqlite3mc aktif)', () {
    final db = sqlite3.openInMemory();
    addTearDown(db.close);
    expect(hasCipherSupport(db), isTrue);
  });

  test('file terenkripsi tidak bisa dibaca tanpa kunci yang benar', () async {
    final dir = await Directory.systemTemp.createTemp('keuangan_test');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}${Platform.pathSeparator}test.db');
    final key = generateHexKey();

    final first = AppDatabase(NativeDatabase(file, setup: (raw) => applyEncryptionKey(raw, key)));
    expect(await first.select(first.categories).get(), hasLength(defaultCategories.length));
    await first.close();

    // File SQLite biasa diawali "SQLite format 3"; file terenkripsi tidak.
    final header = String.fromCharCodes(file.readAsBytesSync().take(15));
    expect(header, isNot('SQLite format 3'));

    final wrongKey = sqlite3.open(file.path);
    addTearDown(wrongKey.close);
    wrongKey.execute("PRAGMA key = '${generateHexKey()}';");
    expect(
      () => wrongKey.select('SELECT COUNT(*) FROM categories'),
      throwsA(isA<SqliteException>()),
    );

    final reopened = AppDatabase(
      NativeDatabase(file, setup: (raw) => applyEncryptionKey(raw, key)),
    );
    addTearDown(reopened.close);
    expect(await reopened.select(reopened.categories).get(), hasLength(defaultCategories.length));
  });

  test('kunci yang bukan hex ditolak sebelum menyentuh SQL', () {
    final db = sqlite3.openInMemory();
    addTearDown(db.close);
    expect(() => applyEncryptionKey(db, "x'; DROP TABLE categories; --"), throwsArgumentError);
  });

  test('generateHexKey menghasilkan 64 karakter hex yang berbeda-beda', () {
    final a = generateHexKey();
    final b = generateHexKey(Random(1));
    expect(a, matches(RegExp(r'^[0-9a-f]{64}$')));
    expect(b, matches(RegExp(r'^[0-9a-f]{64}$')));
    expect(a, isNot(b));
  });
}
