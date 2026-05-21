import 'legal_api.dart';
import 'legal_dto.dart';

class LegalRepository {
  const LegalRepository(this._legalApi);

  final LegalApi _legalApi;

  Future<List<LegalDocumentDto>> getDocuments() async {
    final response = await _legalApi.getDocuments();
    return response.documents;
  }

  Future<AcceptLegalResponseDto> acceptDocument({
    required String documentType,
    required String documentVersion,
  }) {
    return _legalApi.acceptDocument(
      documentType: documentType,
      documentVersion: documentVersion,
    );
  }
}
