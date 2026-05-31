from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.repositories import profile_repository
from app.repositories import progress_repository
from app.schemas.progress import (
    MissionCompleteRequest,
    MissionCompleteResponse,
    MissionProgressItem,
    ProgressResponse,
)

MAX_MISSION_NUMBER = 20


def calculate_player_level(total_score: int) -> int:
    if total_score >= 1800:
        return 5
    if total_score >= 1200:
        return 4
    if total_score >= 700:
        return 3
    if total_score >= 300:
        return 2
    return 1


def get_player_progress(db: Session, user_id: UUID) -> ProgressResponse:
    profile = _get_profile_or_404(db, user_id)
    progress_items = progress_repository.get_progress_by_user_id(db, user_id)
    completed_missions_count = len(progress_items)

    return ProgressResponse(
        total_score=profile.total_score,
        player_level=profile.player_level,
        completed_missions_count=completed_missions_count,
        unlocked_mission=_calculate_unlocked_mission(progress_items),
        missions=[
            MissionProgressItem(
                mission_number=item.mission_number,
                best_score=item.best_score,
                best_flight_accuracy_bonus=item.best_flight_accuracy_bonus,
                best_tank_hit_bonus=item.best_tank_hit_bonus,
                completed_at=item.completed_at,
            )
            for item in progress_items
        ],
    )


def complete_mission(
    db: Session,
    user_id: UUID,
    request: MissionCompleteRequest,
) -> MissionCompleteResponse:
    _validate_mission_sequence(db, user_id, request.mission_number)

    submitted_score = 100 + request.flight_accuracy_bonus + request.tank_hit_bonus
    submitted_score = max(100, min(300, submitted_score))

    mission_progress, previous_best_score, score_improved = (
        progress_repository.upsert_mission_progress(
            db,
            user_id=user_id,
            mission_number=request.mission_number,
            score=submitted_score,
            flight_bonus=request.flight_accuracy_bonus,
            tank_bonus=request.tank_hit_bonus,
        )
    )

    profile = _get_profile_or_404(db, user_id)
    if score_improved:
        total_score = progress_repository.calculate_total_score(db, user_id)
        profile.total_score = total_score
        profile.player_level = calculate_player_level(total_score)
        db.add(profile)
    else:
        total_score = profile.total_score

    db.commit()
    db.refresh(profile)
    db.refresh(mission_progress)

    return MissionCompleteResponse(
        mission_number=request.mission_number,
        submitted_score=submitted_score,
        previous_best_score=previous_best_score,
        saved_best_score=mission_progress.best_score,
        score_improved=score_improved,
        total_score=profile.total_score,
        player_level=profile.player_level,
        unlocked_mission=_calculate_unlocked_mission(
            progress_repository.get_progress_by_user_id(db, user_id),
        ),
    )


def _validate_mission_sequence(db: Session, user_id: UUID, mission_number: int) -> None:
    if mission_number == 1:
        return

    existing_progress = progress_repository.get_mission_progress(
        db,
        user_id,
        mission_number,
    )
    if existing_progress is not None:
        return

    previous_progress = progress_repository.get_mission_progress(
        db,
        user_id,
        mission_number - 1,
    )
    if previous_progress is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Previous mission must be completed first",
        )


def _calculate_unlocked_mission(progress_items: list) -> int:
    if not progress_items:
        return 1

    max_completed_mission = max(item.mission_number for item in progress_items)
    if max_completed_mission >= MAX_MISSION_NUMBER:
        return MAX_MISSION_NUMBER
    return min(max_completed_mission + 1, MAX_MISSION_NUMBER)


def _get_profile_or_404(db: Session, user_id: UUID):
    profile = profile_repository.get_profile_by_user_id(db, user_id)
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Profile not found",
        )
    return profile
