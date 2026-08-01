import 'package:flutter_test/flutter_test.dart';

import 'package:zekr/main.dart';

void main() {
  testWidgets('ZekrApp renders placeholder home screen', (tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ZekrApp());

    // Verify the app bar title is displayed.
    expect(find.text('ذِكر'), findsOneWidget);

    // Verify the welcome message is displayed.
    expect(find.text('مرحباً بك في تطبيق ذكر'), findsOneWidget);
  });
}