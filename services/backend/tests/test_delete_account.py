from uuid import UUID, uuid4

from fastapi.testclient import TestClient
from sqlalchemy import func, select

from app.core.database import SessionLocal
from app.main import app
from app.models import LegalAcceptance, MissionProgress, PlayerProfile, RefreshToken, User


client = TestClient(app)
PASSWORD = "password123"


def unique_email() -> str:
    return f"delete-{uuid4().hex}@example.com"


def register_user() -> tuple[str, str]:
    email = unique_email()
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


def complete_mission(access_token: str) -> None:
    response = client.post(
        "/api/v1/progress/mission-complete",
        headers=auth_headers(access_token),
        json={
            "mission_number": 1,
            "flight_accuracy_bonus": 20,
            "tank_hit_bonus": 30,
        },
    )
    assert response.status_code == 200


def delete_account(access_token: str, password: str = PASSWORD):
    return client.post(
        "/api/v1/auth/delete-account",
        headers=auth_headers(access_token),
        json={"password": password},
    )


def test_delete_account_ok() -> None:
    _, access_token = register_user()
    complete_mission(access_token)

    assert client.get("/api/v1/me", headers=auth_headers(access_token)).status_code == 200
    assert (
        client.get("/api/v1/progress", headers=auth_headers(access_token)).status_code
        == 200
    )

    response = delete_account(access_token)

    assert response.status_code == 200
    assert response.json()["status"] == "deleted"


def test_deleted_account_cannot_use_old_access_token() -> None:
    _, access_token = register_user()

    assert delete_account(access_token).status_code == 200
    me_response = client.get("/api/v1/me", headers=auth_headers(access_token))

    assert me_response.status_code in (401, 404)


def test_deleted_account_cannot_login() -> None:
    email, access_token = register_user()

    assert delete_account(access_token).status_code == 200
    login_response = client.post(
        "/api/v1/auth/login",
        json={"email": email, "password": PASSWORD},
    )

    assert login_response.status_code == 401


def test_delete_account_with_wrong_password() -> None:
    _, access_token = register_user()

    response = delete_account(access_token, password="wrongpassword")
    me_response = client.get("/api/v1/me", headers=auth_headers(access_token))

    assert response.status_code == 401
    assert me_response.status_code == 200


def test_delete_account_removes_user_related_rows() -> None:
    email, access_token = register_user()
    complete_mission(access_token)
    user_id = UUID(
        client.get("/api/v1/me", headers=auth_headers(access_token)).json()["id"]
    )

    response = delete_account(access_token)

    assert response.status_code == 200
    with SessionLocal() as db:
        assert db.scalar(select(User).where(User.email == email)) is None
        assert db.scalar(
            select(func.count()).select_from(PlayerProfile).where(
                PlayerProfile.user_id == user_id
            )
        ) == 0
        assert db.scalar(
            select(func.count()).select_from(MissionProgress).where(
                MissionProgress.user_id == user_id
            )
        ) == 0
        assert db.scalar(
            select(func.count()).select_from(RefreshToken).where(
                RefreshToken.user_id == user_id
            )
        ) == 0
        assert db.scalar(
            select(func.count()).select_from(LegalAcceptance).where(
                LegalAcceptance.user_id == user_id
            )
        ) == 0
