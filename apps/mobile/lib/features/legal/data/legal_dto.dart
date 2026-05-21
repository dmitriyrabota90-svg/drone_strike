class LegalDocumentDto {
  const LegalDocumentDto({
    required this.type,
    required this.version,
    required this.title,
    required this.content,
    required this.operatorName,
    required this.operatorEmail,
  });

  final String type;
  final String version;
  final String title;
  final String content;
  final String operatorName;
  final String operatorEmail;

  factory LegalDocumentDto.fromJson(Map<String, dynamic> json) {
    return LegalDocumentDto(
      type: json['type'] as String,
      version: json['version'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      operatorName: json['operator_name'] as String,
      operatorEmail: json['operator_email'] as String,
    );
  }
}

class LegalDocumentsResponseDto {
  const LegalDocumentsResponseDto({required this.documents});

  final List<LegalDocumentDto> documents;

  factory LegalDocumentsResponseDto.fromJson(Map<String, dynamic> json) {
    final documents = json['documents'] as List<dynamic>? ?? const [];
    return LegalDocumentsResponseDto(
      documents: documents
          .map(
            (item) => LegalDocumentDto.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
    );
  }
}

class AcceptLegalRequestDto {
  const AcceptLegalRequestDto({
    required this.documentType,
    required this.documentVersion,
  });

  final String documentType;
  final String documentVersion;

  Map<String, dynamic> toJson() => {
    'document_type': documentType,
    'document_version': documentVersion,
  };
}

class AcceptLegalResponseDto {
  const AcceptLegalResponseDto({
    required this.status,
    required this.documentType,
    required this.documentVersion,
  });

  final String status;
  final String documentType;
  final String documentVersion;

  factory AcceptLegalResponseDto.fromJson(Map<String, dynamic> json) {
    return AcceptLegalResponseDto(
      status: json['status'] as String,
      documentType: json['document_type'] as String,
      documentVersion: json['document_version'] as String,
    );
  }
}
