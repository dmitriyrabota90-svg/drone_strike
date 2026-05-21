from datetime import UTC, datetime
from uuid import UUID

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.models import MissionProgress


def get_progress_by_user_id(db: Session, user_id: UUID) -> list[MissionProgress]:
    return list(
        db.scalars(
            select(MissionProgress)
            .where(MissionProgress.user_id == user_id)
            .order_by(MissionProgress.mission_number)
        )
    )


def get_mission_progress(
    db: Session,
    user_id: UUID,
    mission_number: int,
) -> MissionProgress | None:
    return db.scalar(
        select(MissionProgress).where(
            MissionProgress.user_id == user_id,
            MissionProgress.mission_number == mission_number,
        )
    )


def upsert_mission_progress(
    db: Session,
    user_id: UUID,
    mission_number: int,
    score: int,
    flight_bonus: int,
    tank_bonus: int,
) -> tuple[MissionProgress, int, bool]:
    mission_progress = get_mission_progress(db, user_id, mission_number)
    previous_best_score = mission_progress.best_score if mission_progress else 0
    score_improved = score > previous_best_score

    if mission_progress is None:
        mission_progress = MissionProgress(
            user_id=user_id,
            mission_number=mission_number,
            best_score=score,
            best_flight_accuracy_bonus=flight_bonus,
            best_tank_hit_bonus=tank_bonus,
            completed_at=datetime.now(UTC),
        )
        db.add(mission_progress)
        db.flush()
        return mission_progress, previous_best_score, True

    if score_improved:
        mission_progress.best_score = score
        mission_progress.best_flight_accuracy_bonus = flight_bonus
        mission_progress.best_tank_hit_bonus = tank_bonus
        mission_progress.completed_at = datetime.now(UTC)
        db.add(mission_progress)
        db.flush()

    return mission_progress, previous_best_score, score_improved


def calculate_total_score(db: Session, user_id: UUID) -> int:
    return int(
        db.scalar(
            select(func.coalesce(func.sum(MissionProgress.best_score), 0)).where(
                MissionProgress.user_id == user_id,
            )
        )
        or 0
    )
