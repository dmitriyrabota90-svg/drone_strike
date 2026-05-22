import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/audio/audio_service.dart';
import '../../../core/audio/audio_settings_controller.dart';
import '../../auth/domain/auth_controller.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../../../shared/widgets/menu_background.dart';
import '../../../shared/widgets/neon_menu_button.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authControllerProvider).asData?.value;
    final isAuthenticated = authState?.isAuthenticated ?? false;
    final isLoading = authState?.isLoading ?? false;
    final audioSettingsValue = ref.watch(audioSettingsControllerProvider);
    final audioSettings = audioSettingsValue.asData?.value;
    final isAudioLoading = audioSettingsValue.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        leading: BackButton(onPressed: () => context.go('/menu')),
      ),
      body: MenuBackground(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GlassPanel(
              padding: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.language),
                title: Text(l10n.language),
                subtitle: const Text('RU / EN'),
              ),
            ),
            const SizedBox(height: 12),
            GlassPanel(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                    child: Text(
                      l10n.sound,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  SwitchListTile(
                    value: audioSettings?.masterSoundEnabled ?? true,
                    onChanged: isAudioLoading
                        ? null
                        : (value) => _setMasterSoundEnabled(value),
                    title: Text(l10n.masterSound),
                    secondary: const Icon(Icons.volume_up),
                  ),
                  SwitchListTile(
                    value: audioSettings?.musicEnabled ?? true,
                    onChanged: isAudioLoading
                        ? null
                        : (value) => _setMusicEnabled(value),
                    title: Text(l10n.music),
                    secondary: const Icon(Icons.music_note),
                  ),
                  SwitchListTile(
                    value: audioSettings?.sfxEnabled ?? true,
                    onChanged: isAudioLoading
                        ? null
                        : (value) => _setSfxEnabled(value),
                    title: Text(l10n.sfx),
                    secondary: const Icon(Icons.surround_sound),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            NeonMenuButton(
              text: l10n.legalDocuments,
              icon: Icons.description,
              onPressed: () => context.go('/legal'),
            ),
            const SizedBox(height: 12),
            GlassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.account,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  NeonMenuButton(
                    text: l10n.deleteAccount,
                    icon: Icons.delete_outline,
                    variant: NeonMenuButtonVariant.danger,
                    onPressed: isAuthenticated && !isLoading
                        ? () => _showDeleteAccountDialog(l10n)
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setMasterSoundEnabled(bool value) async {
    await ref
        .read(audioSettingsControllerProvider.notifier)
        .setMasterSoundEnabled(value);
    final settings = ref.read(audioSettingsControllerProvider).requireValue;
    await ref.read(audioServiceProvider).handleSettingsChanged(settings);
  }

  Future<void> _setMusicEnabled(bool value) async {
    await ref
        .read(audioSettingsControllerProvider.notifier)
        .setMusicEnabled(value);
    final settings = ref.read(audioSettingsControllerProvider).requireValue;
    await ref.read(audioServiceProvider).handleSettingsChanged(settings);
  }

  Future<void> _setSfxEnabled(bool value) async {
    await ref
        .read(audioSettingsControllerProvider.notifier)
        .setSfxEnabled(value);
    final settings = ref.read(audioSettingsControllerProvider).requireValue;
    await ref.read(audioServiceProvider).handleSettingsChanged(settings);
  }

  Future<void> _showDeleteAccountDialog(AppLocalizations l10n) async {
    final passwordController = TextEditingController();
    final password = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.deleteAccount),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.deleteAccountWarning),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: l10n.password),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.back),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pop(passwordController.text),
              child: Text(l10n.confirmDelete),
            ),
          ],
        );
      },
    );
    passwordController.dispose();

    if (password == null || password.isEmpty) {
      return;
    }

    await ref.read(authControllerProvider.notifier).deleteAccount(password);
    final authState = ref.read(authControllerProvider).asData?.value;
    if (!mounted || authState?.isAuthenticated == true) {
      return;
    }

    // TODO: Clear local game progress after local saves are implemented.
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.deleteAccountSuccess)));
    context.go('/menu');
  }
}
