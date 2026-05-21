# Drone Strike

Drone Strike is a 2D horizontal side-scrolling mobile arcade game where the player controls an FPV drone through paired forest obstacles and finishes each mission by striking a tank in the final zone.

## Stack

- Mobile: Flutter + Flame + Riverpod
- Backend: FastAPI + PostgreSQL
- Localization: Russian + English
- Audio: music + SFX

## MVP Scope

- 10 missions
- First 2 missions playable without registration
- Email/password registration
- Player profile
- Leaderboard
- Local saves + future synchronization
- Shop stub
- Achievements stub

## Backend Status

Backend implemented:

- Health endpoints
- Auth
- Profile
- Progress
- Leaderboard
- Account deletion
- Legal stubs

## Mobile Status

Mobile scaffold created:

- Flutter app scaffold
- Russian and English localization
- `go_router` navigation
- Riverpod root
- `API_BASE_URL` support
- Auth/profile/legal/account API integration
- Progress API integration
- Leaderboard API integration
- Flame game core scaffold
- Drone gravity, tap impulse, and deadly top/bottom boundaries
- Obstacle pairs with ceiling nets and bottom trees
- Final tank target and mission complete overlay
- Local lives system
- Mission result scoring
- Guest progress for missions 1-2
- Tank hit mission result sync for authenticated users
- Server-side lives recovery planned later
- Full offline sync queue planned later

## Documentation

- [Mobile API Contract](docs/technical/mobile_api_contract.md)
- [Mobile Local Setup](docs/technical/mobile_local_setup.md)
- [Backend Local QA](docs/technical/backend_local_qa.md)
- [API Draft](docs/technical/api.md)
- [Database Draft](docs/technical/database.md)

## Commands

- mobile setup:

```powershell
cd /d "C:\Mobile Game Drone Strike\apps\mobile"
flutter pub get
flutter analyze
flutter test
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

- backend setup: see [services/backend/README.md](services/backend/README.md)
- local run: TODO
