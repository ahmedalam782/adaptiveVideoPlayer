import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../cubit/youtube_player_cubit.dart';
import '../models/youtube_player_config.dart';
import '../utils/player_utils.dart';
import '../widgets/fullscreen_player_page.dart';

/// Coordinates fullscreen navigation and state synchronization for YouTube player.
class YouTubeFullscreenCoordinator {
  const YouTubeFullscreenCoordinator._();

  static Future<void> openFullScreen({
    required BuildContext context,
    required YoutubePlayerController controller,
    required String videoId,
    required Duration currentPosition,
    required YoutubePlayerCubit cubit,
    required YouTubePlayerConfig config,
    required bool isLive,
    required String? viewerCount,
    required VoidCallback? onEnded,
    required bool Function() isControllerSafe,
    required Future<void> Function({Duration? targetPosition}) onReloadPlayer,
    required void Function(bool ended) onVideoEndedChanged,
  }) async {
    final wasPlaying = PlayerUtils.isPlaying(controller);
    PlayerUtils.pause(controller);

    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    if (!context.mounted) return;

    final result = await Navigator.of(context).push<FullScreenResult>(
      PageRouteBuilder(
        opaque: true,
        pageBuilder: (ctx, animation, secondaryAnimation) {
          return FullScreenPlayerPage(
            videoId: videoId,
            initialPosition: currentPosition,
            startPlaying: wasPlaying,
            cubit: cubit,
            onEnded: onEnded,
            config: config,
            isLive: isLive,
            viewerCount: viewerCount,
          );
        },
        transitionsBuilder: (ctx, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );

    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    if (result == null || !context.mounted) return;

    try {
      final state = cubit.state;

      if (result.videoEnded) {
        onEnded?.call();
        if (result.isMuted != state.isMuted && isControllerSafe()) {
          cubit.setMuted(result.isMuted);
        }
        onVideoEndedChanged(true);
        return;
      }

      if (state.autoPlay != result.autoPlay) {
        cubit.setAutoPlay(result.autoPlay);
      }
      if (state.loop != result.loop) {
        cubit.setLoop(result.loop);
      }
      if (state.forceHD != result.forceHD) {
        cubit.setForceHD(result.forceHD);
      }
      if (state.enableCaption != result.enableCaption) {
        cubit.setEnableCaption(result.enableCaption);
      }

      if (result.isMuted != state.isMuted) {
        cubit.setMuted(result.isMuted);
      }

      await onReloadPlayer(targetPosition: result.position);
      if (isControllerSafe()) {
        PlayerUtils.setMute(controller, result.isMuted);
        if (result.wasPlaying) {
          PlayerUtils.play(controller);
        }
      }
    } catch (e) {
      log('Error syncing after fullscreen: $e');
    }
  }
}
