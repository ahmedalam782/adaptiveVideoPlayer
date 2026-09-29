import 'package:flutter/widgets.dart';

import '../contracts/i_video_player_controller.dart';
import '../di/player_scope.dart';
import '../models/player_state.dart';

/// Extension methods on [BuildContext] to simplify dependency resolution from [PlayerScope].
extension PlayerContextExtensions on BuildContext {
  /// Retrieve the active [IVideoPlayerController] from the nearest [PlayerScope]
  IVideoPlayerController get playerController => PlayerScope.controllerOf(this);

  /// Retrieve the active [PlayerState] from the nearest [PlayerScope]
  PlayerState get playerState => PlayerScope.stateOf(this);

  /// Optional retrieval of [PlayerScope] without throwing if absent
  PlayerScope? get maybePlayerScope => PlayerScope.maybeOf(this);
}
