from uuid import uuid4

from fastapi.testclient import TestClient
from sqlalchemy import func, select

from app.core.database import SessionLocal
from app.main import app
from app.models import LegalAcceptance
from app.repositories.user_repository import get_user_by_email
from app.services.legal_service import OPERATOR_EMAIL, OPERATOR_NAME


client = TestClient(app)


def unique_email() -> str:
    return f"legal-{uuid4().hex}@example.com"


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


def test_get_legal_documents() -> None:
    response = client.get("/api/v1/legal/documents")

    assert response.status_code == 200
    documents = response.json()["documents"]
    document_types = {document["type"] for document in documents}
    assert len(documents) == 3
    assert document_types == {
        "terms_of_use",
        "personal_data_consent",
        "privacy_policy",
    }
    for document in documents:
        assert document["operator_name"] == OPERATOR_NAME
        assert document["operator_email"] == OPERATOR_EMAIL
        assert "FPV Last Run" in document["content"]
        assert "URL to be added before publication" in document["content"]
        assert "placeholder" not in document["content"].lower()


def test_legal_accept_requires_auth() -> None:
    response = client.post(
        "/api/v1/legal/accept",
        json={"document_type": "privacy_policy", "document_version": "1.0"},
    )

    assert response.status_code in (401, 403)


def test_legal_accept_ok() -> None:
    _, access_token = register_and_get_token()

    response = client.post(
        "/api/v1/legal/accept",
        headers=auth_headers(access_token),
        json={"document_type": "privacy_policy", "document_version": "1.0"},
    )

    assert response.status_code == 200
    assert response.json() == {
        "status": "accepted",
        "document_type": "privacy_policy",
        "document_version": "1.0",
    }


def test_legal_accept_idempotent() -> None:
    email, access_token = register_and_get_token()
    payload = {"document_type": "privacy_policy", "document_version": "1.0"}

    first_response = client.post(
        "/api/v1/legal/accept",
        headers=auth_headers(access_token),
        json=payload,
    )
    second_response = client.post(
        "/api/v1/legal/accept",
        headers=auth_headers(access_token),
        json=payload,
    )

    assert first_response.status_code == 200
    assert second_response.status_code == 200
    with SessionLocal() as db:
        user = get_user_by_email(db, email)
        count = db.scalar(
            select(func.count()).select_from(LegalAcceptance).where(
                LegalAcceptance.user_id == user.id,
                LegalAcceptance.document_type == "privacy_policy",
                LegalAcceptance.document_version == "1.0",
            )
        )
    assert count == 1


def test_invalid_document_type_rejected() -> None:
    _, access_token = register_and_get_token()

    response = client.post(
        "/api/v1/legal/accept",
        headers=auth_headers(access_token),
        json={"document_type": "bad_document", "document_version": "1.0"},
    )

    assert response.status_code in (400, 422)
