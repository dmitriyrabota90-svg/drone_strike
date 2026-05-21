from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models import LeaderboardSeedPlayer


LEADERBOARD_SEED_PLAYERS = [
    ("SkyHunter", 1850, 5),
    ("DroneWolf", 1710, 4),
    ("PixelPilot", 1600, 4),
    ("NetBreaker", 1450, 4),
    ("TankRunner", 1320, 4),
    ("CloudRider", 1180, 3),
    ("RotorFox", 990, 3),
    ("NightDrone", 850, 3),
    ("FPVShadow", 720, 3),
    ("StrikeBee", 610, 2),
    ("BlueRotor", 480, 2),
    ("SilentWing", 360, 2),
    ("DroneCadet", 240, 1),
    ("ForestPilot", 170, 1),
    ("FirstFlight", 100, 1),
]


def seed_leaderboard_players(db: Session) -> int:
    changed_count = 0

    for display_name, total_score, player_level in LEADERBOARD_SEED_PLAYERS:
        seed_player = db.scalar(
            select(LeaderboardSeedPlayer).where(
                LeaderboardSeedPlayer.display_name == display_name,
            )
        )
        if seed_player is None:
            db.add(
                LeaderboardSeedPlayer(
                    display_name=display_name,
                    total_score=total_score,
                    player_level=player_level,
                )
            )
            changed_count += 1
            continue

        if (
            seed_player.total_score != total_score
            or seed_player.player_level != player_level
        ):
            seed_player.total_score = total_score
            seed_player.player_level = player_level
            db.add(seed_player)
            changed_count += 1

    db.commit()
    return changed_count
