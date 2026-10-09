import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_video_player/adaptive_video_player.dart';

void main() {
  group('AdaptiveVideoPreloader Tests', () {
    test('rejects empty or invalid URLs without throwing', () async {
      final resEmpty = await AdaptiveVideoPreloader.preload('');
      expect(resEmpty, isNull);

      final resInvalid = await AdaptiveVideoPreloader.preload('ftp://example.com/video.mp4');
      expect(resInvalid, isNull);

      expect(AdaptiveVideoPreloader.isPreloaded(''), isFalse);
    });

    test('isPreloaded and take return null for non-cached URLs', () {
      expect(AdaptiveVideoPreloader.isPreloaded('https://example.com/test.mp4'), isFalse);
      expect(AdaptiveVideoPreloader.take('https://example.com/test.mp4'), isNull);
    });

    test('disposeAll completes cleanly', () async {
      await expectLater(AdaptiveVideoPreloader.disposeAll(), completes);
    });
  });
}
