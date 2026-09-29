import 'package:adaptive_video_player/adaptive_video_player.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlayerState and PlayerCubitState Extensions', () {
    test('UnifiedPlayerStateExtensions computes progress and remaining strings', () {
      const state = PlayerState(
        position: Duration(seconds: 30),
        duration: Duration(seconds: 120),
        isPlaying: true,
      );

      expect(state.remainingDuration, const Duration(seconds: 90));
      expect(state.progressRatio, 0.25);
      expect(state.formattedPosition, '00:30');
      expect(state.formattedDuration, '02:00');
      expect(state.formattedRemaining, '01:30');
    });

    test('PlayerCubitStateExtensions computes properties and converts to unified state', () {
      const cubitState = PlayerCubitState(
        position: Duration(seconds: 45),
        duration: Duration(seconds: 90),
        isPlaying: true,
        isMuted: true,
        errorMessage: 'Test error',
      );

      expect(cubitState.remainingDuration, const Duration(seconds: 45));
      expect(cubitState.progressRatio, 0.5);
      expect(cubitState.hasError, isTrue);
      expect(cubitState.formattedPosition, '00:45');
      expect(cubitState.formattedDuration, '01:30');

      final unified = cubitState.toUnifiedState(isLive: false);
      expect(unified.position, const Duration(seconds: 45));
      expect(unified.duration, const Duration(seconds: 90));
      expect(unified.isPlaying, isTrue);
      expect(unified.isMuted, isTrue);
      expect(unified.volume, 0.0);
      expect(unified.hasError, isTrue);
      expect(unified.errorMessage, 'Test error');
    });

    test('PlayerCubitState operator == and hashCode comparison', () {
      const state1 = PlayerCubitState(isPlaying: true, isMuted: false);
      const state2 = PlayerCubitState(isPlaying: true, isMuted: false);
      const state3 = PlayerCubitState(isPlaying: false, isMuted: false);

      expect(state1, equals(state2));
      expect(state1.hashCode, equals(state2.hashCode));
      expect(state1, isNot(equals(state3)));
    });
  });
}
