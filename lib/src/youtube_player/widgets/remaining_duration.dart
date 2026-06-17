import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../utils/duration_formatter.dart';

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
    final controller = widget.controller ?? YoutubePlayerControllerProvider.maybeOf(context);
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
        final duration = controller.metadata.duration;
        final remaining = duration - position;
        final remainingMs = remaining.isNegative ? 0 : remaining.inMilliseconds;
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Text(
            '- ${durationFormatter(remainingMs)}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}