from datetime import datetime

from pydantic import BaseModel, Field


class MissionCompleteRequest(BaseModel):
    mission_number: int = Field(ge=1, le=10)
    flight_accuracy_bonus: int = Field(ge=0, le=50)
    tank_hit_bonus: int = Field(ge=0, le=50)


class MissionProgressItem(BaseModel):
    mission_number: int
    best_score: int
    best_flight_accuracy_bonus: int
    best_tank_hit_bonus: int
    completed_at: datetime | None


class ProgressResponse(BaseModel):
    total_score: int
    player_level: int
    completed_missions_count: int
    unlocked_mission: int
    missions: list[MissionProgressItem]


class MissionCompleteResponse(BaseModel):
    mission_number: int
    submitted_score: int
    previous_best_score: int
    saved_best_score: int
    score_improved: bool
    total_score: int
    player_level: int
    unlocked_mission: int
