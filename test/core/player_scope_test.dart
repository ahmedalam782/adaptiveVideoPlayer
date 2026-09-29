import 'package:adaptive_video_player/adaptive_video_player.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class MockPlayerController implements IVideoPlayerController {
  final ValueNotifier<PlayerState> _stateNotifier;

  MockPlayerController([PlayerState? state])
      : _stateNotifier = ValueNotifier(state ?? PlayerState.initial());

  @override
  PlayerState get state => _stateNotifier.value;

  @override
  ValueListenable<PlayerState> get stateNotifier => _stateNotifier;

  @override
  Widget buildVideoView(BuildContext context) => const Text('VideoView');

  @override
  Future<void> changeQuality(VideoQuality quality) async {}

  @override
  Future<void> changeSubtitle(SubtitleTrack? track) async {}

  @override
  VideoQuality? get currentQuality => null;

  @override
  SubtitleTrack? get currentSubtitle => null;

  @override
  Future<void> dispose() async {
    _stateNotifier.dispose();
  }

  @override
  Future<void> initialize() async {}

  @override
  Future<void> pause() async {
    _stateNotifier.value = _stateNotifier.value.copyWith(isPlaying: false);
  }

  @override
  Future<void> play() async {
    _stateNotifier.value = _stateNotifier.value.copyWith(isPlaying: true);
  }

  @override
  List<VideoQuality>? get qualities => null;

  @override
  Future<void> seekTo(Duration position) async {
    _stateNotifier.value = _stateNotifier.value.copyWith(position: position);
  }

  @override
  Future<void> setMute(bool mute) async {
    _stateNotifier.value = _stateNotifier.value.copyWith(isMuted: mute);
  }

  @override
  Future<void> setPlaybackSpeed(double speed) async {
    _stateNotifier.value = _stateNotifier.value.copyWith(playbackSpeed: speed);
  }

  @override
  Future<void> setVolume(double volume) async {
    _stateNotifier.value = _stateNotifier.value.copyWith(volume: volume);
  }

  @override
  List<SubtitleTrack>? get subtitles => null;

  @override
  Future<void> toggleMute() async {
    _stateNotifier.value = _stateNotifier.value.copyWith(isMuted: !_stateNotifier.value.isMuted);
  }
}

void main() {
  group('PlayerScope (Flutter DI Container & InheritedWidget)', () {
    testWidgets('provides controller and state down the widget tree', (tester) async {
      final mockController = MockPlayerController(
        const PlayerState(isPlaying: true, volume: 0.75),
      );

      late IVideoPlayerController foundController;
      late PlayerState foundState;

      await tester.pumpWidget(
        MaterialApp(
          home: PlayerScope(
            controller: mockController,
            child: Builder(
              builder: (context) {
                foundController = PlayerScope.controllerOf(context);
                foundState = PlayerScope.stateOf(context);
                return Text('Playing: ${foundState.isPlaying}');
              },
            ),
          ),
        ),
      );

      expect(foundController, equals(mockController));
      expect(foundState.isPlaying, isTrue);
      expect(foundState.volume, 0.75);
      expect(find.text('Playing: true'), findsOneWidget);

      await mockController.dispose();
    });

    testWidgets('maybeOf returns null when not in scope', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final scope = PlayerScope.maybeOf(context);
              return Text('Scope found: ${scope != null}');
            },
          ),
        ),
      );

      expect(find.text('Scope found: false'), findsOneWidget);
    });
  });
}
