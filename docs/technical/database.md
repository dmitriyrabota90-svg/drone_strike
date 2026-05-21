# Database Draft

## users

Stores account identity and auth state.

- `id`
- `email`
- `password_hash`
- `email_verified`
- `created_at`
- `updated_at`
- `deleted_at`

## player_profiles

Stores public player profile data.

- `id`
- `user_id`
- `display_name`
- `display_name_changes_used`
- `player_level`
- `total_score`
- `completed_missions_count`
- `created_at`
- `updated_at`

## mission_progress

Stores best mission results.

- `id`
- `user_id`
- `mission_number`
- `best_score`
- `best_flight_accuracy_bonus`
- `best_tank_hit_bonus`
- `completed_at`
- `updated_at`

## legal_acceptances

Stores user acceptance of legal documents and age confirmation.

- `id`
- `user_id`
- `document_type`
- `document_version`
- `accepted`
- `accepted_at`
- `ip_address`
- `user_agent`

## refresh_tokens

Stores refresh token sessions.

- `id`
- `user_id`
- `token_hash`
- `expires_at`
- `revoked_at`
- `created_at`

## leaderboard_seed_players

Stores fake MVP leaderboard entries.

- `id`
- `display_name`
- `total_score`
- `player_level`
- `enabled`
- `created_at`
