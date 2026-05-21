from uuid import UUID

from sqlalchemy import select
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


def get_legal_acceptance(
    db: Session,
    user_id: UUID,
    document_type: str,
    document_version: str,
) -> LegalAcceptance | None:
    return db.scalar(
        select(LegalAcceptance).where(
            LegalAcceptance.user_id == user_id,
            LegalAcceptance.document_type == document_type,
            LegalAcceptance.document_version == document_version,
        )
    )


def create_legal_acceptance_if_missing(
    db: Session,
    user_id: UUID,
    document_type: str,
    document_version: str,
) -> LegalAcceptance:
    acceptance = get_legal_acceptance(
        db,
        user_id=user_id,
        document_type=document_type,
        document_version=document_version,
    )
    if acceptance:
        return acceptance
    return create_legal_acceptance(db, user_id, document_type, document_version)


def delete_legal_acceptances_by_user_id(db: Session, user_id: UUID) -> int:
    acceptances = list(
        db.scalars(select(LegalAcceptance).where(LegalAcceptance.user_id == user_id))
    )
    for acceptance in acceptances:
        db.delete(acceptance)
    db.flush()
    return len(acceptances)
