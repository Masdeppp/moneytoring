import 'package:flutter_test/flutter_test.dart';
import 'package:keuangan_app/engine/common/local_date.dart';
import 'package:keuangan_app/engine/cycle/pay_cycle.dart';
import 'package:keuangan_app/engine/safe_to_spend/savings_goal.dart';

LocalDate d(int y, int m, int day) => LocalDate(y, m, day);

void main() {
  final calculator = PayCycleCalculator(PayCycleRule.fixedDate(25, shiftOnHoliday: false));
  final current = calculator.cycleContaining(d(2026, 11, 11)); // 25 Okt – 24 Nov

  group('sisihan gaji', () {
    test('persen dari perkiraan gaji, dibulatkan ke atas', () {
      expect(salaryShare(2000000, 1000), 200000);
      expect(salaryShare(2000000, 0), 0);
      expect(salaryShare(1234567, 500), 61729); // 61.728,35
      expect(() => salaryShare(2000000, 10001), throwsRangeError);
    });

    test('yang ditabung tidak lebih dari sisihan dan tidak negatif', () {
      expect(salaryLeftover(available: 300000, share: 200000), 200000);
      expect(salaryLeftover(available: 150000, share: 200000), 150000);
      expect(salaryLeftover(available: -50000, share: 200000), 0);
    });
  });

  group('cyclesUntil', () {
    test('siklus berjalan sampai siklus yang memuat tenggat, ikut keduanya', () {
      expect(cyclesUntil(calculator, current, d(2026, 11, 20)), 1);
      expect(cyclesUntil(calculator, current, d(2026, 11, 25)), 2); // gajian 25 Nov masuk
      // 25 Okt, 25 Nov, 25 Des, 25 Jan, 25 Feb, 25 Mar (memuat 20 Apr)
      expect(cyclesUntil(calculator, current, d(2027, 4, 20)), 6);
    });

    test('tenggat yang sudah lewat: semuanya dibutuhkan sekarang', () {
      expect(cyclesUntil(calculator, current, d(2026, 1, 1)), 1);
    });

    test('tenggat sangat jauh dibatasi', () {
      expect(cyclesUntil(calculator, current, d(2200, 1, 1)), 600);
    });
  });

  group('planSavingsGoal', () {
    test('bertenggat: sisa dibagi siklus tersisa, dibulatkan ke atas', () {
      final plan = planSavingsGoal(
        target: 6000000,
        cyclesLeft: 6,
        savedBeforeCycle: 1200000,
        savedThisCycle: 0,
        keptInSafeToSpend: false,
      );
      expect(plan.need, 800000);
      expect(plan.reserved, 800000);
      expect(plan.dueThisCycle, 800000);
      expect(plan.saved, 1200000);

      final odd = planSavingsGoal(
        target: 1000000,
        cyclesLeft: 3,
        savedBeforeCycle: 0,
        savedThisCycle: 0,
        keptInSafeToSpend: false,
      );
      expect(odd.need, 333334);
    });

    test('setoran ke rekening yang dikecualikan mengurangi cadangan', () {
      final plan = planSavingsGoal(
        target: 6000000,
        cyclesLeft: 6,
        savedBeforeCycle: 1200000,
        savedThisCycle: 300000,
        keptInSafeToSpend: false,
      );
      expect(plan.reserved, 500000);
      expect(plan.dueThisCycle, 500000);
    });

    test('uang tetap di akun yang dihitung: semua setoran tetap dicadangkan', () {
      final plan = planSavingsGoal(
        target: 6000000,
        cyclesLeft: 6,
        savedBeforeCycle: 1200000,
        savedThisCycle: 300000,
        keptInSafeToSpend: true,
      );
      // 1,5 jt sudah disisihkan + 500 rb sisa setoran siklus ini.
      expect(plan.reserved, 2000000);
    });

    test('tanpa tenggat: setoran per siklus, tidak melebihi sisa target', () {
      expect(
        planSavingsGoal(
          amountPerCycle: 500000,
          savedBeforeCycle: 0,
          savedThisCycle: 0,
          keptInSafeToSpend: false,
        ).need,
        500000,
      );
      expect(
        planSavingsGoal(
          target: 1000000,
          amountPerCycle: 500000,
          savedBeforeCycle: 800000,
          savedThisCycle: 0,
          keptInSafeToSpend: false,
        ).need,
        200000,
      );
    });

    test('target tercapai: tidak ada kebutuhan baru', () {
      final reached = planSavingsGoal(
        target: 1000000,
        cyclesLeft: 2,
        savedBeforeCycle: 1000000,
        savedThisCycle: 0,
        keptInSafeToSpend: false,
      );
      expect(reached.need, 0);
      expect(reached.reserved, 0);
    });

    test('menyetor tidak mengubah Safe-to-Spend', () {
      // Rekening dikecualikan: saldo turun 300 rb, cadangan turun 300 rb.
      int reservedAfter(int saved, {required bool kept}) => planSavingsGoal(
        target: 6000000,
        cyclesLeft: 6,
        savedBeforeCycle: 1200000,
        savedThisCycle: saved,
        keptInSafeToSpend: kept,
      ).reserved;
      expect(reservedAfter(0, kept: false) - reservedAfter(300000, kept: false), 300000);
      // Tanpa rekening: saldo tetap, cadangan juga tetap.
      expect(reservedAfter(0, kept: true), reservedAfter(300000, kept: true));
    });
  });
}
