import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../widgets/player_settings_helper.dart';

import '../models/player_settings_config.dart';

export '../models/player_settings_config.dart';

/// Utility functions for YouTube player operations
class PlayerUtils {
  /// Seeks forward by specified duration (default 10 seconds)
  ///
  /// [controller] - The YouTube player controller
  /// [seekDuration] - Duration to seek forward (default: 10 seconds)
  /// [onError] - Optional callback for error handling
  static void seekForward(
    YoutubePlayerController controller, {
    Duration seekDuration = const Duration(seconds: 10),
    void Function(dynamic error)? onError,
  }) async {
    try {
      final currentTimeSec = await controller.currentTime;
      final currentPos = Duration(seconds: currentTimeSec.round());
      final duration = controller.metadata.duration;
      final newPos = currentPos + seekDuration;
      controller.seekTo(
        seconds: (newPos > duration ? duration : newPos).inSeconds.toDouble(),
        allowSeekAhead: true,
      );
    } catch (e) {
      debugPrint('Seek forward error: $e');
      onError?.call(e);
    }
  }

  /// Seeks backward by specified duration (default 10 seconds)
  ///
  /// [controller] - The YouTube player controller
  /// [seekDuration] - Duration to seek backward (default: 10 seconds)
  /// [onError] - Optional callback for error handling
  static void seekBackward(
    YoutubePlayerController controller, {
    Duration seekDuration = const Duration(seconds: 10),
    void Function(dynamic error)? onError,
  }) async {
    try {
      final currentTimeSec = await controller.currentTime;
      final currentPos = Duration(seconds: currentTimeSec.round());
      final newPos = currentPos - seekDuration;
      controller.seekTo(
        seconds:
            (newPos.isNegative ? Duration.zero : newPos).inSeconds.toDouble(),
        allowSeekAhead: true,
      );
    } catch (e) {
      debugPrint('Seek backward error: $e');
      onError?.call(e);
    }
  }

  /// Toggles mute state
  ///
  /// [controller] - The YouTube player controller
  /// [isMuted] - Current mute state
  /// [onError] - Optional callback for error handling
  ///
  /// Returns the new mute state
  static bool toggleMute(
    YoutubePlayerController controller,
    bool isMuted, {
    void Function(dynamic error)? onError,
  }) {
    try {
      final newMuteState = !isMuted;
      if (newMuteState) {
        controller.mute();
      } else {
        controller.unMute();
      }
      return newMuteState;
    } catch (e) {
      debugPrint('Toggle mute error: $e');
      onError?.call(e);
      return isMuted;
    }
  }

  /// Sets mute state directly
  ///
  /// [controller] - The YouTube player controller
  /// [mute] - True to mute, false to unmute
  /// [onError] - Optional callback for error handling
  static void setMute(
    YoutubePlayerController controller,
    bool mute, {
    void Function(dynamic error)? onError,
  }) {
    try {
      if (mute) {
        controller.mute();
      } else {
        controller.unMute();
      }
    } catch (e) {
      debugPrint('Set mute error: $e');
      onError?.call(e);
    }
  }

  /// Gets current playback position safely
  /// Deprecated: since YoutubePlayerController 10.x doesn't cache position synchronously,
  /// it's recommended to subscribe to videoStateStream.
  static Duration getCurrentPosition(YoutubePlayerController? controller) {
    return Duration.zero;
  }

  /// Checks if player is currently playing
  ///
  /// [controller] - The YouTube player controller
  ///
  /// Returns true if playing, false otherwise
  static bool isPlaying(YoutubePlayerController? controller) {
    try {
      return controller?.value.playerState == PlayerState.playing;
    } catch (e) {
      debugPrint('Is playing check error: $e');
      return false;
    }
  }

  /// Checks if player is ready
  ///
  /// [controller] - The YouTube player controller
  ///
  /// Returns true if ready, false otherwise
  static bool isReady(YoutubePlayerController? controller) {
    try {
      if (controller == null) return false;
      return controller.value.playerState != PlayerState.unknown &&
          controller.metadata.videoId.isNotEmpty;
    } catch (e) {
      debugPrint('Is ready check error: $e');
      return false;
    }
  }

  /// Gets video duration safely
  ///
  /// [controller] - The YouTube player controller
  ///
  /// Returns video duration or Duration.zero if unavailable
  static Duration getDuration(YoutubePlayerController? controller) {
    try {
      return controller?.metadata.duration ?? Duration.zero;
    } catch (e) {
      debugPrint('Get duration error: $e');
      return Duration.zero;
    }
  }

  /// Seeks to a specific position
  ///
  /// [controller] - The YouTube player controller
  /// [position] - Target position to seek to
  /// [onError] - Optional callback for error handling
  static void seekTo(
    YoutubePlayerController controller,
    Duration position, {
    void Function(dynamic error)? onError,
  }) {
    try {
      final duration = controller.metadata.duration;
      Duration targetPosition = position;

      // Only clamp to duration if we have valid duration metadata
      if (duration.inSeconds > 0) {
        if (position > duration) {
          targetPosition = duration;
        }
      }

      if (targetPosition.isNegative) {
        targetPosition = Duration.zero;
      }

      debugPrint(
        'PlayerUtils.seekTo: Seeking to ${targetPosition.inSeconds}s (requested: ${position.inSeconds}s)',
      );
      controller.seekTo(
          seconds: targetPosition.inSeconds.toDouble(), allowSeekAhead: true);
    } catch (e) {
      debugPrint('Seek to error: $e');
      onError?.call(e);
    }
  }

  /// Plays the video safely
  ///
  /// [controller] - The YouTube player controller
  /// [onError] - Optional callback for error handling
  static void play(
    YoutubePlayerController? controller, {
    void Function(dynamic error)? onError,
  }) {
    try {
      controller?.playVideo();
    } catch (e) {
      debugPrint('Play error: $e');
      onError?.call(e);
    }
  }

  /// Pauses the video safely
  ///
  /// [controller] - The YouTube player controller
  /// [onError] - Optional callback for error handling
  static void pause(
    YoutubePlayerController? controller, {
    void Function(dynamic error)? onError,
  }) {
    try {
      controller?.pauseVideo();
    } catch (e) {
      debugPrint('Pause error: $e');
      onError?.call(e);
    }
  }

  /// Resets the player safely
  ///
  /// [controller] - The YouTube player controller
  /// [onError] - Optional callback for error handling
  static void reset(
    YoutubePlayerController? controller, {
    void Function(dynamic error)? onError,
  }) {
    try {
      controller?.stopVideo();
    } catch (e) {
      debugPrint('Reset error: $e');
      onError?.call(e);
    }
  }

  /// Loads a new video by ID
  ///
  /// [controller] - The YouTube player controller
  /// [videoId] - The YouTube video ID to load
  /// [onError] - Optional callback for error handling
  static void loadVideo(
    YoutubePlayerController? controller,
    String videoId, {
    void Function(dynamic error)? onError,
  }) {
    try {
      controller?.loadVideoById(videoId: videoId);
    } catch (e) {
      debugPrint('Load video error: $e');
      onError?.call(e);
    }
  }

  /// Sets playback rate
  ///
  /// [controller] - The YouTube player controller
  /// [rate] - Playback rate (0.25, 0.5, 1.0, 1.25, 1.5, 1.75, 2.0)
  /// [onError] - Optional callback for error handling
  static void setPlaybackRate(
    YoutubePlayerController? controller,
    double rate, {
    void Function(dynamic error)? onError,
  }) {
    try {
      controller?.setPlaybackRate(rate);
    } catch (e) {
      debugPrint('Set playback rate error: $e');
      onError?.call(e);
    }
  }

  /// Disposes controller safely
  ///
  /// [controller] - The YouTube player controller
  /// [onError] - Optional callback for error handling
  static void disposeController(
    YoutubePlayerController? controller, {
    void Function(dynamic error)? onError,
  }) {
    try {
      controller?.pauseVideo();
      controller?.close();
    } catch (e) {
      debugPrint('Dispose controller error: $e');
      onError?.call(e);
    }
  }

  /// Checks if the URL is a YouTube video or a YouTube video ID
  ///
  /// [url] - URL or video ID to check
  ///
  /// Returns true if it's a valid YouTube URL or video ID
  static bool isYouTubeUrl(String url) {
    final lowerUrl = url.toLowerCase();
    // Check for YouTube URLs
    if (lowerUrl.contains('youtube.com') ||
        lowerUrl.contains('youtu.be') ||
        lowerUrl.contains('youtube-nocookie.com')) {
      return true;
    }
    // Check if it's a YouTube video ID (11 characters, alphanumeric with dashes/underscores)
    if (url.length == 11 &&
        !url.contains('/') &&
        !url.contains('.') &&
        RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(url)) {
      return true;
    }
    return false;
  }

  /// Extracts video ID from YouTube URL
  ///
  /// [url] - YouTube URL or video ID
  ///
  /// Returns video ID or null if invalid
  static String? extractVideoId(String url) {
    try {
      String? videoId = YoutubePlayerController.convertUrlToId(url);
      if (videoId == null || videoId.isEmpty) {
        // Check if it's already a valid video ID (11 characters, no special chars)
        if (url.length == 11 && !url.contains('/') && !url.contains('.')) {
          return url;
        }
      }
      return videoId;
    } catch (e) {
      debugPrint('Extract video ID error: $e');
      return null;
    }
  }

  /// Shows the player settings bottom sheet
  ///
  /// [context] - BuildContext
  /// [config] - PlayerSettingsConfig with current settings
  /// [onAutoPlayChanged] - Callback when auto play setting changes
  /// [onLoopChanged] - Callback when loop setting changes
  /// [onForceHDChanged] - Callback when force HD setting changes
  /// [onEnableCaptionChanged] - Callback when enable caption setting changes
  /// [onMutedChanged] - Callback when muted setting changes
  static Future<void> showSettings({
    required BuildContext context,
    required PlayerSettingsConfig config,
    required Future<void> Function(bool) onAutoPlayChanged,
    required Future<void> Function(bool) onLoopChanged,
    required Future<void> Function(bool) onForceHDChanged,
    required Future<void> Function(bool) onEnableCaptionChanged,
    required void Function(bool) onMutedChanged,
  }) {
    return showPlayerSettingsSheet(
      context: context,
      autoPlay: config.autoPlay,
      loop: config.loop,
      forceHD: config.forceHD,
      enableCaption: config.enableCaption,
      isMuted: config.isMuted,
      settingsBackgroundColor: config.settingsBackgroundColor,
      settingItemBackgroundColor: config.settingItemBackgroundColor,
      iconColor: config.iconColor,
      textColor: config.textColor,
      switchInactiveThumbColor: config.switchInactiveThumbColor,
      switchInactiveTrackColor: config.switchInactiveTrackColor,
      titleTextStyle: config.settingsTitleStyle,
      itemTextStyle: config.settingItemTextStyle,
      textDirection: config.textDirection,
      playerSettingsText: config.playerSettingsText,
      autoPlayText: config.autoPlayText,
      loopVideoText: config.loopVideoText,
      forceHdQualityText: config.forceHdQualityText,
      enableCaptionsText: config.enableCaptionsText,
      muteAudioText: config.muteAudioText,
      showAutoPlaySetting: config.showAutoPlaySetting,
      showLoopSetting: config.showLoopSetting,
      showForceHDSetting: config.showForceHDSetting,
      showCaptionsSetting: config.showCaptionsSetting,
      showMuteSetting: config.showMuteSetting,
      onAutoPlayChanged: onAutoPlayChanged,
      onLoopChanged: onLoopChanged,
      onForceHDChanged: onForceHDChanged,
      onEnableCaptionChanged: onEnableCaptionChanged,
      onMutedChanged: onMutedChanged,
    );
  }

  /// Hides system UI for immersive fullscreen experience
  /// Should be called when entering fullscreen mode
  static Future<void> hideSystemUI() async {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [],
    );
  }

  /// Shows system UI when exiting fullscreen
  /// Should be called when returning to normal mode
  static Future<void> showSystemUI() async {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  /// Sets device orientation to landscape for fullscreen
  static Future<void> setLandscapeOrientation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  /// Sets device orientation to portrait for normal mode
  static Future<void> setPortraitOrientation() async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  /// Sets all orientations (allows both portrait and landscape)
  static Future<void> setAllOrientations() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  /// Initializes a YouTube player controller with the given settings
  ///
  /// [videoId] - The YouTube video ID
  /// [autoPlay] - Whether to auto-play the video
  /// [mute] - Whether to mute the video initially
  /// [loop] - Whether to loop the video
  /// [forceHD] - Whether to force HD quality
  /// [enableCaption] - Whether to enable captions
  /// [showControls] - Whether to show player controls
  /// [startAt] - Position to start playback (in seconds)
  ///
  /// Returns a new YoutubePlayerController instance
  static YoutubePlayerController createController({
    required String videoId,
    bool autoPlay = false,
    bool mute = false,
    bool loop = false,
    bool forceHD = true,
    bool enableCaption = true,
    bool showControls = true,
    int startAt = 0,
  }) {
    return YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: autoPlay,
      startSeconds: startAt.toDouble(),
      params: YoutubePlayerParams(
        showControls: showControls,
        showFullscreenButton: false, // Handled by our own controls overlay
        mute: mute,
        loop: loop,
        enableCaption: enableCaption,
      ),
    );
  }

  /// Verifies that the player position matches the target position
  /// and corrects it if the difference is significant
  ///
  /// [controller] - The YouTube player controller
  /// [targetPosition] - The expected position
  /// [tolerance] - Maximum acceptable difference in seconds (default: 3)
  ///
  /// Returns true if correction was needed and applied
  static Future<bool> verifyAndCorrectPosition(
    YoutubePlayerController? controller,
    Duration targetPosition, {
    int tolerance = 3,
  }) async {
    if (controller == null) return false;
    if (targetPosition.inSeconds == 0) return false;

    await Future.delayed(const Duration(milliseconds: 300));

    final currentTimeSec = await controller.currentTime;
    final currentPos = Duration(seconds: currentTimeSec.round());
    final difference = (currentPos.inSeconds - targetPosition.inSeconds).abs();

    debugPrint(
      'Position verification - current: ${currentPos.inSeconds}s, target: ${targetPosition.inSeconds}s, diff: $difference',
    );

    if (difference > tolerance) {
      debugPrint('Position off by $difference seconds, correcting');
      seekTo(controller, targetPosition);
      return true;
    }

    return false;
  }

  /// Safely checks if controller is ready for operations
  ///
  /// [controller] - The YouTube player controller
  /// [isDisposed] - Whether the controller has been disposed
  /// [mounted] - Whether the widget is still mounted
  ///
  /// Returns true if controller is safe to use
  static bool isControllerSafe(
    YoutubePlayerController? controller,
    bool isDisposed,
    bool mounted,
  ) {
    return controller != null && !isDisposed && mounted;
  }

  /// Handles video ended state with optional loop
  ///
  /// [controller] - The YouTube player controller
  /// [shouldLoop] - Whether to loop the video
  /// [onEnded] - Callback when video ends (if not looping)
  /// [isDisposed] - Whether controller is disposed
  /// [mounted] - Whether widget is mounted
  ///
  /// Returns true if video was restarted (looped), false if ended
  static Future<bool> handleVideoEnded({
    required YoutubePlayerController? controller,
    required bool shouldLoop,
    required bool isDisposed,
    required bool mounted,
    VoidCallback? onEnded,
  }) async {
    onEnded?.call();

    if (shouldLoop && !isDisposed && mounted && controller != null) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!isDisposed && mounted) {
        seekTo(controller, Duration.zero);
        play(controller);
        return true;
      }
    }

    return false;
  }

  /// Restarts video from the beginning
  /// Typically used when showing replay button after video ends
  ///
  /// [controller] - The YouTube player controller
  /// [onError] - Optional callback for error handling
  static void restartVideo(
    YoutubePlayerController? controller, {
    void Function(dynamic error)? onError,
  }) {
    try {
      if (controller == null) return;
      seekTo(controller, Duration.zero);
      play(controller);
    } catch (e) {
      debugPrint('Restart video error: $e');
      onError?.call(e);
    }
  }
}
