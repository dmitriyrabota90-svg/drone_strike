from __future__ import annotations

from datetime import UTC, datetime, timedelta
from urllib.parse import parse_qs, urlparse
from uuid import uuid4

from fastapi.testclient import TestClient
from sqlalchemy import select

from app.core.database import SessionLocal
from app.core.security import hash_token
from app.main import app
from app.models import AuthToken, User


client = TestClient(app)
PASSWORD = "password123"
NEW_PASSWORD = "newpassword123"


def unique_email() -> str:
    return f"email-auth-{uuid4().hex}@example.com"


def register_user(email: str | None = None) -> tuple[str, str]:
    email = email or unique_email()
    response = client.post(
        "/api/v1/auth/register",
        json={
            "email": email,
            "password": PASSWORD,
            "accepted_terms": True,
            "accepted_personal_data": True,
            "is_at_least_13": True,
        },
    )

    assert response.status_code == 201
    return email, response.json()["access_token"]


def auth_headers(access_token: str) -> dict[str, str]:
    return {"Authorization": f"Bearer {access_token}"}


def token_from_link(link: str) -> str:
    token = parse_qs(urlparse(link).query).get("token", [None])[0]
    assert token
    return token


def capture_email_links(monkeypatch) -> list[tuple[str, str]]:
    links: list[tuple[str, str]] = []

    def capture(email: str, link: str) -> None:
        links.append((email, link))

    monkeypatch.setattr(
        "app.services.email_service.send_email_verification_email",
        capture,
    )
    monkeypatch.setattr(
        "app.services.email_service.send_password_reset_email",
        capture,
    )
    return links


def test_email_verification_request_creates_hashed_token(monkeypatch) -> None:
    email, access_token = register_user()
    links = capture_email_links(monkeypatch)

    response = client.post(
        "/api/v1/auth/email/verification/request",
        headers=auth_headers(access_token),
    )

    assert response.status_code == 200
    assert response.json()["message"] == "Verification email sent"
    assert links and links[0][0] == email

    raw_token = token_from_link(links[0][1])
    with SessionLocal() as db:
        auth_token = db.scalar(
            select(AuthToken).where(AuthToken.token_hash == hash_token(raw_token))
        )
        assert auth_token is not None
        assert auth_token.token_hash != raw_token
        assert auth_token.purpose == "email_verification"
        assert auth_token.used_at is None


def test_email_verification_confirm_marks_email_verified(monkeypatch) -> None:
    _, access_token = register_user()
    links = capture_email_links(monkeypatch)

    assert (
        client.post(
            "/api/v1/auth/email/verification/request",
            headers=auth_headers(access_token),
        ).status_code
        == 200
    )
    raw_token = token_from_link(links[0][1])

    response = client.post(
        "/api/v1/auth/email/verification/confirm",
        json={"token": raw_token},
    )
    me_response = client.get("/api/v1/me", headers=auth_headers(access_token))

    assert response.status_code == 200
    assert response.json()["message"] == "Email verified"
    assert me_response.status_code == 200
    assert me_response.json()["email_verified"] is True


def test_email_verification_invalid_and_expired_tokens_are_rejected(monkeypatch) -> None:
    _, access_token = register_user()
    links = capture_email_links(monkeypatch)

    invalid_response = client.post(
        "/api/v1/auth/email/verification/confirm",
        json={"token": "invalid-token-value"},
    )
    assert invalid_response.status_code == 400

    assert (
        client.post(
            "/api/v1/auth/email/verification/request",
            headers=auth_headers(access_token),
        ).status_code
        == 200
    )
    raw_token = token_from_link(links[0][1])
    with SessionLocal() as db:
        auth_token = db.scalar(
            select(AuthToken).where(AuthToken.token_hash == hash_token(raw_token))
        )
        assert auth_token is not None
        auth_token.expires_at = datetime.now(UTC) - timedelta(minutes=1)
        db.add(auth_token)
        db.commit()

    expired_response = client.post(
        "/api/v1/auth/email/verification/confirm",
        json={"token": raw_token},
    )
    assert expired_response.status_code == 400


def test_password_reset_request_is_generic_for_existing_and_unknown_email(
    monkeypatch,
) -> None:
    email, _ = register_user()
    links = capture_email_links(monkeypatch)

    existing_response = client.post(
        "/api/v1/auth/password-reset/request",
        json={"email": email},
    )
    unknown_response = client.post(
        "/api/v1/auth/password-reset/request",
        json={"email": unique_email()},
    )

    assert existing_response.status_code == 200
    assert unknown_response.status_code == 200
    assert existing_response.json() == unknown_response.json()
    assert links and links[0][0] == email
    assert len(links) == 1


def test_password_reset_valid_token_changes_password_and_cannot_be_reused(
    monkeypatch,
) -> None:
    email, _ = register_user()
    links = capture_email_links(monkeypatch)

    assert (
        client.post(
            "/api/v1/auth/password-reset/request",
            json={"email": email},
        ).status_code
        == 200
    )
    raw_token = token_from_link(links[0][1])

    response = client.post(
        "/api/v1/auth/password-reset/confirm",
        json={"token": raw_token, "new_password": NEW_PASSWORD},
    )
    reuse_response = client.post(
        "/api/v1/auth/password-reset/confirm",
        json={"token": raw_token, "new_password": "anotherpassword123"},
    )
    old_login_response = client.post(
        "/api/v1/auth/login",
        json={"email": email, "password": PASSWORD},
    )
    new_login_response = client.post(
        "/api/v1/auth/login",
        json={"email": email, "password": NEW_PASSWORD},
    )

    assert response.status_code == 200
    assert reuse_response.status_code == 400
    assert old_login_response.status_code == 401
    assert new_login_response.status_code == 200


def test_password_reset_expired_token_is_rejected(monkeypatch) -> None:
    email, _ = register_user()
    links = capture_email_links(monkeypatch)

    assert (
        client.post(
            "/api/v1/auth/password-reset/request",
            json={"email": email},
        ).status_code
        == 200
    )
    raw_token = token_from_link(links[0][1])
    with SessionLocal() as db:
        auth_token = db.scalar(
            select(AuthToken).where(AuthToken.token_hash == hash_token(raw_token))
        )
        assert auth_token is not None
        auth_token.expires_at = datetime.now(UTC) - timedelta(minutes=1)
        db.add(auth_token)
        db.commit()

    response = client.post(
        "/api/v1/auth/password-reset/confirm",
        json={"token": raw_token, "new_password": NEW_PASSWORD},
    )

    assert response.status_code == 400


def test_password_reset_html_form_is_available(monkeypatch) -> None:
    email, _ = register_user()
    links = capture_email_links(monkeypatch)

    assert (
        client.post(
            "/api/v1/auth/password-reset/request",
            json={"email": email},
        ).status_code
        == 200
    )
    raw_token = token_from_link(links[0][1])

    response = client.get(f"/api/v1/auth/password-reset?token={raw_token}")

    assert response.status_code == 200
    assert "Восстановление пароля" in response.text
    assert raw_token in response.text


def test_email_verification_html_is_available(monkeypatch) -> None:
    _, access_token = register_user()
    links = capture_email_links(monkeypatch)

    assert (
        client.post(
            "/api/v1/auth/email/verification/request",
            headers=auth_headers(access_token),
        ).status_code
        == 200
    )
    raw_token = token_from_link(links[0][1])

    response = client.get(
        f"/api/v1/auth/email/verification/confirm?token={raw_token}"
    )

    assert response.status_code == 200
    assert "Email подтвержден" in response.text


def test_email_verification_request_for_verified_user_is_safe(monkeypatch) -> None:
    email, access_token = register_user()
    links = capture_email_links(monkeypatch)
    with SessionLocal() as db:
        user = db.scalar(select(User).where(User.email == email))
        assert user is not None
        user.email_verified = True
        db.add(user)
        db.commit()

    response = client.post(
        "/api/v1/auth/email/verification/request",
        headers=auth_headers(access_token),
    )

    assert response.status_code == 200
    assert response.json()["message"] == "Email is already verified"
    assert links == []
