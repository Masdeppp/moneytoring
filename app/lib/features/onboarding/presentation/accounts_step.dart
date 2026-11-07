import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/model/account_type_defaults.dart';
import '../../../core/model/enums.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/rupiah_field.dart';
import '../../../core/widgets/status_widgets.dart';
import '../../../core/widgets/switch_row.dart';
import '../application/onboarding_controller.dart';
import '../application/onboarding_draft.dart';
import 'onboarding_scaffold.dart';

/// Langkah 2: saldo awal per akun (PRD §8.1). Belum ada di Figma; memakai
/// komponen yang sama dengan layar 01.
class AccountsStep extends ConsumerWidget {
  const AccountsStep({super.key, required this.onBack, required this.onNext});

  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);
    final canRemove = draft.accounts.length > 1;

    return OnboardingScaffold(
      step: 2,
      onBack: onBack,
      title: 'Berapa uangmu sekarang?',
      subtitle:
          'Isi saldo tiap rekening dan dompet. Rekening dana darurat bisa dikecualikan '
          'supaya tidak ikut dibelanjakan.',
      sections: [
        for (final account in draft.accounts)
          _AccountCard(
            key: ValueKey(account.id),
            account: account,
            onChanged: controller.updateAccount,
            onRemove: canRemove ? () => controller.removeAccount(account.id) : null,
          ),
        Wrap(
          spacing: AppSpacing.s8,
          runSpacing: AppSpacing.s8,
          children: [
            for (final type in AccountType.values)
              ActionChip(
                avatar: const Icon(AppIcons.plus, size: 18),
                label: Text(type.defaultName),
                onPressed: () => controller.addAccount(type),
              ),
          ],
        ),
      ],
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OnboardingTotalRow(
            label: draft.hasExcludedAccount ? 'Saldo yang dihitung' : 'Total saldo',
            value: formatRupiah(draft.countedBalance),
          ),
          const SizedBox(height: AppSpacing.s12),
          FilledButton(
            onPressed: draft.isAccountsStepValid ? onNext : null,
            child: const Text('Lanjut'),
          ),
        ],
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    super.key,
    required this.account,
    required this.onChanged,
    required this.onRemove,
  });

  final AccountDraft account;
  final ValueChanged<AccountDraft> onChanged;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final remove = onRemove;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CategoryTile(icon: AppIcons.named(account.type.iconName), tone: account.type.tone),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: TextFormField(
                    initialValue: account.name,
                    textCapitalization: TextCapitalization.words,
                    maxLength: 40,
                    decoration: const InputDecoration(
                      hintText: 'Nama akun, mis. BCA',
                      counterText: '',
                    ),
                    onChanged: (name) => onChanged(account.copyWith(name: name)),
                  ),
                ),
                if (remove != null)
                  IconButton(
                    tooltip: 'Hapus ${account.name}',
                    onPressed: remove,
                    icon: const Icon(AppIcons.close),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.s16),
            RupiahField(
              label: 'Saldo sekarang',
              value: account.balance,
              onChanged: (balance) => onChanged(account.copyWith(balance: balance)),
            ),
            const SizedBox(height: AppSpacing.s12),
            SwitchRow(
              title: 'Hitung di Safe-to-Spend',
              subtitle: 'Matikan untuk dana darurat atau tabungan',
              value: account.includeInSafeToSpend,
              onChanged: (value) => onChanged(account.copyWith(includeInSafeToSpend: value)),
            ),
          ],
        ),
      ),
    );
  }
}
