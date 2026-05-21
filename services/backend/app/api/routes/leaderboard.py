from typing import Annotated

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.api.dependencies import get_current_user
from app.core.database import get_db
from app.models import User
from app.schemas.leaderboard import LeaderboardMeResponse, LeaderboardResponse
from app.services.leaderboard_service import build_leaderboard, get_current_player_rank


router = APIRouter(prefix="/leaderboard", tags=["leaderboard"])


@router.get("", response_model=LeaderboardResponse)
def read_leaderboard(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[Session, Depends(get_db)],
    limit: Annotated[int, Query(ge=1, le=100)] = 50,
) -> LeaderboardResponse:
    return build_leaderboard(db, current_user.id, limit=limit)


@router.get("/me", response_model=LeaderboardMeResponse)
def read_my_leaderboard_rank(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[Session, Depends(get_db)],
) -> LeaderboardMeResponse:
    return get_current_player_rank(db, current_user.id)
