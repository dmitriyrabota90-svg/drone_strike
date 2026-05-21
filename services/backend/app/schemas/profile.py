from uuid import UUID

from pydantic import BaseModel, EmailStr, Field


class MeResponse(BaseModel):
    id: UUID
    email: EmailStr
    email_verified: bool
    display_name: str
    name_changed_once: bool
    total_score: int
    player_level: int
    is_premium: bool


class DisplayNameUpdateRequest(BaseModel):
    display_name: str = Field(pattern=r"^[A-Za-z0-9_]{3,20}$")
