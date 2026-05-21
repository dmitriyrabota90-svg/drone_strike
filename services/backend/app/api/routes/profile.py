from typing import Annotated

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.dependencies import get_current_user
from app.core.database import get_db
from app.models import User
from app.schemas.profile import DisplayNameUpdateRequest, MeResponse
from app.services.profile_service import get_me_response, update_display_name


router = APIRouter(tags=["profile"])


@router.get("/me", response_model=MeResponse)
def read_me(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[Session, Depends(get_db)],
) -> MeResponse:
    return get_me_response(db, current_user)


@router.patch("/me/display-name", response_model=MeResponse)
def patch_display_name(
    request: DisplayNameUpdateRequest,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[Session, Depends(get_db)],
) -> MeResponse:
    return update_display_name(db, current_user, request)
