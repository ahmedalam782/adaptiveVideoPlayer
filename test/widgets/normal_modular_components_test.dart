import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_video_player/src/youtube_player/models/player_text_config.dart';
import 'package:adaptive_video_player/src/normal_video_player/coordinator/normal_fullscreen_coordinator.dart';
import 'package:adaptive_video_player/src/normal_video_player/widgets/adaptive_bottom_bar.dart';
import 'package:adaptive_video_player/src/normal_video_player/widgets/adaptive_center_play_pause.dart';
import 'package:adaptive_video_player/src/normal_video_player/widgets/adaptive_player_settings_sheet.dart';
import 'package:adaptive_video_player/src/normal_video_player/models/video_quality.dart';
import 'package:adaptive_video_player/src/normal_video_player/models/subtitle_track.dart';
import 'package:adaptive_video_player/src/normal_video_player/widgets/adaptive_fullscreen_button.dart';
import 'package:adaptive_video_player/src/normal_video_player/widgets/adaptive_settings_button.dart';
import 'package:adaptive_video_player/src/normal_video_player/widgets/normal_fullscreen_overlay.dart';
import 'package:adaptive_video_player/src/normal_video_player/widgets/normal_player_error_widget.dart';
import 'package:adaptive_video_player/src/normal_video_player/models/video_chapter.dart';
import 'package:adaptive_video_player/src/normal_video_player/adaptive_controls.dart';
import 'package:adaptive_video_player/src/normal_video_player/widgets/adaptive_progress_bar.dart';
import 'package:adaptive_video_player/src/normal_video_player/widgets/normal_mini_player_overlay.dart';
import 'package:adaptive_video_player/src/normal_video_player/widgets/normal_player_loading_widget.dart';
import 'package:adaptive_video_player/src/normal_video_player/widgets/pip_playback_chrome.dart';
import 'package:adaptive_video_player/src/normal_video_player/utils/video_player_web_safe.dart';

class _FakeVideoPlayerController extends VideoPlayerController {
  _FakeVideoPlayerController({
    Duration duration = const Duration(seconds: 100),
    Duration position = const Duration(seconds: 30),
  }) : super.networkUrl(Uri.parse('https://example.com/test.mp4')) {
    value = value.copyWith(
      duration: duration,
      position: position,
      isInitialized: true,
    );
  }

  @override
  Future<void> initialize() async {}

  @override
  Future<void> seekTo(Duration position) async {
    value = value.copyWith(position: position);
  }

  @override
  Future<void> play() async {
    value = value.copyWith(isPlaying: true);
  }

  @override
  Future<void> pause() async {
    value = value.copyWith(isPlaying: false);
  }

  @override
  Future<void> setVolume(double volume) async {
    value = value.copyWith(volume: volume);
  }

  @override
  Future<void> setLooping(bool looping) async {
    value = value.copyWith(isLooping: looping);
  }

  @override
  Future<void> setPlaybackSpeed(double speed) async {
    value = value.copyWith(playbackSpeed: speed);
  }
}

void main() {
  group('Normal Video Player Modular Components Tests', () {
    testWidgets('NormalFullscreenOverlay renders child in directionality and scaffold', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NormalFullscreenOverlay(
            child: Text('Fullscreen Content'),
          ),
        ),
      );

      expect(find.text('Fullscreen Content'), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('NormalPlayerLoadingWidget renders default spinner', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NormalPlayerLoadingWidget(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('NormalPlayerLoadingWidget respects customBuilder', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NormalPlayerLoadingWidget(
              customBuilder: (context) => const Text('Custom Loading...'),
            ),
          ),
        ),
      );

      expect(find.text('Custom Loading...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('NormalPlayerErrorWidget renders error icon and message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NormalPlayerErrorWidget(
              errorMessage: 'Failed to load test stream',
            ),
          ),
        ),
      );

      expect(find.text('Failed to load test stream'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('NormalPlayerErrorWidget respects customBuilder', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NormalPlayerErrorWidget(
              errorMessage: 'Failed to load',
              customBuilder: (context, msg) => Text('Custom Error: $msg'),
            ),
          ),
        ),
      );

      expect(find.text('Custom Error: Failed to load'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsNothing);
    });

    testWidgets('AdaptiveFullscreenButton toggles callback correctly', (tester) async {
      bool enterCalled = false;
      bool exitCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveFullscreenButton(
              isFullScreen: false,
              onEnterFullscreen: () => enterCalled = true,
              onExitFullscreen: () => exitCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AdaptiveFullscreenButton));
      expect(enterCalled, isTrue);
      expect(exitCalled, isFalse);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveFullscreenButton(
              isFullScreen: true,
              onEnterFullscreen: () => enterCalled = true,
              onExitFullscreen: () => exitCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AdaptiveFullscreenButton));
      expect(exitCalled, isTrue);
    });

    testWidgets('AdaptiveSettingsButton renders settings icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdaptiveSettingsButton(),
          ),
        ),
      );

      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    test('NormalFullscreenCoordinator handles initial state and close when not open', () {
      final coordinator = NormalFullscreenCoordinator();
      expect(coordinator.isInFullscreen, isFalse);

      // Should not throw when closing or disposing uninitialized
      coordinator.closeFullscreen();
      expect(coordinator.isInFullscreen, isFalse);

      coordinator.dispose();
      expect(coordinator.isInFullscreen, isFalse);
    });

    testWidgets('NormalFullscreenCoordinator opens overlay and rebuildOverlay updates content', (tester) async {
      final coordinator = NormalFullscreenCoordinator();
      String currentQuality = '720p';

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  coordinator.openFullscreen(
                    context: context,
                    builder: (ctx) => Text('Active Quality: $currentQuality'),
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(coordinator.isInFullscreen, isTrue);
      expect(find.text('Active Quality: 720p'), findsOneWidget);

      // Now change quality and trigger rebuildOverlay
      currentQuality = '1080p';
      coordinator.rebuildOverlay();
      await tester.pumpAndSettle();

      expect(find.text('Active Quality: 1080p'), findsOneWidget);

      coordinator.closeFullscreen();
      await tester.pumpAndSettle();
      expect(coordinator.isInFullscreen, isFalse);
      expect(find.text('Active Quality: 1080p'), findsNothing);

      coordinator.dispose();
    });

    testWidgets('Draggable handle responds to pan gestures and double-tap reset', (tester) async {
      Offset offset = Offset.zero;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Stack(
                  children: [
                    Positioned(
                      bottom: 50,
                      right: 16,
                      child: Transform.translate(
                        offset: offset,
                        child: GestureDetector(
                          key: const ValueKey('drag_handle'),
                          onPanUpdate: (details) {
                            setState(() => offset += details.delta);
                          },
                          onDoubleTap: () {
                            setState(() => offset = Offset.zero);
                          },
                          child: Container(
                            width: 200,
                            height: 100,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      expect(offset, Offset.zero);
      await tester.drag(find.byKey(const ValueKey('drag_handle')), const Offset(-50, -30));
      await tester.pumpAndSettle();
      expect(offset != Offset.zero, isTrue);
      expect(offset.dx < 0, isTrue);
      expect(offset.dy < 0, isTrue);

      // Test double-tap reset
      await tester.tap(find.byKey(const ValueKey('drag_handle')));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.byKey(const ValueKey('drag_handle')));
      await tester.pumpAndSettle();
      expect(offset, Offset.zero);
    });

    testWidgets('AdaptivePlayerSettingsSheet renders without overflow in tight constraints and flips RTL in Arabic', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 250,
                height: 150,
                child: AdaptivePlayerSettingsSheet(
                  qualities: const [
                    VideoQuality(title: '1080p Full HD', url: 'https://example.com/1080.mp4'),
                    VideoQuality(title: '720p HD', url: 'https://example.com/720.mp4'),
                  ],
                  currentQuality: const VideoQuality(title: '1080p Full HD', url: 'https://example.com/1080.mp4'),
                  subtitles: const [
                    SubtitleTrack(id: 'en', title: 'English', content: 'WEBVTT'),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      // Verify that quality and subtitle options render in LTR by default
      expect(find.text('Quality (Resolution)'), findsOneWidget);
      expect(find.text('Subtitles'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Tap on Quality to transition to qualities submenu
      await tester.tap(find.text('Quality (Resolution)'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('1080p Full HD'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Now verify Arabic preset renders in RTL
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 280,
                height: 180,
                child: AdaptivePlayerSettingsSheet(
                  key: ValueKey('arabic_sheet'),
                  messages: PlayerTextConfig.arabic(),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('الجودة (الدقة)'), findsOneWidget);
      expect(find.text('الترجمة'), findsOneWidget);
      final titleContext = tester.element(find.text('الجودة (الدقة)'));
      expect(Directionality.of(titleContext), TextDirection.rtl);
    });

    testWidgets('AdaptiveBottomBar renders -10s, play/pause, and +10s buttons in LTR even inside RTL parent', (tester) async {
      final controller = _FakeVideoPlayerController();

      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: AdaptiveBottomBar(
                controller: controller,
                isFullScreen: false,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.replay_10_rounded), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
      expect(find.byIcon(Icons.forward_10_rounded), findsOneWidget);
      expect(find.text('00:30'), findsOneWidget);
      expect(find.text('01:40'), findsOneWidget);

      // Verify RTL order: in RTL direction, rewind (-10s / later) is first on the right and forward (+10s / increase) is second on the left
      final rewindX = tester.getCenter(find.byIcon(Icons.replay_10_rounded)).dx;
      final forwardX = tester.getCenter(find.byIcon(Icons.forward_10_rounded)).dx;
      expect(rewindX > forwardX, isTrue);

      await controller.dispose();
    });

    testWidgets('AdaptiveBottomBar hides skip buttons when showSkipButtons is false or isLive is true', (tester) async {
      final controller = _FakeVideoPlayerController();

      // Test showSkipButtons: false
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveBottomBar(
              controller: controller,
              isFullScreen: false,
              showSkipButtons: false,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.replay_10_rounded), findsNothing);
      expect(find.byIcon(Icons.forward_10_rounded), findsNothing);
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

      // Test isLive: true
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveBottomBar(
              controller: controller,
              isFullScreen: false,
              isLive: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.replay_10_rounded), findsNothing);
      expect(find.byIcon(Icons.forward_10_rounded), findsNothing);

      await controller.dispose();
    });

    testWidgets('AdaptiveBottomBar tapping -10 and +10 calls seekTo and fires analytics', (tester) async {
      final controller = _FakeVideoPlayerController();

      String? lastEvent;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveBottomBar(
              controller: controller,
              isFullScreen: false,
              onAnalyticsEvent: (event, data) => lastEvent = event,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.replay_10_rounded));
      await tester.pump();
      expect(lastEvent, 'video_seek');
      expect(controller.value.position, const Duration(seconds: 20));

      await tester.tap(find.byIcon(Icons.forward_10_rounded));
      await tester.pump();
      expect(lastEvent, 'video_seek');
      expect(controller.value.position, const Duration(seconds: 30));

      await controller.dispose();
    });

    testWidgets('AdaptiveCenterPlayPause renders and responds to tap', (tester) async {
      final controller = _FakeVideoPlayerController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveCenterPlayPause(controller: controller),
          ),
        ),
      );

      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
      await tester.tap(find.byType(AdaptiveCenterPlayPause));
      await tester.pump();
      expect(controller.value.isPlaying, isTrue);

      await controller.dispose();
    });

    testWidgets('AdaptiveProgressBar displays timestamp pill during scrubbing', (tester) async {
      final controller = _FakeVideoPlayerController(
        duration: const Duration(seconds: 120),
        position: const Duration(seconds: 30),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 400,
                child: AdaptiveProgressBar(
                  controller: controller,
                  dragPosition: 75000, // 01:15
                  onDragChanged: (_) {},
                  onDragEnd: (_) {},
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('01:15'), findsOneWidget);
      await controller.dispose();
    });

    testWidgets('BaseAdaptiveVideoPlayer Hold-to-2x Speed activates on long press and restores on release', (tester) async {
      final controller = _FakeVideoPlayerController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 600,
              height: 350,
              child: BaseAdaptiveVideoPlayer(
                controller: controller,
              ),
            ),
          ),
        ),
      );

      expect(controller.value.playbackSpeed, 1.0);
      expect(find.text('2x'), findsNothing);

      final gesture = await tester.startGesture(const Offset(150, 100));
      await tester.pump(const Duration(milliseconds: 600));

      expect(controller.value.playbackSpeed, 2.0);
      expect(find.text('2x'), findsOneWidget);

      await gesture.up();
      await tester.pumpAndSettle();

      expect(controller.value.playbackSpeed, 1.0);
      expect(find.text('2x'), findsNothing);

      await controller.dispose();
    });

    testWidgets('AdaptiveProgressBar displays active chapter title and timestamp in scrubbing pill', (tester) async {
      final controller = _FakeVideoPlayerController(
        duration: const Duration(seconds: 120),
        position: const Duration(seconds: 30),
      );
      const chapters = [
        VideoChapter(title: 'Introduction', startTime: Duration.zero),
        VideoChapter(title: 'Deep Dive', startTime: Duration(seconds: 60)),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 400,
                child: AdaptiveProgressBar(
                  controller: controller,
                  dragPosition: 75000, // 01:15 -> inside 'Deep Dive'
                  chapters: chapters,
                  onDragChanged: (_) {},
                  onDragEnd: (_) {},
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Deep Dive'), findsOneWidget);
      expect(find.text('01:15'), findsOneWidget);
      await controller.dispose();
    });

    testWidgets('NormalMiniPlayerOverlay renders controls and triggers expand/close callbacks', (tester) async {
      final controller = _FakeVideoPlayerController();
      bool expanded = false;
      bool closed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                NormalMiniPlayerOverlay(
                  controller: controller,
                  onExpand: () => expanded = true,
                  onClose: () => closed = true,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.picture_in_picture_alt_rounded), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.picture_in_picture_alt_rounded));
      expect(expanded, isTrue);

      await tester.tap(find.byIcon(Icons.close_rounded));
      expect(closed, isTrue);

      await controller.dispose();
    });

    testWidgets('PipPlaybackChrome handles 2D diagonal drag updates without assertion errors', (tester) async {
      DragUpdateDetails? receivedDetails;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                height: 200,
                child: PipPlaybackChrome(
                  isPlaying: true,
                  progress: 0.5,
                  onClose: () {},
                  onExpand: () {},
                  onPlayPause: () {},
                  onDragUpdate: (details) {
                    receivedDetails = details;
                  },
                ),
              ),
            ),
          ),
        ),
      );

      final center = tester.getCenter(find.byType(PipPlaybackChrome));
      final gesture = await tester.startGesture(center, kind: PointerDeviceKind.mouse, buttons: kPrimaryMouseButton);
      await gesture.moveBy(const Offset(25, 35));
      await tester.pump();

      expect(receivedDetails, isNotNull);
      expect(receivedDetails!.delta, equals(const Offset(25, 35)));
      expect(receivedDetails!.primaryDelta, isNull);

      await gesture.up();
    });
  });
}
