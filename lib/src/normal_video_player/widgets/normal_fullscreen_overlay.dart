import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Fullscreen overlay scaffold container for normal video player.
class NormalFullscreenOverlay extends StatelessWidget {
  final Widget child;
  final VoidCallback? onExitFullscreen;

  const NormalFullscreenOverlay({
    super.key,
    required this.child,
    this.onExitFullscreen,
  });

  @override
  Widget build(BuildContext context) {
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
            textDirection: TextDirection.ltr,
            child: SizedBox.expand(
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
