import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';
import '../theme/app_typography.dart';
import '../theme/theme_context.dart';
import '../utils/rupiah_input.dart';

/// Isian nominal Rupiah (Figma `Input`): label di atas, awalan "Rp", titik
/// ribuan otomatis. Nilainya selalu `int`.
class RupiahField extends StatefulWidget {
  const RupiahField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.autofocus = false,
    this.textInputAction,
    this.onSubmitted,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final String? label;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final VoidCallback? onSubmitted;

  @override
  State<RupiahField> createState() => _RupiahFieldState();
}

class _RupiahFieldState extends State<RupiahField> {
  late final _controller = TextEditingController(text: formatRupiahInput(widget.value));

  @override
  void didUpdateWidget(RupiahField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Nilai diubah dari luar (bukan dari ketikan di field ini).
    if (parseRupiahInput(_controller.text) != widget.value) {
      _controller.text = formatRupiahInput(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final label = widget.label;
    final field = TextField(
      controller: _controller,
      autofocus: widget.autofocus,
      keyboardType: TextInputType.number,
      textInputAction: widget.textInputAction,
      inputFormatters: const [RupiahInputFormatter()],
      style: AppTypography.titleMedium.copyWith(
        color: c.textPrimary,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      decoration: InputDecoration(
        hintText: '0',
        hintStyle: AppTypography.titleMedium.copyWith(color: c.textTertiary),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.s16, right: AppSpacing.s8),
          child: Text('Rp', style: AppTypography.titleMedium.copyWith(color: c.textTertiary)),
        ),
        prefixIconConstraints: const BoxConstraints(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: AppSpacing.s12,
        ),
      ),
      onChanged: (text) => widget.onChanged(parseRupiahInput(text)),
      onSubmitted: widget.onSubmitted == null ? null : (_) => widget.onSubmitted!(),
    );
    if (label == null) return Semantics(label: 'Nominal rupiah', child: field);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: AppTypography.labelMedium.copyWith(color: c.textSecondary)),
        const SizedBox(height: AppSpacing.s8),
        Semantics(label: label, child: field),
      ],
    );
  }
}
