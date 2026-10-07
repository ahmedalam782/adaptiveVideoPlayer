import 'package:adaptive_video_player/adaptive_video_player.dart';
import 'package:adaptive_video_player/src/normal_video_player/mixins/normal_player_pip_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NormalPlayerSubtitlesMixin Tests', () {
    testWidgets('Subtitles mixin initializes and changes track correctly',
        (tester) async {
      const track1 = SubtitleTrack(
        id: 'en',
        title: 'English',
        content: '1\n00:00:01,000 --> 00:00:04,000\nHello World\n',
      );
      const track2 = SubtitleTrack(
        id: 'es',
        title: 'Spanish',
        content: '1\n00:00:01,000 --> 00:00:04,000\nHola Mundo\n',
      );

      final player = NormalVideoPlayer(
        videoSource: 'https://example.com/video.mp4',
        subtitles: const [track1, track2],
        initialSubtitle: track1,
      );

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: player)));
      final state =
          tester.state<NormalVideoPlayerState>(find.byType(NormalVideoPlayer));

      state.initSubtitles();
      await tester.pump();

      expect(state.currentSubtitleTrack, equals(track1));
      expect(state.parsedSubtitles.length, equals(1));
      expect(state.parsedSubtitles.first.text, equals('Hello World'));

      state.changeSubtitleTrack(track2);
      await tester.pump();

      expect(state.currentSubtitleTrack, equals(track2));
      expect(state.parsedSubtitles.first.text, equals('Hola Mundo'));

      state.changeSubtitleTrack(null);
      await tester.pump();

      expect(state.currentSubtitleTrack, isNull);
      expect(state.parsedSubtitles, isEmpty);
    });
  });

  group('NormalPlayerPipMixin Background Miniplayer Tests', () {
    test('disposeBackgroundMiniPlayer cleans up without throwing', () {
      expect(() => NormalPlayerPipMixin.disposeBackgroundMiniPlayer(),
          returnsNormally);
      expect(NormalPlayerPipMixin.activeBackgroundMiniEntry, isNull);
      expect(NormalPlayerPipMixin.activeBackgroundMiniController, isNull);
    });
  });

  group('NormalVideoPlayer Configuration Model Tests', () {
    testWidgets('NormalVideoPlayer initializes from VideoConfig model',
        (tester) async {
      const config = VideoConfig(
        videoUrl: 'https://example.com/test.mp4',
        isFile: false,
        isLive: true,
        viewerCount: '1.2k',
      );

      final player = NormalVideoPlayer(config: config);

      expect(player.config, equals(config));
      expect(player.videoSource, equals('https://example.com/test.mp4'));
      expect(player.isLive, isTrue);
      expect(player.viewerCount, equals('1.2k'));

      final fromConfigPlayer =
          const NormalVideoPlayer.fromConfig(config: config);
      expect(fromConfigPlayer.config, equals(config));
    });

    test('VideoConfig copyWith produces updated immutable copy', () {
      const original = VideoConfig(
        videoUrl: 'https://example.com/old.mp4',
        isLive: false,
      );

      final updated = original.copyWith(
        videoUrl: 'https://example.com/new.mp4',
        isLive: true,
      );

      expect(updated.videoUrl, equals('https://example.com/new.mp4'));
      expect(updated.isLive, isTrue);
      expect(original.videoUrl, equals('https://example.com/old.mp4'));
      expect(original.isLive, isFalse);
    });
  });
}
