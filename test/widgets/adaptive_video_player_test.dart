import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_video_player/src/normal_video_player/models/video_config.dart';
import 'package:adaptive_video_player/src/youtube_player/models/youtube_player_config.dart';
import 'package:adaptive_video_player/src/youtube_player/utils/player_utils.dart';

void main() {
  group('VideoConfig Widget Configuration', () {
    test('creates config with YouTube URL', () {
      const config = VideoConfig(
        videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      );

      expect(config.videoUrl, contains('youtube.com'));
      expect(config.isFile, false);
      expect(config.videoBytes, null);
    });

    test('creates config with direct video URL', () {
      const config = VideoConfig(videoUrl: 'https://example.com/video.mp4');

      expect(config.videoUrl, endsWith('.mp4'));
      expect(config.isFile, false);
    });

    test('creates config with custom player configuration', () {
      const config = VideoConfig(
        videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        playerConfig: YouTubePlayerConfig(
          playback: PlayerPlaybackConfig(autoPlay: true, loop: true),
        ),
      );

      expect(config.playerConfig.playback.autoPlay, true);
      expect(config.playerConfig.playback.loop, true);
    });

    test('creates config for local file', () {
      const config = VideoConfig(videoUrl: '/path/to/video.mp4', isFile: true);

      expect(config.isFile, true);
      expect(config.videoUrl, startsWith('/'));
    });
  });

  group('Video Type Detection Logic', () {
    test('detects YouTube video from standard URL', () {
      const url = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
      final videoId = PlayerUtils.extractVideoId(url);

      expect(videoId, isNotNull);
      expect(videoId, 'dQw4w9WgXcQ');
    });

    test('detects YouTube video from youtu.be URL', () {
      const url = 'https://youtu.be/dQw4w9WgXcQ';
      final videoId = PlayerUtils.extractVideoId(url);

      expect(videoId, isNotNull);
      expect(videoId, 'dQw4w9WgXcQ');
    });

    test('returns null for direct video URL', () {
      const url = 'https://example.com/video.mp4';
      final videoId = PlayerUtils.extractVideoId(url);

      // Should not extract video ID from direct URLs
      expect(videoId, isNull);
    });

    test('returns null for local file path', () {
      const url = '/path/to/video.mp4';
      final videoId = PlayerUtils.extractVideoId(url);

      expect(videoId, isNull);
    });
  });

  group('Player Configuration', () {
    test('default playback config has correct values', () {
      const config = PlayerPlaybackConfig();

      expect(config.autoPlay, false);
      expect(config.loop, false);
      expect(config.mute, false);
      expect(config.forceHD, false);
      expect(config.enableCaption, false);
    });

    test('can customize playback settings', () {
      const config = PlayerPlaybackConfig(
        autoPlay: false,
        loop: true,
        mute: true,
      );

      expect(config.autoPlay, false);
      expect(config.loop, true);
      expect(config.mute, true);
    });

    test('style config has default colors', () {
      const config = PlayerStyleConfig();

      expect(config.iconColor, isNotNull);
      expect(config.textColor, isNotNull);
      expect(config.progressBarPlayedColor, isNotNull);
    });

    test('visibility config shows controls by default', () {
      const config = PlayerVisibilityConfig();

      expect(config.showSettingsButton, true);
      expect(config.showFullscreenButton, true);
    });
  });
}
