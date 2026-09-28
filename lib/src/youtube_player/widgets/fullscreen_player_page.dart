import 'dart:async';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../cubit/youtube_player_cubit.dart';
import '../models/youtube_player_config.dart';
import '../utils/player_utils.dart';
import '../utils/youtube_settings_helper.dart';
import 'player_controls.dart';
import 'youtube_controls_overlay.dart';
import 'youtube_live_badge.dart';
import 'youtube_replay_overlay.dart';

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

  YoutubePlayerCubit get _cubit => widget.cubit;
  PlayerCubitState get _state => _cubit.state;

  @override
  void initState() {
    super.initState();
    PlayerUtils.hideSystemUI();
    _initController(shouldPlay: widget.startPlaying);
  }

  void _initController({Duration? startPosition, bool? shouldPlay}) {
    final targetPosition = startPosition ?? widget.initialPosition;
    final autoPlayState = shouldPlay ?? _state.autoPlay;

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

        if (value.playerState == PlayerState.playing && _videoEnded) {
          if (mounted) {
            setState(() {
              _videoEnded = false;
            });
          }
        }
      }
    });
  }

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

    PlayerUtils.showSystemUI();
    PlayerUtils.setPortraitOrientation();

    super.dispose();
  }

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
      onError: (e) => debugPrint('Seek forward error in fullscreen: $e'),
    );
  }

  void _seekBackward() {
    if (!_isControllerSafe) return;
    PlayerUtils.seekBackward(
      _controller!,
      onError: (e) => debugPrint('Seek backward error in fullscreen: $e'),
    );
  }

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
    YouTubeSettingsHelper.openSettingsSheet(
      context: context,
      config: widget.config,
      state: _state,
      cubit: _cubit,
      onReloadPlayer: _reloadPlayerWithSettings,
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

    final currentPosition = _currentPosition;
    final wasPlaying = PlayerUtils.isPlaying(_controller);

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

    await Future.delayed(const Duration(milliseconds: 200));

    if (!mounted) {
      setState(() => _isReloading = false);
      return;
    }

    _initController(startPosition: currentPosition);
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted && _controller != null && !_isDisposed) {
      if (_state.isMuted) {
        _controller!.mute();
      } else {
        _controller!.unMute();
      }
    }

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
        body: widget.config.loadingBuilder?.call(context) ??
            PlayerLoadingWidget(
              loadingIndicatorColor: widget.config.style.loadingIndicatorColor,
              backgroundColor: Colors.black,
            ),
      );
    }

    return ValueListenableBuilder<PlayerCubitState>(
      valueListenable: _cubit,
      builder: (context, state, _) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Directionality(
            textDirection: TextDirection.ltr,
            child: Stack(
              children: [
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
                                PositionedDirectional(
                                  top: 40,
                                  end: 16,
                                  child: widget.config.liveBadgeBuilder?.call(
                                        context,
                                        isLive: widget.isLive,
                                        viewerCount: widget.viewerCount,
                                      ) ??
                                      YouTubeLiveBadge(
                                        isLive: widget.isLive,
                                        viewerCount: widget.viewerCount,
                                      ),
                                ),
                                PositionedDirectional(
                                  top: 40,
                                  start: 16,
                                  child: GestureDetector(
                                    onTap: _exitFullscreen,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.black
                                            .withValues(alpha: 0.6),
                                        borderRadius:
                                            BorderRadius.circular(25),
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
                if (_videoEnded)
                  widget.config.replayBuilder?.call(context, _restartVideo) ??
                      YouTubeReplayOverlay(
                        onRestart: _restartVideo,
                        iconColor: widget.config.style.iconColor,
                        iconSize: 56,
                      ),
              ],
            ),
          ),
        );
      },
    );
  }
}
