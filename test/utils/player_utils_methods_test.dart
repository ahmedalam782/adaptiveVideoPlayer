import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_video_player/src/youtube_player/utils/player_utils.dart';
import 'fake_webview_platform.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFakeWebViewPlatform();
  });

  group('PlayerUtils Methods', () {
    // ──────────── isYouTubeUrl ────────────
    group('isYouTubeUrl', () {
      test('identifies valid youtube URLs', () {
        expect(PlayerUtils.isYouTubeUrl('https://www.youtube.com/watch?v=dQw4w9WgXcQ'), true);
        expect(PlayerUtils.isYouTubeUrl('https://youtu.be/dQw4w9WgXcQ'), true);
        expect(PlayerUtils.isYouTubeUrl('https://youtube-nocookie.com/embed/dQw4w9WgXcQ'), true);
        expect(PlayerUtils.isYouTubeUrl('dQw4w9WgXcQ'), true);
      });

      test('identifies non-youtube URLs', () {
        expect(PlayerUtils.isYouTubeUrl('https://example.com/video.mp4'), false);
        expect(PlayerUtils.isYouTubeUrl('https://vimeo.com/12345'), false);
        expect(PlayerUtils.isYouTubeUrl(''), false);
      });
    });

    // ──────────── extractVideoId ────────────
    group('extractVideoId', () {
      test('extracts from standard watch url', () {
        expect(
          PlayerUtils.extractVideoId('https://www.youtube.com/watch?v=dQw4w9WgXcQ'),
          'dQw4w9WgXcQ',
        );
      });

      test('extracts from youtu.be short url', () {
        expect(
          PlayerUtils.extractVideoId('https://youtu.be/dQw4w9WgXcQ'),
          'dQw4w9WgXcQ',
        );
      });

      test('extracts from embed url', () {
        expect(
          PlayerUtils.extractVideoId('https://www.youtube.com/embed/dQw4w9WgXcQ'),
          'dQw4w9WgXcQ',
        );
      });

      test('extracts from shorts url', () {
        expect(
          PlayerUtils.extractVideoId('https://www.youtube.com/shorts/dQw4w9WgXcQ'),
          'dQw4w9WgXcQ',
        );
      });

      test('returns raw 11 character id', () {
        expect(
          PlayerUtils.extractVideoId('dQw4w9WgXcQ'),
          'dQw4w9WgXcQ',
        );
      });

      test('returns null for invalid url', () {
        expect(PlayerUtils.extractVideoId(''), isNull);
        expect(PlayerUtils.extractVideoId('https://example.com'), isNull);
      });
    });

    // ──────────── showSettings ────────────
    testWidgets('showSettings opens bottom sheet', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  PlayerUtils.showSettings(
                    context: context,
                    config: const PlayerSettingsConfig(
                      autoPlay: false,
                      loop: false,
                      forceHD: false,
                      enableCaption: false,
                      isMuted: false,
                    ),
                    onAutoPlayChanged: (_) async {},
                    onLoopChanged: (_) async {},
                    onForceHDChanged: (_) async {},
                    onEnableCaptionChanged: (_) async {},
                    onMutedChanged: (_) {},
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Player Settings'), findsOneWidget);
    });

    // ──────────── SystemChrome methods ────────────
    group('SystemChrome methods', () {
      test('hideSystemUI', () {
        PlayerUtils.hideSystemUI();
      });
      test('showSystemUI', () {
        PlayerUtils.showSystemUI();
      });
      test('setLandscapeOrientation', () {
        PlayerUtils.setLandscapeOrientation();
      });
      test('setPortraitOrientation', () {
        PlayerUtils.setPortraitOrientation();
      });
      test('setAllOrientations', () {
        PlayerUtils.setAllOrientations();
      });
    });
  });
}
