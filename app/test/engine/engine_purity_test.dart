import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

/// PRD §10.1: engine adalah pure Dart supaya bisa dites tanpa Flutter dan
/// dijalankan di isolate. Engine hanya boleh mengimpor `dart:` (kecuali
/// `dart:ui`), file engine lain, dan model domain di `lib/core/model/`.
void main() {
  test('lib/engine tidak mengimpor Flutter atau kode UI', () {
    final files = Directory('lib/engine')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .toList();
    expect(files, isNotEmpty);

    final importPattern = RegExp(r'''^import\s+'([^']+)';''');
    final offenders = <String>[];
    for (final file in files) {
      for (final line in file.readAsLinesSync()) {
        final uri = importPattern.firstMatch(line)?.group(1);
        if (uri != null && !_allowed(file.path, uri)) offenders.add('${file.path}: $uri');
      }
    }
    expect(offenders, isEmpty);
  });
}

bool _allowed(String importer, String uri) {
  if (uri.startsWith('dart:')) return uri != 'dart:ui';
  final String target;
  if (uri.startsWith('package:keuangan_app/')) {
    target = p.join('lib', uri.substring('package:keuangan_app/'.length));
  } else if (uri.startsWith('package:')) {
    return false;
  } else {
    target = p.join(p.dirname(importer), uri);
  }
  final normalized = p.normalize(target).replaceAll(r'\', '/');
  return normalized.startsWith('lib/engine/') || normalized.startsWith('lib/core/model/');
}
