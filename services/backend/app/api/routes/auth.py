from typing import Annotated

from fastapi import APIRouter, Depends, Query, status
from fastapi.responses import HTMLResponse
from sqlalchemy.orm import Session

from app.api.dependencies import get_current_user
from app.core.database import get_db
from app.models import User
from app.schemas.auth import (
    DeleteAccountRequest,
    EmailVerificationConfirmRequest,
    LoginRequest,
    MessageResponse,
    PasswordResetConfirmRequest,
    PasswordResetRequest,
    RefreshRequest,
    RegisterRequest,
    TokenResponse,
)
from app.services.auth_service import confirm_email_verification
from app.services.auth_service import confirm_email_verification_html
from app.services.auth_service import confirm_password_reset
from app.services.auth_service import delete_account, login_user, logout_user, refresh_access_token
from app.services.auth_service import password_reset_form_html
from app.services.auth_service import request_email_verification, request_password_reset
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


@router.post(
    "/email/verification/request",
    response_model=MessageResponse,
)
def request_current_user_email_verification(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[Session, Depends(get_db)],
) -> dict[str, str]:
    return request_email_verification(db, current_user)


@router.post(
    "/email/verification/confirm",
    response_model=MessageResponse,
)
def post_confirm_email_verification(
    request: EmailVerificationConfirmRequest,
    db: Annotated[Session, Depends(get_db)],
) -> dict[str, str]:
    return confirm_email_verification(db, request.token)


@router.get(
    "/email/verification/confirm",
    response_class=HTMLResponse,
)
def get_confirm_email_verification(
    db: Annotated[Session, Depends(get_db)],
    token: Annotated[str, Query(min_length=16)],
) -> HTMLResponse:
    return confirm_email_verification_html(db, token)


@router.post(
    "/password-reset/request",
    response_model=MessageResponse,
)
def post_password_reset_request(
    request: PasswordResetRequest,
    db: Annotated[Session, Depends(get_db)],
) -> dict[str, str]:
    return request_password_reset(db, request)


@router.post(
    "/password-reset/confirm",
    response_model=MessageResponse,
)
def post_password_reset_confirm(
    request: PasswordResetConfirmRequest,
    db: Annotated[Session, Depends(get_db)],
) -> dict[str, str]:
    return confirm_password_reset(db, request)


@router.get(
    "/password-reset",
    response_class=HTMLResponse,
)
def get_password_reset_form(
    token: Annotated[str, Query(min_length=16)],
) -> HTMLResponse:
    return password_reset_form_html(token)
