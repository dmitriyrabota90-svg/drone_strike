# Mobile Local Setup

## 1. Check Flutter

```powershell
flutter --version
flutter doctor -v
```

Flutter doctor should show a working Android toolchain before Android emulator testing.

## 2. Install Mobile Dependencies

```powershell
cd /d "C:\Mobile Game Drone Strike\apps\mobile"
flutter pub get
```

## 3. Generate Localization

```powershell
flutter gen-l10n
```

The app uses Russian and English ARB files from `lib/l10n`.

## 4. Run Static Checks

```powershell
flutter analyze
flutter test
```

## 5. Start Backend Separately

The backend must be running in another terminal before API integration or smoke testing.

```powershell
cd /d "C:\Mobile Game Drone Strike\services\backend"
.venv\Scripts\activate
docker compose -f docker-compose.db.yml up -d
alembic upgrade head
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

## 6. Android Emulator API URL

Android emulator must call the Windows host through:

```text
http://10.0.2.2:8000
```

Run the app with:

```powershell
cd /d "C:\Mobile Game Drone Strike\apps\mobile"
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

## 7. Android Emulator

If no emulator is available, create an AVD through Android Studio:

1. Open Android Studio.
2. Open Device Manager.
3. Create a virtual Android device.
4. Start the emulator.
5. Run the Flutter command above.

For Windows desktop or Chrome testing, the default local API URL is:

```text
http://localhost:8000
```

## 8. Manual Mobile-Backend Test

Start backend:

```powershell
cd /d "C:\Mobile Game Drone Strike\services\backend"
.venv\Scripts\activate
docker compose -f docker-compose.db.yml up -d
alembic upgrade head
python scripts/seed_leaderboard.py
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Start Android emulator, then run mobile:

```powershell
cd /d "C:\Mobile Game Drone Strike\apps\mobile"
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

Manual flow:

1. Register.
2. Confirm that profile loads.
3. Change display name.
4. Open legal documents.
5. Accept privacy policy.
6. Logout.
7. Login.
8. Delete account.

## 9. Mobile Progress/Leaderboard Manual Test

1. Start backend.
2. Seed leaderboard.
3. Run mobile with `API_BASE_URL`.
4. Register.
5. Open Profile and confirm score 0 and level 1.
6. Open Level Select and confirm missions 1-2 are available.
7. Open mission 1.
8. Complete the mission by reaching the final zone and hitting the tank.
9. Check Profile total score and player level.
10. Check Leaderboard.
11. Logout and login again, then confirm progress remains.

## 10. Flame Core Manual Test

1. Run app.
2. Open Level Select.
3. Start Mission 1.
4. Tap screen.
5. Drone should jump upward.
6. Without taps drone should fall.
7. Hitting top or bottom boundary should show Mission Failed.
8. Pause button should open pause menu.
9. Restart should reset drone position.

## 11. Obstacle/Tank Manual Test

1. Start app.
2. Open Level Select.
3. Start Mission 1.
4. Tap to keep drone in gap.
5. Hit top/bottom boundary to confirm Mission Failed.
6. Hit tree/net to confirm Mission Failed.
7. Reach final zone.
8. Stop tapping to descend.
9. Hit tank to confirm Mission Complete.
10. Restart should reset obstacles and drone.

## 12. Scoring/Lives Manual Test

1. Start mission 1.
2. Crash into boundary/tree/net.
3. Confirm life decreases.
4. Restart if lives remain.
5. Lose all lives.
6. Confirm No Lives overlay appears.
7. Wait or reopen later to check recovery.
8. Complete mission by hitting tank.
9. Confirm result overlay shows base, accuracy, tank, and total score.
10. If logged in, confirm Profile/Progress updates.
11. Check Leaderboard after completion.

## 13. Game Feel Manual Test

1. Open Mission 1.
2. Confirm Tap to start state.
3. Tap once and confirm the drone jumps upward.
4. Stop tapping and confirm the drone falls predictably.
5. Fly through the first gaps.
6. Crash into a tree, net, or boundary and confirm Game Over.
7. Restart mission.
8. Reach the final zone.
9. Stop tapping and try to hit the tank.
10. Confirm Mission Complete.
11. Check pause and resume.
12. Check no lives behavior.
