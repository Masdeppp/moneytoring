import 'package:flutter_test/flutter_test.dart';
import 'package:keuangan_app/core/model/enums.dart';
import 'package:keuangan_app/engine/common/local_date.dart';
import 'package:keuangan_app/engine/safe_to_spend/safe_to_spend.dart';

LocalDate d(int y, int m, int day) => LocalDate(y, m, day);

void main() {
  final nextPayday = d(2026, 11, 25);

  group('Lampiran A PRD', () {
    // Hari ini 11 Nov, gajian 25 Nov, saldo Rp 3.000.000.
    final dues = [
      ObligationDue(dueDate: d(2026, 11, 20), expectedAmount: 350000), // Listrik
      ObligationDue(dueDate: d(2026, 11, 25), expectedAmount: 850000), // Cicilan motor
      ObligationDue(dueDate: d(2026, 11, 25), expectedAmount: 1000000), // Kos
    ];

    test('kewajiban belum dibayar sebelum 25 Nov = Rp 2.200.000', () {
      expect(reservedForObligations(dues, nextPayday), 2200000);
    });

    test('Safe-to-Spend Rp 760.000 dan jatah harian Rp 54.285', () {
      final result = calculateSafeToSpend(
        availableBalance: 3000000,
        obligationsReserved: reservedForObligations(dues, nextPayday),
        daysLeft: 14,
      );

      expect(result.availableBalance, 3000000);
      expect(result.obligationsReserved, 2200000);
      expect(result.savingsReserved, 0);
      expect(result.buffer, 40000);
      expect(result.amount, 760000);
      expect(result.dailyAllowance, 54285);
      expect(result.daysLeft, 14);
      expect(result.isNegative, isFalse);
    });
  });

  group('reservedForObligations', () {
    test('yang lunas atau dilewati tidak dicadangkan', () {
      final dues = [
        ObligationDue(
          dueDate: d(2026, 11, 1),
          expectedAmount: 1000000,
          status: ObligationStatus.paid,
        ),
        ObligationDue(
          dueDate: d(2026, 11, 5),
          expectedAmount: 200000,
          status: ObligationStatus.skipped,
        ),
        ObligationDue(dueDate: d(2026, 11, 20), expectedAmount: 350000),
      ];
      expect(reservedForObligations(dues, nextPayday), 350000);
    });

    test('yang terlambat tetap dicadangkan', () {
      final dues = [
        ObligationDue(
          dueDate: d(2026, 10, 20),
          expectedAmount: 300000,
          status: ObligationStatus.late,
        ),
      ];
      expect(reservedForObligations(dues, nextPayday), 300000);
    });

    test('pembayaran sebagian mengurangi yang dicadangkan, kelebihan bayar jadi 0', () {
      final dues = [
        ObligationDue(dueDate: d(2026, 11, 25), expectedAmount: 850000, paidAmount: 350000),
        ObligationDue(dueDate: d(2026, 11, 20), expectedAmount: 350000, paidAmount: 400000),
      ];
      expect(reservedForObligations(dues, nextPayday), 500000);
    });

    test('jatuh tempo setelah gajian berikutnya tidak dicadangkan', () {
      final dues = [ObligationDue(dueDate: d(2026, 11, 26), expectedAmount: 500000)];
      expect(reservedForObligations(dues, nextPayday), 0);
    });
  });

  test('sisa target tabungan tidak pernah negatif', () {
    expect(remainingSavingsTarget(targetPerCycle: 500000, savedThisCycle: 200000), 300000);
    expect(remainingSavingsTarget(targetPerCycle: 500000, savedThisCycle: 700000), 0);
  });

  group('calculateSafeToSpend', () {
    test('target tabungan dikurangkan sebelum buffer', () {
      final result = calculateSafeToSpend(
        availableBalance: 3000000,
        obligationsReserved: 2200000,
        savingsReserved: 300000,
        daysLeft: 14,
      );
      expect(result.buffer, 25000);
      expect(result.amount, 475000);
    });

    test('negatif saat kewajiban tidak tertutup, tanpa buffer dan jatah harian', () {
      final result = calculateSafeToSpend(
        availableBalance: 2000000,
        obligationsReserved: 2200000,
        daysLeft: 14,
      );
      expect(result.buffer, 0);
      expect(result.amount, -200000);
      expect(result.dailyAllowance, 0);
      expect(result.isNegative, isTrue);
    });

    test('buffer dibulatkan ke atas', () {
      final result = calculateSafeToSpend(
        availableBalance: 999,
        obligationsReserved: 0,
        daysLeft: 1,
      );
      expect(result.buffer, 50);
      expect(result.amount, 949);
    });

    test('buffer bisa dimatikan', () {
      final result = calculateSafeToSpend(
        availableBalance: 1000000,
        obligationsReserved: 0,
        daysLeft: 10,
        bufferBasisPoints: 0,
      );
      expect(result.amount, 1000000);
      expect(result.dailyAllowance, 100000);
    });

    test('masukan tidak valid ditolak', () {
      expect(
        () => calculateSafeToSpend(availableBalance: 0, obligationsReserved: 0, daysLeft: 0),
        throwsRangeError,
      );
      expect(
        () => calculateSafeToSpend(availableBalance: 0, obligationsReserved: -1, daysLeft: 1),
        throwsArgumentError,
      );
      expect(
        () => calculateSafeToSpend(
          availableBalance: 0,
          obligationsReserved: 0,
          savingsReserved: -1,
          daysLeft: 1,
        ),
        throwsArgumentError,
      );
      expect(
        () => calculateSafeToSpend(
          availableBalance: 0,
          obligationsReserved: 0,
          daysLeft: 1,
          bufferBasisPoints: 10001,
        ),
        throwsRangeError,
      );
    });
  });
}
