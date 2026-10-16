import 'package:flutter_test/flutter_test.dart';
import 'package:two_cars/main.dart';

void main() {
  testWidgets('starts a new two-car game', (tester) async {
    await tester.pumpWidget(const TwoCarsApp());

    expect(find.text('READY?'), findsOneWidget);
    expect(find.text('START GAME'), findsOneWidget);

    await tester.tap(find.text('START GAME'));
    await tester.pump();

    expect(find.text('READY?'), findsNothing);
    expect(find.textContaining('Tap a lane'), findsOneWidget);
  });
}
