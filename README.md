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

## Documentation

- [Mobile API Contract](docs/technical/mobile_api_contract.md)
- [Backend Local QA](docs/technical/backend_local_qa.md)
- [API Draft](docs/technical/api.md)
- [Database Draft](docs/technical/database.md)

## Commands

- mobile setup: TODO
- backend setup: see [services/backend/README.md](services/backend/README.md)
- local run: TODO
