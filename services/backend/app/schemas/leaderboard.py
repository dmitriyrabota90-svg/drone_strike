from pydantic import BaseModel


class LeaderboardEntry(BaseModel):
    rank: int
    display_name: str
    total_score: int
    player_level: int
    is_current_user: bool = False


class CurrentPlayerLeaderboardEntry(BaseModel):
    rank: int
    display_name: str
    total_score: int
    player_level: int


class LeaderboardResponse(BaseModel):
    entries: list[LeaderboardEntry]
    me: CurrentPlayerLeaderboardEntry | None
    total_count: int


class LeaderboardMeResponse(BaseModel):
    rank: int
    display_name: str
    total_score: int
    player_level: int
    total_count: int
