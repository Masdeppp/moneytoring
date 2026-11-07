import 'enums.dart';

/// Tampilan bawaan per jenis akun. Ikon disimpan sebagai nama Lucide di
/// kolom `accounts.icon` dan dipetakan ke `IconData` lewat `AppIcons.named`.
extension AccountTypeDefaults on AccountType {
  String get defaultName => switch (this) {
    AccountType.cash => 'Tunai',
    AccountType.bank => 'Rekening bank',
    AccountType.ewallet => 'E-wallet',
  };

  String get iconName => switch (this) {
    AccountType.cash => 'banknote',
    AccountType.bank => 'landmark',
    AccountType.ewallet => 'wallet',
  };

  Tone get tone => switch (this) {
    AccountType.cash => Tone.amber,
    AccountType.bank => Tone.blue,
    AccountType.ewallet => Tone.violet,
  };
}
