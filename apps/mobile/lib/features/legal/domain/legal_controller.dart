import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/providers.dart';
import '../data/legal_dto.dart';

final legalControllerProvider =
    AsyncNotifierProvider<LegalController, List<LegalDocumentDto>>(
      LegalController.new,
    );

class LegalController extends AsyncNotifier<List<LegalDocumentDto>> {
  @override
  Future<List<LegalDocumentDto>> build() {
    return ref.read(legalRepositoryProvider).getDocuments();
  }

  Future<void> acceptDocument({
    required String documentType,
    required String documentVersion,
  }) async {
    final current = state.asData?.value ?? const <LegalDocumentDto>[];

    try {
      await _withRefresh(() {
        return ref
            .read(legalRepositoryProvider)
            .acceptDocument(
              documentType: documentType,
              documentVersion: documentVersion,
            );
      });
      state = AsyncData(current);
    } on Object catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<T> _withRefresh<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on ApiException catch (error) {
      if (!error.isUnauthorized) {
        rethrow;
      }

      final refreshed = await ref
          .read(authRepositoryProvider)
          .tryRefreshAccessToken();
      if (!refreshed) {
        rethrow;
      }

      return request();
    }
  }
}
