from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.dependencies import get_current_user
from app.core.database import get_db
from app.models import User
from app.repositories.profile_repository import get_profile_by_user_id
from app.schemas.profile import MeResponse


router = APIRouter(tags=["profile"])


@router.get("/me", response_model=MeResponse)
def read_me(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[Session, Depends(get_db)],
) -> MeResponse:
    profile = get_profile_by_user_id(db, current_user.id)
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Profile not found",
        )

    return MeResponse(
        id=current_user.id,
        email=current_user.email,
        email_verified=current_user.email_verified,
        display_name=profile.display_name,
        name_changed_once=profile.name_changed_once,
        total_score=profile.total_score,
        player_level=profile.player_level,
        is_premium=profile.is_premium,
    )
