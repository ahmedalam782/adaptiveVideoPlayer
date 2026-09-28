import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../normal_video_player/utils/fullscreen_utils_export.dart';
import 'youtube_webview_player_export.dart';

/// Fullscreen overlay and button manager for Desktop YouTube Player.
class YouTubeDesktopFullscreenManager {
  final BuildContext Function() getContext;
  final VoidCallback onStateChange;
  final GlobalKey<YouTubeWebViewPlayerState> desktopWebViewKey;

  OverlayEntry? _overlayEntry;
  bool _isInFullscreen = false;
  bool _isTransitioning = false;
  int currentPositionSeconds = 0;
  bool? wasPlaying;

  YouTubeDesktopFullscreenManager({
    required this.getContext,
    required this.onStateChange,
    required this.desktopWebViewKey,
  });

  bool get isInFullscreen => _isInFullscreen;

  Future<void> openFullscreen({
    required Widget Function() desktopPlayerBuilder,
  }) async {
    if (_isInFullscreen || _isTransitioning) return;
    _isTransitioning = true;

    final context = getContext();
    final overlay = Overlay.of(context);

    if (desktopWebViewKey.currentState != null) {
      try {
        final time = await desktopWebViewKey.currentState!.getCurrentTime();
        if (time != null && time > 0) {
          currentPositionSeconds = time;
        }
        wasPlaying = await desktopWebViewKey.currentState!.isPlaying();
      } catch (e) {
        log('Error reading player state before fullscreen: $e');
      }
    }

    _overlayEntry = OverlayEntry(
      builder: (ctx) {
        TextDirection effectiveDir = TextDirection.ltr;
        try {
          effectiveDir =
              Directionality.maybeOf(getContext()) ?? TextDirection.ltr;
        } catch (_) {}
        return Directionality(
          textDirection: effectiveDir,
          child: CallbackShortcuts(
            bindings: {
              const SingleActivator(LogicalKeyboardKey.escape): () {
                closeFullscreen();
              },
            },
            child: Focus(
              autofocus: true,
              child: Scaffold(
                backgroundColor: Colors.black,
                body: SizedBox.expand(
                  child: desktopPlayerBuilder(),
                ),
              ),
            ),
          ),
        );
      },
    );

    _isInFullscreen = true;
    overlay.insert(_overlayEntry!);
    onStateChange();
    enterBrowserFullscreen();

    if (wasPlaying == true) {
      Future.delayed(const Duration(milliseconds: 150), () {
        desktopWebViewKey.currentState?.play();
      });
    }

    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    Future.delayed(const Duration(milliseconds: 600), () {
      _isTransitioning = false;
    });
  }

  Future<void> closeFullscreen() async {
    if (!_isInFullscreen || _isTransitioning || _overlayEntry == null) return;
    _isTransitioning = true;

    bool shouldKeepPlaying = wasPlaying ?? false;
    if (desktopWebViewKey.currentState != null) {
      try {
        shouldKeepPlaying = await desktopWebViewKey.currentState!.isPlaying();
      } catch (_) {}
    }

    exitBrowserFullscreen();

    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    _overlayEntry = null;

    _isInFullscreen = false;
    onStateChange();

    if (desktopWebViewKey.currentState != null) {
      try {
        desktopWebViewKey.currentState?.exitFullscreen();
        if (shouldKeepPlaying) {
          Future.delayed(const Duration(milliseconds: 150), () {
            desktopWebViewKey.currentState?.play();
          });
        }
      } catch (e) {
        log('Error exiting native fullscreen: $e');
      }
    }

    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    Future.delayed(const Duration(milliseconds: 600), () {
      _isTransitioning = false;
    });
  }

  void dispose() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry?.dispose();
      _overlayEntry = null;
    }
  }

  Widget buildFullscreenButton({
    required bool isFullScreenMode,
    VoidCallback? onEnterFullscreen,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isFullScreenMode ? closeFullscreen : onEnterFullscreen,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            isFullScreenMode ? Icons.fullscreen_exit : Icons.fullscreen,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}
