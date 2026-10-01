import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:example/screens/showcase_screen.dart';

void main() {
  testWidgets('App renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ShowcaseScreen(
          isDark: true,
          onToggleTheme: () {},
          currentLanguageCode: 'en',
          onSelectLanguage: (_) {},
        ),
      ),
    );
    expect(find.text('Adaptive Video Player Studio'), findsOneWidget);
  });
}
