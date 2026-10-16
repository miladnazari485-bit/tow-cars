import 'package:flutter_test/flutter_test.dart';
import 'package:two_cars/main.dart';

void main() {
  testWidgets('shows both-car game instructions', (tester) async {
    await tester.pumpWidget(const TwoCarsApp());

    expect(find.text('TWO CARS'), findsOneWidget);
    expect(find.textContaining('Collect circles'), findsOneWidget);
    expect(find.textContaining('Control both cars'), findsOneWidget);
  });
}
