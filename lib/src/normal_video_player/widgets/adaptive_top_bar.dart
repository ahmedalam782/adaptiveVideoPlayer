import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../youtube_player/models/youtube_player_config.dart';
import '../models/video_config.dart';
import 'adaptive_live_indicator.dart';

/// Top bar overlay displaying back button, live status, and viewer count.
class AdaptiveTopBar extends StatelessWidget {
  final bool isFullScreen;
  final VoidCallback? onExitFullscreen;
  final bool isLive;
  final String? viewerCount;
  final List<VideoQuality>? qualities;
  final void Function(VideoQuality)? onQualitySelected;
  final void Function(String event, Map<String, dynamic> data)?
      onAnalyticsEvent;
  final bool? showBackButton;
  final PlayerTextConfig? messages;
  final PlayerStyleConfig? styling;
  final PlayerVisibilityConfig? visibility;

  const AdaptiveTopBar({
    super.key,
    required this.isFullScreen,
    this.onExitFullscreen,
    this.isLive = false,
    this.viewerCount,
    this.qualities,
    this.onQualitySelected,
    this.onAnalyticsEvent,
    this.showBackButton,
    this.messages,
    this.styling,
    this.visibility,
  });

  bool get _shouldShowBackButton {
    if (!isFullScreen) return false;
    if (showBackButton != null) return showBackButton!;
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  @override
  Widget build(BuildContext context) {
    final textDirection = messages?.resolveTextDirection(context) ??
        Directionality.maybeOf(context) ??
        TextDirection.ltr;
    final isRtl = textDirection == TextDirection.rtl;
    final iconColor = styling?.iconColor ?? Colors.white;
    final textColor = styling?.textColor ?? Colors.white;
    final showLive = visibility?.showLiveBadge ?? true;

    return Directionality(
      textDirection: textDirection,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_shouldShowBackButton)
            Tooltip(
              message: messages?.backText ??
                  messages?.exitFullscreenText ??
                  'Back',
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onExitFullscreen,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    isRtl ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded,
                    color: iconColor,
                    size: 20,
                  ),
                ),
              ),
            )
          else
            const SizedBox.shrink(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showLive)
                AdaptiveLiveIndicator(
                  isLive: isLive,
                  qualities: qualities,
                  onQualitySelected: onQualitySelected,
                  onAnalyticsEvent: onAnalyticsEvent,
                  messages: messages,
                  styling: styling,
                ),
              if (viewerCount != null)
                Container(
                  margin: const EdgeInsetsDirectional.only(end: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.remove_red_eye_outlined,
                          color: iconColor, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        viewerCount!,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
