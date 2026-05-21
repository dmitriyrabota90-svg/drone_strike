from uuid import uuid4

from fastapi.testclient import TestClient

from app.main import app


client = TestClient(app)


def unique_email() -> str:
    return f"user-{uuid4().hex}@example.com"


def register_payload(email: str, password: str = "password123") -> dict[str, object]:
    return {
        "email": email,
        "password": password,
        "accepted_terms": True,
        "accepted_personal_data": True,
        "is_at_least_13": True,
    }


def test_register_ok() -> None:
    response = client.post("/api/v1/auth/register", json=register_payload(unique_email()))

    assert response.status_code == 201
    data = response.json()
    assert data["access_token"]
    assert data["refresh_token"]
    assert data["token_type"] == "bearer"


def test_register_duplicate_email() -> None:
    email = unique_email()

    first_response = client.post("/api/v1/auth/register", json=register_payload(email))
    second_response = client.post("/api/v1/auth/register", json=register_payload(email))

    assert first_response.status_code == 201
    assert second_response.status_code == 409


def test_register_rejects_missing_legal_consent() -> None:
    payload = register_payload(unique_email())
    payload["accepted_personal_data"] = False

    response = client.post("/api/v1/auth/register", json=payload)

    assert response.status_code == 422


def test_login_ok() -> None:
    email = unique_email()
    password = "password123"

    register_response = client.post(
        "/api/v1/auth/register",
        json=register_payload(email, password),
    )
    login_response = client.post(
        "/api/v1/auth/login",
        json={"email": email, "password": password},
    )

    assert register_response.status_code == 201
    assert login_response.status_code == 200
    data = login_response.json()
    assert data["access_token"]
    assert data["refresh_token"]


def test_login_invalid_password() -> None:
    email = unique_email()

    register_response = client.post("/api/v1/auth/register", json=register_payload(email))
    login_response = client.post(
        "/api/v1/auth/login",
        json={"email": email, "password": "wrongpassword"},
    )

    assert register_response.status_code == 201
    assert login_response.status_code == 401


def test_me_ok() -> None:
    email = unique_email()
    register_response = client.post("/api/v1/auth/register", json=register_payload(email))
    access_token = register_response.json()["access_token"]

    me_response = client.get(
        "/api/v1/me",
        headers={"Authorization": f"Bearer {access_token}"},
    )

    assert register_response.status_code == 201
    assert me_response.status_code == 200
    data = me_response.json()
    assert data["email"] == email
    assert data["display_name"].startswith("Drone")


def test_me_without_token() -> None:
    response = client.get("/api/v1/me")

    assert response.status_code == 401
