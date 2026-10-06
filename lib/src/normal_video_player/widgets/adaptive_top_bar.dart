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

  bool get _shouldShowBackButton => showBackButton == true;

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
        children: [
          if (_shouldShowBackButton)
            Tooltip(
              message: messages?.backText ??
                  messages?.exitFullscreenText ??
                  'Back',
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onExitFullscreen,
                  splashColor: Colors.white24,
                  highlightColor: Colors.white10,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: PlayerIcon.resolve(
                      context,
                      icon: styling?.icons.backIcon,
                      fallbackIcon: isRtl
                          ? Icons.arrow_forward_rounded
                          : Icons.arrow_back_rounded,
                      defaultColor: iconColor,
                      defaultSize: 24,
                    ),
                  ),
                ),
              ),
            ),
          if (_shouldShowBackButton) const SizedBox(width: 8),
          if (showLive)
            AdaptiveLiveIndicator(
              isLive: isLive,
              qualities: qualities,
              onQualitySelected: onQualitySelected,
              onAnalyticsEvent: onAnalyticsEvent,
              messages: messages,
              styling: styling,
            ),
          if (viewerCount != null) ...[
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PlayerIcon.resolve(
                    context,
                    icon: styling?.icons.viewerCountIcon,
                    fallbackIcon: Icons.remove_red_eye_outlined,
                    defaultColor: iconColor,
                    defaultSize: 14,
                  ),
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
        ],
      ),
    );
  }
}
