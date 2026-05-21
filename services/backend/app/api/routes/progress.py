from typing import Annotated

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.dependencies import get_current_user
from app.core.database import get_db
from app.models import User
from app.schemas.progress import (
    MissionCompleteRequest,
    MissionCompleteResponse,
    ProgressResponse,
)
from app.services.progress_service import complete_mission, get_player_progress


router = APIRouter(prefix="/progress", tags=["progress"])


@router.get("", response_model=ProgressResponse)
def read_progress(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[Session, Depends(get_db)],
) -> ProgressResponse:
    return get_player_progress(db, current_user.id)


@router.post("/mission-complete", response_model=MissionCompleteResponse)
def complete_player_mission(
    request: MissionCompleteRequest,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[Session, Depends(get_db)],
) -> MissionCompleteResponse:
    return complete_mission(db, current_user.id, request)
