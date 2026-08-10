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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  Map<String, List<String>> _fieldErrors = const {};
  bool _submitting = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _fieldErrors = const {};
    });

    try {
      await ref.read(authControllerProvider.notifier).login(
            phone: _phoneController.text.trim(),
            password: _passwordController.text,
          );
      if (!mounted) return;
      await showLedgerStamp(context, label: context.l10n.stampVerifiedLabel);
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: LedgerSpacing.md),
              const AuthHeader(),
              const SizedBox(height: LedgerSpacing.xxl),
              SkylineIllustration(size: 130, pinColor: scheme.primary),
              const SizedBox(height: LedgerSpacing.xl),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: textTheme.headlineLarge,
                  children: [
                    TextSpan(text: l10n.loginGreetingTitle),
                    TextSpan(text: ' !', style: TextStyle(color: scheme.primary)),
                  ],
                ),
              ),
              const SizedBox(height: LedgerSpacing.sm),
              Text(
                l10n.loginSubtitle,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: LedgerSpacing.xxl),
              LedgerTextField(
                controller: _phoneController,
                label: l10n.fieldPhoneLabel,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.call_outlined,
                errorText: _fieldErrors['phone']?.first,
              ),
              const SizedBox(height: LedgerSpacing.lg),
              LedgerPasswordField(
                controller: _passwordController,
                label: l10n.fieldPasswordLabel,
                errorText: _fieldErrors['password']?.first,
              ),
              const SizedBox(height: LedgerSpacing.xxl),
              PillCtaButton(
                label: l10n.actionLogin,
                onPressed: _submit,
                loading: _submitting,
              ),
              const SizedBox(height: LedgerSpacing.xl),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                  children: [
                    TextSpan(text: l10n.loginNoAccountPrompt),
                    TextSpan(
                      text: l10n.loginRegisterLink,
                      style: TextStyle(color: scheme.secondary, fontWeight: FontWeight.w600),
                      recognizer: (TapGestureRecognizer()
                        ..onTap = _submitting ? null : () => context.go('/register')),
                    ),
                  ],
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
