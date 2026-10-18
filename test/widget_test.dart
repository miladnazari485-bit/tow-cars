import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:two_cars/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows two-thumb instructions', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const TwoCarsApp());
    await tester.pump();

    expect(find.text('TWO CARS'), findsOneWidget);
    expect(find.textContaining('Left thumb'), findsOneWidget);
    expect(find.textContaining('Right thumb'), findsOneWidget);
  });
}
