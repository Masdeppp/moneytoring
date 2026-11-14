/// Tombol keypad nominal (Figma layar 06): 1–9, `000`, `0`, dan hapus.
const keypadKeys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '000', '0', 'del'];

/// Batas 13 digit, sama dengan isian Rupiah lainnya.
const _maxAmount = 9999999999999;

/// Nominal setelah [key] ditekan. Tombol yang membuat nominal melebihi batas
/// diabaikan.
int applyKeypadKey(int amount, String key) {
  final next = switch (key) {
    'del' => amount ~/ 10,
    '000' => amount * 1000,
    _ => amount * 10 + int.parse(key),
  };
  return next > _maxAmount ? amount : next;
}
