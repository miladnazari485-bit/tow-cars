import 'package:flutter_test/flutter_test.dart';
import 'package:two_cars/collision.dart';

void main() {
  test('collects a circle that passes through the car in one frame', () {
    expect(
      objectHitsCar(
        previousY: 0.70,
        objectY: 0.90,
        objectTrack: 1,
        carTrack: 1,
      ),
      isTrue,
    );
  });

  test('does not collect a circle in the other lane', () {
    expect(
      objectHitsCar(
        previousY: 0.80,
        objectY: 0.84,
        objectTrack: 0,
        carTrack: 1,
      ),
      isFalse,
    );
  });

  test('left and right taps map to the two cars', () {
    expect(sideFromX(10, 400), 0);
    expect(sideFromX(300, 400), 1);
    expect(toggleTrack(0), 1);
    expect(toggleTrack(1), 0);
  });
}
