import 'dart:async';

import 'package:flutter/material.dart';

import '../../youtube_player/models/youtube_player_config.dart';
import '../utils/video_player_web_safe.dart';
import 'adaptive_circular_percentage_loader.dart';

/// Buffering loading indicator overlay shown while the player is loading or buffering.
///
/// Includes debouncing to prevent high-frequency flickering when the underlying
/// platform backend repeatedly fires micro-buffering events.
class AdaptiveBufferingIndicator extends StatefulWidget {
  final VideoPlayerController controller;
  final PlayerStyleConfig? styling;
  final Duration debounceDuration;

  const AdaptiveBufferingIndicator({
    super.key,
    required this.controller,
    this.styling,
    this.debounceDuration = const Duration(milliseconds: 250),
  });

  @override
  State<AdaptiveBufferingIndicator> createState() =>
      _AdaptiveBufferingIndicatorState();
}

class _AdaptiveBufferingIndicatorState
    extends State<AdaptiveBufferingIndicator> {
  bool _showIndicator = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    final value = widget.controller.value;
    _showIndicator = value.isBuffering &&
        (value.isPlaying || value.position == Duration.zero);
    widget.controller.addListener(_onControllerUpdate);
  }

  @override
  void didUpdateWidget(AdaptiveBufferingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerUpdate);
      widget.controller.addListener(_onControllerUpdate);
      _checkBuffering();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    widget.controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

  void _onControllerUpdate() {
    _checkBuffering();
  }

  void _checkBuffering() {
    final value = widget.controller.value;
    final isBuffering = value.isBuffering &&
        (value.isPlaying || value.position == Duration.zero);

    if (isBuffering) {
      if (!_showIndicator && _debounceTimer == null) {
        _debounceTimer = Timer(widget.debounceDuration, () {
          if (mounted) {
            setState(() {
              _showIndicator = true;
            });
          }
        });
      }
    } else {
      _debounceTimer?.cancel();
      _debounceTimer = null;
      if (_showIndicator) {
        setState(() {
          _showIndicator = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_showIndicator) {
      return const SizedBox.shrink();
    }

    if (widget.styling?.loadingIndicatorBuilder != null) {
      return Center(
        child: widget.styling!.loadingIndicatorBuilder!(context),
      );
    }

    return Center(
      child: AdaptiveCircularPercentageLoader(
        controller: widget.controller,
        styling: widget.styling,
      ),
    );
  }
}


