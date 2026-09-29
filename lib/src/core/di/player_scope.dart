import 'package:flutter/widgets.dart';

import '../contracts/i_analytics_service.dart';
import '../contracts/i_fullscreen_service.dart';
import '../contracts/i_video_player_controller.dart';
import '../models/player_state.dart';

/// Flutter-native Dependency Injection Scope (InheritedWidget Pattern).
///
/// Injects [IVideoPlayerController], [IFullscreenService], and [IAnalyticsService]
/// down the widget subtree so that child widgets do not need tight parameter drilling.
class PlayerScope extends InheritedWidget {
  final IVideoPlayerController controller;
  final IFullscreenService? fullscreenService;
  final IAnalyticsService? analyticsService;

  const PlayerScope({
    super.key,
    required this.controller,
    this.fullscreenService,
    this.analyticsService,
    required super.child,
  });

  /// Retrieve the closest [PlayerScope] from the widget tree
  static PlayerScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<PlayerScope>();
    assert(scope != null, 'No PlayerScope found in context');
    return scope!;
  }

  /// Retrieve the closest [PlayerScope] without registering a dependency
  static PlayerScope? maybeOf(BuildContext context) {
    return context.getInheritedWidgetOfExactType<PlayerScope>();
  }

  /// Convenience getter for the controller
  static IVideoPlayerController controllerOf(BuildContext context) {
    return of(context).controller;
  }

  /// Convenience getter for the current state snapshot
  static PlayerState stateOf(BuildContext context) {
    return of(context).controller.state;
  }

  @override
  bool updateShouldNotify(PlayerScope oldWidget) {
    return controller != oldWidget.controller ||
        fullscreenService != oldWidget.fullscreenService ||
        analyticsService != oldWidget.analyticsService;
  }
}
