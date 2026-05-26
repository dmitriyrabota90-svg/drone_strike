# Drone Strike Mobile

Flutter scaffold for the Drone Strike mobile game.

## Local Development

```powershell
cd /d "C:\Mobile Game Drone Strike\apps\mobile"
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
```

## Android Emulator Backend URL

```powershell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

The backend must be running separately. See `docs/technical/mobile_api_contract.md` and `docs/technical/mobile_local_setup.md` from the repository root.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
