import 'package:adaptive_video_player/adaptive_video_player.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlayerDurationExtensions & IntDurationExtensions', () {
    test('formatTime formats minutes and seconds correctly', () {
      const dur = Duration(minutes: 3, seconds: 25);
      expect(dur.formatTime(), '03:25');
    });

    test('formatTime formats hours, minutes, and seconds correctly', () {
      const dur = Duration(hours: 1, minutes: 12, seconds: 40);
      expect(dur.formatTime(), '01:12:40');
    });

    test('remainingFrom calculates remaining time', () {
      const current = Duration(seconds: 40);
      const total = Duration(seconds: 100);
      expect(current.remainingFrom(total), const Duration(seconds: 60));
    });

    test('remainingFrom returns zero when current exceeds total', () {
      const current = Duration(seconds: 110);
      const total = Duration(seconds: 100);
      expect(current.remainingFrom(total), Duration.zero);
    });

    test('progressRatio calculates normalized progress from 0.0 to 1.0', () {
      const current = Duration(seconds: 50);
      const total = Duration(seconds: 100);
      expect(current.progressRatio(total), 0.5);
    });

    test('int extension formatAsDuration formats milliseconds', () {
      const ms = 65000;
      expect(ms.formatAsDuration(), '01:05');
    });
  });
}
