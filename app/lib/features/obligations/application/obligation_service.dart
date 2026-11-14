import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/model/enums.dart';
import '../../../data/providers.dart';
import '../../../data/repositories/obligation_repository.dart';
import '../../../data/repositories/pay_cycle_repository.dart';
import '../../../engine/common/local_date.dart';
import '../../../engine/cycle/holiday_calendar.dart';
import '../../../engine/cycle/pay_cycle.dart';

/// Isian editor kewajiban yang sudah divalidasi.
typedef ObligationInput = ({
  String name,
  ObligationAmountType amountType,
  int amount,
  int dueDay,
  int categoryId,
});

/// Menambah, mengubah, dan menghapus kewajiban dari layar 08, lalu langsung
/// membuat jatuh temponya supaya timeline dan Safe-to-Spend ikut berubah
/// tanpa menunggu Beranda menghitung ulang.
class ObligationService {
  ObligationService({
    required this._obligations,
    required this._payCycles,
    required this._holidays,
  });

  final ObligationRepository _obligations;
  final PayCycleRepository _payCycles;
  final HolidayCalendar _holidays;

  /// Jatuh tempo sebelum [today] dianggap sudah diurus sebelum kewajiban
  /// dicatat, sama seperti saat onboarding.
  Future<int> create(ObligationInput input, {required LocalDate today}) async {
    final id = await _obligations.create(
      name: input.name,
      amountType: input.amountType,
      amount: input.amount,
      dueDay: input.dueDay,
      categoryId: input.categoryId,
      startsOn: today,
    );
    await _ensureInstances(today);
    return id;
  }

  Future<void> update(int id, ObligationInput input, {required LocalDate today}) async {
    await _obligations.update(
      id,
      name: input.name,
      amountType: input.amountType,
      amount: input.amount,
      dueDay: input.dueDay,
      categoryId: input.categoryId,
      today: today,
    );
    await _ensureInstances(today);
  }

  /// Riwayat pembayarannya tetap ada di Transaksi, hanya tidak lagi terhubung.
  Future<void> delete(int id) => _obligations.delete(id);

  Future<void> _ensureInstances(LocalDate today) async {
    final config = await _payCycles.current();
    if (config == null) return;
    final calculator = PayCycleCalculator(PayCycleRepository.ruleOf(config), holidays: _holidays);
    await _obligations.ensureInstances(calculator: calculator, today: today);
  }
}

final obligationServiceProvider = Provider<ObligationService>(
  (ref) => ObligationService(
    obligations: ref.watch(obligationRepositoryProvider),
    payCycles: ref.watch(payCycleRepositoryProvider),
    holidays: ref.watch(holidayCalendarProvider),
  ),
);
