# Database Draft

## users

Stores account identity and auth state.

- `id` UUID primary key
- `email` string, unique, indexed, required
- `password_hash` string, required
- `email_verified` boolean, default false
- `created_at` timezone datetime, default now
- `updated_at` timezone datetime, default now
- `deleted_at` nullable timezone datetime

## player_profiles

Stores public player profile data.

- `id` UUID primary key
- `user_id` UUID foreign key to `users.id`, unique, indexed, required
- `display_name` string, unique, indexed, required
- `name_changed_once` boolean, default false
- `total_score` integer, default 0
- `player_level` integer, default 1
- `is_premium` boolean, default false
- `created_at` timezone datetime, default now
- `updated_at` timezone datetime, default now

## mission_progress

Stores best mission results.

- `id` UUID primary key
- `user_id` UUID foreign key to `users.id`, indexed, required
- `mission_number` integer, required
- `best_score` integer, default 0
- `best_flight_accuracy_bonus` integer, default 0
- `best_tank_hit_bonus` integer, default 0
- `completed_at` nullable timezone datetime
- `updated_at` timezone datetime, default now

Constraints:

- unique `user_id` + `mission_number`
- `mission_number >= 1`
- `best_score >= 0`

## legal_acceptances

Stores user acceptance of legal documents.

- `id` UUID primary key
- `user_id` UUID foreign key to `users.id`, indexed, required
- `document_type` string, required
- `document_version` string, required
- `accepted_at` timezone datetime, default now

This table stores accepted legal document versions. Registration creates required MVP acceptances for terms of use and personal data consent; privacy policy can be accepted separately through the legal API.

Constraints:

- unique `user_id` + `document_type` + `document_version`

## refresh_tokens

Stores refresh token sessions.

- `id` UUID primary key
- `user_id` UUID foreign key to `users.id`, indexed, required
- `token_hash` string, unique, indexed, required
- `expires_at` timezone datetime, required
- `revoked_at` nullable timezone datetime
- `created_at` timezone datetime, default now

## leaderboard_seed_players

Stores fake MVP leaderboard entries.

- `id` UUID primary key
- `display_name` string, unique, indexed, required
- `total_score` integer, default 0
- `player_level` integer, default 1
- `created_at` timezone datetime, default now
- `updated_at` timezone datetime, default now

This table is used only for MVP seed players. Seed entries are not real users and are not mixed into `users` or `player_profiles`.

## Account deletion

Hard account deletion removes user-related rows from `refresh_tokens`, `legal_acceptances`, `mission_progress`, `player_profiles`, and `users`. MVP leaderboard seed players are not affected.
