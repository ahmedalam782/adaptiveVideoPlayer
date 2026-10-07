import 'package:flutter/material.dart';

import '../utils/youtube_web_export.dart';

/// Platform-adaptive widget that embeds the YouTube web iframe element.
///
/// Replaces the direct usage of helper functions with an OOP [StatelessWidget].
class YouTubeWebIframeView extends StatelessWidget {
  final String viewId;

  const YouTubeWebIframeView({
    super.key,
    required this.viewId,
  });

  @override
  Widget build(BuildContext context) {
    return buildYoutubeWebIframe(viewId, key: key);
  }
}
