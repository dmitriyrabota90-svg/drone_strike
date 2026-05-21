import argparse
import sys
import uuid

import httpx


DEFAULT_BASE_URL = "http://localhost:8000"
PASSWORD = "TestPassword123"


def fail(name: str, response: httpx.Response) -> None:
    print(f"[FAIL] {name}", file=sys.stderr)
    print(f"Endpoint: {response.request.method} {response.request.url}", file=sys.stderr)
    print(f"Status: {response.status_code}", file=sys.stderr)
    print(f"Response: {response.text}", file=sys.stderr)
    raise SystemExit(1)


def expect_status(
    name: str,
    response: httpx.Response,
    expected_statuses: set[int] | None = None,
) -> dict:
    expected = expected_statuses or {200}
    if response.status_code not in expected:
        fail(name, response)
    print(f"[OK] {name}")
    if response.content:
        return response.json()
    return {}


def main() -> None:
    parser = argparse.ArgumentParser(description="Run Drone Strike API smoke checks.")
    parser.add_argument("--base-url", default=DEFAULT_BASE_URL)
    args = parser.parse_args()

    base_url = args.base_url.rstrip("/")
    unique_id = uuid.uuid4().hex[:10]
    email = f"smoke_{unique_id}@example.com"
    display_name = f"Smoke_{unique_id[:8]}"

    with httpx.Client(base_url=base_url, timeout=10.0) as client:
        expect_status("health", client.get("/health"))
        expect_status("api health", client.get("/api/v1/health"))
        expect_status("legal documents", client.get("/api/v1/legal/documents"))

        token_data = expect_status(
            "register",
            client.post(
                "/api/v1/auth/register",
                json={
                    "email": email,
                    "password": PASSWORD,
                    "accepted_terms": True,
                    "accepted_personal_data": True,
                    "is_at_least_13": True,
                },
            ),
            {200, 201},
        )
        access_token = token_data["access_token"]
        refresh_token = token_data["refresh_token"]
        auth_headers = {"Authorization": f"Bearer {access_token}"}

        expect_status("me", client.get("/api/v1/me", headers=auth_headers))
        expect_status(
            "display name",
            client.patch(
                "/api/v1/me/display-name",
                headers=auth_headers,
                json={"display_name": display_name},
            ),
        )
        expect_status(
            "mission complete",
            client.post(
                "/api/v1/progress/mission-complete",
                headers=auth_headers,
                json={
                    "mission_number": 1,
                    "flight_accuracy_bonus": 20,
                    "tank_hit_bonus": 30,
                },
            ),
        )
        expect_status("progress", client.get("/api/v1/progress", headers=auth_headers))
        expect_status(
            "leaderboard",
            client.get("/api/v1/leaderboard", headers=auth_headers, params={"limit": 10}),
        )
        expect_status("leaderboard me", client.get("/api/v1/leaderboard/me", headers=auth_headers))
        expect_status(
            "legal accept",
            client.post(
                "/api/v1/legal/accept",
                headers=auth_headers,
                json={"document_type": "privacy_policy", "document_version": "1.0"},
            ),
        )
        expect_status(
            "logout",
            client.post("/api/v1/auth/logout", json={"refresh_token": refresh_token}),
        )

        fresh_token_data = expect_status(
            "login after logout",
            client.post(
                "/api/v1/auth/login",
                json={"email": email, "password": PASSWORD},
            ),
        )
        fresh_access_token = fresh_token_data["access_token"]
        fresh_headers = {"Authorization": f"Bearer {fresh_access_token}"}

        expect_status(
            "delete account",
            client.post(
                "/api/v1/auth/delete-account",
                headers=fresh_headers,
                json={"password": PASSWORD},
            ),
        )
        expect_status(
            "old token rejected after delete",
            client.get("/api/v1/me", headers=fresh_headers),
            {401, 404},
        )

    print("Smoke API completed successfully.")


if __name__ == "__main__":
    main()
