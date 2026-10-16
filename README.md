# Two Cars

A Flutter arcade game for Android and the web. Control two cars independently,
collect the circles, and avoid the squares.

## Controls

- Touch: tap one of the four road lanes to move that road's car.
- Keyboard: `A` / `D` controls the left car; arrow keys control the right car.
- Collecting a circle adds one point to that car.
- Hitting a square ends the round.

## Run in VS Code on Android

Install Flutter and the VS Code Flutter extension, then open this folder. If the
`android` and `web` folders are not present yet, generate them once:

```powershell
flutter create --platforms=android,web .
flutter pub get
flutter doctor
```

Start an Android emulator (or connect a phone with USB debugging), select it in
the VS Code status bar, and press `F5`. You can also run:

```powershell
flutter run
```

## Run locally with Docker

Docker serves the web build through nginx:

```powershell
docker build -t two-cars .
docker run --rm -p 8080:80 two-cars
```

Open <http://localhost:8080>.

## Test

```powershell
flutter test
flutter analyze
```
