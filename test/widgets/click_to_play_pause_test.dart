import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_video_player/src/normal_video_player/adaptive_controls.dart';
import 'package:adaptive_video_player/src/normal_video_player/utils/video_player_web_safe.dart';
import 'package:adaptive_video_player/src/youtube_player/models/youtube_player_config.dart';

void main() {
  group('Single click play and pause (close) tests', () {
    late VideoPlayerController controller;

    setUp(() {
      controller = VideoPlayerController.networkUrl(
        Uri.parse(
          'https://media.w3.org/2010/05/bunny/trailer.mp4',
        ),
      );
    });

    tearDown(() {
      controller.dispose();
    });

    Future<void> simulateMouseSingleClick(WidgetTester tester) async {
      final pointer = TestPointer(1, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(pointer.down(const Offset(400, 225)));
      await tester.sendEventToBinding(pointer.up());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }

    testWidgets(
        'Single click with mouse plays video when currently paused',
        (tester) async {
      final events = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 450,
              child: BaseAdaptiveVideoPlayer(
                controller: controller,
                onAnalyticsEvent: (event, data) => events.add(event),
              ),
            ),
          ),
        ),
      );

      expect(controller.value.isPlaying, isFalse);

      await simulateMouseSingleClick(tester);

      expect(controller.value.isPlaying, isTrue);
      expect(events, contains('video_played'));
    });

    testWidgets(
        'Single click with mouse pauses (closes) video when currently playing',
        (tester) async {
      final events = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 450,
              child: BaseAdaptiveVideoPlayer(
                controller: controller,
                onAnalyticsEvent: (event, data) => events.add(event),
              ),
            ),
          ),
        ),
      );

      // Start playback first
      await controller.play();
      expect(controller.value.isPlaying, isTrue);

      await simulateMouseSingleClick(tester);

      expect(controller.value.isPlaying, isFalse);
      expect(events, contains('video_paused'));
    });

    testWidgets(
        'Single click does not alter playback when clickToPlayPause is disabled',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 450,
              child: BaseAdaptiveVideoPlayer(
                controller: controller,
                visibility: const PlayerVisibilityConfig(
                  clickToPlayPause: false,
                ),
              ),
            ),
          ),
        ),
      );

      expect(controller.value.isPlaying, isFalse);

      await simulateMouseSingleClick(tester);

      expect(controller.value.isPlaying, isFalse);
    });

    testWidgets(
        'Single tap on touch screen pauses video if controls are open and playing',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 450,
              child: BaseAdaptiveVideoPlayer(
                controller: controller,
              ),
            ),
          ),
        ),
      );

      // Play video with controls visible
      await controller.play();
      expect(controller.value.isPlaying, isTrue);

      // Tap on screen via touch pointer
      final touch = TestPointer(2, PointerDeviceKind.touch);
      await tester.sendEventToBinding(touch.down(const Offset(400, 225)));
      await tester.sendEventToBinding(touch.up());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(controller.value.isPlaying, isFalse);
    });
  });
}
