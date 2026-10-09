import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_video_player/src/normal_video_player/adaptive_controls.dart';
import 'package:adaptive_video_player/src/normal_video_player/utils/video_player_web_safe.dart';
import 'package:adaptive_video_player/src/youtube_player/models/youtube_player_config.dart';

void main() {
  group('Double-click mouse fullscreen tests', () {
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

    Future<void> simulateMouseDoubleClick(WidgetTester tester) async {
      final pointer1 = TestPointer(1, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(pointer1.down(const Offset(400, 225)));
      await tester.sendEventToBinding(pointer1.up());
      await tester.pump(const Duration(milliseconds: 50));
      final pointer2 = TestPointer(2, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(pointer2.down(const Offset(400, 225)));
      await tester.sendEventToBinding(pointer2.up());
      await tester.pumpAndSettle();
    }

    testWidgets(
        'Double clicking with mouse enters fullscreen when in windowed mode',
        (tester) async {
      bool enterCalled = false;
      bool exitCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 450,
              child: BaseAdaptiveVideoPlayer(
                controller: controller,
                isFullScreen: false,
                onEnterFullscreen: () => enterCalled = true,
                onExitFullscreen: () => exitCalled = true,
              ),
            ),
          ),
        ),
      );

      await simulateMouseDoubleClick(tester);

      expect(enterCalled, isTrue);
      expect(exitCalled, isFalse);
    });

    testWidgets(
        'Double clicking with mouse exits fullscreen when already in fullscreen mode',
        (tester) async {
      bool enterCalled = false;
      bool exitCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 450,
              child: BaseAdaptiveVideoPlayer(
                controller: controller,
                isFullScreen: true,
                onEnterFullscreen: () => enterCalled = true,
                onExitFullscreen: () => exitCalled = true,
              ),
            ),
          ),
        ),
      );

      await simulateMouseDoubleClick(tester);

      expect(enterCalled, isFalse);
      expect(exitCalled, isTrue);
    });

    testWidgets(
        'Double click does not toggle fullscreen if doubleClickToggleFullscreen is false',
        (tester) async {
      bool enterCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 450,
              child: BaseAdaptiveVideoPlayer(
                controller: controller,
                isFullScreen: false,
                visibility: const PlayerVisibilityConfig(
                  doubleClickToggleFullscreen: false,
                ),
                onEnterFullscreen: () => enterCalled = true,
              ),
            ),
          ),
        ),
      );

      await simulateMouseDoubleClick(tester);

      expect(enterCalled, isFalse);
    });
  });
}
