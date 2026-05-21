# Drone Strike Technical Game Design v1

## 1. Project Summary

Drone Strike is a 2D horizontal side-scrolling mobile arcade game. The player controls an FPV drone in landscape orientation and completes missions by navigating paired obstacles before descending into a tank in the final strike zone.

## 2. Core Gameplay

The drone moves forward automatically. One tap gives a short, sharp upward boost; no tap means the drone descends. The core skill is timing boosts to pass through gaps and then stop tapping at the right moment for the final strike.

## 3. Visual Style

The visual style is modern pixel art with a dark blue night sky, clouds, forest silhouettes, an FPV drone, anti-drone nets, and a tank. Readability on mobile screens is more important than dense decoration.

## 4. Controls

Controls are one-tap. Tap to boost upward; release or stop tapping to descend. Top and bottom screen boundaries are deadly.

## 5. Missions

The MVP contains 10 missions. Missions 1-2 are tutorial missions with easier timing. A normal mission lasts about 60 seconds before the final zone begins.

## 6. Obstacles

Obstacles are always paired: a bottom tree and a top anti-drone net. A tree without a net is not allowed, and a net without a tree is not allowed. Nets attach directly to the ceiling and hang down, not from chains.

Gap sizing is based on drone height:

- Mission 1: drone height x 1.8
- Mission 2: drone height x 1.6
- Mission 3+: drone height x 1.4

## 7. Final Strike Zone

The final zone lasts about 8 seconds. There are no nets above the tank. The player must stop tapping at the correct moment so the drone descends into the tank. Hitting the tank means victory.

Missing the tank is not an instant defeat. Defeat happens after hitting the top or bottom boundary, with a fail-safe distance limit to prevent endless flight after a missed strike.

## 8. Lives

Normal max lives: 3. One life recovers every 5 minutes. Future premium tuning may allow max 5 lives and one recovered life every 4 minutes.

## 9. Scoring

Score is awarded only after mission completion. A normal mission has a base score of 100, a flight accuracy bonus from 0 to 50, and a tank hit bonus from 0 to 50. The max score per normal mission is 200.

Only the best score per mission is saved. `totalScore` is the sum of best mission scores.

## 10. Player Level

Player level grows from `totalScore`. Level thresholds should be deterministic and stored in the mobile app, with backend validation added when online sync is implemented.

## 11. Profile

Profile MVP fields include display name, email, email status, player level, total score, completed missions, and leaderboard place.

## 12. Achievements

The achievements screen is a stub in MVP. It should reserve space for future unlock conditions, progress counters, and reward presentation.

## 13. Leaderboard

Leaderboard uses a real backend endpoint and ranks players globally by `totalScore`. Fake seed players are allowed for MVP to make the leaderboard feel populated before real users arrive.

## 14. Registration

The first 2 missions can be played without registration. Missions 3+ require registration with email and password.

On registration, the backend generates a display name in the format `DroneXXXX`. The player can change the name once for free. Email verification is planned later; MVP shows a warning only.

Registration requires two legal checkboxes for terms of use and personal data consent, plus a checkbox confirming: I am at least 13 years old.

## 15. Account Deletion

Account deletion is available through settings -> account -> delete account. The flow requires password confirmation and deletes both server data and local data.

## 16. Screens

Main menu items:

- Continue, visible only if at least one mission is completed
- Level Select
- Profile
- Achievements
- Leaderboard
- Shop
- Settings
- Exit

Shop is a stub in MVP. Settings include master sound, music, SFX, and language selection for Russian and English.

## 17. Audio

Audio MVP includes menu music loop, mission music loop, victory jingle, defeat jingle, drone hum loop, tap boost, collision, explosion, tank hit, and UI click.

## 18. Localization

Localization supports Russian and English. The mobile app should use Flutter l10n so UI strings are kept out of gameplay code.

## 19. Mobile Architecture

Mobile stack:

- Flutter
- Flame
- Riverpod
- l10n
- shared_preferences
- flutter_secure_storage

Local progress should work offline first. Auth tokens and sensitive data should use secure storage. Non-sensitive settings and local progress snapshots can use shared preferences until a stronger local store is needed.

## 20. Backend Architecture

Backend stack:

- FastAPI
- PostgreSQL
- SQLAlchemy
- Alembic
- JWT access/refresh

Local backend will later run on `localhost:8000`. Android emulator builds should call it through `http://10.0.2.2:8000`.

## 21. Database Draft

Initial tables: `users`, `player_profiles`, `mission_progress`, `legal_acceptances`, `refresh_tokens`, and `leaderboard_seed_players`.

## 22. API Draft

Initial API groups cover health checks, auth, profile, progress, leaderboard, and legal document acceptance. Mission completion should submit enough data for scoring validation and local sync reconciliation.

## 23. MVP Scope

MVP includes 10 missions, local saves, first 2 missions without registration, registration for missions 3+, profile, leaderboard, shop stub, achievements stub, settings, audio, and ru/en localization.

## 24. Post-MVP Ideas

Post-MVP ideas include premium lives, verified email flow, richer achievements, real shop items, cloud save conflict resolution, more mission biomes, drone skins, and seasonal leaderboards.

## 25. Development Plan

1. Create monorepo structure and documentation.
2. Scaffold Flutter mobile app.
3. Implement core Flame prototype with drone physics and paired obstacles.
4. Add mission flow, scoring, local saves, and menus.
5. Scaffold FastAPI backend with PostgreSQL and Alembic.
6. Add auth, profile, progress, leaderboard, and legal endpoints.
7. Integrate mobile app with backend.
8. Add audio, localization, polish, and MVP QA.
