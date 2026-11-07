import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keuangan_app/core/router/app_router.dart';

void main() {
  const loading = AsyncLoading<bool>();
  const done = AsyncData(true);
  const fresh = AsyncData(false);

  test('selama status belum diketahui, semua ke layar loading', () {
    expect(onboardingRedirect(loading, Routes.home), Routes.loading);
    expect(onboardingRedirect(loading, Routes.loading), isNull);
    expect(
      onboardingRedirect(AsyncError<bool>(StateError('db'), StackTrace.empty), Routes.home),
      Routes.loading,
    );
  });

  test('pengguna baru selalu ke onboarding', () {
    expect(onboardingRedirect(fresh, Routes.home), Routes.onboarding);
    expect(onboardingRedirect(fresh, Routes.loading), Routes.onboarding);
    expect(onboardingRedirect(fresh, Routes.onboarding), isNull);
  });

  test('pengguna lama tidak bisa kembali ke onboarding', () {
    expect(onboardingRedirect(done, Routes.onboarding), Routes.home);
    expect(onboardingRedirect(done, Routes.loading), Routes.home);
    expect(onboardingRedirect(done, Routes.transactions), isNull);
  });
}
