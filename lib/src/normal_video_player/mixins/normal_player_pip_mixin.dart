import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../core/services/native_pip_service.dart';
import '../../youtube_player/models/player_text_config.dart';
import '../normal_video_player.dart';
import '../utils/fullscreen_utils_export.dart';
import '../utils/video_player_web_safe.dart';
import '../widgets/normal_mini_player_overlay.dart';

/// Mixin handling Picture-in-Picture (OS native and in-app floating mini-player) for [NormalVideoPlayer].
mixin NormalPlayerPipMixin on State<NormalVideoPlayer> {
  static OverlayEntry? activeBackgroundMiniEntry;
  static VideoPlayerController? activeBackgroundMiniController;

  static void disposeBackgroundMiniPlayer() {
    exitDesktopPipMode();
    activeBackgroundMiniEntry?.remove();
    activeBackgroundMiniEntry = null;
    activeBackgroundMiniController?.dispose();
    activeBackgroundMiniController = null;
  }

  OverlayEntry? miniPlayerOverlayEntry;
  bool transferredToBackgroundMini = false;
  bool? lastReportedPipPlaying;

  bool get isInMiniPlayer => miniPlayerOverlayEntry != null;

  VideoPlayerController? get activePipController;
  PlayerTextConfig resolveEffectiveMessages(BuildContext context);
  void onHoldPlayback();
  void onResumeHeldPlayback();
  void onEnsurePlaybackContinues(bool wasPlaying);

  void initPipListeners() {
    NativePipService.isInPip.addListener(_onNativePipModeChanged);
    NativePipService.pipAction.addListener(_onPipActionReceived);
  }

  void disposePipListeners() {
    NativePipService.isInPip.removeListener(_onNativePipModeChanged);
    NativePipService.pipAction.removeListener(_onPipActionReceived);
  }

  void _onNativePipModeChanged() {
    onHoldPlayback();
    if (mounted) {
      setState(() {});
      final ctrl = activePipController;
      if (NativePipService.isInPip.value && ctrl != null) {
        final currentPlaying = ctrl.value.isPlaying;
        lastReportedPipPlaying = currentPlaying;
        NativePipService.updatePlaybackState(isPlaying: currentPlaying);
      }
    }
    onResumeHeldPlayback();
  }

  void _onPipActionReceived() {
    if (!mounted) return;
    final action = NativePipService.pipAction.value;
    if (action == 'toggle_play') {
      final ctrl = activePipController;
      if (ctrl != null) {
        final isPlaying = ctrl.value.isPlaying;
        if (isPlaying) {
          ctrl.pause();
        } else {
          ctrl.play();
        }
        lastReportedPipPlaying = !isPlaying;
        NativePipService.updatePlaybackState(isPlaying: !isPlaying);
        if (mounted) setState(() {});
      }
    }
  }

  void handlePipControllerUpdate() {
    if (NativePipService.isInPip.value && activePipController != null) {
      final currentPlaying = activePipController!.value.isPlaying;
      if (lastReportedPipPlaying != currentPlaying) {
        lastReportedPipPlaying = currentPlaying;
        NativePipService.updatePlaybackState(isPlaying: currentPlaying);
      }
    }
  }

  void pipSeek(int seconds) {
    final ctrl = activePipController;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    var target = ctrl.value.position + Duration(seconds: seconds);
    if (target.isNegative) target = Duration.zero;
    final duration = ctrl.value.duration;
    if (duration > Duration.zero && target > duration) target = duration;
    ctrl.seekTo(target);
  }

  void openMiniPlayer() async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      final entered = await NativePipService.enterPip();
      if (entered) return;
    }
    if (!mounted) return;
    final ctrl = activePipController;
    if (isInMiniPlayer || ctrl == null) return;
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    // Clean up any older background mini-player before opening a new one
    disposeBackgroundMiniPlayer();

    final wasPlaying = ctrl.value.isPlaying;
    final initialMessages = resolveEffectiveMessages(context);
    final initialStyling = widget.styling;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (overlayCtx) {
        final effectiveMessages =
            mounted ? resolveEffectiveMessages(context) : initialMessages;
        final styling = mounted ? widget.styling : initialStyling;
        final activeCtrl =
            activePipController ?? activeBackgroundMiniController ?? ctrl;
        return NormalMiniPlayerOverlay(
          controller: activeCtrl,
          messages: effectiveMessages,
          styling: styling,
          onExpand: () {
            if (mounted) {
              closeMiniPlayer(pauseOnClose: false);
            } else {
              exitDesktopPipMode();
              entry.remove();
              if (activeBackgroundMiniEntry == entry) {
                activeBackgroundMiniEntry = null;
              }
            }
          },
          onClose: () {
            if (mounted) {
              closeMiniPlayer(pauseOnClose: true);
            } else {
              disposeBackgroundMiniPlayer();
            }
          },
        );
      },
    );
    miniPlayerOverlayEntry = entry;
    overlay.insert(entry);
    if (mounted) setState(() {});

    // Activate OS-level Picture-in-Picture (Windows always-on-top PiP window or Web native PiP)
    enterDesktopPipMode();
    entry.markNeedsBuild();

    if (wasPlaying) {
      onEnsurePlaybackContinues(true);
    } else {
      // Refresh current position frame for mobile texture attachment
      ctrl.seekTo(ctrl.value.position);
    }
    widget.onAnalyticsEvent?.call('mini_player_opened', {});
  }

  void closeMiniPlayer({bool pauseOnClose = false}) {
    if (!isInMiniPlayer) return;
    final wasPlaying = activePipController?.value.isPlaying ?? false;
    exitDesktopPipMode();
    miniPlayerOverlayEntry?.remove();
    miniPlayerOverlayEntry = null;
    if (pauseOnClose) {
      activePipController?.pause();
    } else {
      onEnsurePlaybackContinues(wasPlaying);
    }
    if (mounted) setState(() {});
    widget.onAnalyticsEvent
        ?.call('mini_player_closed', {'paused': pauseOnClose});
  }

  void handlePipDisposal(VoidCallback onStandardDispose) {
    disposePipListeners();
    if (isInMiniPlayer && activePipController != null) {
      // Keep mini-player and controller alive in background when page pops
      activeBackgroundMiniEntry = miniPlayerOverlayEntry;
      activeBackgroundMiniController = activePipController;
      miniPlayerOverlayEntry = null;
      transferredToBackgroundMini = true;
    } else if (!transferredToBackgroundMini) {
      miniPlayerOverlayEntry?.remove();
      miniPlayerOverlayEntry = null;
      onStandardDispose();
    }
  }
}
