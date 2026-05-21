import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _masterSound = true;
  bool _music = true;
  bool _sfx = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        leading: BackButton(onPressed: () => context.go('/menu')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.language),
              title: Text(l10n.language),
              subtitle: const Text('RU / EN'),
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            value: _masterSound,
            onChanged: (value) => setState(() => _masterSound = value),
            title: Text(l10n.masterSound),
            secondary: const Icon(Icons.volume_up),
          ),
          SwitchListTile(
            value: _music,
            onChanged: (value) => setState(() => _music = value),
            title: Text(l10n.music),
            secondary: const Icon(Icons.music_note),
          ),
          SwitchListTile(
            value: _sfx,
            onChanged: (value) => setState(() => _sfx = value),
            title: Text(l10n.sfx),
            secondary: const Icon(Icons.surround_sound),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => context.go('/legal'),
            icon: const Icon(Icons.description),
            label: Text(l10n.legalDocuments),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.deleteAccountPlaceholder)),
            ),
            icon: const Icon(Icons.delete_outline),
            label: Text(l10n.deleteAccount),
          ),
        ],
      ),
    );
  }
}
