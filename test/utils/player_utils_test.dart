import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_video_player/src/youtube_player/utils/player_utils.dart';
import 'fake_webview_platform.dart';

void main() {
  setUpAll(() {
    registerFakeWebViewPlatform();
  });
  group('PlayerSettingsConfig', () {
    test('creates default PlayerSettingsConfig', () {
      const config = PlayerSettingsConfig(
        autoPlay: true,
        loop: false,
        forceHD: true,
        enableCaption: false,
        isMuted: false,
      );

      expect(config.autoPlay, true);
      expect(config.loop, false);
      expect(config.forceHD, true);
      expect(config.enableCaption, false);
      expect(config.isMuted, false);
      expect(config.showAutoPlaySetting, true);
    });

    test('copyWith updates fields', () {
      const config = PlayerSettingsConfig(
        autoPlay: false,
        loop: false,
        forceHD: false,
        enableCaption: false,
        isMuted: false,
      );

      final copy = config.copyWith(
        autoPlay: true,
        loop: true,
        forceHD: true,
        enableCaption: true,
        isMuted: true,
      );

      expect(copy.autoPlay, true);
      expect(copy.loop, true);
      expect(copy.forceHD, true);
      expect(copy.enableCaption, true);
      expect(copy.isMuted, true);
    });

    test('copyWith null fallbacks', () {
      const config = PlayerSettingsConfig(
        autoPlay: true,
        loop: false,
        forceHD: true,
        enableCaption: false,
        isMuted: true,
      );

      final copy = config.copyWith();

      expect(copy.autoPlay, config.autoPlay);
      expect(copy.loop, config.loop);
      expect(copy.forceHD, config.forceHD);
      expect(copy.enableCaption, config.enableCaption);
      expect(copy.isMuted, config.isMuted);
    });
  });

  group('PlayerUtils - extractVideoId', () {
    test('extracts video ID from standard YouTube URL', () {
      const url = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
      expect(PlayerUtils.extractVideoId(url), 'dQw4w9WgXcQ');
    });

    test('extracts video ID from shortened youtu.be URL', () {
      const url = 'https://youtu.be/dQw4w9WgXcQ';
      expect(PlayerUtils.extractVideoId(url), 'dQw4w9WgXcQ');
    });

    test('returns null for non-YouTube URL', () {
      const url = 'https://www.example.com/video.mp4';
      expect(PlayerUtils.extractVideoId(url), null);
    });

    test('returns null for valid URL pattern but empty', () {
      expect(PlayerUtils.extractVideoId(''), null);
    });
  });

  group('PlayerUtils - isYouTubeUrl', () {
    test('returns true for youtube.com', () {
      expect(PlayerUtils.isYouTubeUrl('youtube.com'), true);
      expect(PlayerUtils.isYouTubeUrl('HTTPS://YOUTUBE.COM/WATCH?V=XYZ'), true);
    });
    test('returns true for 11-char ID', () {
      expect(PlayerUtils.isYouTubeUrl('dQw4w9WgXcQ'), true);
    });
    test('returns false for generic URLs', () {
      expect(PlayerUtils.isYouTubeUrl('https://example.com/video.mp4'), false);
    });
  });
}
