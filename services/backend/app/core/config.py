from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    app_name: str = "Drone Strike API"
    app_env: str = "local"
    api_v1_prefix: str = "/api/v1"
    database_url: str = (
        "postgresql+psycopg://drone_user:drone_password@localhost:5432/drone_strike"
    )
    jwt_secret_key: str = "dev-secret-change-me-dev-only-please"
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = 30
    refresh_token_expire_days: int = 30
    legal_terms_version: str = "1.0"
    legal_personal_data_version: str = "1.0"

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    @property
    def is_production(self) -> bool:
        return self.app_env.lower() == "production"

    @property
    def docs_url(self) -> str | None:
        return None if self.is_production else "/docs"

    @property
    def redoc_url(self) -> str | None:
        return None if self.is_production else "/redoc"

    @property
    def openapi_url(self) -> str | None:
        return None if self.is_production else "/openapi.json"


@lru_cache
def get_settings() -> Settings:
    return Settings()


settings = get_settings()
