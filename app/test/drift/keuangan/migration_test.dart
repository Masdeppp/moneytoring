import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keuangan_app/core/model/enums.dart';
import 'package:keuangan_app/data/db/app_database.dart';

import 'generated/schema.dart';
import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;
import 'generated/schema_v3.dart' as v3;

// Test migrasi skema. Snapshot di `generated/` dibuat ulang oleh
// `dart run drift_dev make-migrations` setiap kali schemaVersion naik;
// tambahkan test data untuk migrasi baru di bawah.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  group('skema hasil migrasi sama dengan skema terbaru', () {
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      for (final toVersion in versions.skip(i + 1)) {
        test('v$fromVersion → v$toVersion', () async {
          final schema = await verifier.schemaAt(fromVersion);
          final db = AppDatabase(schema.newConnection());
          await verifier.migrateAndValidate(db, toVersion);
          await db.close();
        });
      }
    }
  });

  test('v1 → v2 mempertahankan data dan relasinya', () async {
    final schema = await verifier.schemaAt(1);
    final oldDb = v1.DatabaseAtV1(schema.newConnection());
    for (final sql in [
      '''INSERT INTO accounts (id, name, type, initial_balance, icon)
         VALUES (1, 'BCA', 'bank', 3000000, 'landmark')''',
      '''INSERT INTO categories (id, name, type, icon, tone)
         VALUES (1, 'Tempat tinggal', 'expense', 'house', 'brand')''',
      '''INSERT INTO pay_cycle_configs (id, payday_rule, day, shift_on_holiday, expected_income)
         VALUES (1, 'fixedDate', 25, 1, 7500000)''',
      '''INSERT INTO obligations (id, name, amount_type, amount, due_day, category_id, account_id)
         VALUES (1, 'Kos', 'fixed', 1000000, 1, 1, 1)''',
      '''INSERT INTO obligation_instances
           (id, obligation_id, cycle_start, due_date, expected_amount, status)
         VALUES (1, 1, '2026-10-25T00:00:00.000Z', '2026-11-01T00:00:00.000Z', 1000000, 'paid')''',
      '''INSERT INTO transactions
           (id, type, amount, account_id, category_id, date, obligation_instance_id)
         VALUES (1, 'expense', 1000000, 1, 1, '2026-11-01T02:00:00.000Z', 1)''',
    ]) {
      await oldDb.customStatement(sql);
    }
    await oldDb.close();

    final migratedAt = DateTime.now();
    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 2);

    final account = await db.select(db.accounts).getSingle();
    expect(account.name, 'BCA');
    expect(account.initialBalance, 3000000);
    expect(account.includeInSafeToSpend, isTrue);

    final config = await db.select(db.payCycleConfigs).getSingle();
    expect(config.paydayRule, PaydayRule.fixedDate);
    expect(config.day, 25);
    expect(config.expectedIncome, 7500000);
    expect(config.bufferBasisPoints, 500);
    expect(config.trackingSince.difference(migratedAt).inMinutes.abs(), lessThan(1));

    final obligation = await db.select(db.obligations).getSingle();
    expect(obligation.name, 'Kos');
    expect(obligation.startsOn.difference(migratedAt).inMinutes.abs(), lessThan(1));

    // Membuat ulang tabel obligations tidak boleh ikut menghapus instance
    // lewat ON DELETE CASCADE.
    final instance = await db.select(db.obligationInstances).getSingle();
    expect(instance.obligationId, 1);
    expect(instance.dueDate, DateTime.utc(2026, 11, 1));
    expect(instance.status, ObligationStatus.paid);

    final transaction = await db.select(db.transactions).getSingle();
    expect(transaction.obligationInstanceId, instance.id);

    final foreignKeys = await db.customSelect('PRAGMA foreign_keys').getSingle();
    expect(foreignKeys.data.values.single, 1, reason: 'foreign key aktif lagi setelah migrasi');
    await db.close();
  });

  test('v2 → v3: target tunggal menjadi target bernama tanpa tenggat', () async {
    final schema = await verifier.schemaAt(2);
    final oldDb = v2.DatabaseAtV2(schema.newConnection());
    for (final sql in [
      '''INSERT INTO accounts (id, name, type, initial_balance, icon, include_in_safe_to_spend)
         VALUES (1, 'BCA', 'bank', 3000000, 'landmark', 1),
                (2, 'Tabungan', 'bank', 0, 'piggy-bank', 0)''',
      '''INSERT INTO savings_targets (id, amount_per_cycle, account_id) VALUES (1, 500000, 2)''',
    ]) {
      await oldDb.customStatement(sql);
    }
    await oldDb.close();

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 3);

    final goal = await db.select(db.savingsGoals).getSingle();
    expect(goal.name, 'Tabungan');
    expect(goal.amountPerCycle, 500000);
    expect(goal.accountId, 2);
    expect(goal.targetAmount, isNull);
    expect(goal.deadline, isNull);
    expect(goal.archived, isFalse);
    expect(await db.select(db.goalContributions).get(), isEmpty);
    await db.close();
  });

  test('v3 → v4: target lama tetap target biasa, setorannya utuh', () async {
    final schema = await verifier.schemaAt(3);
    final oldDb = v3.DatabaseAtV3(schema.newConnection());
    for (final sql in [
      '''INSERT INTO savings_goals (id, name, amount_per_cycle) VALUES (1, 'Dana darurat', 500000)''',
      '''INSERT INTO goal_contributions (id, goal_id, amount, date)
         VALUES (1, 1, 250000, '2026-11-01T00:00:00.000Z')''',
    ]) {
      await oldDb.customStatement(sql);
    }
    await oldDb.close();

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 4);

    final goal = await db.select(db.savingsGoals).getSingle();
    expect(goal.name, 'Dana darurat');
    expect(goal.amountPerCycle, 500000);
    expect(goal.salaryBasisPoints, isNull);
    expect(goal.settledThrough, isNull);
    expect((await db.select(db.goalContributions).getSingle()).amount, 250000);
    await db.close();
  });
}
