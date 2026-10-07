import 'dart:async';
import 'package:flutter/material.dart';

import '../../core/constants/player_strings.dart';
import '../utils/youtube_web_export.dart';
import 'youtube_web_iframe_view.dart';

/// Chrome / YouTube styled Picture-in-Picture floating window for Flutter Web.
///
/// Features a dark rounded frame, official red YouTube badge, "youtube.com" domain,
/// window controls (minimize, back to tab, close), center replay/play/forward buttons,
/// and a bottom scrubber bar with time display, volume toggle, and caption controls.
class YouTubeWebPipOverlay extends StatefulWidget {
  final String viewId;
  final String videoId;
  final VoidCallback onExpand;
  final VoidCallback onClose;
  final void Function(Offset delta) onDrag;
  final bool initialMuted;
  final bool initialCaption;
  final String expandTooltip;
  final String closeTooltip;

  const YouTubeWebPipOverlay({
    super.key,
    required this.viewId,
    required this.videoId,
    required this.onExpand,
    required this.onClose,
    required this.onDrag,
    this.initialMuted = false,
    this.initialCaption = true,
    this.expandTooltip = PlayerStrings.expand,
    this.closeTooltip = PlayerStrings.close,
  });

  @override
  State<YouTubeWebPipOverlay> createState() => _YouTubeWebPipOverlayState();
}

class _YouTubeWebPipOverlayState extends State<YouTubeWebPipOverlay> {
  bool _isPlaying = true;
  bool _isMuted = false;
  bool _isCaptionEnabled = true;
  bool _isMinimized = false;
  bool _controlsVisible = true;

  double _currentTime = 0.0;
  double _duration = 180.0; // fallback duration until synced

  Timer? _hideTimer;
  Timer? _playbackTicker;

  @override
  void initState() {
    super.initState();
    _isMuted = widget.initialMuted;
    _isCaptionEnabled = widget.initialCaption;

    _scheduleHide();

    // Listen to real YouTube iframe postMessage events (infoDelivery)
    listenToYoutubeWebMessages(widget.viewId, ({
      currentTime,
      duration,
      playerState,
      isMuted,
    }) {
      if (!mounted) return;
      setState(() {
        if (currentTime != null) _currentTime = currentTime;
        if (duration != null && duration > 0) _duration = duration;
        if (playerState != null) {
          // 1: playing, 2: paused, 3: buffering, 0: ended
          _isPlaying = playerState == 1 || playerState == 3;
        }
        if (isMuted != null) _isMuted = isMuted;
      });
    });

    // Local smooth ticker for progress bar when playing
    _playbackTicker = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!mounted) return;
      if (_isPlaying && _currentTime < _duration) {
        setState(() {
          _currentTime = (_currentTime + 0.5).clamp(0.0, _duration);
        });
      }
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _playbackTicker?.cancel();
    super.dispose();
  }

  void _onUserActivity() {
    if (!mounted) return;
    if (!_controlsVisible) {
      setState(() {
        _controlsVisible = true;
      });
    }
    _scheduleHide();
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(milliseconds: 2800), () {
      if (mounted && _isPlaying && !_isMinimized) {
        setState(() {
          _controlsVisible = false;
        });
      }
    });
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      _controlsVisible = true;
    });
    sendYoutubeWebCommand(
      widget.viewId,
      _isPlaying ? 'playVideo' : 'pauseVideo',
    );
    _scheduleHide();
  }

  void _seekBy(double deltaSeconds) {
    final target = (_currentTime + deltaSeconds).clamp(0.0, _duration);
    setState(() {
      _currentTime = target;
      _controlsVisible = true;
    });
    sendYoutubeWebCommand(widget.viewId, 'seekTo', [target, true]);
    _scheduleHide();
  }

  void _seekTo(double target) {
    setState(() {
      _currentTime = target.clamp(0.0, _duration);
      _controlsVisible = true;
    });
    sendYoutubeWebCommand(widget.viewId, 'seekTo', [target, true]);
    _scheduleHide();
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _controlsVisible = true;
    });
    sendYoutubeWebCommand(widget.viewId, _isMuted ? 'mute' : 'unMute');
    _scheduleHide();
  }

  void _toggleCaption() {
    setState(() {
      _isCaptionEnabled = !_isCaptionEnabled;
      _controlsVisible = true;
    });
    // Toggle CC via iframe options
    sendYoutubeWebCommand(
      widget.viewId,
      _isCaptionEnabled ? 'loadModule' : 'unloadModule',
      ['captions'],
    );
    _scheduleHide();
  }

  void _skipPrevious() {
    _seekTo(0);
    sendYoutubeWebCommand(widget.viewId, 'previousVideo');
    _onUserActivity();
  }

  void _skipNext() {
    sendYoutubeWebCommand(widget.viewId, 'nextVideo');
    _onUserActivity();
  }

  String _formatTime(double seconds) {
    final totalSec = seconds.toInt();
    final m = (totalSec ~/ 60).toString();
    final s = (totalSec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    const windowWidth = 360.0;
    const windowHeight = 202.0;

    if (_isMinimized) {
      return Material(
        color: Colors.transparent,
        elevation: 16,
        borderRadius: BorderRadius.circular(10),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanUpdate: (details) => widget.onDrag(details.delta),
          child: Container(
            width: 230,
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF121212),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildYoutubeBadge(),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'youtube.com',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.none,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                  icon: Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                  ),
                  onPressed: _togglePlayPause,
                ),
                IconButton(
                  iconSize: 18,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                  icon: const Icon(Icons.aspect_ratio_rounded, color: Colors.white),
                  tooltip: 'Restore',
                  onPressed: () => setState(() => _isMinimized = false),
                ),
                IconButton(
                  iconSize: 18,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  tooltip: widget.closeTooltip,
                  onPressed: widget.onClose,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      elevation: 16,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: MouseRegion(
        onEnter: (_) => _onUserActivity(),
        onHover: (_) => _onUserActivity(),
        onExit: (_) {
          if (mounted && _isPlaying) {
            setState(() => _controlsVisible = false);
          }
        },
        child: Container(
          width: windowWidth,
          height: windowHeight,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.65),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. YouTube Iframe Video
              YouTubeWebIframeView(
                key: ValueKey(widget.viewId),
                viewId: widget.viewId,
              ),

              // 2. Transparent hit layer over video to capture hover and tap gestures on Web
              Positioned(
                top: 38,
                bottom: 50,
                left: 0,
                right: 0,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (!_controlsVisible) {
                      _onUserActivity();
                    } else {
                      _togglePlayPause();
                    }
                  },
                  child: const ColoredBox(
                    color: Colors.transparent,
                  ),
                ),
              ),

              // 3. Top Title Bar (Draggable)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 38,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanUpdate: (details) => widget.onDrag(details.delta),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.82),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        _buildYoutubeBadge(),
                        const SizedBox(width: 8),
                        const Text(
                          'youtube.com',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const Spacer(),
                        // Minimize (_)
                        _buildHeaderButton(
                          icon: Icons.remove_rounded,
                          size: 18,
                          tooltip: 'Minimize',
                          onTap: () => setState(() => _isMinimized = true),
                        ),
                        const SizedBox(width: 4),
                        // Back to Tab / Restore (⧉)
                        _buildHeaderButton(
                          icon: Icons.open_in_new_rounded,
                          size: 16,
                          tooltip: widget.expandTooltip,
                          onTap: widget.onExpand,
                        ),
                        const SizedBox(width: 4),
                        // Close (X)
                        _buildHeaderButton(
                          icon: Icons.close_rounded,
                          size: 18,
                          tooltip: widget.closeTooltip,
                          onTap: widget.onClose,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 4. Center Play/Pause & 10s Skip Buttons (Chrome Style)
              Positioned(
                top: 45,
                bottom: 45,
                left: 20,
                right: 20,
                child: AnimatedOpacity(
                  opacity: _controlsVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: IgnorePointer(
                    ignoring: !_controlsVisible,
                    child: Align(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Replay 10s
                          _buildCircleActionButton(
                            icon: Icons.replay_10_rounded,
                            size: 26,
                            tooltip: '-10s',
                            onTap: () => _seekBy(-10),
                          ),
                          const SizedBox(width: 24),
                          // Center Play / Pause
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _togglePlayPause,
                            child: Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.55),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          // Forward 10s
                          _buildCircleActionButton(
                            icon: Icons.forward_10_rounded,
                            size: 26,
                            tooltip: '+10s',
                            onTap: () => _seekBy(10),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 5. Bottom Scrubber Bar & Controls (Chrome Style)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: AnimatedOpacity(
                  opacity: _controlsVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: IgnorePointer(
                    ignoring: !_controlsVisible,
                    child: Container(
                      padding: const EdgeInsets.only(
                        left: 8,
                        right: 8,
                        bottom: 6,
                        top: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.85),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Scrubber row with Previous | Slider | Next
                          Row(
                            children: [
                              _buildBottomIconButton(
                                icon: Icons.skip_previous_rounded,
                                size: 20,
                                tooltip: 'Previous',
                                onTap: _skipPrevious,
                              ),
                              Expanded(
                                child: SliderTheme(
                                  data: SliderThemeData(
                                    trackHeight: 3.0,
                                    activeTrackColor: const Color(0xFF8AB4F8),
                                    inactiveTrackColor:
                                        Colors.white.withValues(alpha: 0.25),
                                    thumbColor: const Color(0xFF8AB4F8),
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 5.0,
                                    ),
                                    overlayShape: const RoundSliderOverlayShape(
                                      overlayRadius: 10.0,
                                    ),
                                  ),
                                  child: Slider(
                                    value: _currentTime.clamp(
                                      0.0,
                                      _duration > 0 ? _duration : 1.0,
                                    ),
                                    min: 0.0,
                                    max: _duration > 0 ? _duration : 1.0,
                                    onChanged: (val) {
                                      setState(() => _currentTime = val);
                                    },
                                    onChangeEnd: _seekTo,
                                  ),
                                ),
                              ),
                              _buildBottomIconButton(
                                icon: Icons.skip_next_rounded,
                                size: 20,
                                tooltip: 'Next',
                                onTap: _skipNext,
                              ),
                            ],
                          ),
                          // Time & Action row
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              children: [
                                Text(
                                  '${_formatTime(_currentTime)} / ${_formatTime(_duration)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                                const Spacer(),
                                _buildBottomIconButton(
                                  icon: _isMuted
                                      ? Icons.volume_off_rounded
                                      : Icons.volume_up_rounded,
                                  size: 19,
                                  tooltip: _isMuted ? 'Unmute' : 'Mute',
                                  onTap: _toggleMute,
                                ),
                                const SizedBox(width: 4),
                                _buildBottomIconButton(
                                  icon: Icons.closed_caption_rounded,
                                  size: 19,
                                  color: _isCaptionEnabled
                                      ? const Color(0xFF8AB4F8)
                                      : Colors.white,
                                  tooltip: 'Subtitles',
                                  onTap: _toggleCaption,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildYoutubeBadge() {
    return Container(
      width: 22,
      height: 16,
      decoration: BoxDecoration(
        color: const Color(0xFFFF0000),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Center(
        child: Icon(
          Icons.play_arrow_rounded,
          color: Colors.white,
          size: 13,
        ),
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required double size,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(icon, color: Colors.white, size: size),
          ),
        ),
      ),
    );
  }

  Widget _buildCircleActionButton({
    required IconData icon,
    required double size,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.45),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(icon, color: Colors.white, size: size),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomIconButton({
    required IconData icon,
    required double size,
    required String tooltip,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Icon(icon, color: color, size: size),
        ),
      ),
    );
  }
}
