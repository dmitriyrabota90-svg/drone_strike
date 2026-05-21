import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _termsAccepted = false;
  bool _personalDataAccepted = false;
  bool _ageConfirmed = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.apiIntegrationComingNext)),
                ),
                child: Text(l10n.register),
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
}
