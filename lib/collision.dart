import 'dart:math';

const double carY = 0.82;
const double catchWindow = 0.12;

bool objectHitsCar({
  required double objectY,
  required double previousY,
  required int objectTrack,
  required int carTrack,
}) {
  if (objectTrack != carTrack) return false;
  final top = min(previousY, objectY);
  final bottom = max(previousY, objectY);
  return bottom >= carY - catchWindow && top <= carY + catchWindow;
}

int toggleTrack(int track) => 1 - track;

int sideFromX(double x, double width) => x < width / 2 ? 0 : 1;
