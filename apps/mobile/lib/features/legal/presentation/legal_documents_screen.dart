import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/domain/auth_controller.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/legal_dto.dart';
import '../domain/legal_controller.dart';

class LegalDocumentsScreen extends ConsumerWidget {
  const LegalDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final legalState = ref.watch(legalControllerProvider);
    final authState = ref.watch(authControllerProvider).asData?.value;
    final isAuthenticated = authState?.isAuthenticated ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.legalDocuments),
        leading: BackButton(onPressed: () => context.go('/settings')),
      ),
      body: legalState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.error, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(error.toString(), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => ref.invalidate(legalControllerProvider),
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
        data: (documents) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final document = documents[index];
            return _LegalDocumentCard(
              document: document,
              isAuthenticated: isAuthenticated,
              onAccept: () async {
                await ref
                    .read(legalControllerProvider.notifier)
                    .acceptDocument(
                      documentType: document.type,
                      documentVersion: document.version,
                    );
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(l10n.accepted)));
                }
              },
            );
          },
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemCount: documents.length,
        ),
      ),
    );
  }
}

class _LegalDocumentCard extends StatelessWidget {
  const _LegalDocumentCard({
    required this.document,
    required this.isAuthenticated,
    required this.onAccept,
  });

  final LegalDocumentDto document;
  final bool isAuthenticated;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              document.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text('${l10n.version}: ${document.version}'),
            const SizedBox(height: 12),
            Text(document.content),
            const SizedBox(height: 12),
            Text('${l10n.operator}: ${document.operatorName}'),
            Text(document.operatorEmail),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: isAuthenticated ? onAccept : null,
              icon: const Icon(Icons.check),
              label: Text(isAuthenticated ? l10n.accept : l10n.loginRequired),
            ),
          ],
        ),
      ),
    );
  }
}
