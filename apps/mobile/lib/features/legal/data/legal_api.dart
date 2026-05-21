import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import 'legal_dto.dart';

class LegalApi {
  const LegalApi(this._apiClient);

  final ApiClient _apiClient;

  Future<LegalDocumentsResponseDto> getDocuments() async {
    try {
      final response = await _apiClient.dio.get('/api/v1/legal/documents');
      return LegalDocumentsResponseDto.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<AcceptLegalResponseDto> acceptDocument({
    required String documentType,
    required String documentVersion,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/v1/legal/accept',
        data: AcceptLegalRequestDto(
          documentType: documentType,
          documentVersion: documentVersion,
        ).toJson(),
      );
      return AcceptLegalResponseDto.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }
}
