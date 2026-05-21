from uuid import UUID

from sqlalchemy.orm import Session

from app.repositories.legal_repository import create_legal_acceptance_if_missing
from app.schemas.legal import (
    LegalAcceptRequest,
    LegalAcceptResponse,
    LegalDocument,
    LegalDocumentsResponse,
)

OPERATOR_NAME = "Анпилов Дмитрий Сергеевич"
OPERATOR_EMAIL = "anpilovdmitriy@yandex.ru"
LEGAL_DOCUMENTS = [
    LegalDocument(
        type="terms_of_use",
        version="1.0",
        title="Пользовательское соглашение",
        content=(
            "Временная заглушка пользовательского соглашения. "
            "Полный юридический текст будет добавлен позже."
        ),
        operator_name=OPERATOR_NAME,
        operator_email=OPERATOR_EMAIL,
    ),
    LegalDocument(
        type="personal_data_consent",
        version="1.0",
        title="Согласие на обработку персональных данных",
        content=(
            "Временная заглушка согласия на обработку персональных данных. "
            "Полный юридический текст будет добавлен позже."
        ),
        operator_name=OPERATOR_NAME,
        operator_email=OPERATOR_EMAIL,
    ),
    LegalDocument(
        type="privacy_policy",
        version="1.0",
        title="Политика обработки персональных данных",
        content=(
            "Временная заглушка политики обработки персональных данных. "
            "Полный юридический текст будет добавлен позже."
        ),
        operator_name=OPERATOR_NAME,
        operator_email=OPERATOR_EMAIL,
    ),
]


def get_legal_documents() -> LegalDocumentsResponse:
    return LegalDocumentsResponse(documents=LEGAL_DOCUMENTS)


def accept_legal_document(
    db: Session,
    user_id: UUID,
    request: LegalAcceptRequest,
) -> LegalAcceptResponse:
    create_legal_acceptance_if_missing(
        db,
        user_id=user_id,
        document_type=request.document_type,
        document_version=request.document_version,
    )
    db.commit()
    return LegalAcceptResponse(
        status="accepted",
        document_type=request.document_type,
        document_version=request.document_version,
    )
