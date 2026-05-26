# FPV Last Run

FPV Last Run is a 2D horizontal side-scrolling mobile arcade game where the player controls an FPV drone. The player flies through trees and nets, collects batteries, and hits a tank at the end of the mission.

The old technical name may still appear in package names, database names, Docker resources, and paths such as `Drone Strike` or `Mobile Game Drone Strike`. The current game name for product and documentation work is `FPV Last Run`.

## Stack

- Mobile: Flutter + Flame + Riverpod
- Backend: FastAPI + PostgreSQL
- Database: PostgreSQL via Docker Compose
- Localization: Russian and English
- Target platform: Android first

## Repository Structure

- `apps/mobile` - Flutter mobile app.
- `apps/mobile/lib/game` - Flame gameplay, mission systems, components, scoring, and level generation.
- `apps/mobile/lib/features` - App features such as auth, profile, settings, leaderboard, achievements, and menus.
- `services/backend` - FastAPI backend, Alembic migrations, tests, and local database compose file.
- `docs/legal` - Legal documents and policy drafts.
- `docs/qa` - QA checklists and release testing notes.
- `tools/dev` - Development helper tools.

## Current MVP Features

- Mission-based FPV drone gameplay.
- Guest mode with early mission access.
- Registration, login, and profile screens.
- Backend-backed leaderboard.
- Local lives system: 5 lives with 90 second recovery.
- MVP achievements.
- Battery collectible mechanic.
- Tank finale at the end of missions.
- Explosion and fire effects.
- Russian and English localization.
- Legal documents flow.
- Backend account deletion endpoint.
- QA checklist for alpha testing.

## Local Development Environment - Ubuntu 26

Current local development machine:

```text
OS: Ubuntu 26
Project path: /home/dmitriy/Projects/Mobile Game Drone Strike
Flutter SDK path: /home/dmitriy/development/flutter
Android AVD: FPV_Test_Device
```

Local status notes:

- Docker works locally.
- KVM works locally.
- Android Studio is installed mainly for Android SDK, emulator, and Device Manager.
- Flutter and Android builds should use OpenJDK 17.
- Flutter/Android development can be run from the terminal.
- The local backend health endpoint works at `http://localhost:8000/health`.
- The Android emulator reaches the host backend through `http://10.0.2.2:8000`.

## Local Backend Setup

Start PostgreSQL, run migrations, seed the leaderboard, and run the API:

```bash
cd "/home/dmitriy/Projects/Mobile Game Drone Strike/services/backend"
source .venv/bin/activate
docker compose -f docker-compose.db.yml up -d
alembic upgrade head
python scripts/seed_leaderboard.py
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Health check:

```bash
curl http://localhost:8000/health
```

Useful local URLs:

- Swagger: `http://localhost:8000/docs`
- OpenAPI JSON: `http://localhost:8000/openapi.json`
- Health: `http://localhost:8000/health`
- API health: `http://localhost:8000/api/v1/health`

## Local Backend Tests

```bash
cd "/home/dmitriy/Projects/Mobile Game Drone Strike/services/backend"
source .venv/bin/activate
python -m pytest
```

## Local Mobile Checks

```bash
cd "/home/dmitriy/Projects/Mobile Game Drone Strike/apps/mobile"
flutter clean
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
```

`flutter gen-l10n` may report the existing `synthetic-package` deprecation warning from `l10n.yaml`.

## Debug APK Build

Build a debug APK for the Android emulator/backend bridge:

```bash
cd "/home/dmitriy/Projects/Mobile Game Drone Strike/apps/mobile"
flutter build apk --debug --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

Expected output path:

```text
apps/mobile/build/app/outputs/flutter-apk/app-debug.apk
```

## Emulator Run

Start the AVD:

```bash
emulator -avd FPV_Test_Device
```

In another terminal, verify that ADB sees the device:

```bash
adb devices
```

Run the app against the local backend:

```bash
cd "/home/dmitriy/Projects/Mobile Game Drone Strike/apps/mobile"
flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

If the emulator has a different device id, use the id shown by `flutter devices`.

## Android Studio Note

Android Studio is mainly used for Android SDK management, emulator images, and Device Manager. Normal code changes are usually done through VS Code, Cursor, Codex, or another editor.

Do not accept Gradle or plugin migrations automatically unless the migration is intentionally planned and reviewed. Flutter may print migration warnings or add tool-generated changes during builds; inspect `git diff` before committing any Android project updates.

## Backend Server Deployment Notes

Server SSH:

```bash
ssh dmitriy@192.168.1.67
```

The backend server setup is in progress. The backend is intended to run in an isolated environment so other projects on the server are not broken.

Careful server rules:

- Do not run destructive server commands.
- Do not overwrite server files.
- Do not install Python dependencies globally.
- Use a project-specific virtual environment or Docker.
- Keep PostgreSQL private; do not expose PostgreSQL publicly.
- Only expose HTTP/HTTPS through a reverse proxy later.
- Use environment variables for secrets.
- Do not commit `.env`.
- Do not put passwords, tokens, private keys, SMTP credentials, database passwords, or other secrets into documentation or git.
- Exact production server path and domain/API URL are still to be confirmed.

Current placeholders:

```text
SERVER_BACKEND_PATH=<to be confirmed>
PRODUCTION_API_URL=<to be confirmed, likely https://api.fpv-last-run.ru>
```

## Domain And Future Production Notes

Domain:

```text
fpv-last-run.ru
```

Future desired endpoints:

- `https://fpv-last-run.ru`
- `https://api.fpv-last-run.ru`
- `https://fpv-last-run.ru/privacy`
- `https://fpv-last-run.ru/account-deletion`

DNS, SSL, reverse proxy, and backend deployment are ongoing tasks.

## QA Notes

QA checklist:

```text
docs/qa/rustore_alpha_test_checklist_ru.md
```

Before alpha APK distribution, run:

```bash
cd "/home/dmitriy/Projects/Mobile Game Drone Strike/services/backend"
source .venv/bin/activate
python -m pytest

cd "/home/dmitriy/Projects/Mobile Game Drone Strike/apps/mobile"
flutter clean
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
flutter build apk --debug --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

Also run a manual gameplay test on the Android emulator: start a mission, fly through obstacles, collect batteries, hit the final tank, check lives recovery behavior, and verify auth/profile/leaderboard flows against the local backend.

## Additional Documentation

- [Mobile API Contract](docs/technical/mobile_api_contract.md)
- [Mobile Local Setup](docs/technical/mobile_local_setup.md)
- [Backend Local QA](docs/technical/backend_local_qa.md)
- [Backend README](services/backend/README.md)
- [API Draft](docs/technical/api.md)
- [Database Draft](docs/technical/database.md)

## Important Agent Rules

- Do not commit or push unless explicitly asked.
- Do not reset, stash, clean, or revert user changes unless explicitly asked.
- Ask when data is missing or risky to infer.
- Do not invent secrets, server paths, production values, or environment variables.
- Keep backend server actions careful and isolated.
