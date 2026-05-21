from uuid import UUID

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models import LeaderboardSeedPlayer, PlayerProfile, User


def get_real_leaderboard_profiles(db: Session) -> list[PlayerProfile]:
    return list(
        db.scalars(
            select(PlayerProfile)
            .join(User, PlayerProfile.user_id == User.id)
            .where(User.deleted_at.is_(None))
        )
    )


def get_seed_players(db: Session) -> list[LeaderboardSeedPlayer]:
    return list(db.scalars(select(LeaderboardSeedPlayer)))


def get_current_player_profile(
    db: Session,
    user_id: UUID,
) -> PlayerProfile | None:
    return db.scalar(select(PlayerProfile).where(PlayerProfile.user_id == user_id))
