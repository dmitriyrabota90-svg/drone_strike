import sys
from pathlib import Path

BACKEND_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(BACKEND_ROOT))

from app.core.database import SessionLocal
from app.seed.leaderboard_seed import seed_leaderboard_players


def main() -> None:
    with SessionLocal() as db:
        changed_count = seed_leaderboard_players(db)
    print(f"Seeded leaderboard players: {changed_count}")


if __name__ == "__main__":
    main()
