from typing import Annotated

from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.api.dependencies import get_current_user
from app.core.database import get_db
from app.models import User
from app.schemas.auth import (
    DeleteAccountRequest,
    LoginRequest,
    RefreshRequest,
    RegisterRequest,
    TokenResponse,
)
from app.services.auth_service import delete_account, login_user, logout_user, refresh_access_token
from app.services.auth_service import register_user


router = APIRouter(prefix="/auth", tags=["auth"])


@router.post(
    "/register",
    response_model=TokenResponse,
    status_code=status.HTTP_201_CREATED,
)
def register(
    request: RegisterRequest,
    db: Annotated[Session, Depends(get_db)],
) -> TokenResponse:
    return register_user(db, request)


@router.post("/login", response_model=TokenResponse)
def login(
    request: LoginRequest,
    db: Annotated[Session, Depends(get_db)],
) -> TokenResponse:
    return login_user(db, request)


@router.post("/refresh", response_model=TokenResponse)
def refresh(
    request: RefreshRequest,
    db: Annotated[Session, Depends(get_db)],
) -> TokenResponse:
    return refresh_access_token(db, request.refresh_token)


@router.post("/logout")
def logout(
    request: RefreshRequest,
    db: Annotated[Session, Depends(get_db)],
) -> dict[str, str]:
    logout_user(db, request.refresh_token)
    return {"status": "ok"}


@router.post("/delete-account")
def delete_current_account(
    request: DeleteAccountRequest,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[Session, Depends(get_db)],
) -> dict[str, str]:
    delete_account(db, current_user, request)
    return {"status": "deleted"}
