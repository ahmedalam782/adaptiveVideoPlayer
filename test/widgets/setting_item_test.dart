import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_video_player/src/youtube_player/widgets/setting_item.dart';

void main() {
  testWidgets('SettingItem renders correctly and handles tap', (
    WidgetTester tester,
  ) async {
    bool isTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SettingItem(
            title: 'Test Setting',
            value: true,
            icon: Icons.settings,
            onChanged: (val) {
              isTapped = val;
            },
            backgroundColor: Colors.black,
            textColor: Colors.white,
            iconColor: Colors.blue,
            switchInactiveThumbColor: Colors.red,
            switchInactiveTrackColor: Colors.grey,
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );

    // Initial assertions
    expect(find.text('Test Setting'), findsOneWidget);
    expect(find.byIcon(Icons.settings), findsOneWidget);
    expect(find.byType(Switch), findsOneWidget);

    // Tap switch
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    // Verify callback
    expect(isTapped, false);
  });

  testWidgets('SettingItem builds with default properties', (
    WidgetTester tester,
  ) async {
    bool isTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SettingItem(
            title: 'Basic Setting',
            value: false,
            icon: Icons.home,
            onChanged: (val) {
              isTapped = val;
            },
            iconColor: Colors.white,
            textColor: Colors.black,
            backgroundColor: Colors.grey,
          ),
        ),
      ),
    );

    expect(find.text('Basic Setting'), findsOneWidget);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(isTapped, true);
  });
}
