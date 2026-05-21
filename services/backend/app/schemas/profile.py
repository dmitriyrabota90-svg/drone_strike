from uuid import UUID

from pydantic import BaseModel, EmailStr


class MeResponse(BaseModel):
    id: UUID
    email: EmailStr
    email_verified: bool
    display_name: str
    name_changed_once: bool
    total_score: int
    player_level: int
    is_premium: bool
