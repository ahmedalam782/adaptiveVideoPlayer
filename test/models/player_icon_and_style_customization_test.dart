import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_player/video_player.dart';
import 'package:adaptive_video_player/adaptive_video_player.dart';
import 'package:adaptive_video_player/src/normal_video_player/widgets/adaptive_buffering_indicator.dart';
import 'package:adaptive_video_player/src/normal_video_player/widgets/adaptive_center_play_pause.dart';
import 'package:adaptive_video_player/src/normal_video_player/widgets/adaptive_fullscreen_button.dart';
import 'package:adaptive_video_player/src/normal_video_player/widgets/adaptive_progress_bar.dart';
import 'package:adaptive_video_player/src/normal_video_player/widgets/adaptive_settings_button.dart';
import 'package:adaptive_video_player/src/normal_video_player/widgets/adaptive_volume_control.dart';
import 'package:adaptive_video_player/src/normal_video_player/widgets/adaptive_volume_hud_overlay.dart';
import 'package:adaptive_video_player/src/normal_video_player/widgets/normal_player_error_widget.dart';
import 'package:adaptive_video_player/src/normal_video_player/widgets/normal_player_loading_widget.dart';

class _FakeVideoPlayerController extends VideoPlayerController {
  _FakeVideoPlayerController({
    Duration duration = const Duration(seconds: 120),
    Duration position = const Duration(seconds: 40),
    bool isPlaying = true,
    bool isBuffering = false,
    double volume = 1.0,
    bool isLooping = false,
  }) : super.networkUrl(Uri.parse('https://example.com/video.mp4')) {
    value = value.copyWith(
      duration: duration,
      position: position,
      isInitialized: true,
      isPlaying: isPlaying,
      isBuffering: isBuffering,
      volume: volume,
      isLooping: isLooping,
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
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PlayerIcon & PlayerIconConfig Unit Tests', () {
    testWidgets('PlayerIcon.icon builds Icon with custom IconData, color, and size',
        (tester) async {
      const iconDef = PlayerIcon.icon(
        Icons.rocket_launch,
        color: Colors.amber,
        size: 32,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => iconDef.build(context),
            ),
          ),
        ),
      );

      final iconFinder = find.byIcon(Icons.rocket_launch);
      expect(iconFinder, findsOneWidget);
      final iconWidget = tester.widget<Icon>(iconFinder);
      expect(iconWidget.color, Colors.amber);
      expect(iconWidget.size, 32);
    });

    testWidgets('PlayerIcon.widget builds custom Widget (SVG / PNG / Custom container)',
        (tester) async {
      final iconDef = PlayerIcon.widget(
        Container(
          key: const Key('custom_svg_mock'),
          width: 24,
          height: 24,
          color: Colors.purple,
        ),
        size: 28,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => iconDef.build(context),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('custom_svg_mock')), findsOneWidget);
    });

    testWidgets('PlayerIcon.builder dynamically receives context, color, and size',
        (tester) async {
      final iconDef = PlayerIcon.builder(
        (context, color, size) => Container(
          key: const Key('dynamic_built_icon'),
          width: size,
          height: size,
          decoration: BoxDecoration(color: color),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => iconDef.build(
                context,
                defaultColor: Colors.teal,
                defaultSize: 30,
              ),
            ),
          ),
        ),
      );

      final containerFinder = find.byKey(const Key('dynamic_built_icon'));
      expect(containerFinder, findsOneWidget);
      final containerWidget = tester.widget<Container>(containerFinder);
      final decoration = containerWidget.decoration as BoxDecoration;
      expect(decoration.color, Colors.teal);
      expect(containerWidget.constraints?.maxWidth, 30);
    });

    test('PlayerIcon.asset creates Image.asset widget', () {
      final assetIcon = PlayerIcon.asset(
        'assets/icons/play.png',
        color: Colors.red,
        size: 24,
      );
      expect(assetIcon.widget, isA<Image>());
      expect(assetIcon.size, 24);
      expect(assetIcon.color, Colors.red);
    });

    testWidgets('PlayerIcon.resolve falls back to fallbackIcon when PlayerIcon is null',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => PlayerIcon.resolve(
                context,
                icon: null,
                fallbackIcon: Icons.play_arrow,
                defaultColor: Colors.cyan,
                defaultSize: 22,
              ),
            ),
          ),
        ),
      );

      final iconFinder = find.byIcon(Icons.play_arrow);
      expect(iconFinder, findsOneWidget);
      final iconWidget = tester.widget<Icon>(iconFinder);
      expect(iconWidget.color, Colors.cyan);
      expect(iconWidget.size, 22);
    });

    test('PlayerIconConfig copyWith preserves and overrides values', () {
      const config = PlayerIconConfig(
        playIcon: PlayerIcon.icon(Icons.play_circle),
      );
      final updated = config.copyWith(
        pauseIcon: const PlayerIcon.icon(Icons.pause_circle),
      );
      expect(updated.playIcon?.iconData, Icons.play_circle);
      expect(updated.pauseIcon?.iconData, Icons.pause_circle);
      expect(updated.stopIcon, isNull);
    });
  });

  group('PlayerStyleConfig & PlayerVisibilityConfig Options', () {
    test('PlayerStyleConfig has defaults and supports progress circle and volume customization', () {
      const style = PlayerStyleConfig();
      expect(style.progressBarThumbRadius, 6.0);
      expect(style.progressBarHoverThumbRadius, 7.5);
      expect(style.progressBarTrackHeight, 3.5);
      expect(style.progressBarHoverTrackHeight, 5.5);
      expect(style.progressBarOverlayRadius, 12.0);
      expect(style.showProgressBarThumb, isTrue);
      expect(style.loadingIndicatorStrokeWidth, 4.0);
      expect(style.volumeSliderThumbRadius, 5.5);
      expect(style.volumeSliderTrackHeight, 3.0);

      final custom = style.copyWith(
        progressBarThumbRadius: 10.0,
        progressBarHoverThumbRadius: 12.0,
        progressBarTrackHeight: 5.0,
        showProgressBarThumb: false,
        loadingIndicatorSize: 48.0,
        loadingIndicatorStrokeWidth: 6.0,
        volumeSliderActiveColor: Colors.green,
        volumeSliderThumbRadius: 8.0,
      );

      expect(custom.progressBarThumbRadius, 10.0);
      expect(custom.progressBarHoverThumbRadius, 12.0);
      expect(custom.progressBarTrackHeight, 5.0);
      expect(custom.showProgressBarThumb, isFalse);
      expect(custom.loadingIndicatorSize, 48.0);
      expect(custom.loadingIndicatorStrokeWidth, 6.0);
      expect(custom.volumeSliderActiveColor, Colors.green);
      expect(custom.volumeSliderThumbRadius, 8.0);
    });

    test('PlayerVisibilityConfig supports showStopButton', () {
      const vis = PlayerVisibilityConfig();
      expect(vis.showStopButton, isFalse);
      final withStop = vis.copyWith(showStopButton: true);
      expect(withStop.showStopButton, isTrue);
    });

    test('VideoConfig exposes icons getter', () {
      final videoConfig = VideoConfig(
        videoUrl: 'https://example.com/test.mp4',
        playerConfig: const PlayerConfig(
          style: PlayerStyleConfig(
            icons: PlayerIconConfig(
              playIcon: PlayerIcon.icon(Icons.play_circle_fill),
            ),
          ),
        ),
      );
      expect(videoConfig.icons.playIcon?.iconData, Icons.play_circle_fill);
    });
  });

  group('Widget Customization Tests (Adaptive Controls with Dynamic Icons)', () {
    testWidgets('AdaptiveBottomBar displays custom play/pause icons (PNG/SVG/Icon/builder)',
        (tester) async {
      final controller = _FakeVideoPlayerController(isPlaying: false);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveBottomBar(
              controller: controller,
              isFullScreen: false,
              styling: const PlayerStyleConfig(
                icons: PlayerIconConfig(
                  playIcon: PlayerIcon.icon(Icons.play_circle_filled, color: Colors.blue),
                  pauseIcon: PlayerIcon.icon(Icons.pause_circle_filled, color: Colors.red),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.play_circle_filled), findsOneWidget);

      // Change to playing state
      controller.value = controller.value.copyWith(isPlaying: true);
      await tester.pump();

      expect(find.byIcon(Icons.pause_circle_filled), findsOneWidget);

      await controller.dispose();
    });

    testWidgets('AdaptiveBottomBar displays and triggers dedicated Stop button when showStopButton is true',
        (tester) async {
      final controller = _FakeVideoPlayerController(
        isPlaying: true,
        position: const Duration(seconds: 45),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveBottomBar(
              controller: controller,
              isFullScreen: false,
              visibility: const PlayerVisibilityConfig(
                showStopButton: true,
              ),
              styling: const PlayerStyleConfig(
                icons: PlayerIconConfig(
                  stopIcon: PlayerIcon.icon(Icons.stop_circle_outlined, color: Colors.deepOrange),
                ),
              ),
            ),
          ),
        ),
      );

      final stopFinder = find.byIcon(Icons.stop_circle_outlined);
      expect(stopFinder, findsOneWidget);

      // Tap stop button
      await tester.tap(stopFinder);
      await tester.pump();

      // Controller should be paused and seeked to Duration.zero
      expect(controller.value.isPlaying, isFalse);
      expect(controller.value.position, Duration.zero);

      await controller.dispose();
    });

    testWidgets('AdaptiveBottomBar displays custom skip forward (+10s) and skip backward (-10s) icons',
        (tester) async {
      final controller = _FakeVideoPlayerController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveBottomBar(
              controller: controller,
              isFullScreen: false,
              showSkipButtons: true,
              visibility: const PlayerVisibilityConfig(showSkipButtons: true),
              styling: const PlayerStyleConfig(
                icons: PlayerIconConfig(
                  skipBackwardIcon: PlayerIcon.icon(Icons.fast_rewind_rounded),
                  skipForwardIcon: PlayerIcon.icon(Icons.fast_forward_rounded),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.fast_rewind_rounded), findsOneWidget);
      expect(find.byIcon(Icons.fast_forward_rounded), findsOneWidget);

      await controller.dispose();
    });

    testWidgets('AdaptiveVolumeControl displays custom voice / volume icons based on volume level',
        (tester) async {
      final controller = _FakeVideoPlayerController(volume: 0.0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveVolumeControl(
              controller: controller,
              styling: const PlayerStyleConfig(
                icons: PlayerIconConfig(
                  volumeMuteIcon: PlayerIcon.icon(Icons.volume_mute, color: Colors.red),
                  volumeLowIcon: PlayerIcon.icon(Icons.volume_down, color: Colors.yellow),
                  volumeHighIcon: PlayerIcon.icon(Icons.volume_up, color: Colors.green),
                ),
              ),
            ),
          ),
        ),
      );

      // Volume = 0 -> mute icon
      expect(find.byIcon(Icons.volume_mute), findsOneWidget);

      // Volume = 0.3 -> low icon
      controller.value = controller.value.copyWith(volume: 0.3);
      await tester.pump();
      expect(find.byIcon(Icons.volume_down), findsOneWidget);

      // Volume = 0.8 -> high icon
      controller.value = controller.value.copyWith(volume: 0.8);
      await tester.pump();
      expect(find.byIcon(Icons.volume_up), findsOneWidget);

      await controller.dispose();
    });

    testWidgets('AdaptiveProgressBar respects circle progress circle customization (thumb radius, shape, track height)',
        (tester) async {
      final controller = _FakeVideoPlayerController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveProgressBar(
              controller: controller,
              dragPosition: null,
              onDragChanged: (_) {},
              onDragEnd: (_) {},
              styling: const PlayerStyleConfig(
                progressBarPlayedColor: Colors.deepPurple,
                progressBarHandleColor: Colors.amber,
                progressBarThumbRadius: 9.0,
                progressBarTrackHeight: 6.0,
                progressBarBufferedColor: Colors.white60,
                progressBarBackgroundColor: Colors.black26,
              ),
            ),
          ),
        ),
      );

      final sliderThemeFinder = find.descendant(
        of: find.byType(AdaptiveProgressBar),
        matching: find.byType(SliderTheme),
      );
      expect(sliderThemeFinder, findsOneWidget);
      final sliderTheme = tester.widget<SliderTheme>(sliderThemeFinder);
      expect(sliderTheme.data.activeTrackColor, Colors.deepPurple);
      expect(sliderTheme.data.thumbColor, Colors.amber);
      expect(sliderTheme.data.trackHeight, 6.0);
      expect(sliderTheme.data.thumbShape, isA<RoundSliderThumbShape>());
      final thumb = sliderTheme.data.thumbShape as RoundSliderThumbShape;
      expect(thumb.enabledThumbRadius, 9.0);

      await controller.dispose();
    });

    testWidgets('AdaptiveProgressBar can hide thumb when showProgressBarThumb is false',
        (tester) async {
      final controller = _FakeVideoPlayerController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveProgressBar(
              controller: controller,
              dragPosition: null,
              onDragChanged: (_) {},
              onDragEnd: (_) {},
              styling: const PlayerStyleConfig(
                showProgressBarThumb: false,
              ),
            ),
          ),
        ),
      );

      final sliderThemeFinder = find.descendant(
        of: find.byType(AdaptiveProgressBar),
        matching: find.byType(SliderTheme),
      );
      final sliderTheme = tester.widget<SliderTheme>(sliderThemeFinder);
      final thumb = sliderTheme.data.thumbShape as RoundSliderThumbShape;
      expect(thumb.enabledThumbRadius, 0.0);

      await controller.dispose();
    });

    testWidgets('AdaptiveBufferingIndicator respects loading indicator circle stroke width, color, and size',
        (tester) async {
      final controller = _FakeVideoPlayerController(isBuffering: true, isPlaying: true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveBufferingIndicator(
              controller: controller,
              styling: const PlayerStyleConfig(
                loadingIndicatorColor: Colors.tealAccent,
                loadingIndicatorStrokeWidth: 5.5,
                loadingIndicatorSize: 44.0,
              ),
            ),
          ),
        ),
      );

      final indicatorFinder = find.byType(CircularProgressIndicator);
      expect(indicatorFinder, findsOneWidget);
      final indicator = tester.widget<CircularProgressIndicator>(indicatorFinder);
      expect(indicator.color, Colors.tealAccent);
      expect(indicator.strokeWidth, 5.5);

      final sizedBoxFinder = find.ancestor(
        of: indicatorFinder,
        matching: find.byType(SizedBox),
      );
      expect(sizedBoxFinder, findsWidgets);
      final sizedBox = tester.widget<SizedBox>(sizedBoxFinder.first);
      expect(sizedBox.width, 44.0);
      expect(sizedBox.height, 44.0);

      await controller.dispose();
    });

    testWidgets('NormalPlayerLoadingWidget uses custom loadingIndicatorBuilder when provided in PlayerStyleConfig',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NormalPlayerLoadingWidget(
              styling: PlayerStyleConfig(
                loadingIndicatorBuilder: (context) => const Text(
                  'CUSTOM_PROGRESS_CIRCLE',
                  key: Key('custom_loading_text'),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('custom_loading_text')), findsOneWidget);
    });

    testWidgets('AdaptiveCenterPlayPause uses custom PlayerIcon for play and pause',
        (tester) async {
      final controller = _FakeVideoPlayerController(isPlaying: false);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveCenterPlayPause(
              controller: controller,
              styling: const PlayerStyleConfig(
                icons: PlayerIconConfig(
                  playIcon: PlayerIcon.icon(Icons.play_circle),
                  pauseIcon: PlayerIcon.icon(Icons.pause_circle),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.play_circle), findsOneWidget);

      controller.value = controller.value.copyWith(isPlaying: true);
      await tester.pump();

      expect(find.byIcon(Icons.pause_circle), findsOneWidget);

      await controller.dispose();
    });

    testWidgets('AdaptiveFullscreenButton uses custom fullscreen and exitFullscreen icons',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdaptiveFullscreenButton(
              isFullScreen: false,
              styling: PlayerStyleConfig(
                icons: PlayerIconConfig(
                  fullscreenIcon: PlayerIcon.icon(Icons.fit_screen),
                  exitFullscreenIcon: PlayerIcon.icon(Icons.fullscreen_exit),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.fit_screen), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdaptiveFullscreenButton(
              isFullScreen: true,
              styling: PlayerStyleConfig(
                icons: PlayerIconConfig(
                  fullscreenIcon: PlayerIcon.icon(Icons.fit_screen),
                  exitFullscreenIcon: PlayerIcon.icon(Icons.fullscreen_exit),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.fullscreen_exit), findsOneWidget);
    });

    testWidgets('AdaptiveSettingsButton uses custom settingsIcon',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdaptiveSettingsButton(
              styling: PlayerStyleConfig(
                icons: PlayerIconConfig(
                  settingsIcon: PlayerIcon.icon(Icons.tune_rounded),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.tune_rounded), findsOneWidget);
    });

    testWidgets('NormalPlayerErrorWidget uses custom errorIcon from PlayerStyleConfig',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NormalPlayerErrorWidget(
              errorMessage: 'Failed to load video',
              styling: PlayerStyleConfig(
                icons: PlayerIconConfig(
                  errorIcon: PlayerIcon.icon(Icons.warning_amber_rounded),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      expect(find.text('Failed to load video'), findsOneWidget);
    });

    testWidgets('AdaptiveVolumeHudOverlay renders volume slider and custom voice icons',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                AdaptiveVolumeHudOverlay(
                  volume: 0.75,
                  isFullScreen: false,
                  styling: PlayerStyleConfig(
                    volumeSliderActiveColor: Colors.cyan,
                    icons: PlayerIconConfig(
                      volumeHighIcon: PlayerIcon.icon(Icons.surround_sound),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.surround_sound), findsOneWidget);
      expect(find.text('75%'), findsOneWidget);
    });

    testWidgets('AdaptiveInlineBottomBar renders unified capsule with inline slider, play, and fullscreen',
        (tester) async {
      final controller = _FakeVideoPlayerController(
        duration: const Duration(minutes: 4, seconds: 32),
        position: Duration.zero,
        isPlaying: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveInlineBottomBar(
              controller: controller,
              isFullScreen: false,
              isLive: false,
              styling: const PlayerStyleConfig(
                bottomBarLayout: BottomBarLayout.inline,
                controlsBackgroundColor: Color(0xFF1B313F),
                progressBarPlayedColor: Color(0xFF00A3FF),
                icons: PlayerIconConfig(
                  playIcon: PlayerIcon.icon(Icons.play_arrow_outlined),
                  fullscreenIcon: PlayerIcon.icon(Icons.crop_free_rounded),
                ),
              ),
              visibility: const PlayerVisibilityConfig(
                showVolumeButton: true,
                showFullscreenButton: true,
                showTimeDisplay: true,
                showProgressBar: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.play_arrow_outlined), findsOneWidget);
      expect(find.text('00:00'), findsOneWidget);
      expect(find.text('04:32'), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
      expect(find.byIcon(Icons.crop_free_rounded), findsOneWidget);

      // Tap play
      await tester.tap(find.byIcon(Icons.play_arrow_outlined));
      await tester.pump();
      expect(controller.value.isPlaying, isTrue);
    });
  });
}
