import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException({required this.message, this.statusCode, this.rawBody});

  final String message;
  final int? statusCode;
  final Object? rawBody;

  bool get isUnauthorized => statusCode == 401 || statusCode == 403;

  factory ApiException.fromDioException(DioException error) {
    final response = error.response;
    if (response != null) {
      return ApiException(
        message: _messageFromBody(response.data, response.statusCode),
        statusCode: response.statusCode,
        rawBody: response.data,
      );
    }

    return ApiException(message: _networkMessage(error.type));
  }

  static String _networkMessage(DioExceptionType type) {
    return switch (type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout => 'Connection timed out. Try again.',
      DioExceptionType.badCertificate => 'Secure connection failed.',
      _ => 'Network error. Check connection.',
    };
  }

  static String _messageFromBody(Object? body, int? statusCode) {
    if (body is Map) {
      final detail = body['detail'];
      if (detail is String && detail.isNotEmpty) {
        return detail;
      }
      if (detail is List) {
        final messages = detail
            .map((item) {
              if (item is Map && item['msg'] != null) {
                return item['msg'].toString();
              }
              return item.toString();
            })
            .where((message) => message.isNotEmpty)
            .toList();
        if (messages.isNotEmpty) {
          return messages.join(', ');
        }
      }
    }

    if (body is String && body.isNotEmpty) {
      return body;
    }

    return switch (statusCode) {
      400 => 'Invalid request.',
      401 => 'Invalid email, password, or session.',
      403 => 'Access denied.',
      409 => 'This value already exists.',
      422 => 'Validation error.',
      _ => 'Unexpected API error.',
    };
  }

  @override
  String toString() => message;
}
