import 'package:adaptive_video_player/adaptive_video_player.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlayerControllerFactory (Strategy & Factory Pattern, OCP)', () {
    test('creates YouTube adapter for standard YouTube URL', () {
      const config = VideoConfig(
        videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      );

      final controller = PlayerControllerFactory.create(config);
      expect(controller, isA<YouTubePlayerAdapter>());
      final ytAdapter = controller as YouTubePlayerAdapter;
      expect(ytAdapter.videoId, 'dQw4w9WgXcQ');
    });

    test('creates YouTube adapter for short youtu.be URL', () {
      const config = VideoConfig(
        videoUrl: 'https://youtu.be/dQw4w9WgXcQ',
      );

      final controller = PlayerControllerFactory.create(config);
      expect(controller, isA<YouTubePlayerAdapter>());
    });

    test('allows registering and overriding with custom strategy (OCP)', () {
      const customPrefix = 'custom://';
      PlayerControllerFactory.registerStrategy(customPrefix, (config) {
        return YouTubePlayerAdapter(
          videoId: 'custom_id',
          config: config.playerConfig,
        );
      });

      const customConfig = VideoConfig(videoUrl: 'custom://stream/123');
      final controller = PlayerControllerFactory.create(customConfig);
      expect(controller, isA<YouTubePlayerAdapter>());
      expect((controller as YouTubePlayerAdapter).videoId, 'custom_id');

      PlayerControllerFactory.unregisterStrategy(customPrefix);
    });
  });
}
