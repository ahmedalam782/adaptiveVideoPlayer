import 'package:adaptive_video_player/adaptive_video_player.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnalyticsService (SRP & DIP)', () {
    test('CallbackAnalyticsService forwards events to callback', () {
      final loggedEvents = <String, Map<String, dynamic>>{};

      final service = CallbackAnalyticsService((event, data) {
        loggedEvents[event] = data;
      });

      service.logEvent('video_played', {'position': 10});
      service.logEvent('video_ended');

      expect(loggedEvents.containsKey('video_played'), isTrue);
      expect(loggedEvents['video_played']?['position'], 10);
      expect(loggedEvents.containsKey('video_ended'), isTrue);
      expect(loggedEvents['video_ended'], isEmpty);
    });

    test('CallbackAnalyticsService handles null callback safely', () {
      final service = CallbackAnalyticsService();
      expect(() => service.logEvent('test_event'), returnsNormally);
    });
  });
}
