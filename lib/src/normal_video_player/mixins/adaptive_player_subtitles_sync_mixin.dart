import 'package:flutter/material.dart';

import '../adaptive_controls.dart';

/// Mixin handling timeline subtitle text synchronization for [BaseAdaptiveVideoPlayer].
mixin AdaptivePlayerSubtitlesSyncMixin on State<BaseAdaptiveVideoPlayer> {
  String currentSubtitleText = '';

  void updateSubtitle(Duration position) {
    if (widget.parsedSubtitles == null || widget.parsedSubtitles!.isEmpty) {
      if (currentSubtitleText.isNotEmpty) {
        setState(() => currentSubtitleText = '');
      }
      return;
    }

    String newText = '';
    for (final item in widget.parsedSubtitles!) {
      if (position >= item.start && position <= item.end) {
        newText = item.text;
        break;
      }
    }

    if (currentSubtitleText != newText && mounted) {
      setState(() => currentSubtitleText = newText);
    }
  }

  void resetSubtitleText() {
    currentSubtitleText = '';
  }
}
