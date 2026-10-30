import 'package:flutter_test/flutter_test.dart';
import 'package:farmer_voice_app/main.dart';
import 'package:farmer_voice_app/home_screen.dart';

void main() {
  testWidgets('Farmer Voice Assistant home screen loads',
      (WidgetTester tester) async {
    await tester.pumpWidget(const KissanSetuApp());
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
