# Drone Strike Backend

Minimal FastAPI backend skeleton for Drone Strike.

## Create Virtual Environment

```powershell
cd /d "C:\Mobile Game Drone Strike\services\backend"
python -m venv .venv
.venv\Scripts\activate
```

## Install Dependencies

```powershell
python -m pip install --upgrade pip
pip install -r requirements.txt
```

## Start PostgreSQL

```powershell
docker compose -f docker-compose.db.yml up -d
```

## Run Backend

```powershell
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

## Run Tests

```powershell
pytest
```

## Leaderboard Seed

```powershell
docker compose -f docker-compose.db.yml up -d
alembic upgrade head
python scripts/seed_leaderboard.py
```

Seed players are only for the MVP leaderboard. Re-running the seed command is safe and will not create duplicate seed players. Real players are read from `player_profiles`.

## Android Emulator

Future Android emulator API URL:

```text
http://10.0.2.2:8000
```
