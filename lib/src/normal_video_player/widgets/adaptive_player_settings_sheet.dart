import 'package:flutter/material.dart';

import '../../core/constants/player_events.dart';
import '../../core/constants/player_strings.dart';
import '../../youtube_player/models/youtube_player_config.dart';
import '../models/video_config.dart';

enum SettingsPage { main, qualities, subtitles }

/// Player settings bottom sheet for video resolutions and subtitle selections (SRP).
class AdaptivePlayerSettingsSheet extends StatefulWidget {
  final PlayerStyleConfig? styling;
  final PlayerTextConfig? messages;
  final PlayerVisibilityConfig? visibility;
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
    this.visibility,
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
    final effectiveMessages = widget.messages ?? const PlayerTextConfig();

    Widget page;
    switch (_currentPage) {
      case SettingsPage.main:
        page = AdaptiveSettingsMainMenu(
          styling: widget.styling,
          messages: effectiveMessages,
          visibility: widget.visibility,
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
  final PlayerVisibilityConfig? visibility;
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
    this.visibility,
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
    final showQuality = visibility?.showQualitySetting ?? true;
    final showSubtitles = visibility?.showSubtitlesSetting ?? true;

    return ListView(
      key: const ValueKey('main_menu'),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        if (showQuality)
          ListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            leading: PlayerIcon.resolve(
              context,
              icon: styling?.icons.qualityIcon,
              fallbackIcon: Icons.hd,
              defaultColor: styling?.iconColor ?? Colors.white,
              defaultSize: 20,
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
              onAnalyticsEvent
                  ?.call(PlayerEvents.resolutionSettingsClicked, {});
              if (qualities != null && qualities!.isNotEmpty) {
                onOpenQualities();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  backgroundColor: styling?.settingsBackgroundColor ??
                      const Color(0xFF212121),
                  behavior: SnackBarBehavior.floating,
                  content: Text(
                    messages?.noQualitiesAvailableText ??
                        PlayerStrings.noQualitiesAvailable,
                    style: styling?.settingItemTextStyle ??
                        const TextStyle(color: Colors.white),
                  ),
                ));
              }
            },
          ),
        if (showSubtitles)
          ListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            leading: PlayerIcon.resolve(
              context,
              icon: styling?.icons.subtitlesIcon,
              fallbackIcon: Icons.closed_caption,
              defaultColor: styling?.iconColor ?? Colors.white,
              defaultSize: 20,
            ),
            title: Text(
              messages?.subtitlesText ?? PlayerStrings.subtitles,
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
                          (messages?.offText ?? PlayerStrings.off),
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
              onAnalyticsEvent?.call(PlayerEvents.subtitleSettingsClicked, {});
              if (subtitles != null && subtitles!.isNotEmpty) {
                onOpenSubtitles();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  backgroundColor: styling?.settingsBackgroundColor ??
                      const Color(0xFF212121),
                  behavior: SnackBarBehavior.floating,
                  content: Text(
                    messages?.noSubtitlesAvailableText ??
                        PlayerStrings.noSubtitlesAvailable,
                    style: styling?.settingItemTextStyle ??
                        const TextStyle(color: Colors.white),
                  ),
                ));
              }
            },
          ),
      ],
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
    final color = styling?.iconColor ?? Colors.white;
    return ListView(
      key: const ValueKey('qualities_menu'),
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      children: [
        ResponsiveSettingsBackHeader(
          title: messages?.qualityText ?? 'Quality (Resolution)',
          color: color,
          onBack: onBack,
        ),
        const SizedBox(height: 12),
        ...(qualities ?? const <VideoQuality>[]).map((quality) {
          return ResponsiveSettingsChoice(
            label: quality.title,
            selected: currentQuality == quality,
            color: color,
            onTap: () {
              if (onDismiss != null) {
                onDismiss!();
              } else if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
              onQualitySelected?.call(quality);
            },
          );
        }),
      ],
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
    final color = styling?.iconColor ?? Colors.white;
    return ListView(
      key: const ValueKey('subtitles_menu'),
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      children: [
        ResponsiveSettingsBackHeader(
          title: messages?.subtitlesText ?? 'Subtitles',
          color: color,
          onBack: onBack,
        ),
        ResponsiveSettingsChoice(
          label: messages?.offText ?? 'Off',
          selected: currentSubtitleTrack == null,
          color: color,
          onTap: () {
            if (onDismiss != null) {
              onDismiss!();
            } else if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
            onSubtitleSelected?.call(null);
          },
        ),
        ...(subtitles ?? const <SubtitleTrack>[]).map((track) {
          return ResponsiveSettingsChoice(
            label: track.title,
            selected: currentSubtitleTrack?.id == track.id,
            color: color,
            onTap: () {
              if (onDismiss != null) {
                onDismiss!();
              } else if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
              onSubtitleSelected?.call(track);
            },
          );
        }),
      ],
    );
  }
}

/// Back control and title for a settings page.
class ResponsiveSettingsBackHeader extends StatelessWidget {
  final String title;
  final Color color;
  final VoidCallback onBack;

  const ResponsiveSettingsBackHeader({
    super.key,
    required this.title,
    required this.color,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Row(
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              onPressed: onBack,
              icon: Icon(
                Icons.arrow_back,
                color: color,
                size: 20,
                textDirection: Directionality.of(context),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Divider(color: color.withValues(alpha: .5), height: .5),
      ],
    );
  }
}

/// One centered choice in the quality or subtitle list.
class ResponsiveSettingsChoice extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const ResponsiveSettingsChoice({
    super.key,
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: 24),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 8),
              Icon(Icons.check_rounded, color: color, size: 18),
            ],
          ],
        ),
      ),
    );
  }
}
