from datetime import UTC, datetime
from uuid import UUID

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models import AuthToken


def create_auth_token(
    db: Session,
    *,
    user_id: UUID | None,
    email: str,
    token_hash: str,
    purpose: str,
    expires_at: datetime,
) -> AuthToken:
    auth_token = AuthToken(
        user_id=user_id,
        email=email.lower(),
        token_hash=token_hash,
        purpose=purpose,
        expires_at=expires_at,
    )
    db.add(auth_token)
    db.flush()
    return auth_token


def get_auth_token_by_hash(db: Session, token_hash: str) -> AuthToken | None:
    return db.scalar(select(AuthToken).where(AuthToken.token_hash == token_hash))


def mark_auth_token_used(db: Session, auth_token: AuthToken) -> AuthToken:
    auth_token.used_at = datetime.now(UTC)
    db.add(auth_token)
    db.flush()
    return auth_token


def invalidate_active_tokens(
    db: Session,
    *,
    email: str,
    purpose: str,
) -> int:
    tokens = list(
        db.scalars(
            select(AuthToken).where(
                AuthToken.email == email.lower(),
                AuthToken.purpose == purpose,
                AuthToken.used_at.is_(None),
            )
        )
    )
    for token in tokens:
        token.used_at = datetime.now(UTC)
        db.add(token)
    db.flush()
    return len(tokens)


def delete_auth_tokens_by_user_id(db: Session, user_id: UUID) -> int:
    tokens = list(db.scalars(select(AuthToken).where(AuthToken.user_id == user_id)))
    for token in tokens:
        db.delete(token)
    db.flush()
    return len(tokens)
