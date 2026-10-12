# Habit Tracker

Flutter habit tracker inspired by HelloHabit: monthly day strip, overdue tasks, daily habit cards with heatmaps, light/dark theme, and a shared add button.

## Run

Flutter is not required to be on PATH if you installed it at `%USERPROFILE%\flutter`.

```powershell
$env:Path = "$env:USERPROFILE\flutter\bin;" + $env:Path
$env:FLUTTER_STORAGE_BASE_URL = "https://storage.flutter-io.cn"
$env:PUB_HOSTED_URL = "https://pub.flutter-io.cn"
flutter pub get
flutter run
```

On Android, use an emulator or a USB-connected device with USB debugging enabled.
