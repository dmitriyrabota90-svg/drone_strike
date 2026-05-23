# Development Helpers

## Install debug APK on emulator

Use this helper when Android Studio or `adb install` reports emulator install
issues for the FPV Last Run debug APK.

Safe install:

```powershell
.\tools\dev\install_debug_apk.ps1
```

Clean reinstall:

```powershell
.\tools\dev\install_debug_apk.ps1 -CleanUserInstall
```

Fix storage and reinstall:

```powershell
.\tools\dev\install_debug_apk.ps1 -CleanUserInstall -TrimCaches
```

If install still fails with insufficient storage, wipe emulator data manually:

```text
Android Studio -> Device Manager -> dropdown near emulator -> Wipe Data -> Start
```

The script does not wipe emulator data automatically.
