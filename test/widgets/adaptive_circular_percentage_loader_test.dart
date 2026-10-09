import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_video_player/adaptive_video_player.dart';

void main() {
  group('AdaptiveCircularPercentageLoader', () {
    testWidgets('renders exact percentage text and circular progress indicator',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AdaptiveCircularPercentageLoader(
                progress: 0.77,
                color: Color(0xFFE50914),
                strokeWidth: 4.0,
                size: 56.0,
              ),
            ),
          ),
        ),
      );

      // Verify the 77% text is rendered prominently
      expect(find.text('77%'), findsOneWidget);

      // Verify CircularProgressIndicator is present with correct styling
      final indicatorFinder = find.byType(CircularProgressIndicator);
      expect(indicatorFinder, findsOneWidget);
      final indicator = tester.widget<CircularProgressIndicator>(indicatorFinder);
      expect(indicator.color, const Color(0xFFE50914));
      expect(indicator.strokeWidth, 4.0);
      expect(indicator.strokeCap, StrokeCap.round);
      expect(indicator.value, 0.77);

      // Verify size constraints
      final sizedBoxFinder = find.ancestor(
        of: indicatorFinder,
        matching: find.byType(SizedBox),
      );
      expect(sizedBoxFinder, findsWidgets);
      final sizedBox = tester.widget<SizedBox>(sizedBoxFinder.first);
      expect(sizedBox.width, 56.0);
      expect(sizedBox.height, 56.0);
    });

    testWidgets('respects showPercentage = false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AdaptiveCircularPercentageLoader(
                progress: 0.77,
                showPercentage: false,
              ),
            ),
          ),
        ),
      );

      expect(find.text('77%'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('respects custom textStyle', (tester) async {
      const customStyle = TextStyle(
        color: Colors.yellow,
        fontSize: 18.0,
        fontWeight: FontWeight.w900,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AdaptiveCircularPercentageLoader(
                progress: 0.50,
                textStyle: customStyle,
              ),
            ),
          ),
        ),
      );

      final textFinder = find.text('50%');
      expect(textFinder, findsOneWidget);
      final textWidget = tester.widget<Text>(textFinder);
      expect(textWidget.style?.color, Colors.yellow);
      expect(textWidget.style?.fontSize, 18.0);
      expect(textWidget.style?.fontWeight, FontWeight.w900);
    });

    testWidgets('respects PlayerStyleConfig showLoadingPercentage',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AdaptiveCircularPercentageLoader(
                progress: 0.85,
                styling: PlayerStyleConfig(
                  showLoadingPercentage: false,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('85%'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
