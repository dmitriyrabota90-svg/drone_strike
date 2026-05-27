from app.core.database import Base
from app.models import (
    AuthToken,
    LeaderboardSeedPlayer,
    LegalAcceptance,
    MissionProgress,
    PlayerProfile,
    RefreshToken,
    User,
)


def test_metadata_contains_initial_tables() -> None:
    expected_tables = {
        "users",
        "player_profiles",
        "mission_progress",
        "legal_acceptances",
        "refresh_tokens",
        "auth_tokens",
        "leaderboard_seed_players",
    }

    assert expected_tables.issubset(Base.metadata.tables.keys())


def test_model_classes_are_registered_with_expected_tables() -> None:
    assert User.__tablename__ == "users"
    assert PlayerProfile.__tablename__ == "player_profiles"
    assert MissionProgress.__tablename__ == "mission_progress"
    assert LegalAcceptance.__tablename__ == "legal_acceptances"
    assert RefreshToken.__tablename__ == "refresh_tokens"
    assert AuthToken.__tablename__ == "auth_tokens"
    assert LeaderboardSeedPlayer.__tablename__ == "leaderboard_seed_players"


def test_mission_progress_constraints() -> None:
    table = Base.metadata.tables["mission_progress"]
    constraint_names = {constraint.name for constraint in table.constraints}

    assert "uq_mission_progress_user_mission" in constraint_names
    assert "ck_mission_progress_mission_number_min" in constraint_names
    assert "ck_mission_progress_best_score_min" in constraint_names


def test_unique_indexes() -> None:
    expected_unique_indexes = {
        "users": {"ix_users_email"},
        "player_profiles": {
            "ix_player_profiles_user_id",
            "ix_player_profiles_display_name",
        },
        "refresh_tokens": {"ix_refresh_tokens_token_hash"},
        "auth_tokens": {"ix_auth_tokens_token_hash"},
        "leaderboard_seed_players": {"ix_leaderboard_seed_players_display_name"},
    }

    for table_name, index_names in expected_unique_indexes.items():
        table = Base.metadata.tables[table_name]
        unique_indexes = {index.name for index in table.indexes if index.unique}

        assert index_names.issubset(unique_indexes)
