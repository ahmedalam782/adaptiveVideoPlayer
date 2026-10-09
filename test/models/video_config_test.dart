import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_video_player/src/normal_video_player/models/video_config.dart';
import 'package:adaptive_video_player/src/youtube_player/models/youtube_player_config.dart';

void main() {
  group('VideoConfig', () {
    test('creates VideoConfig with required parameters', () {
      const config = VideoConfig(videoUrl: 'https://example.com/video.mp4');

      expect(config.videoUrl, 'https://example.com/video.mp4');
      expect(config.isFile, false);
      expect(config.videoBytes, null);
      expect(config.playerConfig, isA<YouTubePlayerConfig>());
    });

    test('creates VideoConfig with all parameters', () {
      final videoBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      const playerConfig = YouTubePlayerConfig(
        playback: PlayerPlaybackConfig(autoPlay: true),
      );

      final config = VideoConfig(
        videoUrl: '/path/to/video.mp4',
        isFile: true,
        videoBytes: videoBytes,
        playerConfig: playerConfig,
      );

      expect(config.videoUrl, '/path/to/video.mp4');
      expect(config.isFile, true);
      expect(config.videoBytes, videoBytes);
      expect(config.playerConfig, playerConfig);
    });

    test('convenience getters return correct values', () {
      const config = VideoConfig(
        videoUrl: 'https://example.com/video.mp4',
        playerConfig: YouTubePlayerConfig(
          style: PlayerStyleConfig(iconColor: Color(0xFF00FF00)),
          text: PlayerTextConfig(playerSettingsText: 'Custom Settings'),
          visibility: PlayerVisibilityConfig(showSettingsButton: false),
          playback: PlayerPlaybackConfig(autoPlay: true, loop: true),
        ),
      );

      expect(config.styling, config.playerConfig.style);
      expect(config.messages, config.playerConfig.text);
      expect(config.visibility, config.playerConfig.visibility);
      expect(config.playback, config.playerConfig.playback);
    });

    test('uses default YouTubePlayerConfig when not provided', () {
      const config = VideoConfig(videoUrl: 'https://example.com/video.mp4');

      expect(config.playerConfig.style.iconColor, Colors.white);
      expect(config.playerConfig.playback.autoPlay, false); // Default is false
      expect(config.playerConfig.visibility.showSettingsButton, true);
    });

    test('isFile defaults to false', () {
      const config = VideoConfig(videoUrl: 'https://example.com/video.mp4');
      expect(config.isFile, false);
    });

    test('videoBytes defaults to null', () {
      const config = VideoConfig(videoUrl: 'https://example.com/video.mp4');
      expect(config.videoBytes, null);
    });

    test('handles empty video URL', () {
      const config = VideoConfig(videoUrl: '');
      expect(config.videoUrl, '');
    });

    test('handles YouTube URL', () {
      const config = VideoConfig(
        videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      );
      expect(config.videoUrl, contains('youtube.com'));
    });

    test('handles local file path', () {
      const config = VideoConfig(
        videoUrl: '/path/to/local/video.mp4',
        isFile: true,
      );
      expect(config.isFile, true);
      expect(config.videoUrl, '/path/to/local/video.mp4');
    });

    test('enableCache defaults to false and copyWith updates it', () {
      const config = VideoConfig(videoUrl: 'https://example.com/video.mp4');
      expect(config.enableCache, false);

      final withCache = config.copyWith(enableCache: true);
      expect(withCache.enableCache, true);
    });
  });
}
