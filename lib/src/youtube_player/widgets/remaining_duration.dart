import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../utils/duration_formatter.dart';

/// Shows the full video length, never a negative countdown.
class TotalDuration extends StatefulWidget {
  final YoutubePlayerController? controller;

  const TotalDuration({super.key, this.controller});

  @override
  State<TotalDuration> createState() => _TotalDurationState();
}

class _TotalDurationState extends State<TotalDuration> {
  YoutubePlayerController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller = widget.controller ??
        YoutubePlayerControllerProvider.maybeOf(context);
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) return const SizedBox.shrink();
    return StreamBuilder<YoutubeVideoState>(
      stream: controller.videoStateStream,
      initialData: const YoutubeVideoState(),
      builder: (context, snapshot) {
        final raw = controller.metadata.duration;
        final duration = raw.isNegative ? Duration.zero : raw;
        return Text(
          durationFormatter(duration.inMilliseconds),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.2,
          ),
        );
      },
    );
  }
}

/// A widget which displays the remaining duration of the video.
class RemainingDuration extends StatefulWidget {
  /// Overrides the default [YoutubePlayerController].
  final YoutubePlayerController? controller;

  /// Creates [RemainingDuration] widget.
  const RemainingDuration({super.key, this.controller});

  @override
  State<RemainingDuration> createState() => _RemainingDurationState();
}

class _RemainingDurationState extends State<RemainingDuration> {
  YoutubePlayerController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller =
        widget.controller ?? YoutubePlayerControllerProvider.maybeOf(context);
    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) {
      return const SizedBox.shrink();
    }
    return StreamBuilder<YoutubeVideoState>(
      stream: controller.videoStateStream,
      initialData: const YoutubeVideoState(),
      builder: (context, snapshot) {
        final position = snapshot.data?.position ?? Duration.zero;
        final rawDuration = controller.metadata.duration;
        final duration = rawDuration.isNegative ? Duration.zero : rawDuration;
        final remaining = duration - position;
        final remainingMs = remaining.isNegative ? 0 : remaining.inMilliseconds;
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Text(
            durationFormatter(remainingMs),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
        );
      },
    );
  }
}
