from fastapi.testclient import TestClient

from app.core.config import Settings
from app.main import app


client = TestClient(app)


def test_health_returns_ok() -> None:
    response = client.get("/health")

    assert response.status_code == 200
    assert response.json()["status"] == "ok"


def test_api_v1_health_returns_ok() -> None:
    response = client.get("/api/v1/health")

    assert response.status_code == 200
    assert response.json()["status"] == "ok"


def test_dev_docs_are_available() -> None:
    response = client.get("/docs")

    assert response.status_code == 200


def test_docs_urls_are_disabled_in_production() -> None:
    settings = Settings(app_env="production")

    assert settings.docs_url is None
    assert settings.redoc_url is None
    assert settings.openapi_url is None


def test_docs_urls_are_enabled_outside_production() -> None:
    settings = Settings(app_env="local")

    assert settings.docs_url == "/docs"
    assert settings.redoc_url == "/redoc"
    assert settings.openapi_url == "/openapi.json"
