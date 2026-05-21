# Drone Strike Mobile API Contract

## 1. Base URLs

Local backend on Windows:

```text
http://localhost:8000
```

Android emulator:

```text
http://10.0.2.2:8000
```

Future real server:

```text
TODO
```

## 2. Authentication Model

The mobile client sends the access token in every protected request:

```http
Authorization: Bearer <token>
```

The access token is short-lived. The refresh token is longer-lived and should be stored in secure storage on the mobile client. When the API returns `401`, the client should try to refresh the access token with `POST /api/v1/auth/refresh`. If refresh fails, the client should clear local auth state and return the player to login.

Logout revokes the submitted refresh token. Delete account removes the user row and related server-side data, so old access tokens become useless because the user no longer exists.

## 3. Error Format

Most application errors use the standard FastAPI shape:

```json
{
  "detail": "Error message"
}
```

Validation errors return FastAPI/Pydantic `422` responses with a `detail` array describing invalid fields, locations, and validation messages.

## 4. Auth Endpoints

### POST /api/v1/auth/register

Auth required: no.

Request:

```json
{
  "email": "player@example.com",
  "password": "password123",
  "accepted_terms": true,
  "accepted_personal_data": true,
  "is_at_least_13": true
}
```

Response:

```json
{
  "access_token": "...",
  "refresh_token": "...",
  "token_type": "bearer"
}
```

Status codes:

- `201` success
- `409` duplicate email
- `422` validation error

### POST /api/v1/auth/login

Auth required: no.

Request:

```json
{
  "email": "player@example.com",
  "password": "password123"
}
```

Response:

```json
{
  "access_token": "...",
  "refresh_token": "...",
  "token_type": "bearer"
}
```

Status codes:

- `200` success
- `401` invalid credentials
- `422` validation error

### POST /api/v1/auth/refresh

Auth required: no.

Request:

```json
{
  "refresh_token": "..."
}
```

Response:

```json
{
  "access_token": "...",
  "refresh_token": "...",
  "token_type": "bearer"
}
```

Status codes:

- `200` success
- `401` invalid, expired, or revoked refresh token
- `422` validation error

### POST /api/v1/auth/logout

Auth required: no. The refresh token identifies the session to revoke.

Request:

```json
{
  "refresh_token": "..."
}
```

Response:

```json
{
  "status": "ok"
}
```

Status codes:

- `200` success
- `422` validation error

### POST /api/v1/auth/delete-account

Auth required: yes.

Request:

```json
{
  "password": "password123"
}
```

Response:

```json
{
  "status": "deleted"
}
```

Status codes:

- `200` success
- `401` missing token, invalid token, or wrong password
- `422` validation error

The endpoint permanently deletes the user's server-side rows: refresh tokens, legal acceptances, mission progress, profile, and user.

## 5. Profile Endpoints

### GET /api/v1/me

Auth required: yes.

Response:

```json
{
  "id": "00000000-0000-0000-0000-000000000000",
  "email": "player@example.com",
  "email_verified": false,
  "display_name": "Drone1234",
  "name_changed_once": false,
  "total_score": 0,
  "player_level": 1,
  "is_premium": false
}
```

### PATCH /api/v1/me/display-name

Auth required: yes.

Request:

```json
{
  "display_name": "DronePilot"
}
```

Response is the same shape as `GET /api/v1/me`.

Rules:

- `display_name` must be 3..20 characters.
- Only Latin letters, digits, and underscore are allowed.
- The name must be unique.
- Each player gets one free display name change.
- A second change returns `400`.
- A duplicate name returns `409`.

## 6. Progress Endpoints

### GET /api/v1/progress

Auth required: yes.

Response:

```json
{
  "total_score": 0,
  "player_level": 1,
  "completed_missions_count": 0,
  "unlocked_mission": 1,
  "missions": []
}
```

### POST /api/v1/progress/mission-complete

Auth required: yes.

Request:

```json
{
  "mission_number": 1,
  "flight_accuracy_bonus": 20,
  "tank_hit_bonus": 30
}
```

Response:

```json
{
  "mission_number": 1,
  "submitted_score": 150,
  "previous_best_score": 0,
  "saved_best_score": 150,
  "score_improved": true,
  "total_score": 150,
  "player_level": 1,
  "unlocked_mission": 2
}
```

Score formula:

```text
score = 100 + flight_accuracy_bonus + tank_hit_bonus
```

Rules:

- `mission_number`: 1..10
- `flight_accuracy_bonus`: 0..50
- `tank_hit_bonus`: 0..50
- The server saves only the best score for each mission.
- `totalScore` is the sum of best mission scores.
- `playerLevel` is recalculated by the server.
- Mission order is enforced by the server.

## 7. Leaderboard Endpoints

### GET /api/v1/leaderboard?limit=50

Auth required: yes.

Response:

```json
{
  "entries": [
    {
      "rank": 1,
      "display_name": "SkyHunter",
      "total_score": 1850,
      "player_level": 5,
      "is_current_user": false
    }
  ],
  "me": {
    "rank": 12,
    "display_name": "Drone1234",
    "total_score": 150,
    "player_level": 1
  },
  "total_count": 16
}
```

Rules:

- `limit` must be 1..100.
- The leaderboard does not return email.
- Seed players are allowed in the MVP.
- The current player is also returned in the separate `me` block, even when not visible in the top list.

### GET /api/v1/leaderboard/me

Auth required: yes.

Response:

```json
{
  "rank": 12,
  "display_name": "Drone1234",
  "total_score": 150,
  "player_level": 1,
  "total_count": 16
}
```

## 8. Legal Endpoints

### GET /api/v1/legal/documents

Auth required: no.

Response:

```json
{
  "documents": [
    {
      "type": "terms_of_use",
      "version": "1.0",
      "title": "Пользовательское соглашение",
      "content": "Temporary placeholder...",
      "operator_name": "Анпилов Дмитрий Сергеевич",
      "operator_email": "anpilovdmitriy@yandex.ru"
    }
  ]
}
```

Legal documents are MVP placeholders. Full legal texts are planned later.

Operator name:

```text
Анпилов Дмитрий Сергеевич
```

Operator email:

```text
anpilovdmitriy@yandex.ru
```

### POST /api/v1/legal/accept

Auth required: yes.

Request:

```json
{
  "document_type": "privacy_policy",
  "document_version": "1.0"
}
```

Response:

```json
{
  "status": "accepted",
  "document_type": "privacy_policy",
  "document_version": "1.0"
}
```

Allowed document types:

- `terms_of_use`
- `personal_data_consent`
- `privacy_policy`

The endpoint is idempotent for the same user, document type, and version.

## 9. Mobile Storage Expectations

The mobile client should keep:

- access token in memory or secure storage;
- refresh token in secure storage;
- display name cache;
- progress cache;
- sound settings;
- language settings;
- pending sync queue later.

## 10. Offline Behavior

If the backend is unavailable, a registered player can keep playing already unlocked levels locally. New results should be stored in a pending sync queue later. The full `POST /api/v1/progress/sync` endpoint is still planned.

For the MVP, the mobile client can send `POST /api/v1/progress/mission-complete` when the network is available.

## 11. Guest Mode

- Missions 1-2 are available without registration.
- Missions 3+ require registration.
- Profile requires auth.
- Leaderboard requires auth.

## 12. Flutter Integration Notes

Android emulator API base URL:

```text
http://10.0.2.2:8000
```

Future Flutter run command:

```powershell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

The Flutter app should use a dedicated `ApiClient`. On `401`, it should try the refresh-token flow once. If refresh fails, the client should clear local auth state and return to login or guest mode.
