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
