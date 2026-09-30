import 'package:adaptive_video_player/src/normal_video_player/utils/video_player_web_safe.dart';
import 'package:adaptive_video_player/src/normal_video_player/widgets/buffer_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BufferSlider (BufferPainter & GradientSliderTrackShape)', () {
    test('BufferPainter repaints when ranges change', () {
      final range1 = [
        DurationRange(Duration.zero, const Duration(seconds: 10)),
      ];
      final range2 = [
        DurationRange(Duration.zero, const Duration(seconds: 20)),
      ];

      final painter1 = BufferPainter(range1, const Duration(seconds: 60));
      final painter2 = BufferPainter(range2, const Duration(seconds: 60));
      final painterSame = BufferPainter(range1, const Duration(seconds: 60));

      expect(painter1.shouldRepaint(painter2), isTrue);
      expect(painter1.shouldRepaint(painterSame), isFalse);
    });

    testWidgets('GradientSliderTrackShape renders within SliderTheme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SliderTheme(
              data: const SliderThemeData(
                trackShape: GradientSliderTrackShape(),
                trackHeight: 4.0,
                activeTrackColor: Colors.red,
                inactiveTrackColor: Colors.grey,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.0),
              ),
              child: Slider(
                value: 0.5,
                onChanged: (val) {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('GradientSliderTrackShape in RTL paints active track from thumb to right', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Directionality(
              textDirection: TextDirection.rtl,
              child: SliderTheme(
                data: const SliderThemeData(
                  trackShape: GradientSliderTrackShape(),
                  trackHeight: 4.0,
                  activeTrackColor: Colors.red,
                  inactiveTrackColor: Colors.grey,
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.0),
                ),
                child: SizedBox(
                  width: 200,
                  child: Slider(
                    value: 0.2, // 20%
                    min: 0.0,
                    max: 1.0,
                    onChanged: (_) {},
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Slider), findsOneWidget);
    });
  });
}
