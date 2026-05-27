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
    smtp_host: str | None = None
    smtp_port: int = 587
    smtp_username: str | None = None
    smtp_password: str | None = None
    smtp_from_email: str | None = None
    smtp_from_name: str = "FPV Last Run"
    smtp_use_tls: bool = True
    public_site_url: str = "http://localhost:3000"
    public_api_url: str = "http://localhost:8000"

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

    @property
    def smtp_configured(self) -> bool:
        return bool(
            self.smtp_host
            and self.smtp_port
            and self.smtp_username
            and self.smtp_password
            and self.smtp_from_email
        )


@lru_cache
def get_settings() -> Settings:
    return Settings()


settings = get_settings()
