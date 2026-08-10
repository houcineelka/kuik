import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../l10n/app_localizations_x.dart';
import '../../../theme/spacing.dart';
import '../../../widgets/shared/pill_cta_button.dart';
import '../../../widgets/shared/skyline_illustration.dart';
import '../providers/auth_providers.dart';
import '../widgets/auth_header.dart';
import '../widgets/ledger_stamp.dart';
import '../widgets/ledger_text_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cityController = TextEditingController();

  Map<String, List<String>> _fieldErrors = const {};
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _fieldErrors = const {};
    });

    try {
      await ref.read(authControllerProvider.notifier).register(
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            password: _passwordController.text,
            city: _cityController.text.trim(),
          );
      if (!mounted) return;
      await showLedgerStamp(context, label: context.l10n.registerStampLabel);
      if (!mounted) return;
      context.go('/home');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _fieldErrors = e.errors);
      if (e.errors.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: LedgerSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: LedgerSpacing.md),
              AuthHeader(onBack: () => context.go('/login')),
              const SizedBox(height: LedgerSpacing.lg),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: textTheme.headlineLarge,
                            children: [
                              TextSpan(text: l10n.registerTitle),
                              TextSpan(text: ' !', style: TextStyle(color: scheme.primary)),
                            ],
                          ),
                        ),
                        const SizedBox(height: LedgerSpacing.sm),
                        Text(
                          l10n.registerSubtitle,
                          style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: LedgerSpacing.sm),
                  SkylineIllustration(size: 130, pinColor: scheme.primary),
                ],
              ),
              const SizedBox(height: LedgerSpacing.lg),
              const _StepDots(activeStep: 0, stepCount: 3),
              const SizedBox(height: LedgerSpacing.xl),
              LedgerTextField(
                controller: _nameController,
                label: l10n.registerNameLabel,
                textCapitalization: TextCapitalization.words,
                prefixIcon: Icons.person_outline,
                errorText: _fieldErrors['name']?.first,
              ),
              const SizedBox(height: LedgerSpacing.lg),
              LedgerTextField(
                controller: _phoneController,
                label: l10n.fieldPhoneLabel,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.call_outlined,
                errorText: _fieldErrors['phone']?.first,
              ),
              const SizedBox(height: LedgerSpacing.lg),
              LedgerTextField(
                controller: _cityController,
                label: l10n.fieldCityLabel,
                textCapitalization: TextCapitalization.words,
                prefixIcon: Icons.location_on_outlined,
                errorText: _fieldErrors['city']?.first,
              ),
              const SizedBox(height: LedgerSpacing.lg),
              LedgerPasswordField(
                controller: _passwordController,
                label: l10n.fieldPasswordLabel,
                errorText: _fieldErrors['password']?.first,
              ),
              const SizedBox(height: LedgerSpacing.xxl),
              PillCtaButton(
                label: l10n.actionRegister,
                onPressed: _submit,
                loading: _submitting,
              ),
              const SizedBox(height: LedgerSpacing.xl),
              Center(
                child: RichText(
                  text: TextSpan(
                    style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                    children: [
                      TextSpan(text: l10n.registerHasAccountPrompt),
                      TextSpan(
                        text: l10n.actionLogin,
                        style: TextStyle(color: scheme.secondary, fontWeight: FontWeight.w600),
                        recognizer: (TapGestureRecognizer()
                          ..onTap = _submitting ? null : () => context.go('/login')),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: LedgerSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepDots extends StatelessWidget {
  const _StepDots({required this.activeStep, required this.stepCount});

  final int activeStep;
  final int stepCount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        for (var i = 0; i < stepCount; i++) ...[
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i <= activeStep ? scheme.primary : scheme.outline,
            ),
          ),
          if (i != stepCount - 1)
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                color: i < activeStep ? scheme.primary : scheme.outline,
              ),
            ),
        ],
      ],
    );
  }
}
