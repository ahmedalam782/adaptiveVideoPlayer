import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// How much room the player surface has for its controls.
enum PlayerSurfaceTier {
  /// Phone, or a very small player box.
  phone,

  /// Tablet, or a desktop/web window sized like a tablet.
  tablet,

  /// Wide desktop or web window.
  desktop,
}

/// The normal player has two designs.
///
/// Phones use the mobile design. Tablets, Windows, and web use the window
/// design, including when that window is only tablet-sized.
PlayerSurfaceTier resolvePlayerSurfaceTier({
  required Size window,
  required Size player,
}) {
  final windowTier = _windowTier(window);
  if (windowTier == PlayerSurfaceTier.phone) return PlayerSurfaceTier.phone;
  if (windowTier == PlayerSurfaceTier.tablet) return PlayerSurfaceTier.tablet;

  if (!player.width.isFinite || !player.height.isFinite) {
    return PlayerSurfaceTier.desktop;
  }
  final playerLongest = math.max(player.width, player.height);
  if (playerLongest < 1100) return PlayerSurfaceTier.tablet;
  return PlayerSurfaceTier.desktop;
}

PlayerSurfaceTier _windowTier(Size window) {
  if (!window.width.isFinite ||
      !window.height.isFinite ||
      window.shortestSide <= 0) {
    return PlayerSurfaceTier.desktop;
  }
  final shortest = window.shortestSide;
  final longest = window.longestSide;
  if (shortest < 600) return PlayerSurfaceTier.phone;
  // iPad-class screens and desktop/web windows resized into that range.
  if (shortest <= 1100 && longest <= 1400) return PlayerSurfaceTier.tablet;
  if (longest < 1200) return PlayerSurfaceTier.tablet;
  return PlayerSurfaceTier.desktop;
}

/// Keeps fullscreen on the same design as the player that opened it.
class PlayerSurfaceScope extends InheritedWidget {
  final PlayerSurfaceTier tier;

  const PlayerSurfaceScope({
    super.key,
    required this.tier,
    required super.child,
  });

  static PlayerSurfaceTier? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<PlayerSurfaceScope>()
        ?.tier;
  }

  @override
  bool updateShouldNotify(PlayerSurfaceScope oldWidget) => tier != oldWidget.tier;
}

/// Uses a captured design when one is set, otherwise the live window size.
PlayerSurfaceTier playerSurfaceTierOf(BuildContext context, Size player) {
  return PlayerSurfaceScope.maybeOf(context) ??
      resolvePlayerSurfaceTier(
        window: MediaQuery.sizeOf(context),
        player: player,
      );
}
