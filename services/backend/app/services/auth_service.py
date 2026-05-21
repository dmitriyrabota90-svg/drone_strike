from __future__ import annotations

import secrets
from datetime import UTC, datetime, timedelta
from uuid import UUID

from fastapi import HTTPException, status
from jwt import InvalidTokenError
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.security import (
    create_access_token,
    create_refresh_token as create_raw_refresh_token,
    decode_token,
    hash_password,
    hash_token,
    verify_password,
)
from app.models import User
from app.repositories import legal_repository
from app.repositories import profile_repository
from app.repositories import progress_repository
from app.repositories import refresh_token_repository
from app.repositories import user_repository
from app.schemas.auth import DeleteAccountRequest, LoginRequest, RegisterRequest, TokenResponse


def generate_unique_display_name(db: Session) -> str:
    for _ in range(50):
        display_name = f"Drone{secrets.randbelow(10_000):04d}"
        if not profile_repository.display_name_exists(db, display_name):
            return display_name

    for _ in range(50):
        display_name = f"Drone{secrets.randbelow(1_000_000):06d}"
        if not profile_repository.display_name_exists(db, display_name):
            return display_name

    raise HTTPException(
        status_code=status.HTTP_400_BAD_REQUEST,
        detail="Unable to generate unique display name",
    )


def register_user(db: Session, request: RegisterRequest) -> TokenResponse:
    email = str(request.email).lower()
    if user_repository.get_user_by_email(db, email):
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Email already exists",
        )

    try:
        user = user_repository.create_user(
            db,
            email=email,
            password_hash=hash_password(request.password),
        )
        profile_repository.create_profile(
            db,
            user_id=user.id,
            display_name=generate_unique_display_name(db),
        )
        legal_repository.create_legal_acceptance(
            db,
            user_id=user.id,
            document_type="terms_of_use",
            document_version=settings.legal_terms_version,
        )
        legal_repository.create_legal_acceptance(
            db,
            user_id=user.id,
            document_type="personal_data_consent",
            document_version=settings.legal_personal_data_version,
        )
        token_response = _issue_token_pair(db, user)
        db.commit()
        return token_response
    except IntegrityError as exc:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="User registration conflict",
        ) from exc


def authenticate_user(db: Session, email: str, password: str) -> User:
    user = user_repository.get_user_by_email(db, email.lower())
    if not user or not verify_password(password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password",
        )
    return user


def login_user(db: Session, request: LoginRequest) -> TokenResponse:
    user = authenticate_user(db, str(request.email), request.password)
    token_response = _issue_token_pair(db, user)
    db.commit()
    return token_response


def refresh_access_token(db: Session, refresh_token: str) -> TokenResponse:
    token_hash = hash_token(refresh_token)
    refresh_token_model = refresh_token_repository.get_refresh_token_by_hash(
        db,
        token_hash,
    )
    if not refresh_token_model or refresh_token_model.revoked_at is not None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid refresh token",
        )

    expires_at = _ensure_aware(refresh_token_model.expires_at)
    if expires_at <= datetime.now(UTC):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Refresh token expired",
        )

    return TokenResponse(
        access_token=create_access_token(str(refresh_token_model.user_id)),
        refresh_token=refresh_token,
    )


def logout_user(db: Session, refresh_token: str) -> None:
    token_hash = hash_token(refresh_token)
    refresh_token_model = refresh_token_repository.get_refresh_token_by_hash(
        db,
        token_hash,
    )
    if refresh_token_model and refresh_token_model.revoked_at is None:
        refresh_token_repository.revoke_refresh_token(db, refresh_token_model)
        db.commit()


def delete_account(db: Session, user: User, request: DeleteAccountRequest) -> None:
    if not verify_password(request.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid password",
        )

    refresh_token_repository.delete_refresh_tokens_by_user_id(db, user.id)
    legal_repository.delete_legal_acceptances_by_user_id(db, user.id)
    progress_repository.delete_progress_by_user_id(db, user.id)
    profile_repository.delete_profile_by_user_id(db, user.id)
    user_repository.delete_user(db, user)
    db.commit()


def get_user_from_access_token(db: Session, token: str) -> User:
    try:
        payload = decode_token(token)
    except InvalidTokenError as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid access token",
        ) from exc

    if payload.get("type") != "access" or not payload.get("sub"):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid access token",
        )

    try:
        user_id = UUID(str(payload["sub"]))
    except ValueError as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid access token",
        ) from exc

    user = user_repository.get_user_by_id(db, user_id)
    if not user or user.deleted_at is not None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found",
        )
    return user


def _issue_token_pair(db: Session, user: User) -> TokenResponse:
    raw_refresh_token, refresh_token_hash = create_raw_refresh_token(str(user.id))
    refresh_expires_at = datetime.now(UTC) + timedelta(
        days=settings.refresh_token_expire_days,
    )
    refresh_token_repository.create_refresh_token(
        db,
        user_id=user.id,
        token_hash=refresh_token_hash,
        expires_at=refresh_expires_at,
    )
    return TokenResponse(
        access_token=create_access_token(str(user.id)),
        refresh_token=raw_refresh_token,
    )


def _ensure_aware(value: datetime) -> datetime:
    if value.tzinfo is None:
        return value.replace(tzinfo=UTC)
    return value
