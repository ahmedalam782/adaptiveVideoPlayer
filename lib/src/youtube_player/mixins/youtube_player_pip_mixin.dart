import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/services/native_pip_service.dart';
import '../models/youtube_player_config.dart';
import '../utils/youtube_web_export.dart';
import '../widgets/youtube_web_iframe_view.dart';
import '../youtube_video_player.dart';

/// Mixin handling Picture-in-Picture mode (OS-native and floating in-app window) for [YouTubeVideoPlayer].
mixin YouTubePlayerPipMixin on State<YouTubeVideoPlayer> {
  OverlayEntry? mobilePipOverlayEntry;
  String? pipWebIframeId;

  bool get isInMobilePip => mobilePipOverlayEntry != null;

  String? get currentVideoId;
  String? get currentWebIframeId;
  YouTubePlayerConfig resolveEffectiveConfig(BuildContext context);
  bool get isMuted;
  bool get isLooping;
  bool get isCaptionEnabled;
  void onPauseVideo();
  void onAfterClosePip(bool pauseOnClose);

  Future<void> openMobilePip() async {
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS)) {
      final entered = await NativePipService.enterPip();
      if (entered) return;
    }
    if (!mounted || isInMobilePip) return;
    if (kIsWeb && (currentVideoId == null || currentWebIframeId == null)) {
      return;
    }

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    if (kIsWeb) {
      final effectiveConfig =
          mounted ? resolveEffectiveConfig(context) : widget.config;
      final isRtl = effectiveConfig.text.resolveTextDirection(context) ==
          TextDirection.rtl;
      final currentLang =
          isRtl ? 'ar' : (effectiveConfig.text.languageCode ?? 'en');
      pipWebIframeId =
          'youtube-iframe-pip-$currentVideoId-${DateTime.now().millisecondsSinceEpoch}';
      registerYoutubeWebIframe(
        pipWebIframeId!,
        currentVideoId!,
        true,
        mute: isMuted,
        loop: isLooping,
        enableCaption: isCaptionEnabled,
        languageCode: currentLang,
      );
    }

    Offset offset = Offset.zero;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setOverlayState) {
          final currentText = mounted
              ? resolveEffectiveConfig(context).text
              : widget.config.text;
          final effectiveDir = currentText.resolveTextDirection(ctx);
          final isRtl = effectiveDir == TextDirection.rtl;
          return Directionality(
            textDirection: effectiveDir,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  left: isRtl ? (16 + offset.dx) : null,
                  right: isRtl ? null : (16 - offset.dx),
                  bottom: 24 - offset.dy,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanUpdate: (details) {
                      setOverlayState(() {
                        offset += details.delta;
                      });
                    },
                    child: Material(
                      color: Colors.black,
                      elevation: 14,
                      borderRadius: BorderRadius.circular(12),
                      clipBehavior: Clip.antiAlias,
                      child: SizedBox(
                        width: 280,
                        height: 158,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (kIsWeb && pipWebIframeId != null)
                              YouTubeWebIframeView(
                                key: ValueKey(pipWebIframeId!),
                                viewId: pipWebIframeId!,
                              ),
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              height: 38,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withValues(alpha: 0.75),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Tooltip(
                                      message: currentText.expandPlayerText,
                                      child: GestureDetector(
                                        onTap: () => closeMobilePip(
                                          pauseOnClose: false,
                                        ),
                                        child: Container(
                                          width: 28,
                                          height: 28,
                                          decoration: const BoxDecoration(
                                            color: Color(0xAA000000),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.open_in_full_rounded,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Tooltip(
                                      message: currentText.closeMiniPlayerText,
                                      child: GestureDetector(
                                        onTap: () => closeMobilePip(
                                          pauseOnClose: true,
                                        ),
                                        child: Container(
                                          width: 28,
                                          height: 28,
                                          decoration: const BoxDecoration(
                                            color: Color(0xAA000000),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close_rounded,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
          );
        },
      ),
    );

    mobilePipOverlayEntry = entry;
    overlay.insert(entry);
    if (mounted) setState(() {});
  }

  void closeMobilePip({bool pauseOnClose = false}) {
    if (!isInMobilePip) return;
    mobilePipOverlayEntry?.remove();
    mobilePipOverlayEntry = null;
    pipWebIframeId = null;
    if (pauseOnClose) {
      onPauseVideo();
    }
    onAfterClosePip(pauseOnClose);
    if (mounted) setState(() {});
  }

  void disposeMobilePip() {
    mobilePipOverlayEntry?.remove();
    mobilePipOverlayEntry = null;
  }
}
