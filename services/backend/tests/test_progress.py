from uuid import uuid4

from fastapi.testclient import TestClient

from app.main import app


client = TestClient(app)


def unique_email() -> str:
    return f"progress-{uuid4().hex}@example.com"


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
):
    return client.post(
        "/api/v1/progress/mission-complete",
        headers=auth_headers(access_token),
        json={
            "mission_number": mission_number,
            "flight_accuracy_bonus": flight_bonus,
            "tank_hit_bonus": tank_bonus,
        },
    )


def test_get_progress_after_registration() -> None:
    _, access_token = register_and_get_token()

    response = client.get("/api/v1/progress", headers=auth_headers(access_token))

    assert response.status_code == 200
    data = response.json()
    assert data["total_score"] == 0
    assert data["player_level"] == 1
    assert data["completed_missions_count"] == 0
    assert data["unlocked_mission"] == 1
    assert data["missions"] == []


def test_complete_mission_1() -> None:
    _, access_token = register_and_get_token()

    response = complete_mission(access_token, 1, 20, 30)

    assert response.status_code == 200
    data = response.json()
    assert data["submitted_score"] == 150
    assert data["previous_best_score"] == 0
    assert data["saved_best_score"] == 150
    assert data["score_improved"] is True
    assert data["total_score"] == 150


def test_recomplete_mission_with_worse_score_keeps_best() -> None:
    _, access_token = register_and_get_token()

    first_response = complete_mission(access_token, 1, 40, 40)
    second_response = complete_mission(access_token, 1, 10, 10)

    assert first_response.status_code == 200
    assert second_response.status_code == 200
    data = second_response.json()
    assert data["submitted_score"] == 120
    assert data["previous_best_score"] == 180
    assert data["saved_best_score"] == 180
    assert data["score_improved"] is False
    assert data["total_score"] == 180


def test_recomplete_mission_with_better_score_updates_best() -> None:
    _, access_token = register_and_get_token()

    first_response = complete_mission(access_token, 1, 10, 20)
    second_response = complete_mission(access_token, 1, 45, 45)

    assert first_response.status_code == 200
    assert second_response.status_code == 200
    data = second_response.json()
    assert data["submitted_score"] == 190
    assert data["previous_best_score"] == 130
    assert data["saved_best_score"] == 190
    assert data["score_improved"] is True
    assert data["total_score"] == 190


def test_mission_sequence_validation() -> None:
    _, access_token = register_and_get_token()

    response = complete_mission(access_token, 3, 20, 20)

    assert response.status_code == 400


def test_unlock_next_mission() -> None:
    _, access_token = register_and_get_token()

    complete_response = complete_mission(access_token, 1, 20, 20)
    progress_response = client.get(
        "/api/v1/progress",
        headers=auth_headers(access_token),
    )

    assert complete_response.status_code == 200
    assert progress_response.status_code == 200
    assert progress_response.json()["unlocked_mission"] == 2


def test_player_level_update_visible_in_me() -> None:
    email, access_token = register_and_get_token()

    assert complete_mission(access_token, 1, 50, 50).status_code == 200
    assert complete_mission(access_token, 2, 50, 50).status_code == 200

    me_response = client.get("/api/v1/me", headers=auth_headers(access_token))

    assert me_response.status_code == 200
    data = me_response.json()
    assert data["email"] == email
    assert data["total_score"] == 400
    assert data["player_level"] == 2
