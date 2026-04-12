import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/auth_providers.dart';

class VerifyNationalIdForm extends ConsumerStatefulWidget {
  const VerifyNationalIdForm({super.key});

  @override
  ConsumerState<VerifyNationalIdForm> createState() => _VerifyNationalIdFormState();
}

class _VerifyNationalIdFormState extends ConsumerState<VerifyNationalIdForm> {
  final _formKey = GlobalKey<FormState>();
  final _nationalIdController = TextEditingController(text: '29801011234567');

  @override
  void dispose() {
    _nationalIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return AppCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Verify National ID', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'For account protection, confirm your National ID before entering the student workspace.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: _nationalIdController,
              label: 'National ID',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.badge_outlined,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'National ID is required';
                }
                if (value.trim().length != 14) {
                  return 'National ID must be 14 digits';
                }
                return null;
              },
            ),
            if (authState.errorMessage != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                authState.errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: authState.isSubmitting ? 'Verifying...' : 'Verify and continue',
              onPressed: authState.isSubmitting
                  ? null
                  : () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        await ref
                            .read(authNotifierProvider.notifier)
                            .verifyNationalId(_nationalIdController.text);
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }
}

