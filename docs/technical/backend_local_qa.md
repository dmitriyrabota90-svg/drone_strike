# Backend Local QA

## 1. Start PostgreSQL

```powershell
cd /d "C:\Mobile Game Drone Strike\services\backend"
docker compose -f docker-compose.db.yml up -d
```

## 2. Apply Migrations

```powershell
alembic upgrade head
```

## 3. Seed Leaderboard

```powershell
python scripts/seed_leaderboard.py
```

## 4. Run Tests

```powershell
pytest
```

## 5. Start API

```powershell
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

## 6. URLs

Swagger:

```text
http://localhost:8000/docs
```

OpenAPI JSON:

```text
http://localhost:8000/openapi.json
```

Health:

```text
http://localhost:8000/health
http://localhost:8000/api/v1/health
```

Android emulator base URL:

```text
http://10.0.2.2:8000
```

## 7. Manual Check Sequence

1. Open `/docs`.
2. Run `GET /api/v1/health`.
3. Run `POST /api/v1/auth/register`.
4. Copy the returned access token.
5. Authorize in Swagger with `Bearer <access_token>`.
6. Run `GET /api/v1/me`.
7. Run `POST /api/v1/progress/mission-complete`.
8. Run `GET /api/v1/leaderboard`.
9. Run `GET /api/v1/legal/documents`.
10. Run `POST /api/v1/auth/delete-account` with the account password.

## 8. Common Problems

- PostgreSQL port `5432` is already used by another local database.
- Docker Desktop is not running.
- The Python virtual environment is not activated.
- Android emulator should use `http://10.0.2.2:8000`, not `http://localhost:8000`.
- Stale Flutter lock files were previously seen on this machine, but they do not affect the backend.
