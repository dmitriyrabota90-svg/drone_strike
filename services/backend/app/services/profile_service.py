from fastapi import HTTPException, status
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.models import User
from app.repositories.profile_repository import (
    display_name_exists,
    get_profile_by_user_id,
)
from app.schemas.profile import DisplayNameUpdateRequest, MeResponse


def get_me_response(db: Session, user: User) -> MeResponse:
    profile = get_profile_by_user_id(db, user.id)
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Profile not found",
        )

    return MeResponse(
        id=user.id,
        email=user.email,
        email_verified=user.email_verified,
        display_name=profile.display_name,
        name_changed_once=profile.name_changed_once,
        total_score=profile.total_score,
        player_level=profile.player_level,
        is_premium=profile.is_premium,
    )


def update_display_name(
    db: Session,
    user: User,
    request: DisplayNameUpdateRequest,
) -> MeResponse:
    profile = get_profile_by_user_id(db, user.id)
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Profile not found",
        )
    if profile.name_changed_once:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Display name was already changed",
        )
    if display_name_exists(db, request.display_name):
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Display name already exists",
        )

    try:
        profile.display_name = request.display_name
        profile.name_changed_once = True
        db.add(profile)
        db.commit()
        db.refresh(profile)
    except IntegrityError as exc:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Display name already exists",
        ) from exc

    return get_me_response(db, user)
