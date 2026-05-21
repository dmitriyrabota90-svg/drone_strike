from uuid import UUID

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models import PlayerProfile


def get_profile_by_user_id(db: Session, user_id: UUID) -> PlayerProfile | None:
    return db.scalar(select(PlayerProfile).where(PlayerProfile.user_id == user_id))


def display_name_exists(db: Session, display_name: str) -> bool:
    return db.scalar(
        select(PlayerProfile.id).where(PlayerProfile.display_name == display_name)
    ) is not None


def create_profile(db: Session, user_id: UUID, display_name: str) -> PlayerProfile:
    profile = PlayerProfile(user_id=user_id, display_name=display_name)
    db.add(profile)
    db.flush()
    return profile
