# API Draft

Local backend target for future development: `localhost:8000`.

Android emulator target for future development: `http://10.0.2.2:8000`.

## Health

- `GET /health` - service health check.

## Auth

- `POST /api/v1/auth/register` - implemented. Creates account with email, password, required legal confirmations, age 13+ confirmation, generated `DroneXXXX` display name, access token, and refresh token.
- `POST /api/v1/auth/login` - implemented. Issues access and refresh tokens.
- `POST /api/v1/auth/refresh` - implemented. Validates stored refresh token hash and issues a new access token.
- `POST /api/v1/auth/logout` - implemented. Revokes current refresh token.
- `POST /api/v1/auth/delete-account` - implemented. Deletes server-side user data after password confirmation.

## Profile

- `GET /api/v1/me` - implemented. Returns current user and player profile from Bearer access token.
- `PATCH /api/v1/me/display-name` - implemented. Change display name once for free.

## Progress

- `GET /api/v1/progress` - implemented. Return total score, player level, completed missions count, unlocked mission, and best mission scores.
- `POST /api/v1/progress/mission-complete` - implemented. Submit completed mission result, save only the best score per mission, recalculate total score and player level.
- `POST /api/v1/progress/sync` - planned. Sync local progress snapshot with server state.

## Leaderboard

- `GET /api/v1/leaderboard` - implemented. Returns global leaderboard entries sorted by `player_profiles.total_score`, with MVP seed players included when present.
- `GET /api/v1/leaderboard/me` - implemented. Returns the current player's rank even if the player is outside the top leaderboard limit.

Leaderboard notes:

- Real players are sourced from `player_profiles` and exclude deleted users.
- MVP seed players are sourced from `leaderboard_seed_players`.
- Leaderboard responses do not expose email or internal user IDs.
- Shop is planned.
- Achievements are planned.

## Legal

- `GET /api/v1/legal/documents` - implemented. Returns MVP placeholder legal documents.
- `POST /api/v1/legal/accept` - implemented. Saves legal document acceptance idempotently.

Legal notes:

- Legal documents are placeholders in MVP.
- Full legal texts are planned later.
- Account deletion requires password confirmation and hard-deletes server-side user data.
