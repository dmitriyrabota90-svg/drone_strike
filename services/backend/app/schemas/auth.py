from uuid import UUID

from pydantic import BaseModel, EmailStr, Field, field_validator


class RegisterRequest(BaseModel):
    email: EmailStr
    password: str = Field(min_length=8)
    accepted_terms: bool
    accepted_personal_data: bool
    is_at_least_13: bool

    @field_validator("accepted_terms")
    @classmethod
    def terms_must_be_accepted(cls, value: bool) -> bool:
        if not value:
            raise ValueError("Terms of use must be accepted")
        return value

    @field_validator("accepted_personal_data")
    @classmethod
    def personal_data_must_be_accepted(cls, value: bool) -> bool:
        if not value:
            raise ValueError("Personal data consent must be accepted")
        return value

    @field_validator("is_at_least_13")
    @classmethod
    def age_must_be_confirmed(cls, value: bool) -> bool:
        if not value:
            raise ValueError("Age confirmation is required")
        return value


class LoginRequest(BaseModel):
    email: EmailStr
    password: str = Field(min_length=8)


class RefreshRequest(BaseModel):
    refresh_token: str


class DeleteAccountRequest(BaseModel):
    password: str = Field(min_length=8)


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"


class AuthUserResponse(BaseModel):
    id: UUID
    email: EmailStr
    email_verified: bool
    display_name: str
    total_score: int
    player_level: int
