import 'package:adaptive_video_player/adaptive_video_player.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlayerState Model (OOP Encapsulation & Immutability)', () {
    test('initial factory sets default values', () {
      final state = PlayerState.initial(isLive: true);
      expect(state.position, Duration.zero);
      expect(state.duration, Duration.zero);
      expect(state.isPlaying, isFalse);
      expect(state.isLive, isTrue);
      expect(state.volume, 1.0);
      expect(state.isMuted, isFalse);
    });

    test('copyWith creates new instance with updated properties', () {
      final state = PlayerState.initial();
      final updated = state.copyWith(
        position: const Duration(seconds: 15),
        duration: const Duration(seconds: 100),
        isPlaying: true,
        volume: 0.8,
        isMuted: true,
        currentQuality: const VideoQuality(title: '1080p', url: 'https://example.com/1080'),
        currentSubtitle: const SubtitleTrack(id: 'en', title: 'English'),
      );

      expect(updated.position, const Duration(seconds: 15));
      expect(updated.duration, const Duration(seconds: 100));
      expect(updated.isPlaying, isTrue);
      expect(updated.volume, 0.8);
      expect(updated.isMuted, isTrue);
      expect(updated.currentQuality?.title, '1080p');
      expect(updated.currentSubtitle?.id, 'en');
    });

    test('value equality and hashCode comparison', () {
      const state1 = PlayerState(isPlaying: true, volume: 0.5);
      const state2 = PlayerState(isPlaying: true, volume: 0.5);
      const state3 = PlayerState(isPlaying: false, volume: 0.5);

      expect(state1, equals(state2));
      expect(state1.hashCode, equals(state2.hashCode));
      expect(state1, isNot(equals(state3)));
    });
  });
}
