from uuid import uuid4

from fastapi.testclient import TestClient
from sqlalchemy import func, select

from app.core.database import SessionLocal
from app.main import app
from app.models import LeaderboardSeedPlayer
from app.seed.leaderboard_seed import LEADERBOARD_SEED_PLAYERS, seed_leaderboard_players


client = TestClient(app)


def unique_email() -> str:
    return f"leaderboard-{uuid4().hex}@example.com"


def register_and_get_token() -> tuple[str, str]:
    email = unique_email()
    response = client.post(
        "/api/v1/auth/register",
        json={
            "email": email,
            "password": "password123",
            "accepted_terms": True,
            "accepted_personal_data": True,
            "is_at_least_13": True,
        },
    )

    assert response.status_code == 201
    return email, response.json()["access_token"]


def auth_headers(access_token: str) -> dict[str, str]:
    return {"Authorization": f"Bearer {access_token}"}


def complete_mission(
    access_token: str,
    mission_number: int,
    flight_bonus: int,
    tank_bonus: int,
) -> None:
    response = client.post(
        "/api/v1/progress/mission-complete",
        headers=auth_headers(access_token),
        json={
            "mission_number": mission_number,
            "flight_accuracy_bonus": flight_bonus,
            "tank_hit_bonus": tank_bonus,
        },
    )
    assert response.status_code == 200


def test_leaderboard_requires_auth() -> None:
    response = client.get("/api/v1/leaderboard")

    assert response.status_code in (401, 403)


def test_leaderboard_me_requires_auth() -> None:
    response = client.get("/api/v1/leaderboard/me")

    assert response.status_code in (401, 403)


def test_leaderboard_returns_current_player() -> None:
    email, access_token = register_and_get_token()
    complete_mission(access_token, 1, 20, 30)

    response = client.get("/api/v1/leaderboard", headers=auth_headers(access_token))
    me_response = client.get("/api/v1/me", headers=auth_headers(access_token))

    assert response.status_code == 200
    data = response.json()
    assert isinstance(data["entries"], list)
    assert data["me"] is not None
    assert data["me"]["display_name"] == me_response.json()["display_name"]
    assert data["me"]["display_name"].startswith("Drone")
    assert data["me"]["total_score"] > 0
    assert me_response.json()["email"] == email


def test_leaderboard_me_returns_rank() -> None:
    _, access_token = register_and_get_token()
    complete_mission(access_token, 1, 20, 30)

    response = client.get("/api/v1/leaderboard/me", headers=auth_headers(access_token))

    assert response.status_code == 200
    data = response.json()
    assert data["rank"] >= 1
    assert data["total_count"] >= 1


def test_leaderboard_is_sorted_by_total_score_desc() -> None:
    _, first_token = register_and_get_token()
    _, second_token = register_and_get_token()
    _, third_token = register_and_get_token()
    complete_mission(first_token, 1, 10, 10)
    complete_mission(second_token, 1, 50, 50)
    complete_mission(third_token, 1, 25, 25)

    response = client.get("/api/v1/leaderboard", headers=auth_headers(first_token))

    assert response.status_code == 200
    scores = [entry["total_score"] for entry in response.json()["entries"]]
    assert scores == sorted(scores, reverse=True)


def test_seed_function_is_idempotent() -> None:
    seed_names = [display_name for display_name, _, _ in LEADERBOARD_SEED_PLAYERS]
    with SessionLocal() as db:
        seed_leaderboard_players(db)
        first_count = db.scalar(
            select(func.count())
            .select_from(LeaderboardSeedPlayer)
            .where(LeaderboardSeedPlayer.display_name.in_(seed_names))
        )
        seed_leaderboard_players(db)
        second_count = db.scalar(
            select(func.count())
            .select_from(LeaderboardSeedPlayer)
            .where(LeaderboardSeedPlayer.display_name.in_(seed_names))
        )

    assert first_count == len(seed_names)
    assert second_count == first_count


def test_leaderboard_works_with_seed_players() -> None:
    with SessionLocal() as db:
        seed_leaderboard_players(db)
    _, access_token = register_and_get_token()

    response = client.get("/api/v1/leaderboard", headers=auth_headers(access_token))

    assert response.status_code == 200
    data = response.json()
    assert data["entries"]
    assert "email" not in str(data).lower()


def test_limit_parameter_works() -> None:
    _, access_token = register_and_get_token()

    response = client.get(
        "/api/v1/leaderboard?limit=5",
        headers=auth_headers(access_token),
    )

    assert response.status_code == 200
    assert len(response.json()["entries"]) <= 5


def test_invalid_limit_rejected() -> None:
    _, access_token = register_and_get_token()

    low_response = client.get(
        "/api/v1/leaderboard?limit=0",
        headers=auth_headers(access_token),
    )
    high_response = client.get(
        "/api/v1/leaderboard?limit=101",
        headers=auth_headers(access_token),
    )

    assert low_response.status_code == 422
    assert high_response.status_code == 422
