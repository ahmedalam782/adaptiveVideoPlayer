import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart'
    hide FullscreenButton;
import 'package:adaptive_video_player/src/youtube_player/widgets/youtube_controls_overlay.dart';
import 'package:adaptive_video_player/src/youtube_player/models/youtube_player_config.dart';

class MockYoutubePlayerController extends Mock
    implements YoutubePlayerController {}

void main() {
  late MockYoutubePlayerController controller;
  late StreamController<YoutubePlayerValue> valueStreamController;

  setUp(() {
    controller = MockYoutubePlayerController();
    valueStreamController = StreamController<YoutubePlayerValue>.broadcast();

    when(() => controller.value).thenReturn(
      YoutubePlayerValue(
        playerState: PlayerState.playing,
      ),
    );
    when(() => controller.videoStateStream).thenAnswer(
      (_) => const Stream<YoutubeVideoState>.empty(),
    );
    when(() => controller.metadata).thenReturn(
      const YoutubeMetaData(
        duration: Duration(minutes: 4, seconds: 32),
      ),
    );
    when(() => controller.listen(
          any(),
          onError: any(named: 'onError'),
          onDone: any(named: 'onDone'),
          cancelOnError: any(named: 'cancelOnError'),
        )).thenAnswer(
      (invocation) {
        final onData = invocation.positionalArguments[0]
            as void Function(YoutubePlayerValue)?;
        return valueStreamController.stream.listen(onData);
      },
    );
  });

  tearDown(() {
    valueStreamController.close();
  });

  Widget buildControls(YouTubePlayerConfig config) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 800,
          height: 450,
          child: CustomYoutubeControls(
            controller: controller,
            config: config,
            isMuted: false,
            onFullscreenTap: () {},
            onMuteTap: () {},
            onSeekBackward: () {},
            onSeekForward: () {},
          ),
        ),
      ),
    );
  }

  group('CustomYoutubeControls - BottomBarLayout.inline', () {
    testWidgets('hides center play button and renders inline capsule bar',
        (tester) async {
      final config = YouTubePlayerConfig(
        style: const PlayerStyleConfig(
          bottomBarLayout: BottomBarLayout.inline,
          controlsBackgroundColor: Color(0xFF1B313F),
          progressBarPlayedColor: Color(0xFF00A3FF),
        ),
        visibility: const PlayerVisibilityConfig(
          showCenterPlayPause: true,
          showVolumeButton: true,
          showFullscreenButton: true,
          showProgressBar: true,
          showTimeDisplay: true,
        ),
      );

      await tester.pumpWidget(buildControls(config));
      await tester.pump();

      // Verify the unified rounded capsule container is present
      final containerFinder = find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).color == const Color(0xFF1B313F) &&
            (w.decoration as BoxDecoration).borderRadius ==
                BorderRadius.circular(16),
      );
      expect(containerFinder, findsOneWidget);

      // Verify inline play/pause icon is present in the bar
      expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
    });

    testWidgets('shows center play button when youtubePills layout and enabled',
        (tester) async {
      final config = const YouTubePlayerConfig(
        style: PlayerStyleConfig(
          bottomBarLayout: BottomBarLayout.youtubePills,
        ),
        visibility: PlayerVisibilityConfig(
          showCenterPlayPause: true,
        ),
      );

      await tester.pumpWidget(buildControls(config));
      await tester.pump();

      // In youtubePills layout with showCenterPlayPause: true,
      // center button container (58x58 with circle) is rendered
      final centerButtonFinder = find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.constraints?.maxWidth == 58 &&
            w.constraints?.maxHeight == 58,
      );
      expect(centerButtonFinder, findsOneWidget);
    });

    testWidgets('hides center play button when showCenterPlayPause is false',
        (tester) async {
      final config = const YouTubePlayerConfig(
        style: PlayerStyleConfig(
          bottomBarLayout: BottomBarLayout.youtubePills,
        ),
        visibility: PlayerVisibilityConfig(
          showCenterPlayPause: false,
        ),
      );

      await tester.pumpWidget(buildControls(config));
      await tester.pump();

      final centerButtonFinder = find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.constraints?.maxWidth == 58 &&
            w.constraints?.maxHeight == 58,
      );
      expect(centerButtonFinder, findsNothing);
    });
  });
}
