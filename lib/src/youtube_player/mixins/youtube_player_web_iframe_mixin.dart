import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/youtube_player_config.dart';
import '../utils/youtube_web_export.dart';
import '../youtube_video_player.dart';

/// Mixin handling web iframe registration, language tracking, and iframe lifecycle for [YouTubeVideoPlayer].
mixin YouTubePlayerWebIframeMixin on State<YouTubeVideoPlayer> {
  String? webIframeId;
  String? lastResolvedLang;

  void syncWebIframe({
    required BuildContext context,
    required String? videoId,
    required bool autoPlay,
    required bool isMuted,
    required bool loop,
    required bool enableCaption,
    required YouTubePlayerConfig Function(BuildContext) resolveConfig,
  }) {
    if (!kIsWeb || videoId == null || !mounted) return;

    final effectiveConfig = resolveConfig(context);
    final isRtl = effectiveConfig.text.resolveTextDirection(context) ==
        TextDirection.rtl;
    final currentLang =
        isRtl ? 'ar' : (effectiveConfig.text.languageCode ?? 'en');

    if (webIframeId == null) {
      lastResolvedLang = currentLang;
      webIframeId =
          'youtube-iframe-$videoId-${DateTime.now().millisecondsSinceEpoch}';
      registerYoutubeWebIframe(
        webIframeId!,
        videoId,
        autoPlay,
        mute: isMuted,
        loop: loop,
        enableCaption: enableCaption,
        languageCode: currentLang,
      );
      setState(() {});
    } else if (lastResolvedLang != null && lastResolvedLang != currentLang) {
      lastResolvedLang = currentLang;
      webIframeId =
          'youtube-iframe-$videoId-${DateTime.now().millisecondsSinceEpoch}';
      registerYoutubeWebIframe(
        webIframeId!,
        videoId,
        autoPlay,
        mute: isMuted,
        loop: loop,
        enableCaption: enableCaption,
        languageCode: currentLang,
      );
      setState(() {});
    }
  }

  void resetWebIframe() {
    webIframeId = null;
    lastResolvedLang = null;
  }
}
