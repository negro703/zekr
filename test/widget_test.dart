import 'package:flutter_test/flutter_test.dart';

import 'package:zekr/main.dart';

void main() {
  testWidgets('ZekrApp renders Home navigation shell', (tester) async {
    // Build the app and pump one frame (avoids pumpAndSettle timeout
    // from ongoing async cubit loads in home tabs).
    await tester.pumpWidget(const ZekrApp());
    await tester.pump();

    // Verify the bottom navigation bar tabs are present.
    expect(find.text('القرآن'), findsOneWidget);
    expect(find.text('الأذكار'), findsOneWidget);
    expect(find.text('السبحة'), findsOneWidget);
    expect(find.text('الإعدادات'), findsOneWidget);
  });
}