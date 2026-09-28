import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Fullscreen overlay scaffold container for normal video player.
class NormalFullscreenOverlay extends StatelessWidget {
  final Widget child;
  final VoidCallback? onExitFullscreen;
  final TextDirection? textDirection;

  const NormalFullscreenOverlay({
    super.key,
    required this.child,
    this.onExitFullscreen,
    this.textDirection,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveDirection =
        textDirection ?? Directionality.maybeOf(context) ?? TextDirection.ltr;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () {
          onExitFullscreen?.call();
        },
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Directionality(
            textDirection: effectiveDirection,
            child: SizedBox.expand(
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
