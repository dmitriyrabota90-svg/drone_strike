from __future__ import annotations

import secrets
from datetime import UTC, datetime, timedelta
from html import escape
from urllib.parse import urlencode
from uuid import UUID

from fastapi import HTTPException, status
from fastapi.responses import HTMLResponse
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
from app.repositories import auth_token_repository
from app.repositories import legal_repository
from app.repositories import profile_repository
from app.repositories import progress_repository
from app.repositories import refresh_token_repository
from app.repositories import user_repository
from app.schemas.auth import (
    DeleteAccountRequest,
    LoginRequest,
    PasswordResetConfirmRequest,
    PasswordResetRequest,
    RegisterRequest,
    TokenResponse,
)
from app.services import email_service
from app.services.email_service import EmailDeliveryError


EMAIL_VERIFICATION_PURPOSE = "email_verification"
PASSWORD_RESET_PURPOSE = "password_reset"
PASSWORD_RESET_GENERIC_MESSAGE = "If account exists, reset instructions were sent"


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
    auth_token_repository.delete_auth_tokens_by_user_id(db, user.id)
    profile_repository.delete_profile_by_user_id(db, user.id)
    user_repository.delete_user(db, user)
    db.commit()


def request_email_verification(db: Session, user: User) -> dict[str, str]:
    if user.email_verified:
        return {"message": "Email is already verified"}

    raw_token, token_hash = _create_auth_action_token()
    expires_at = datetime.now(UTC) + timedelta(hours=24)
    auth_token_repository.invalidate_active_tokens(
        db,
        email=user.email,
        purpose=EMAIL_VERIFICATION_PURPOSE,
    )
    auth_token_repository.create_auth_token(
        db,
        user_id=user.id,
        email=user.email,
        token_hash=token_hash,
        purpose=EMAIL_VERIFICATION_PURPOSE,
        expires_at=expires_at,
    )
    db.commit()

    link = _build_api_link(
        "/api/v1/auth/email/verification/confirm",
        {"token": raw_token},
    )
    try:
        email_service.send_email_verification_email(user.email, link)
    except EmailDeliveryError as exc:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Email delivery is temporarily unavailable",
        ) from exc

    return {"message": "Verification email sent"}


def confirm_email_verification(db: Session, raw_token: str) -> dict[str, str]:
    auth_token = _get_valid_auth_token(
        db,
        raw_token=raw_token,
        purpose=EMAIL_VERIFICATION_PURPOSE,
    )
    user = auth_token.user
    if user is None or user.deleted_at is not None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid or expired token",
        )

    user_repository.mark_email_verified(db, user)
    auth_token_repository.mark_auth_token_used(db, auth_token)
    db.commit()
    return {"message": "Email verified"}


def confirm_email_verification_html(db: Session, raw_token: str) -> HTMLResponse:
    try:
        confirm_email_verification(db, raw_token)
    except HTTPException:
        return _html_page(
            title="Ссылка недействительна",
            message="Ссылка подтверждения email недействительна или устарела.",
            status_code=status.HTTP_400_BAD_REQUEST,
        )

    return _html_page(
        title="Email подтвержден",
        message="Email успешно подтвержден. Можно вернуться в FPV Last Run.",
    )


def request_password_reset(
    db: Session,
    request: PasswordResetRequest,
) -> dict[str, str]:
    email = str(request.email).lower()
    user = user_repository.get_user_by_email(db, email)
    if user is None or user.deleted_at is not None:
        return {"message": PASSWORD_RESET_GENERIC_MESSAGE}

    raw_token, token_hash = _create_auth_action_token()
    expires_at = datetime.now(UTC) + timedelta(hours=1)
    auth_token_repository.invalidate_active_tokens(
        db,
        email=email,
        purpose=PASSWORD_RESET_PURPOSE,
    )
    auth_token_repository.create_auth_token(
        db,
        user_id=user.id,
        email=email,
        token_hash=token_hash,
        purpose=PASSWORD_RESET_PURPOSE,
        expires_at=expires_at,
    )
    db.commit()

    link = _build_api_link("/api/v1/auth/password-reset", {"token": raw_token})
    try:
        email_service.send_password_reset_email(email, link)
    except EmailDeliveryError:
        # Keep the response generic so password reset cannot reveal account existence.
        pass

    return {"message": PASSWORD_RESET_GENERIC_MESSAGE}


def confirm_password_reset(
    db: Session,
    request: PasswordResetConfirmRequest,
) -> dict[str, str]:
    auth_token = _get_valid_auth_token(
        db,
        raw_token=request.token,
        purpose=PASSWORD_RESET_PURPOSE,
    )
    user = auth_token.user
    if user is None or user.deleted_at is not None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid or expired token",
        )

    user_repository.update_password_hash(
        db,
        user,
        hash_password(request.new_password),
    )
    auth_token_repository.mark_auth_token_used(db, auth_token)
    refresh_token_repository.delete_refresh_tokens_by_user_id(db, user.id)
    db.commit()
    return {"message": "Password reset complete"}


def password_reset_form_html(raw_token: str) -> HTMLResponse:
    escaped_token = escape(raw_token, quote=True)
    return HTMLResponse(
        content=f"""<!doctype html>
<html lang="ru">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Восстановление пароля — FPV Last Run</title>
  <style>
    body {{
      margin: 0;
      min-height: 100vh;
      display: grid;
      place-items: center;
      background: #07090d;
      color: #f5f7fb;
      font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
    }}
    main {{
      width: min(440px, calc(100% - 32px));
      border: 1px solid rgba(255,255,255,.14);
      border-radius: 12px;
      padding: 24px;
      background: rgba(15,19,27,.92);
    }}
    label, input, button {{ display: block; width: 100%; }}
    input {{
      margin: 8px 0 16px;
      padding: 12px;
      border-radius: 8px;
      border: 1px solid rgba(255,255,255,.18);
      background: #0b0f16;
      color: #f5f7fb;
    }}
    button {{
      min-height: 44px;
      border: 1px solid rgba(39,224,197,.5);
      border-radius: 8px;
      background: rgba(39,224,197,.14);
      color: #f5f7fb;
      font-weight: 700;
    }}
    #message {{ color: #aeb8c8; }}
  </style>
</head>
<body>
  <main>
    <h1>Восстановление пароля</h1>
    <p id="message">Введите новый пароль для FPV Last Run.</p>
    <label for="password">Новый пароль</label>
    <input id="password" type="password" minlength="8" autocomplete="new-password" required>
    <button id="submit" type="button">Сохранить пароль</button>
  </main>
  <script>
    const button = document.getElementById("submit");
    const message = document.getElementById("message");
    button.addEventListener("click", async () => {{
      const password = document.getElementById("password").value;
      if (password.length < 8) {{
        message.textContent = "Пароль должен быть не короче 8 символов.";
        return;
      }}
      button.disabled = true;
      const response = await fetch("/api/v1/auth/password-reset/confirm", {{
        method: "POST",
        headers: {{ "Content-Type": "application/json" }},
        body: JSON.stringify({{ token: "{escaped_token}", new_password: password }})
      }});
      message.textContent = response.ok
        ? "Пароль обновлен. Можно вернуться в FPV Last Run."
        : "Ссылка недействительна или устарела.";
      button.disabled = false;
    }});
  </script>
</body>
</html>""",
    )


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


def _create_auth_action_token() -> tuple[str, str]:
    raw_token = secrets.token_urlsafe(48)
    return raw_token, hash_token(raw_token)


def _build_api_link(path: str, params: dict[str, str]) -> str:
    base_url = settings.public_api_url.rstrip("/")
    return f"{base_url}{path}?{urlencode(params)}"


def _get_valid_auth_token(db: Session, *, raw_token: str, purpose: str):
    auth_token = auth_token_repository.get_auth_token_by_hash(
        db,
        hash_token(raw_token),
    )
    if auth_token is None or auth_token.purpose != purpose:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid or expired token",
        )
    if auth_token.used_at is not None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid or expired token",
        )
    if _ensure_aware(auth_token.expires_at) <= datetime.now(UTC):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid or expired token",
        )
    return auth_token


def _html_page(title: str, message: str, status_code: int = status.HTTP_200_OK):
    return HTMLResponse(
        content=f"""<!doctype html>
<html lang="ru">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>{escape(title)} — FPV Last Run</title>
  <style>
    body {{
      margin: 0;
      min-height: 100vh;
      display: grid;
      place-items: center;
      background: #07090d;
      color: #f5f7fb;
      font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
    }}
    main {{
      width: min(520px, calc(100% - 32px));
      border: 1px solid rgba(255,255,255,.14);
      border-radius: 12px;
      padding: 24px;
      background: rgba(15,19,27,.92);
    }}
    p {{ color: #aeb8c8; line-height: 1.6; }}
  </style>
</head>
<body>
  <main>
    <h1>{escape(title)}</h1>
    <p>{escape(message)}</p>
  </main>
</body>
</html>""",
        status_code=status_code,
    )


def _ensure_aware(value: datetime) -> datetime:
    if value.tzinfo is None:
        return value.replace(tzinfo=UTC)
    return value
