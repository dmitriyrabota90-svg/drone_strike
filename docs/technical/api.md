# API Draft

Local backend target for future development: `localhost:8000`.

Android emulator target for future development: `http://10.0.2.2:8000`.

## Health

- `GET /health` - service health check.

## Auth

- `POST /auth/register` - create account with email, password, required legal confirmations, and age confirmation.
- `POST /auth/login` - issue access and refresh tokens.
- `POST /auth/refresh` - rotate refresh token and issue a new access token.
- `POST /auth/logout` - revoke current refresh token.
- `POST /auth/delete-account` - delete account after password confirmation.

## Profile

- `GET /me` - return current user and player profile.
- `PATCH /me/display-name` - change display name, with one free change in MVP rules.

## Progress

- `GET /progress` - return mission progress and best scores.
- `POST /progress/mission-complete` - submit completed mission result and update best score.
- `POST /progress/sync` - sync local progress snapshot with server state.

## Leaderboard

- `GET /leaderboard` - return global leaderboard by `totalScore`.
- `GET /leaderboard/me` - return current player rank and nearby players.

## Legal

- `GET /legal/documents` - return active legal document versions.
- `POST /legal/accept` - save legal acceptance for terms, personal data consent, and age confirmation.
