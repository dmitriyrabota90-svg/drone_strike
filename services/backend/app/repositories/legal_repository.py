from uuid import UUID

from sqlalchemy.orm import Session

from app.models import LegalAcceptance


def create_legal_acceptance(
    db: Session,
    user_id: UUID,
    document_type: str,
    document_version: str,
) -> LegalAcceptance:
    acceptance = LegalAcceptance(
        user_id=user_id,
        document_type=document_type,
        document_version=document_version,
    )
    db.add(acceptance)
    db.flush()
    return acceptance
