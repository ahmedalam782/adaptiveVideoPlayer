import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'youtube_controls_overlay.dart';
import 'player_controls.dart';
import '../utils/player_utils.dart';
import '../models/player_config.dart';
import '../cubit/youtube_player_cubit.dart';

/// Fullscreen player page - pushed as a new route with its own controller
class FullScreenPlayerPage extends StatefulWidget {
  final String videoId;
  final Duration initialPosition;
  final bool startPlaying;
  final YoutubePlayerCubit cubit;
  final VoidCallback? onEnded;
  final YouTubePlayerConfig config;
  final bool isLive;
  final String? viewerCount;

  const FullScreenPlayerPage({
    super.key,
    required this.videoId,
    required this.initialPosition,
    required this.startPlaying,
    required this.cubit,
    required this.config,
    this.onEnded,
    this.isLive = false,
    this.viewerCount,
  });

  @override
  State<FullScreenPlayerPage> createState() => _FullScreenPlayerPageState();
}

class _FullScreenPlayerPageState extends State<FullScreenPlayerPage> {
  YoutubePlayerController? _controller;
  bool _isDisposed = false;
  bool _isReloading = false;
  bool _hasSeekToPosition = false;
  bool _videoEnded = false;
  Duration _currentPosition = Duration.zero;
  StreamSubscription<YoutubeVideoState>? _videoStateSub;
  StreamSubscription<YoutubePlayerValue>? _playerValueSub;

  // Access cubit for state management
  YoutubePlayerCubit get _cubit => widget.cubit;
  PlayerCubitState get _state => _cubit.state;

  @override
  void initState() {
    super.initState();

    // Hide system UI and set landscape for fullscreen
    PlayerUtils.hideSystemUI();
    // PlayerUtils.setLandscapeOrientation();

    _initController(shouldPlay: widget.startPlaying);
  }

  void _initController({Duration? startPosition, bool? shouldPlay}) {
    final targetPosition = startPosition ?? widget.initialPosition;
    final autoPlayState = shouldPlay ?? _state.autoPlay;

    debugPrint(
      'Fullscreen: Initializing with target position: ${targetPosition.inSeconds}s, autoPlay: $autoPlayState, muted: ${_state.isMuted}',
    );

    _controller = PlayerUtils.createController(
      videoId: widget.videoId,
      autoPlay: autoPlayState,
      mute: _state.isMuted,
      loop: _state.loop,
      forceHD: _state.forceHD,
      enableCaption: _state.enableCaption,
      showControls: true,
      startAt: targetPosition.inSeconds,
    );

    // Explicitly set mute state to ensure it's applied
    if (_state.isMuted) {
      _controller!.mute();
    } else {
      _controller!.unMute();
    }

    _videoStateSub?.cancel();
    _videoStateSub = _controller!.videoStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _currentPosition = state.position;
        });
      }
    });

    _playerValueSub?.cancel();
    _playerValueSub = _controller!.stream.listen((value) {
      if (!_isDisposed && mounted) {
        if (PlayerUtils.isReady(_controller) && !_hasSeekToPosition) {
          _hasSeekToPosition = true;
          // Run seek verification in background - don't block
          _verifyAndCorrectPosition(targetPosition);
        }

        if (value.playerState == PlayerState.ended) {
          PlayerUtils.handleVideoEnded(
            controller: _controller,
            shouldLoop: _state.loop,
            isDisposed: _isDisposed,
            mounted: mounted,
            onEnded: widget.onEnded,
          ).then((looped) {
            if (!looped && mounted) {
              setState(() {
                _videoEnded = true;
              });
            } else if (looped && mounted) {
              setState(() {
                _videoEnded = false;
              });
            }
          });
        }

        // Reset video ended flag when playing starts
        if (value.playerState == PlayerState.playing &&
            _videoEnded) {
          if (mounted) {
            setState(() {
              _videoEnded = false;
            });
          }
        }
      }
    });
  }

  /// Verifies position and corrects if needed (runs in background, doesn't block playback)
  Future<void> _verifyAndCorrectPosition(Duration targetPosition) async {
    if (_isDisposed || !mounted || _controller == null) return;
    await PlayerUtils.verifyAndCorrectPosition(_controller, targetPosition);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _videoStateSub?.cancel();
    _playerValueSub?.cancel();
    PlayerUtils.disposeController(_controller);
    _controller = null;

    // Restore system UI and orientation when exiting fullscreen
    PlayerUtils.showSystemUI();
    PlayerUtils.setPortraitOrientation();

    super.dispose();
  }

  /// Safely checks if the controller is ready for use
  bool get _isControllerSafe =>
      PlayerUtils.isControllerSafe(_controller, _isDisposed, mounted);

  void _toggleMute() {
    if (!_isControllerSafe) return;
    try {
      final newMuteState = PlayerUtils.toggleMute(_controller!, _state.isMuted);
      _cubit.setMuted(newMuteState);
    } catch (e) {
      debugPrint('Toggle mute error in fullscreen: $e');
    }
  }

  void _seekForward() {
    if (!_isControllerSafe) return;
    PlayerUtils.seekForward(
      _controller!,
      onError: (e) {
        debugPrint('Seek forward error in fullscreen: $e');
      },
    );
  }

  void _seekBackward() {
    if (!_isControllerSafe) return;
    PlayerUtils.seekBackward(
      _controller!,
      onError: (e) {
        debugPrint('Seek backward error in fullscreen: $e');
      },
    );
  }

  /// Restart video from beginning when video has ended
  void _restartVideo() {
    if (!_isControllerSafe) return;

    setState(() {
      _videoEnded = false;
    });

    PlayerUtils.restartVideo(_controller);
  }

  void _exitFullscreen() {
    if (_isDisposed) return;
    _isDisposed = true;

    // Get current state to return safely
    Duration position = Duration.zero;
    bool wasPlaying = false;
    bool videoEnded = false;

    try {
      position = _currentPosition;
      wasPlaying = PlayerUtils.isPlaying(_controller);
      videoEnded = _controller?.value.playerState == PlayerState.ended;
      PlayerUtils.pause(_controller);
    } catch (e) {
      debugPrint('Error getting state before exit fullscreen: $e');
    }

    Navigator.of(context).pop(
      FullScreenResult(
        position: position,
        wasPlaying: wasPlaying,
        isMuted: _state.isMuted,
        autoPlay: _state.autoPlay,
        loop: _state.loop,
        forceHD: _state.forceHD,
        enableCaption: _state.enableCaption,
        videoEnded: videoEnded,
      ),
    );
  }

  void _showSettingsBottomSheet() {
    PlayerUtils.showSettings(
      context: context,
      config: PlayerSettingsConfig(
        autoPlay: _state.autoPlay,
        loop: _state.loop,
        forceHD: _state.forceHD,
        enableCaption: _state.enableCaption,
        isMuted: _state.isMuted,
        settingsBackgroundColor: widget.config.style.settingsBackgroundColor,
        settingItemBackgroundColor:
            widget.config.style.settingItemBackgroundColor,
        iconColor: widget.config.style.iconColor,
        textColor: widget.config.style.textColor,
        switchInactiveThumbColor: widget.config.style.switchInactiveThumbColor,
        switchInactiveTrackColor: widget.config.style.switchInactiveTrackColor,
        playerSettingsText: widget.config.text.playerSettingsText,
        autoPlayText: widget.config.text.autoPlayText,
        loopVideoText: widget.config.text.loopVideoText,
        forceHdQualityText: widget.config.text.forceHdQualityText,
        enableCaptionsText: widget.config.text.enableCaptionsText,
        muteAudioText: widget.config.text.muteAudioText,
        showAutoPlaySetting: widget.config.visibility.showAutoPlaySetting,
        showLoopSetting: widget.config.visibility.showLoopSetting,
        showForceHDSetting: widget.config.visibility.showForceHDSetting,
        showCaptionsSetting: widget.config.visibility.showCaptionsSetting,
        showMuteSetting: widget.config.visibility.showMuteSetting,
        settingsTitleStyle: widget.config.style.settingsTitleStyle,
        settingItemTextStyle: widget.config.style.settingItemTextStyle,
      ),
      onAutoPlayChanged: (value) async {
        if (_state.autoPlay != value) {
          _cubit.setAutoPlay(value);
          await _reloadPlayerWithSettings();
        }
      },
      onLoopChanged: (value) async {
        if (_state.loop != value) {
          _cubit.setLoop(value);
          await _reloadPlayerWithSettings();
        }
      },
      onForceHDChanged: (value) async {
        if (_state.forceHD != value) {
          _cubit.setForceHD(value);
          await _reloadPlayerWithSettings();
        }
      },
      onEnableCaptionChanged: (value) async {
        if (_state.enableCaption != value) {
          _cubit.setEnableCaption(value);
          await _reloadPlayerWithSettings();
        }
      },
      onMutedChanged: (value) {
        if (_state.isMuted != value) {
          _cubit.setMuted(value);
          if (value) {
            _controller?.mute();
          } else {
            _controller?.unMute();
          }
        }
      },
    );
  }

  Future<void> _reloadPlayerWithSettings() async {
    if (_controller == null || _isDisposed || _isReloading) return;

    setState(() => _isReloading = true);

    // Save current state
    final currentPosition = _currentPosition;
    final wasPlaying = PlayerUtils.isPlaying(_controller);

    // Dispose old controller
    _isDisposed = true;
    _hasSeekToPosition = false;
    _videoStateSub?.cancel();
    _playerValueSub?.cancel();
    PlayerUtils.pause(_controller);
    PlayerUtils.disposeController(_controller);
    _controller = null;

    setState(() {
      _isDisposed = false;
    });

    // Wait for disposal to complete
    await Future.delayed(const Duration(milliseconds: 200));

    if (!mounted) {
      setState(() => _isReloading = false);
      return;
    }

    // Initialize new controller with new settings and current position
    _initController(startPosition: currentPosition);

    // Wait for player to be ready
    await Future.delayed(const Duration(milliseconds: 500));

    // Restore mute state explicitly
    if (mounted && _controller != null && !_isDisposed) {
      if (_state.isMuted) {
        _controller!.mute();
      } else {
        _controller!.unMute();
      }
    }

    // Restore playback state
    if (mounted && _controller != null && !_isDisposed && wasPlaying) {
      await Future.delayed(const Duration(milliseconds: 100));
      PlayerUtils.play(_controller);
    }

    if (mounted) {
      setState(() => _isReloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: PlayerLoadingWidget(
          loadingIndicatorColor: widget.config.style.loadingIndicatorColor,
          backgroundColor: Colors.black,
        ),
      );
    }

    return BlocBuilder<YoutubePlayerCubit, PlayerCubitState>(
      bloc: _cubit,
      builder: (context, state) {
        return Scaffold(
            backgroundColor: Colors.black,
            body: Directionality(
              textDirection: TextDirection.rtl,
              child: Stack(
                children: [
                  // Fullscreen YouTube Player
                  Center(
                    child: YoutubePlayer(
                      controller: _controller!,
                      builder: (context, player, controller) {
                        return Stack(
                          children: [
                            player,
                            CustomYoutubeControls(
                              controller: controller,
                              config: widget.config,
                              isLive: widget.isLive,
                              isMuted: state.isMuted,
                              isFullscreen: true,
                              onFullscreenTap: _exitFullscreen,
                              onMuteTap: _toggleMute,
                              onSettingsTap: _showSettingsBottomSheet,
                              onSeekBackward: _seekBackward,
                              onSeekForward: _seekForward,
                              topActions: Stack(
                                children: [
                                  if (widget.isLive || widget.viewerCount != null)
                                    Positioned(
                                      top: 40,
                                      right: 16,
                                      child: Row(
                                        children: [
                                          if (widget.isLive)
                                            Container(
                                              margin: const EdgeInsets.only(right: 8),
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 6, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    width: 6,
                                                    height: 6,
                                                    decoration: const BoxDecoration(
                                                      color: Colors.white,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  const Text('LIVE',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.bold)),
                                                ],
                                              ),
                                            ),
                                          if (widget.viewerCount != null)
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.black54,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.person,
                                                      color: Colors.white, size: 14),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    widget.viewerCount!,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  Positioned(
                                    top: 40,
                                    left: 16,
                                    child: GestureDetector(
                                      onTap: _exitFullscreen,
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.6),
                                          borderRadius: BorderRadius.circular(25),
                                        ),
                                        child: const Icon(
                                          Icons.arrow_back,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  // Replay overlay when video ended
                  if (_videoEnded)
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: _restartVideo,
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.6),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.7),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.replay,
                                color: widget.config.style.iconColor,
                                size: 56,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ));
      },
    );
  }
}
