from uuid import uuid4

from fastapi.testclient import TestClient

from app.main import app


client = TestClient(app)


def unique_email() -> str:
    return f"profile-{uuid4().hex}@example.com"


def unique_display_name(prefix: str = "Pilot") -> str:
    return f"{prefix}_{uuid4().hex[:8]}"


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


def test_change_display_name_ok() -> None:
    _, access_token = register_and_get_token()
    new_name = unique_display_name()

    response = client.patch(
        "/api/v1/me/display-name",
        headers=auth_headers(access_token),
        json={"display_name": new_name},
    )
    me_response = client.get("/api/v1/me", headers=auth_headers(access_token))

    assert response.status_code == 200
    assert response.json()["display_name"] == new_name
    assert response.json()["name_changed_once"] is True
    assert me_response.json()["display_name"] == new_name


def test_cannot_change_display_name_twice() -> None:
    _, access_token = register_and_get_token()

    first_response = client.patch(
        "/api/v1/me/display-name",
        headers=auth_headers(access_token),
        json={"display_name": unique_display_name("First")},
    )
    second_response = client.patch(
        "/api/v1/me/display-name",
        headers=auth_headers(access_token),
        json={"display_name": unique_display_name("Second")},
    )

    assert first_response.status_code == 200
    assert second_response.status_code == 400


def test_duplicate_display_name_rejected() -> None:
    _, first_token = register_and_get_token()
    _, second_token = register_and_get_token()
    display_name = unique_display_name("Unique")

    first_response = client.patch(
        "/api/v1/me/display-name",
        headers=auth_headers(first_token),
        json={"display_name": display_name},
    )
    second_response = client.patch(
        "/api/v1/me/display-name",
        headers=auth_headers(second_token),
        json={"display_name": display_name},
    )

    assert first_response.status_code == 200
    assert second_response.status_code == 409


def test_invalid_display_name_rejected() -> None:
    _, access_token = register_and_get_token()

    for display_name in ["ab", "bad name", "имя", "name!"]:
        response = client.patch(
            "/api/v1/me/display-name",
            headers=auth_headers(access_token),
            json={"display_name": display_name},
        )
        assert response.status_code in (400, 422)
