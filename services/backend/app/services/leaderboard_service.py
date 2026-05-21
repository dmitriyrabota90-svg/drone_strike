from dataclasses import dataclass
from datetime import datetime
from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.repositories.leaderboard_repository import (
    get_current_player_profile,
    get_real_leaderboard_profiles,
    get_seed_players,
)
from app.schemas.leaderboard import (
    CurrentPlayerLeaderboardEntry,
    LeaderboardEntry,
    LeaderboardMeResponse,
    LeaderboardResponse,
)


@dataclass(frozen=True)
class NormalizedLeaderboardRow:
    display_name: str
    total_score: int
    player_level: int
    sort_date: datetime | None
    user_id: UUID | None = None


def build_leaderboard(
    db: Session,
    current_user_id: UUID,
    limit: int = 50,
) -> LeaderboardResponse:
    rows = _ranked_rows(db)
    total_count = len(rows)
    me = _find_current_player_entry(rows, current_user_id, total_count)

    entries = [
        LeaderboardEntry(
            rank=rank,
            display_name=row.display_name,
            total_score=row.total_score,
            player_level=row.player_level,
            is_current_user=row.user_id == current_user_id,
        )
        for rank, row in rows[:limit]
    ]

    return LeaderboardResponse(entries=entries, me=me, total_count=total_count)


def get_current_player_rank(
    db: Session,
    current_user_id: UUID,
) -> LeaderboardMeResponse:
    profile = get_current_player_profile(db, current_user_id)
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Profile not found",
        )

    rows = _ranked_rows(db)
    total_count = len(rows)
    me = _find_current_player_entry(rows, current_user_id, total_count)
    if not me:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Player is not ranked",
        )

    return LeaderboardMeResponse(
        rank=me.rank,
        display_name=me.display_name,
        total_score=me.total_score,
        player_level=me.player_level,
        total_count=total_count,
    )


def _ranked_rows(db: Session) -> list[tuple[int, NormalizedLeaderboardRow]]:
    rows = [
        NormalizedLeaderboardRow(
            user_id=profile.user_id,
            display_name=profile.display_name,
            total_score=profile.total_score,
            player_level=profile.player_level,
            sort_date=profile.updated_at or profile.created_at,
        )
        for profile in get_real_leaderboard_profiles(db)
    ]
    rows.extend(
        NormalizedLeaderboardRow(
            display_name=seed_player.display_name,
            total_score=seed_player.total_score,
            player_level=seed_player.player_level,
            sort_date=seed_player.updated_at or seed_player.created_at,
        )
        for seed_player in get_seed_players(db)
    )

    sorted_rows = sorted(
        rows,
        key=lambda row: (
            -row.total_score,
            -row.player_level,
            row.sort_date or datetime.max,
            row.display_name.lower(),
        ),
    )
    return list(enumerate(sorted_rows, start=1))


def _find_current_player_entry(
    rows: list[tuple[int, NormalizedLeaderboardRow]],
    current_user_id: UUID,
    total_count: int,
) -> CurrentPlayerLeaderboardEntry | None:
    for rank, row in rows:
        if row.user_id == current_user_id:
            return CurrentPlayerLeaderboardEntry(
                rank=rank,
                display_name=row.display_name,
                total_score=row.total_score,
                player_level=row.player_level,
            )
    return None
