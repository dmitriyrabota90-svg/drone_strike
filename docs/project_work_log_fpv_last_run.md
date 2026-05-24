# FPV Last Run Project Work Log

Date: 2026-05-24

This document summarizes the work completed on the FPV Last Run project so far.
It is a documentation-only log and does not describe a new feature request.

## Project Identity

- Original project name: Drone Strike.
- Current app name: FPV Last Run.
- Repository path: `C:\Mobile Game Drone Strike`.
- Mobile app path: `apps/mobile`.
- Backend path: `services/backend`.
- Main working branch: `main`.

## Major Mobile Systems Implemented

- Flutter mobile application structure.
- Flame-based side-scrolling drone game core.
- Game screen with mission loading.
- Tap-to-start mission flow.
- Pause, game over, mission complete, and no-lives overlays.
- HUD with mission, score/progress, lives, and pause action.
- Landscape gameplay orientation.
- Portrait menu and regular app screens.
- Menu music and mission music integration.
- Victory, defeat, and final tension audio integration.
- Obstacles, tank finale, scoring, lives, and progress sync flows.

## Orientation, Layout, Tap, And Audio Fixes

- Fixed mission entry orientation so the game screen switches to landscape.
- Fixed exit/dispose behavior so menus return to portrait.
- Guarded game layout startup to avoid creating the game with zero-size constraints.
- Preserved a 16:9 landscape game area.
- Fixed tap-to-start so the first tap starts gameplay reliably.
- Changed first tap behavior to be safer with a reduced start impulse and grace period.
- Fixed HUD and tap-to-start input blocking issues.
- Fixed audio asset paths so Flame audio uses paths relative to `assets/audio/`.
- Removed bad paths such as `assets/audio/audio/...`.
- Kept audio failures non-fatal with debug logging.

## Menu Visual Assets And UI Polish

- Connected FPV Last Run logo asset.
- Connected destroyed city menu background.
- Added shared asset constants.
- Added reusable menu background widget.
- Added neon-style menu buttons.
- Added glass-style UI panels.
- Updated splash, main menu, login, register, profile, leaderboard, shop, achievements, settings, legal documents, and level select visuals.
- Made menu buttons more centered, readable, and game-like.
- Added active exit flow with confirmation dialog.
- Used button reference only as visual guidance, not as image buttons.

## Branding And Native Android Polish

- Updated visible app branding to FPV Last Run.
- Updated Android app label.
- Integrated app icon branding.
- Restyled native Android splash to avoid the old blue Flutter splash look.
- Fixed Android resource linking issue caused by invalid splash style configuration.
- Removed or hid the centered native splash logo where possible.
- Kept launcher icon unchanged after final branding integration.

## Physics And Difficulty Tuning

- Smoothed drone physics for a less harsh FPV-glide feel.
- Added vertical velocity clamps.
- Tuned gravity, tap impulse, start tap impulse, max rise speed, and max fall speed.
- Increased early mission gaps to make the first missions playable.
- Kept minimum playable gap rules for MVP.
- Tuned obstacle spacing and mission density.
- Preserved core defeat/victory rules:
  - tree, net, and boundary collision fail the mission;
  - tank collision completes the mission;
  - missing the tank fails the mission.

## Game Image Asset Integration

- Registered game image asset folders in Flutter.
- Added AppAssets constants for game images.
- Added game image cache/preload helper.
- Integrated PNG drone sprite with aspect ratio preserved.
- Integrated segmented tree sprites.
- Integrated segmented net sprites.
- Integrated tank sprite.
- Integrated layered game background:
  - night sky;
  - cloud layers;
  - ruined city;
  - asphalt road/ground.
- Kept Canvas fallback rendering when images fail to load.
- Preserved hitboxes independently from sprite pixel sizes.

## Sprite Layout And Visual Fixes

- Fixed squashed drone rendering by preserving aspect ratio.
- Fixed squashed tank rendering by preserving aspect ratio.
- Reduced visible gaps between tree segments.
- Reduced visible gaps between net segments.
- Adjusted tree and net segment overlap.
- Moved road to the bottom of the game scene.
- Moved city lower and scaled it for better background composition.
- Removed visible tank target circle.
- Reduced invisible tank hit target size.
- Moved tank lower so it sits on the road/ground line.
- Kept missed-tank fail line behavior.

## Obstacle Generation Rewrite

- Reworked obstacle generation so obstacles are not evenly spaced.
- Added random per-obstacle X spacing.
- Added random playable gap height.
- Added random vertical gap position.
- Added explicit generated obstacle data:
  - x position;
  - spacing from previous obstacle;
  - gap top;
  - gap bottom;
  - gap height;
  - tree height;
  - net height;
  - gap band.
- Made tree and net heights render from actual generated heights.
- Increased mission obstacle counts more clearly across missions.
- Added debug output for generated obstacle data.
- Later adjusted vertical variety so tree and net heights are not mirrored.
- Added high, center, low, and varied gap bands.
- Added tests proving:
  - gaps respect minimum height;
  - obstacle spacing varies;
  - tree and net heights vary;
  - mission 7 is denser than mission 1.

## Mission Startup And Asset Preload Fixes

- Fixed first mission asset preload reliability.
- Changed game image preload to be awaited before first gameplay render.
- Added safe image cache timeout/fallback behavior for tests and failures.
- Ensured pre-start mission state renders the actual frozen game scene instead of a plain black screen.
- Kept physics paused before the first tap.
- Preserved tap-to-start overlay above the visible scene.
- Ensured restart and next mission use reliable asset-loaded paths.

## Lives System

- Updated lives balance to:
  - max lives: 5;
  - starting lives: 5;
  - recovery interval: 90 seconds.
- Confirmed no practice mode or unlimited mode was added.
- Kept no-lives overlay blocking play when `currentLives == 0`.
- Found and fixed stale no-lives overlay behavior:
  - root cause: overlay was shown when lives were zero but not removed when a life recovered;
  - fix: game screen now hides the no-lives overlay when lives recover;
  - if the mission is still ready, tap-to-start becomes available again;
  - if the mission is in game-over state, normal game-over overlay is restored.
- Added tests for no-lives overlay recovery behavior.
- Added tests confirming 90-second recovery remains intact.

## Battery Collectibles

- Added optional battery collectibles.
- Battery scoring:
  - 5 points per battery;
  - maximum battery bonus: 40 points per mission.
- Battery bonus contributes to final mission score and leaderboard-submitted score through the existing mission score path.
- Batteries do not restore lives.
- Batteries are optional and not required to finish a mission.
- Added procedural battery visual first.
- Later integrated PNG battery asset:
  - `assets/images/game/collectibles/battery_collectible.png`.
- Kept glow/pulse styling.
- Added collection feedback effect.
- Added battery scoring tests.

## Tank Hit Effects

- Added delayed mission complete after tank hit.
- Tank hit flow:
  - hit tank;
  - freeze/stop active gameplay input;
  - show tank explosion/fire effect;
  - wait 1.2 seconds;
  - show mission complete overlay.
- Added procedural explosion first.
- Later integrated PNG effects:
  - `assets/images/game/effects/tank_explosion_burst.png`;
  - `assets/images/game/effects/tank_fire_smoke_after_hit.png`.
- Preserved no visible target circle.
- Preserved invisible victory hit area and missed-tank failure.

## Result Overlay And HUD Polish

- Redesigned gameplay HUD toward a compact action-game style.
- Added visible lives indicators.
- Added mission display.
- Added pause icon button.
- Added mission progress indicator where safely supported.
- Added HUD safe-area/gameplay-safe-inset behavior so top obstacles are not hidden behind HUD.
- Updated mission complete and game over overlays toward neon arcade style.
- Removed duplicated lives info from result overlay because lives are already visible in HUD.

## Achievements MVP

- Implemented exactly 8 MVP achievements using only existing icons:
  - `first_run`;
  - `training_complete`;
  - `fifth_target`;
  - `mvp_campaign`;
  - `clean_hit`;
  - `bullseye`;
  - `stable_flight`;
  - `perfect_score`.
- Added local achievement definitions.
- Added local achievement unlock storage through SharedPreferences.
- Added achievement evaluator for mission results and progress.
- Added achievements screen route/menu entry.
- Added locked/unlocked visual states.
- Added achievement unlock snackbar/popup.
- Added RU/EN localization strings.
- Added achievement tests for:
  - exactly 8 definitions;
  - icon paths;
  - no duplicate unlocks;
  - mission-result achievements;
  - progress-based achievements;
  - screen rendering.

## Localization And Settings

- Added and updated RU/EN strings for new UI.
- Fixed language switching so selecting RU/EN updates the UI immediately.
- Persisted selected locale locally.
- Connected selected locale to the app root MaterialApp.
- Confirmed language switch visually during QA.

## Legal Documents

- Filled legal documents for FPV Last Run using provided user information.
- Developer/operator: Анпилов Дмитрий Сергеевич.
- Contact email: `anpilovdmitriy@yandex.ru`.
- Jurisdiction: Российская Федерация.
- Age target: 13+.
- Added or updated:
  - privacy policy;
  - terms of use;
  - personal data consent;
  - account deletion instructions.
- Did not invent missing website, privacy URL, or account deletion URL.
- Marked missing URLs as publication blockers.
- Updated backend legal service/tests where legal text is served by backend.

## Backend QA And Smoke Testing

- Backend tests passed during QA:
  - `42 passed`.
- Backend smoke API passed:
  - health;
  - legal documents;
  - register;
  - login/logout;
  - profile;
  - display name update;
  - mission complete;
  - progress;
  - leaderboard;
  - legal acceptance;
  - delete account;
  - old token rejection after account deletion.
- Database migration passed with Alembic.
- Leaderboard seed script ran successfully.
- No backend changes were made during the latest alpha-blocker fix.

## Mobile QA And Build Status

- Mobile checks passed after the latest blocker fix:
  - `flutter gen-l10n`: passed;
  - `flutter analyze`: passed;
  - `flutter test`: passed, 31/31;
  - `flutter build apk --debug --dart-define=API_BASE_URL=http://10.0.2.2:8000`: passed.
- Latest debug APK path:
  - `apps/mobile/build/app/outputs/flutter-apk/app-debug.apk`.
- Latest reported APK size:
  - 181,156,364 bytes.
- Non-blocking warning remains:
  - `l10n.yaml` contains `synthetic-package`, which Flutter says no longer has any effect.
- Test logs may include expected image-cache timeout debug messages in widget tests because fallback rendering is exercised.

## Dev Tools

- Added PowerShell helper:
  - `tools/dev/install_debug_apk.ps1`.
- Added development helper README:
  - `tools/dev/README.md`.
- Helper supports:
  - normal install;
  - clean user uninstall;
  - cache trimming;
  - optional emulator kill;
  - custom device, package, and APK path.
- Fixed default package name from:
  - `com.example.drone_strike`
  to:
  - `com.anpilov.dronestrike`.

## QA Screenshots And Checklist

- Visual QA screenshots were saved under:
  - `apps/mobile/build/qa_screenshots/`.
- QA checked:
  - launch/menu;
  - mission pre-start;
  - mission gameplay;
  - no-lives behavior;
  - mission 7 scene;
  - orientation return;
  - achievements screen;
  - settings/language;
  - launcher icon/app label.
- A RuStore alpha test checklist exists as an untracked file:
  - `docs/qa/rustore_alpha_test_checklist_ru.md`.

## Important Commits In Project History

Recent local Git history includes:

- `067dc3e Polish splash and gameplay background scale`
- `173c7f9 Fix Android splash build configuration`
- `ccb0788 Add battery collectibles and tank hit effects`
- `1732b2b Polish FPV Last Run MVP systems and legal docs`
- `6257d0f Improve obstacle generation and game screen startup`
- `4b723bc Integrate game sprites and polish visual layout`
- `8b0487d Tune obstacle gaps and mission difficulty`
- `c6acf91 Add prepared game sprite assets`
- `3684432 Fix mission navigation splash and background stability`
- `248ccae Polish menu buttons and exit flow`
- `dba84c7 Add menu visuals and neon UI`
- `c54c8fe Fix game orientation tap start audio paths and add image assets`

## Current Uncommitted Work At Time Of This Log

The working tree has uncommitted mobile QA/gameplay changes from recent passes.
Known modified files include:

- `apps/mobile/lib/features/game/presentation/game_placeholder_screen.dart`
- `apps/mobile/lib/game/components/background_layer_component.dart`
- `apps/mobile/lib/game/components/battery_component.dart`
- `apps/mobile/lib/game/components/drone_component.dart`
- `apps/mobile/lib/game/components/explosion_component.dart`
- `apps/mobile/lib/game/components/net_component.dart`
- `apps/mobile/lib/game/components/tank_component.dart`
- `apps/mobile/lib/game/components/tree_component.dart`
- `apps/mobile/lib/game/drone_game.dart`
- `apps/mobile/lib/game/game_image_cache.dart`
- `apps/mobile/lib/game/systems/level_generator.dart`
- `apps/mobile/test/app_smoke_test.dart`
- `tools/dev/install_debug_apk.ps1`

Known untracked file:

- `docs/qa/rustore_alpha_test_checklist_ru.md`

## Remaining Risks Before Alpha

- Manual retest after the no-lives overlay fix.
- Real device test, not only emulator.
- Release signing setup.
- Backend deployment environment.
- Public Privacy Policy URL.
- Public account deletion URL.
- Store-specific checklist validation, especially RuStore/Google Play requirements.
- Optional cleanup of the non-blocking `synthetic-package` l10n warning.

## Current Recommendation

The project is close to alpha testing.
After the latest no-lives overlay fix and install helper package fix, core automated mobile checks pass and the debug APK builds.
Recommended next step is a short manual emulator retest focused on:

- no-lives recovery overlay;
- Mission 1 start/restart;
- Mission 7 obstacle variety;
- tank hit and missed-tank failure;
- battery collection;
- achievements popup persistence;
- RU/EN switch;
- install helper clean reinstall.
