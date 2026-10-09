import 'package:flutter/material.dart';

import '../normal_video_player.dart';
import '../utils/video_player_web_safe.dart';

/// Mixin handling playback state resilience across transitions (fullscreen,
/// orientation changes, and widget rebuilds) for [NormalVideoPlayer].
mixin NormalPlayerPlaybackResilienceMixin on State<NormalVideoPlayer> {
  Duration? heldPosition;
  bool heldPlaying = false;
  int holdGeneration = 0;
  int ensureGeneration = 0;

  /// The active controller to observe and restore.
  VideoPlayerController? get resilienceController;

  void holdPlayback() {
    final ctrl = resilienceController;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    heldPosition = ctrl.value.position;
    heldPlaying = ctrl.value.isPlaying;
  }

  /// Cancels any scheduled playback restorations or auto-continuation tasks.
  void cancelPlaybackResilience() {
    holdGeneration++;
    ensureGeneration++;
  }

  void resumeHeldPlayback() {
    final generation = ++holdGeneration;
    final held = heldPosition;
    final wasPlaying = heldPlaying;
    if (held == null && !wasPlaying) return;

    Future<void> restore() async {
      if (!mounted || generation != holdGeneration) return;
      final ctrl = resilienceController;
      if (ctrl == null || !ctrl.value.isInitialized) return;

      // Only restore held position if the controller lost its position and reset backwards
      // (e.g. dropped to 0 on orientation change).
      // If position has continued forward (ctrl.value.position >= held - 800ms), NEVER seek backwards!
      if (held != null &&
          held > const Duration(milliseconds: 500) &&
          ctrl.value.position < held - const Duration(milliseconds: 800)) {
        await ctrl.seekTo(held);
      }
      if (!mounted || generation != holdGeneration) return;
      if (wasPlaying && !ctrl.value.isPlaying) {
        await ctrl.play();
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => restore());
    for (final delay in const [120, 350, 700]) {
      Future.delayed(Duration(milliseconds: delay), restore);
    }
  }

  void ensurePlaybackContinues(bool wasPlaying) {
    if (!wasPlaying) return;
    final generation = ++ensureGeneration;

    void tryPlay() {
      if (!mounted || generation != ensureGeneration) return;
      final ctrl = resilienceController;
      if (ctrl != null && ctrl.value.isInitialized && !ctrl.value.isPlaying) {
        ctrl.play();
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => tryPlay());
    Future.delayed(const Duration(milliseconds: 150), tryPlay);
  }
}
