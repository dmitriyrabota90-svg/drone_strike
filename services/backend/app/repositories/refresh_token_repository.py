from datetime import UTC, datetime
from uuid import UUID

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models import RefreshToken


def create_refresh_token(
    db: Session,
    user_id: UUID,
    token_hash: str,
    expires_at: datetime,
) -> RefreshToken:
    refresh_token = RefreshToken(
        user_id=user_id,
        token_hash=token_hash,
        expires_at=expires_at,
    )
    db.add(refresh_token)
    db.flush()
    return refresh_token


def get_refresh_token_by_hash(db: Session, token_hash: str) -> RefreshToken | None:
    return db.scalar(select(RefreshToken).where(RefreshToken.token_hash == token_hash))


def revoke_refresh_token(db: Session, refresh_token_model: RefreshToken) -> RefreshToken:
    refresh_token_model.revoked_at = datetime.now(UTC)
    db.add(refresh_token_model)
    db.flush()
    return refresh_token_model


def delete_refresh_tokens_by_user_id(db: Session, user_id: UUID) -> int:
    refresh_tokens = list(
        db.scalars(select(RefreshToken).where(RefreshToken.user_id == user_id))
    )
    for refresh_token in refresh_tokens:
        db.delete(refresh_token)
    db.flush()
    return len(refresh_tokens)
