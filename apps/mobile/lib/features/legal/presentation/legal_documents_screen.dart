import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';

class LegalDocumentsScreen extends StatelessWidget {
  const LegalDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final documents = [
      l10n.termsOfUse,
      l10n.privacyPolicy,
      l10n.personalDataConsent,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.legalDocuments),
        leading: BackButton(onPressed: () => context.go('/settings')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final document in documents) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(l10n.comingSoon),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.operator,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text('Анпилов Дмитрий Сергеевич'),
                  const Text('anpilovdmitriy@yandex.ru'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
