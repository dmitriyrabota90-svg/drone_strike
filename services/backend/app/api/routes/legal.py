from typing import Annotated

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.dependencies import get_current_user
from app.core.database import get_db
from app.models import User
from app.schemas.legal import (
    LegalAcceptRequest,
    LegalAcceptResponse,
    LegalDocumentsResponse,
)
from app.services.legal_service import accept_legal_document, get_legal_documents


router = APIRouter(prefix="/legal", tags=["legal"])


@router.get("/documents", response_model=LegalDocumentsResponse)
def read_legal_documents() -> LegalDocumentsResponse:
    return get_legal_documents()


@router.post("/accept", response_model=LegalAcceptResponse)
def accept_document(
    request: LegalAcceptRequest,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[Session, Depends(get_db)],
) -> LegalAcceptResponse:
    return accept_legal_document(db, current_user.id, request)
