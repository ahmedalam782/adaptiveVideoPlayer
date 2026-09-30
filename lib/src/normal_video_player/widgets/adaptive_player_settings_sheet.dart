import 'package:flutter/material.dart';

import '../../youtube_player/models/youtube_player_config.dart';
import '../models/video_config.dart';

enum SettingsPage { main, qualities, subtitles }

/// Player settings bottom sheet for video resolutions and subtitle selections (SRP).
class AdaptivePlayerSettingsSheet extends StatefulWidget {
  final PlayerStyleConfig? styling;
  final PlayerTextConfig? messages;
  final List<VideoQuality>? qualities;
  final VideoQuality? currentQuality;
  final void Function(VideoQuality)? onQualitySelected;
  final List<SubtitleTrack>? subtitles;
  final SubtitleTrack? currentSubtitleTrack;
  final void Function(SubtitleTrack?)? onSubtitleSelected;
  final void Function(String event, Map<String, dynamic> data)?
      onAnalyticsEvent;
  final VoidCallback? onDismiss;

  const AdaptivePlayerSettingsSheet({
    super.key,
    this.styling,
    this.messages,
    this.qualities,
    this.currentQuality,
    this.onQualitySelected,
    this.subtitles,
    this.currentSubtitleTrack,
    this.onSubtitleSelected,
    this.onAnalyticsEvent,
    this.onDismiss,
  });

  @override
  State<AdaptivePlayerSettingsSheet> createState() =>
      AdaptivePlayerSettingsSheetState();
}

class AdaptivePlayerSettingsSheetState
    extends State<AdaptivePlayerSettingsSheet> {
  SettingsPage _currentPage = SettingsPage.main;

  bool _isArabicOrRtl(BuildContext context) {
    final msg = widget.messages ?? const PlayerTextConfig();
    return msg.resolveTextDirection(context) == TextDirection.rtl;
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = _isArabicOrRtl(context);
    final effectiveMessages = widget.messages ??
        (isRtl
            ? const PlayerTextConfig.arabic()
            : const PlayerTextConfig.english());

    Widget page;
    switch (_currentPage) {
      case SettingsPage.main:
        page = AdaptiveSettingsMainMenu(
          styling: widget.styling,
          messages: effectiveMessages,
          currentQuality: widget.currentQuality,
          currentSubtitleTrack: widget.currentSubtitleTrack,
          qualities: widget.qualities,
          subtitles: widget.subtitles,
          onOpenQualities: () =>
              setState(() => _currentPage = SettingsPage.qualities),
          onOpenSubtitles: () =>
              setState(() => _currentPage = SettingsPage.subtitles),
          onAnalyticsEvent: widget.onAnalyticsEvent,
        );
        break;
      case SettingsPage.qualities:
        page = AdaptiveSettingsQualitiesMenu(
          styling: widget.styling,
          messages: effectiveMessages,
          qualities: widget.qualities,
          currentQuality: widget.currentQuality,
          onBack: () => setState(() => _currentPage = SettingsPage.main),
          onQualitySelected: widget.onQualitySelected,
          onDismiss: widget.onDismiss,
        );
        break;
      case SettingsPage.subtitles:
        page = AdaptiveSettingsSubtitlesMenu(
          styling: widget.styling,
          messages: effectiveMessages,
          subtitles: widget.subtitles,
          currentSubtitleTrack: widget.currentSubtitleTrack,
          onBack: () => setState(() => _currentPage = SettingsPage.main),
          onSubtitleSelected: widget.onSubtitleSelected,
          onDismiss: widget.onDismiss,
        );
        break;
    }

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Material(
        color: Colors.transparent,
        child: SafeArea(
          top: false,
          bottom: false,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: page,
          ),
        ),
      ),
    );
  }
}

/// Main settings menu displaying resolution and subtitles rows.
class AdaptiveSettingsMainMenu extends StatelessWidget {
  final PlayerStyleConfig? styling;
  final PlayerTextConfig? messages;
  final VideoQuality? currentQuality;
  final SubtitleTrack? currentSubtitleTrack;
  final List<VideoQuality>? qualities;
  final List<SubtitleTrack>? subtitles;
  final VoidCallback onOpenQualities;
  final VoidCallback onOpenSubtitles;
  final void Function(String event, Map<String, dynamic> data)?
      onAnalyticsEvent;

  const AdaptiveSettingsMainMenu({
    super.key,
    this.styling,
    this.messages,
    this.currentQuality,
    this.currentSubtitleTrack,
    this.qualities,
    this.subtitles,
    required this.onOpenQualities,
    required this.onOpenSubtitles,
    this.onAnalyticsEvent,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey('main_menu'),
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            leading: Icon(
              Icons.hd,
              color: styling?.iconColor ?? Colors.white,
            ),
            title: Text(
              messages?.qualityText ?? 'Quality (Resolution)',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: styling?.settingItemTextStyle ??
                  const TextStyle(color: Colors.white),
            ),
            trailing: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 130),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      currentQuality?.title ?? (messages?.autoText ?? 'Auto'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: styling?.iconColor.withValues(alpha: 0.7) ??
                            Colors.white70,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right,
                    color: styling?.iconColor.withValues(alpha: 0.7) ??
                        Colors.white70,
                    size: 20,
                  ),
                ],
              ),
            ),
            onTap: () {
              onAnalyticsEvent?.call('resolution_settings_clicked', {});
              if (qualities != null && qualities!.isNotEmpty) {
                onOpenQualities();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  backgroundColor: styling?.settingsBackgroundColor ??
                      const Color(0xFF212121),
                  behavior: SnackBarBehavior.floating,
                  content: Text(
                    messages?.noQualitiesAvailableText ??
                        'No qualities available',
                    style: styling?.settingItemTextStyle ??
                        const TextStyle(color: Colors.white),
                  ),
                ));
              }
            },
          ),
          ListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            leading: Icon(
              Icons.closed_caption,
              color: styling?.iconColor ?? Colors.white,
            ),
            title: Text(
              messages?.subtitlesText ?? 'Subtitles',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: styling?.settingItemTextStyle ??
                  const TextStyle(color: Colors.white),
            ),
            trailing: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 130),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      currentSubtitleTrack?.title ??
                          (messages?.offText ?? 'Off'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: styling?.iconColor.withValues(alpha: 0.7) ??
                            Colors.white70,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right,
                    color: styling?.iconColor.withValues(alpha: 0.7) ??
                        Colors.white70,
                    size: 20,
                  ),
                ],
              ),
            ),
            onTap: () {
              onAnalyticsEvent?.call('subtitle_settings_clicked', {});
              if (subtitles != null && subtitles!.isNotEmpty) {
                onOpenSubtitles();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  backgroundColor: styling?.settingsBackgroundColor ??
                      const Color(0xFF212121),
                  behavior: SnackBarBehavior.floating,
                  content: Text(
                    messages?.noSubtitlesAvailableText ??
                        'No subtitles available',
                    style: styling?.settingItemTextStyle ??
                        const TextStyle(color: Colors.white),
                  ),
                ));
              }
            },
          ),
        ],
      ),
    );
  }
}

/// Qualities selection menu for picking video resolution.
class AdaptiveSettingsQualitiesMenu extends StatelessWidget {
  final PlayerStyleConfig? styling;
  final PlayerTextConfig? messages;
  final List<VideoQuality>? qualities;
  final VideoQuality? currentQuality;
  final VoidCallback onBack;
  final void Function(VideoQuality)? onQualitySelected;
  final VoidCallback? onDismiss;

  const AdaptiveSettingsQualitiesMenu({
    super.key,
    this.styling,
    this.messages,
    this.qualities,
    this.currentQuality,
    required this.onBack,
    this.onQualitySelected,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: const ValueKey('qualities_menu'),
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: styling?.iconColor ?? Colors.white,
              ),
              onPressed: onBack,
            ),
            title: Text(
              messages?.qualityText ?? 'Quality (Resolution)',
              style: styling?.settingItemTextStyle?.copyWith(
                    fontWeight: FontWeight.bold,
                  ) ??
                  const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: qualities?.length ?? 0,
              itemBuilder: (context, index) {
                final quality = qualities![index];
                final isSelected = currentQuality == quality;
                return ListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  title: Text(
                    quality.title,
                    style: styling?.settingItemTextStyle ??
                        const TextStyle(color: Colors.white),
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.check,
                          color: styling?.iconColor ?? Colors.white,
                        )
                      : null,
                  onTap: () {
                    if (onDismiss != null) {
                      onDismiss!();
                    } else if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                    onQualitySelected?.call(quality);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Subtitles selection menu for picking active subtitle track.
class AdaptiveSettingsSubtitlesMenu extends StatelessWidget {
  final PlayerStyleConfig? styling;
  final PlayerTextConfig? messages;
  final List<SubtitleTrack>? subtitles;
  final SubtitleTrack? currentSubtitleTrack;
  final VoidCallback onBack;
  final void Function(SubtitleTrack?)? onSubtitleSelected;
  final VoidCallback? onDismiss;

  const AdaptiveSettingsSubtitlesMenu({
    super.key,
    this.styling,
    this.messages,
    this.subtitles,
    this.currentSubtitleTrack,
    required this.onBack,
    this.onSubtitleSelected,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final subtitlesCount = (subtitles?.length ?? 0) + 1;
    return Padding(
      key: const ValueKey('subtitles_menu'),
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: styling?.iconColor ?? Colors.white,
              ),
              onPressed: onBack,
            ),
            title: Text(
              messages?.subtitlesText ?? 'Subtitles',
              style: styling?.settingItemTextStyle?.copyWith(
                    fontWeight: FontWeight.bold,
                  ) ??
                  const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: subtitlesCount,
              itemBuilder: (context, index) {
                if (index == 0) {
                  final isSelected = currentSubtitleTrack == null;
                  return ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    title: Text(
                      messages?.offText ?? 'Off',
                      style: styling?.settingItemTextStyle ??
                          const TextStyle(color: Colors.white),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check,
                            color: styling?.iconColor ?? Colors.white,
                          )
                        : null,
                    onTap: () {
                      if (onDismiss != null) {
                        onDismiss!();
                      } else if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                      onSubtitleSelected?.call(null);
                    },
                  );
                }
                final track = subtitles![index - 1];
                final isSelected = currentSubtitleTrack?.id == track.id;
                return ListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  title: Text(
                    track.title,
                    style: styling?.settingItemTextStyle ??
                        const TextStyle(color: Colors.white),
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.check,
                          color: styling?.iconColor ?? Colors.white,
                        )
                      : null,
                  onTap: () {
                    if (onDismiss != null) {
                      onDismiss!();
                    } else if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                    onSubtitleSelected?.call(track);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
