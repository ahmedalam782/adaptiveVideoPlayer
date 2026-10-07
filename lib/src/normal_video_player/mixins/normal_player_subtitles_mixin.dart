import 'dart:developer';

import 'package:flutter/material.dart';

import '../models/video_config.dart';
import '../normal_video_player.dart';
import '../utils/subtitle_parser.dart';

/// Mixin handling subtitle tracks and subtitle parsing for [NormalVideoPlayer].
mixin NormalPlayerSubtitlesMixin on State<NormalVideoPlayer> {
  SubtitleTrack? currentSubtitleTrack;
  List<SubtitleItem> parsedSubtitles = [];

  void initSubtitles() {
    currentSubtitleTrack = widget.initialSubtitle;
    loadSubtitleTrack();
  }

  void syncSubtitlesOnUpdate(NormalVideoPlayer oldWidget) {
    if (widget.subtitles != null && currentSubtitleTrack != null) {
      final byId = widget.subtitles!
          .where((s) => s.id == currentSubtitleTrack!.id)
          .firstOrNull;
      if (byId != null && byId != currentSubtitleTrack) {
        currentSubtitleTrack = byId;
        loadSubtitleTrack();
      }
    }
  }

  Future<void> loadSubtitleTrack() async {
    if (currentSubtitleTrack == null) {
      if (mounted) setState(() => parsedSubtitles = []);
      return;
    }

    try {
      String subtitleContent = '';
      if (currentSubtitleTrack!.content != null &&
          currentSubtitleTrack!.content!.isNotEmpty) {
        subtitleContent = currentSubtitleTrack!.content!;
      } else if (currentSubtitleTrack!.fetcher != null) {
        subtitleContent = await currentSubtitleTrack!.fetcher!();
      }

      if (mounted) {
        setState(() {
          parsedSubtitles = SubtitleParser.parse(subtitleContent);
        });
      }
    } catch (e) {
      log('Error parsing subtitles: $e');
    }
  }

  void changeSubtitleTrack(SubtitleTrack? newTrack) {
    if (currentSubtitleTrack == newTrack) return;
    setState(() {
      currentSubtitleTrack = newTrack;
      parsedSubtitles = []; // clear while loading
    });
    loadSubtitleTrack();
  }
}
