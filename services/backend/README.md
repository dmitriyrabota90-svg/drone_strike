# Drone Strike Backend

FastAPI backend for Drone Strike with PostgreSQL, auth, profile, progress, leaderboard, account deletion, and legal placeholder endpoints.

## Local Development

### 1. Create Virtual Environment

```powershell
cd /d "C:\Mobile Game Drone Strike\services\backend"
python -m venv .venv
.venv\Scripts\activate
```

### 2. Install Requirements

```powershell
python -m pip install --upgrade pip
pip install -r requirements.txt
```

### 3. Start PostgreSQL

```powershell
docker compose -f docker-compose.db.yml up -d
```

### 4. Apply Migrations

```powershell
alembic upgrade head
```

### 5. Seed Leaderboard

```powershell
python scripts/seed_leaderboard.py
```

Seed players are only for the MVP leaderboard. Re-running the seed command is safe and will not create duplicate seed players. Real players are read from `player_profiles`.

### 6. Run Tests

```powershell
pytest
```

### 7. Start API

```powershell
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### 8. Run Smoke Script

Run this in another terminal while the API is running:

```powershell
cd /d "C:\Mobile Game Drone Strike\services\backend"
.venv\Scripts\activate
python scripts/smoke_api.py --base-url http://localhost:8000
```

The smoke script creates a temporary test account, checks the main API flow over HTTP, and deletes the test account at the end.

## Android Emulator

The future mobile app should use:

```text
http://10.0.2.2:8000
```

## Useful URLs

- Swagger: `http://localhost:8000/docs`
- OpenAPI JSON: `http://localhost:8000/openapi.json`
- Health: `http://localhost:8000/health`
- API health: `http://localhost:8000/api/v1/health`
