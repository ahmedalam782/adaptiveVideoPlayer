import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/video_config.dart';
import '../normal_video_player.dart';
import '../utils/file_utils_export.dart';
import '../utils/video_player_web_safe.dart';

/// Mixin handling VideoPlayerController initialization, URL validation, and seamless quality changes
/// for [NormalVideoPlayer].
mixin NormalPlayerControllerMixin on State<NormalVideoPlayer> {
  VideoPlayerController? videoPlayerController;
  bool isInitialized = false;
  bool hasError = false;
  String errorMessage = '';
  late final bool hasInMemoryData;
  late final bool useFileController;
  late String effectiveSource;
  VideoQuality? currentQuality;

  bool get effectiveIsLive => currentQuality?.isLive ?? widget.isLive;

  void initControllerState() {
    currentQuality = widget.initialQuality ?? widget.qualities?.firstOrNull;
    hasInMemoryData = widget.videoBytes != null;
    updateEffectiveSource();
    useFileController = widget.isFile && !hasInMemoryData;
  }

  void syncQualityOnUpdate(NormalVideoPlayer oldWidget) {
    if (widget.qualities != null &&
        widget.qualities!.isNotEmpty &&
        currentQuality != null) {
      final oldList = oldWidget.qualities;
      final oldIndex = oldList != null ? oldList.indexOf(currentQuality!) : -1;
      if (oldIndex >= 0 && oldIndex < widget.qualities!.length) {
        currentQuality = widget.qualities![oldIndex];
      } else {
        final byUrl = widget.qualities!
            .where((q) =>
                q.url == currentQuality!.url &&
                q.isLive == currentQuality!.isLive)
            .firstOrNull;
        if (byUrl != null) {
          currentQuality = byUrl;
        }
      }
    }
  }

  void updateEffectiveSource() {
    if (hasInMemoryData) {
      effectiveSource =
          'data:video/mp4;base64,${base64Encode(widget.videoBytes!)}';
    } else if (currentQuality != null) {
      effectiveSource = currentQuality!.url;
    } else {
      effectiveSource = widget.videoSource;
    }
  }

  bool isValidVideoUrl(String url) {
    if (url.isEmpty) return false;
    if (url.startsWith('data:')) return true;

    if (useFileController) {
      return checkFileExists(url);
    }

    if (widget.extension != null) return true;

    try {
      final uri = Uri.parse(url);
      if (!uri.hasScheme || (uri.scheme != 'http' && uri.scheme != 'https')) {
        return false;
      }
      final path = uri.path.toLowerCase();
      if (path.contains('.')) {
        return VideoFileExtension.isSupported(path);
      }
      return true;
    } catch (e) {
      log('URL validation error: $e');
      return false;
    }
  }

  Future<void> changeQuality(
    VideoQuality newQuality, {
    required VoidCallback onPlaybackUpdate,
    required void Function(bool) onEnsurePlayback,
  }) async {
    if (currentQuality == newQuality || !mounted) return;

    setState(() {
      currentQuality = newQuality;
    });

    if (newQuality.url == effectiveSource) {
      return;
    }

    final currentPosition =
        videoPlayerController?.value.position ?? Duration.zero;
    final isPlaying = videoPlayerController?.value.isPlaying ?? false;
    final currentVolume = videoPlayerController?.value.volume ?? 1.0;
    final currentSpeed = videoPlayerController?.value.playbackSpeed ?? 1.0;
    final oldController = videoPlayerController;

    try {
      final isHls = widget.extension == VideoFileExtension.hls ||
          newQuality.url.contains('.m3u8');
      final isDash = widget.extension == VideoFileExtension.dash ||
          newQuality.url.contains('.mpd');
      final formatHint = isHls
          ? VideoFormat.hls
          : isDash
              ? VideoFormat.dash
              : null;

      final newController = useFileController
          ? getFileVideoController(newQuality.url)
          : VideoPlayerController.networkUrl(
              Uri.parse(newQuality.url),
              formatHint: formatHint,
              videoPlayerOptions: VideoPlayerOptions(
                allowBackgroundPlayback: true,
                mixWithOthers: true,
              ),
            );

      await newController.initialize();
      newController.addListener(onPlaybackUpdate);
      if (!newQuality.isLive && currentPosition > Duration.zero) {
        await newController.seekTo(currentPosition);
      }
      await newController.setVolume(currentVolume);
      if (currentSpeed != 1.0) {
        await newController.setPlaybackSpeed(currentSpeed);
      }
      if (widget.playback.loop) {
        await newController.setLooping(true);
      }
      if (isPlaying) {
        await newController.play();
      }

      if (mounted) {
        setState(() {
          videoPlayerController = newController;
          currentQuality = newQuality;
          effectiveSource = newQuality.url;
        });
      }

      oldController?.removeListener(onPlaybackUpdate);
      await oldController?.dispose();
    } catch (e) {
      log('Error during seamless quality change: $e');
      currentQuality = newQuality;
      updateEffectiveSource();
      await oldController?.dispose();
      await initializeVideo(
        startAt: currentPosition,
        wasPlaying: isPlaying,
        onPlaybackUpdate: onPlaybackUpdate,
        onEnsurePlayback: onEnsurePlayback,
      );
    }
  }

  Future<void> initializeVideo({
    Duration? startAt,
    bool wasPlaying = false,
    required VoidCallback onPlaybackUpdate,
    required void Function(bool) onEnsurePlayback,
  }) async {
    try {
      if (!isValidVideoUrl(effectiveSource)) {
        if (mounted) {
          setState(() {
            hasError = true;
            errorMessage = widget.messages.videoLoadFailedText;
          });
        } else {
          hasError = true;
          errorMessage = widget.messages.videoLoadFailedText;
        }
        return;
      }

      final bool isNetworkSource = !useFileController;
      if (isNetworkSource &&
          !effectiveSource.startsWith('data:') &&
          effectiveSource.startsWith('http://')) {
        log(
          'Warning: Using HTTP URL for video. Consider using HTTPS for production.',
        );
      }

      log(
        hasInMemoryData
            ? 'Playing in-memory video source'
            : 'Playing video from: $effectiveSource',
      );

      final isHls = widget.extension == VideoFileExtension.hls ||
          effectiveSource.contains('.m3u8');
      final isDash = widget.extension == VideoFileExtension.dash ||
          effectiveSource.contains('.mpd');
      final formatHint = isHls
          ? VideoFormat.hls
          : isDash
              ? VideoFormat.dash
              : null;

      videoPlayerController = useFileController
          ? getFileVideoController(effectiveSource)
          : VideoPlayerController.networkUrl(
              Uri.parse(effectiveSource),
              formatHint: formatHint,
              videoPlayerOptions: VideoPlayerOptions(
                allowBackgroundPlayback: true,
                mixWithOthers: true,
              ),
            );

      await videoPlayerController!.initialize();
      videoPlayerController!.addListener(onPlaybackUpdate);

      if (startAt != null && !effectiveIsLive) {
        await videoPlayerController!.seekTo(startAt);
      }

      if (widget.playback.loop) {
        await videoPlayerController!.setLooping(true);
      }

      if (widget.playback.isMuted) {
        await videoPlayerController!.setVolume(0.0);
      }

      final speed = widget.playback.playbackSpeed;
      if (speed != null && speed > 0) {
        await videoPlayerController!.setPlaybackSpeed(speed);
      }

      if (mounted) {
        setState(() {
          isInitialized = true;
          hasError = false;
        });
      }

      if (wasPlaying || widget.playback.autoPlay) {
        try {
          await videoPlayerController!.play();
        } catch (playError) {
          log('Unmuted autoplay blocked by browser, falling back to muted autoplay: $playError');
          try {
            await videoPlayerController!.setVolume(0.0);
            await videoPlayerController!.play();
          } catch (_) {}
        }
        onEnsurePlayback(true);
      }
    } catch (e) {
      log('Video player initialization error: $e');
      if (mounted) {
        setState(() {
          hasError = true;
          if (e is PlatformException) {
            final errorMsg = e.message ?? e.toString();
            if (errorMsg.contains('MediaCodec') ||
                errorMsg.contains('ExoPlaybackException') ||
                errorMsg.contains('MEDIA_ERR_SRC_NOT_SUPPORTED') ||
                errorMsg.contains('DEMUXER_ERROR') ||
                errorMsg.contains('not supported')) {
              errorMessage = widget.messages.videoNotCompatibleText;
            } else {
              errorMessage =
                  widget.messages.videoCannotBeLoadedSecurityPolicyText;
            }
          } else {
            errorMessage = widget.messages.videoLoadFailedText;
          }
        });
      }
    }
  }

  void handleControllerPlaybackUpdate(VoidCallback onPipUpdate) {
    if (!mounted || videoPlayerController == null) return;
    if (videoPlayerController!.value.hasError && !hasError) {
      final errorMsg = videoPlayerController!.value.errorDescription ?? '';
      log('Controller reported playback error: $errorMsg');
      setState(() {
        hasError = true;
        if (errorMsg.contains('MediaCodec') ||
            errorMsg.contains('ExoPlaybackException') ||
            errorMsg.contains('MEDIA_ERR_SRC_NOT_SUPPORTED') ||
            errorMsg.contains('DEMUXER_ERROR') ||
            errorMsg.contains('not supported')) {
          errorMessage = widget.messages.videoNotCompatibleText;
        } else {
          errorMessage = errorMsg.isNotEmpty
              ? errorMsg
              : widget.messages.videoLoadFailedText;
        }
      });
    }
    onPipUpdate();
  }
}
