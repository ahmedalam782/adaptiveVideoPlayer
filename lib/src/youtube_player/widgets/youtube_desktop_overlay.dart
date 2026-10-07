import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/player_strings.dart';
import '../../normal_video_player/utils/fullscreen_utils_export.dart';
import 'youtube_desktop_fullscreen_button.dart';
import 'youtube_desktop_pip_content.dart';
import 'youtube_webview_player_export.dart';

/// Fullscreen overlay and button manager for Desktop YouTube Player.
class YouTubeDesktopFullscreenManager {
  final BuildContext Function() getContext;
  final VoidCallback onStateChange;
  final GlobalKey<YouTubeWebViewPlayerState> desktopWebViewKey;

  OverlayEntry? _overlayEntry;
  OverlayEntry? _pipOverlayEntry;
  bool _isInFullscreen = false;
  bool _isInPip = false;
  bool _isTransitioning = false;
  int currentPositionSeconds = 0;
  bool? wasPlaying;

  YouTubeDesktopFullscreenManager({
    required this.getContext,
    required this.onStateChange,
    required this.desktopWebViewKey,
  });

  bool get isInFullscreen => _isInFullscreen;
  bool get isInPip => _isInPip;

  Future<void> _captureWebViewState() async {
    if (desktopWebViewKey.currentState != null) {
      try {
        final time = await desktopWebViewKey.currentState!.getCurrentTime();
        if (time != null && time > 0) {
          currentPositionSeconds = time;
        }
        wasPlaying = await desktopWebViewKey.currentState!.isPlaying();
      } catch (e) {
        log('Error reading YouTube player state: $e');
      }
    }
  }

  Future<void> openFullscreen({
    required Widget Function() desktopPlayerBuilder,
    TextDirection? textDirection,
  }) async {
    if (_isInFullscreen || _isTransitioning) return;
    final context = getContext();
    final overlay = Overlay.of(context, rootOverlay: true);
    final effectiveDirection =
        textDirection ?? Directionality.maybeOf(context) ?? TextDirection.ltr;

    if (_isInPip) {
      await closePip(pauseOnClose: false);
    }
    _isTransitioning = true;

    await _captureWebViewState();

    _overlayEntry = OverlayEntry(
      builder: (ctx) {
        return Directionality(
          textDirection: effectiveDirection,
          child: CallbackShortcuts(
            bindings: {
              const SingleActivator(LogicalKeyboardKey.escape): () {
                closeFullscreen();
              },
            },
            child: Focus(
              autofocus: true,
              child: PopScope(
                canPop: false,
                onPopInvokedWithResult: (didPop, result) {
                  if (didPop) return;
                  closeFullscreen();
                },
                child: Scaffold(
                  backgroundColor: Colors.black,
                  body: SizedBox.expand(
                    child: desktopPlayerBuilder(),
                  ),
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

    await _captureWebViewState();
    final shouldKeepPlaying = wasPlaying ?? false;

    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    _overlayEntry = null;

    _isInFullscreen = false;
    onStateChange();

    exitBrowserFullscreen();

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

  void markOverlaysNeedBuild() {
    _overlayEntry?.markNeedsBuild();
    _pipOverlayEntry?.markNeedsBuild();
  }

  Future<void> openPip({
    required Widget Function() desktopPlayerBuilder,
    String Function()? getExpandTooltip,
    String Function()? getCloseTooltip,
    TextDirection? textDirection,
    bool Function()? isPlaying,
    double Function()? progress,
    VoidCallback? onPlayPause,
    VoidCallback? onSeekBackward,
    VoidCallback? onSeekForward,
  }) async {
    if (_isInPip || _isTransitioning) return;
    final context = getContext();
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    final effectiveDirection =
        textDirection ?? Directionality.maybeOf(context) ?? TextDirection.ltr;

    if (_isInFullscreen) {
      await closeFullscreen();
    }
    _isTransitioning = true;

    await _captureWebViewState();

    _pipOverlayEntry = OverlayEntry(
      builder: (ctx) => _YouTubeDesktopPipOverlay(
        playerBuilder: desktopPlayerBuilder,
        onExpand: () => closePip(pauseOnClose: false),
        onClose: () => closePip(pauseOnClose: true),
        getExpandTooltip: getExpandTooltip,
        getCloseTooltip: getCloseTooltip,
        textDirection: effectiveDirection,
        isPlaying: isPlaying,
        progress: progress,
        onPlayPause: onPlayPause,
        onSeekBackward: onSeekBackward,
        onSeekForward: onSeekForward,
      ),
    );

    _isInPip = true;
    overlay.insert(_pipOverlayEntry!);
    onStateChange();
    enterDesktopPipMode();
    _pipOverlayEntry?.markNeedsBuild();

    if (wasPlaying == true || currentPositionSeconds == 0) {
      Future.delayed(const Duration(milliseconds: 250), () {
        desktopWebViewKey.currentState?.play();
        desktopWebViewKey.currentState?.unMute();
      });
    }

    Future.delayed(const Duration(milliseconds: 400), () {
      _isTransitioning = false;
    });
  }

  Future<void> closePip({bool pauseOnClose = false}) async {
    if (!_isInPip || _isTransitioning) return;
    _isTransitioning = true;

    await _captureWebViewState();
    if (pauseOnClose) {
      wasPlaying = false;
    }

    if (_pipOverlayEntry != null) {
      _pipOverlayEntry?.remove();
      _pipOverlayEntry?.dispose();
      _pipOverlayEntry = null;
    }
    _isInPip = false;
    onStateChange();

    exitDesktopPipMode();

    if (pauseOnClose) {
      Future.delayed(const Duration(milliseconds: 150), () {
        desktopWebViewKey.currentState?.pause();
      });
    } else if (wasPlaying == true) {
      Future.delayed(const Duration(milliseconds: 150), () {
        desktopWebViewKey.currentState?.play();
      });
    }

    Future.delayed(const Duration(milliseconds: 400), () {
      _isTransitioning = false;
    });
  }

  void dispose() {
    if (_isInPip) {
      exitDesktopPipMode();
      _pipOverlayEntry?.remove();
      _pipOverlayEntry?.dispose();
      _pipOverlayEntry = null;
      _isInPip = false;
    }
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
    return YouTubeDesktopFullscreenButton(
      isFullScreenMode: isFullScreenMode,
      onTap: isFullScreenMode ? closeFullscreen : (onEnterFullscreen ?? () {}),
    );
  }
}

class _YouTubeDesktopPipOverlay extends StatefulWidget {
  final Widget Function() playerBuilder;
  final VoidCallback onExpand;
  final VoidCallback onClose;
  final String Function()? getExpandTooltip;
  final String Function()? getCloseTooltip;
  final TextDirection? textDirection;
  final bool Function()? isPlaying;
  final double Function()? progress;
  final VoidCallback? onPlayPause;
  final VoidCallback? onSeekBackward;
  final VoidCallback? onSeekForward;

  const _YouTubeDesktopPipOverlay({
    required this.playerBuilder,
    required this.onExpand,
    required this.onClose,
    this.getExpandTooltip,
    this.getCloseTooltip,
    this.textDirection,
    this.isPlaying,
    this.progress,
    this.onPlayPause,
    this.onSeekBackward,
    this.onSeekForward,
  });

  @override
  State<_YouTubeDesktopPipOverlay> createState() =>
      _YouTubeDesktopPipOverlayState();
}

class _YouTubeDesktopPipOverlayState extends State<_YouTubeDesktopPipOverlay> {
  Offset _offset = Offset.zero;

  void _handleDrag(DragUpdateDetails details, bool isOsPipWindow) {
    if (isOsPipWindow) {
      moveDesktopPipWindow(
        details.delta.dx.round(),
        details.delta.dy.round(),
      );
    } else {
      setState(() {
        _offset += details.delta;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveDirection = widget.textDirection ??
        Directionality.maybeOf(context) ??
        TextDirection.ltr;
    final isRtl = effectiveDirection == TextDirection.rtl;
    final isOsPipWindow = isDesktopPipMode();
    final content = YouTubeDesktopPipContent(
      isOsPipWindow: isOsPipWindow,
      isPlaying: widget.isPlaying?.call() ?? false,
      progress: widget.progress?.call() ?? 0,
      closeTooltip:
          widget.getCloseTooltip?.call() ?? PlayerStrings.closeMiniPlayer,
      expandTooltip: widget.getExpandTooltip?.call() ?? PlayerStrings.expand,
      onClose: widget.onClose,
      onExpand: widget.onExpand,
      onPlayPause: widget.onPlayPause ?? () {},
      onSeekBackward: widget.onSeekBackward,
      onSeekForward: widget.onSeekForward,
      onDragUpdate: (details) => _handleDrag(details, isOsPipWindow),
      child: widget.playerBuilder(),
    );

    final pipContent = isOsPipWindow
        ? Scaffold(
            backgroundColor: Colors.black,
            body: SizedBox.expand(
              child: content,
            ),
          )
        : Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                left: isRtl ? (16 + _offset.dx) : null,
                right: isRtl ? null : (16 - _offset.dx),
                bottom: 24 - _offset.dy,
                child: content,
              ),
            ],
          );

    return Directionality(
      textDirection: effectiveDirection,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          widget.onExpand();
        },
        child: pipContent,
      ),
    );
  }
}
