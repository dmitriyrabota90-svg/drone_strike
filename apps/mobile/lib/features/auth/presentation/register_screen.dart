import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../domain/auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _termsAccepted = false;
  bool _personalDataAccepted = false;
  bool _ageConfirmed = false;
  String? _validationError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authControllerProvider).asData?.value;
    final isLoading = authState?.isLoading ?? false;
    final errorMessage = _validationError ?? authState?.errorMessage;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.register),
        leading: BackButton(onPressed: () => context.go('/menu')),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: l10n.email),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: l10n.password),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: l10n.confirmPassword),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                value: _termsAccepted,
                onChanged: (value) =>
                    setState(() => _termsAccepted = value ?? false),
                title: Text(l10n.termsAccepted),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              CheckboxListTile(
                value: _personalDataAccepted,
                onChanged: (value) {
                  setState(() => _personalDataAccepted = value ?? false);
                },
                title: Text(l10n.personalDataAccepted),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              CheckboxListTile(
                value: _ageConfirmed,
                onChanged: (value) =>
                    setState(() => _ageConfirmed = value ?? false),
                title: Text(l10n.age13),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              TextButton.icon(
                onPressed: () => context.go('/legal'),
                icon: const Icon(Icons.description),
                label: Text(l10n.legalDocuments),
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  errorMessage,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: isLoading ? null : () => _submit(l10n),
                child: isLoading
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.register),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.go('/login'),
                child: Text(l10n.login),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit(AppLocalizations l10n) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final validationError = _validate(
      l10n: l10n,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );

    if (validationError != null) {
      setState(() => _validationError = validationError);
      return;
    }

    setState(() => _validationError = null);
    await ref
        .read(authControllerProvider.notifier)
        .register(
          email: email,
          password: password,
          acceptedTerms: _termsAccepted,
          acceptedPersonalData: _personalDataAccepted,
          isAtLeast13: _ageConfirmed,
        );

    final state = ref.read(authControllerProvider).asData?.value;
    if (!mounted || state?.isAuthenticated != true) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.registerSuccess)));
    context.go('/profile');
  }

  String? _validate({
    required AppLocalizations l10n,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    if (email.isEmpty) {
      return l10n.invalidEmailOrPassword;
    }
    if (password.length < 8) {
      return l10n.passwordTooShort;
    }
    if (password != confirmPassword) {
      return l10n.passwordsDoNotMatch;
    }
    if (!_termsAccepted) {
      return l10n.acceptTermsRequired;
    }
    if (!_personalDataAccepted) {
      return l10n.acceptPersonalDataRequired;
    }
    if (!_ageConfirmed) {
      return l10n.ageRequired;
    }
    return null;
  }
}
