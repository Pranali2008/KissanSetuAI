import 'package:flutter_test/flutter_test.dart';
import 'package:farmer_voice_app/main.dart';

void main() {
  testWidgets('Farmer Voice Assistant home screen loads',
      (WidgetTester tester) async {
    await tester.pumpWidget(const FarmerVoiceApp());
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('KissanSetu AI'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
  });
}
