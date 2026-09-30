import 'package:flutter/material.dart';

import '../../youtube_player/models/youtube_player_config.dart';
import '../models/video_config.dart';
import 'adaptive_player_settings_sheet.dart';

/// Settings button widget for the adaptive player bottom bar.
class AdaptiveSettingsButton extends StatelessWidget {
  final bool isFullScreen;
  final PlayerStyleConfig? styling;
  final PlayerTextConfig? messages;
  final List<VideoQuality>? qualities;
  final VideoQuality? currentQuality;
  final ValueChanged<VideoQuality>? onQualitySelected;
  final List<SubtitleTrack>? subtitles;
  final SubtitleTrack? currentSubtitleTrack;
  final ValueChanged<SubtitleTrack?>? onSubtitleSelected;
  final void Function(String event, Map<String, dynamic> data)?
      onAnalyticsEvent;
  final VoidCallback? onPressed;

  const AdaptiveSettingsButton({
    super.key,
    this.isFullScreen = false,
    this.styling,
    this.messages,
    this.qualities,
    this.currentQuality,
    this.onQualitySelected,
    this.subtitles,
    this.currentSubtitleTrack,
    this.onSubtitleSelected,
    this.onAnalyticsEvent,
    this.onPressed,
  });

  void _openSettings(BuildContext context) {
    onAnalyticsEvent?.call('settings_opened', {});

    final box = context.findRenderObject() as RenderBox?;
    final offset = box != null ? box.localToGlobal(Offset.zero) : Offset.zero;
    final size = box?.size ?? Size.zero;
    final media = MediaQuery.of(context);
    final screenSize = media.size;

    final rightPos = (screenSize.width - offset.dx - size.width).clamp(16.0, screenSize.width - 340.0);
    final bottomPos = (screenSize.height - offset.dy + 8.0).clamp(16.0, screenSize.height - 360.0);
    final isWide = media.size.width > 600 || isFullScreen;

    if (isWide) {
      showDialog(
        context: context,
        useRootNavigator: true,
        barrierColor: Colors.black26,
        builder: (dialogContext) {
          return Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(dialogContext).pop(),
                  child: const SizedBox.expand(),
                ),
              ),
              Positioned(
                bottom: bottomPos,
                right: rightPos,
                child: Container(
                  width: 320,
                  constraints: BoxConstraints(
                    maxHeight: media.size.height * 0.75,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.6),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Material(
                    color: styling?.settingsBackgroundColor ??
                        const Color(0xF21F1F1F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: AdaptivePlayerSettingsSheet(
                      styling: styling,
                      messages: messages,
                      qualities: qualities,
                      currentQuality: currentQuality,
                      onQualitySelected: (q) {
                        onQualitySelected?.call(q);
                      },
                      subtitles: subtitles,
                      currentSubtitleTrack: currentSubtitleTrack,
                      onSubtitleSelected: (s) {
                        onSubtitleSelected?.call(s);
                      },
                      onAnalyticsEvent: onAnalyticsEvent,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    } else {
      showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        backgroundColor:
            styling?.settingsBackgroundColor ?? const Color(0xFF212121),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (sheetContext) {
          return AdaptivePlayerSettingsSheet(
            styling: styling,
            messages: messages,
            qualities: qualities,
            currentQuality: currentQuality,
            onQualitySelected: onQualitySelected,
            subtitles: subtitles,
            currentSubtitleTrack: currentSubtitleTrack,
            onSubtitleSelected: onSubtitleSelected,
            onAnalyticsEvent: onAnalyticsEvent,
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: messages?.playerSettingsText ?? 'Player Settings',
      waitDuration: const Duration(milliseconds: 500),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (onPressed != null) {
            onAnalyticsEvent?.call('settings_opened', {});
            onPressed!();
          } else {
            _openSettings(context);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Icon(
            Icons.settings,
            color: styling?.iconColor ?? Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }
}
