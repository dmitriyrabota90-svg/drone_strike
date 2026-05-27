"""create auth tokens

Revision ID: 7b31cbba6a4b
Revises: 0a9ff20b0518
Create Date: 2026-05-27 09:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = "7b31cbba6a4b"
down_revision: Union[str, Sequence[str], None] = "0a9ff20b0518"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    op.create_table(
        "auth_tokens",
        sa.Column("id", sa.UUID(), nullable=False),
        sa.Column("user_id", sa.UUID(), nullable=True),
        sa.Column("email", sa.String(length=255), nullable=False),
        sa.Column("token_hash", sa.String(length=255), nullable=False),
        sa.Column("purpose", sa.String(length=64), nullable=False),
        sa.Column("expires_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("used_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.CheckConstraint(
            "purpose IN ('email_verification', 'password_reset')",
            name="ck_auth_tokens_purpose",
        ),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"]),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(op.f("ix_auth_tokens_email"), "auth_tokens", ["email"], unique=False)
    op.create_index(
        op.f("ix_auth_tokens_purpose"),
        "auth_tokens",
        ["purpose"],
        unique=False,
    )
    op.create_index(
        op.f("ix_auth_tokens_token_hash"),
        "auth_tokens",
        ["token_hash"],
        unique=True,
    )
    op.create_index(
        op.f("ix_auth_tokens_user_id"),
        "auth_tokens",
        ["user_id"],
        unique=False,
    )


def downgrade() -> None:
    """Downgrade schema."""
    op.drop_index(op.f("ix_auth_tokens_user_id"), table_name="auth_tokens")
    op.drop_index(op.f("ix_auth_tokens_token_hash"), table_name="auth_tokens")
    op.drop_index(op.f("ix_auth_tokens_purpose"), table_name="auth_tokens")
    op.drop_index(op.f("ix_auth_tokens_email"), table_name="auth_tokens")
    op.drop_table("auth_tokens")
