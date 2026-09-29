import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../models/player_state.dart';
import 'i_playback_controls.dart';
import 'i_quality_manageable.dart';
import 'i_subtitle_manageable.dart';
import 'i_volume_controls.dart';

/// Comprehensive contract for an abstract video player controller (DIP, ISP, OOP Abstraction).
///
/// Both Native video players and YouTube video players implement/adapt to this
/// common interface so that UI controls and business logic do not depend
/// on concrete player SDKs.
abstract class IVideoPlayerController
    implements
        IPlaybackControls,
        IVolumeControls,
        IQualityManageable,
        ISubtitleManageable {
  /// Reactive player state notifier (Observer Pattern)
  ValueListenable<PlayerState> get stateNotifier;

  /// Current snapshot of player state
  PlayerState get state;

  /// Initialize the player engine
  Future<void> initialize();

  /// Dispose any resources used by the player
  Future<void> dispose();

  /// Build the native or web video rendering widget (Polymorphic rendering)
  Widget buildVideoView(BuildContext context);
}
