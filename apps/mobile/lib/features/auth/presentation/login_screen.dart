import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/assets/app_assets.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../../../shared/widgets/menu_background.dart';
import '../../../shared/widgets/neon_menu_button.dart';
import '../domain/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _validationError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
        title: Text(l10n.login),
        leading: BackButton(onPressed: () => context.go('/menu')),
      ),
      body: MenuBackground(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ListView(
              padding: const EdgeInsets.all(24),
              shrinkWrap: true,
              children: [
                Image.asset(AppAssets.logo, height: 86, fit: BoxFit.contain),
                const SizedBox(height: 18),
                GlassPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: isLoading
                              ? null
                              : () => _showPasswordResetDialog(l10n),
                          child: Text(l10n.forgotPassword),
                        ),
                      ),
                      if (errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          errorMessage,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      NeonMenuButton(
                        text: isLoading ? l10n.loading : l10n.login,
                        icon: Icons.login,
                        onPressed: isLoading ? null : () => _submit(l10n),
                      ),
                      const SizedBox(height: 12),
                      NeonMenuButton(
                        text: l10n.register,
                        icon: Icons.person_add,
                        variant: NeonMenuButtonVariant.secondary,
                        onPressed: () => context.go('/register'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showPasswordResetDialog(AppLocalizations l10n) async {
    final controller = TextEditingController(
      text: _emailController.text.trim(),
    );
    final email = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.passwordResetTitle),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(labelText: l10n.email),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: Text(l10n.send),
            ),
          ],
        );
      },
    );
    controller.dispose();

    if (!mounted || email == null) {
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      _showInfoSnackBar(l10n.invalidEmail);
      return;
    }

    final error = await ref
        .read(authControllerProvider.notifier)
        .requestPasswordReset(email);
    if (!mounted) {
      return;
    }
    _showInfoSnackBar(error ?? l10n.passwordResetInstructionsSent);
  }

  Future<void> _submit(AppLocalizations l10n) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _validationError = l10n.invalidEmailOrPassword);
      return;
    }

    setState(() => _validationError = null);
    await ref
        .read(authControllerProvider.notifier)
        .login(email: email, password: password);

    final state = ref.read(authControllerProvider).asData?.value;
    if (!mounted || state?.isAuthenticated != true) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.loginSuccess)));
    context.go('/profile');
  }

  void _showInfoSnackBar(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
