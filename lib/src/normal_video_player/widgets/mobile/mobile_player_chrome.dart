import 'package:flutter/material.dart';

import '../../../core/constants/player_events.dart';
import '../../../youtube_player/models/youtube_player_config.dart';
import '../../models/video_config.dart';
import '../../utils/player_chrome_utils.dart';
import '../../utils/video_player_web_safe.dart';
import '../adaptive_progress_bar.dart';

/// Phone-only controls for normal video.
class MobilePlayerChrome extends StatelessWidget {
  final VideoPlayerController controller;
  final bool isFullScreen;
  final bool isLive;
  final PlayerStyleConfig? styling;
  final PlayerTextConfig? messages;
  final PlayerVisibilityConfig? visibility;
  final PlayerPlaybackConfig? playback;
  final List<VideoChapter>? chapters;
  final void Function(String event, Map<String, dynamic> data)? onAnalyticsEvent;
  final String? title;
  final VideoEpisode? currentEpisode;
  final List<VideoEpisode>? episodes;
  final List<AudioTrack>? audioTracks;
  final List<SubtitleTrack>? subtitles;
  final double? dragPosition;
  final ValueChanged<double>? onDragChanged;
  final ValueChanged<double>? onDragEnd;
  final VoidCallback? onEnterFullscreen;
  final VoidCallback? onExitFullscreen;
  final VoidCallback? onMiniPlayerPressed;
  final VoidCallback? onNextEpisode;
  final VoidCallback? onEpisodesPressed;
  final VoidCallback? onAudioSubtitlesPressed;
  final VoidCallback? onSpeedPressed;
  final VoidCallback? onSettingsPressed;
  final VoidCallback? onLockPressed;
  final ValueNotifier<double>? brightnessListenable;

  const MobilePlayerChrome({
    super.key,
    required this.controller,
    required this.isFullScreen,
    this.isLive = false,
    this.styling,
    this.messages,
    this.visibility,
    this.playback,
    this.chapters,
    this.onAnalyticsEvent,
    this.title,
    this.currentEpisode,
    this.episodes,
    this.audioTracks,
    this.subtitles,
    this.dragPosition,
    this.onDragChanged,
    this.onDragEnd,
    this.onEnterFullscreen,
    this.onExitFullscreen,
    this.onMiniPlayerPressed,
    this.onNextEpisode,
    this.onEpisodesPressed,
    this.onAudioSubtitlesPressed,
    this.onSpeedPressed,
    this.onSettingsPressed,
    this.onLockPressed,
    this.brightnessListenable,
  });

  @override
  Widget build(BuildContext context) {
    final textDirection = messages?.resolveTextDirection(context) ??
        Directionality.maybeOf(context) ??
        TextDirection.ltr;
    final isRtl = textDirection == TextDirection.rtl;
    final effectiveVisibility = visibility ?? const PlayerVisibilityConfig();

    return Directionality(
      textDirection: textDirection,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final short = constraints.maxHeight < 340;
          final showLabels = constraints.maxHeight >= 300;
          return Stack(
            fit: StackFit.expand,
            children: [
              const IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xCC000000),
                        Color(0x00000000),
                        Color(0x00000000),
                        Color(0xE6000000),
                      ],
                      stops: [0.0, 0.28, 0.55, 1.0],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: Column(
                  children: [
                    MobileTopBar(
                      headline: PlayerChromeUtils.headline(
                        title: title,
                        episodeTitle: currentEpisode?.title,
                      ),
                      isRtl: isRtl,
                      isFullScreen: isFullScreen,
                      isLive: isLive,
                      styling: styling,
                      messages: messages,
                      visibility: effectiveVisibility,
                      audioTracks: audioTracks,
                      subtitles: subtitles,
                      onExitFullscreen: onExitFullscreen,
                      onEnterFullscreen: onEnterFullscreen,
                      onMiniPlayerPressed: onMiniPlayerPressed,
                      onAudioSubtitlesPressed: onAudioSubtitlesPressed,
                      onLockPressed: onLockPressed,
                    ),
                    Expanded(
                      child: MobileCenterTransport(
                        controller: controller,
                        styling: styling,
                        messages: messages,
                        visibility: effectiveVisibility,
                        isLive: isLive,
                        compact: short,
                        onAnalyticsEvent: onAnalyticsEvent,
                      ),
                    ),
                    if (effectiveVisibility.showProgressBar && !isLive)
                      AdaptiveProgressBar(
                        controller: controller,
                        dragPosition: dragPosition,
                        onDragChanged: onDragChanged ?? (_) {},
                        onDragEnd: onDragEnd ?? (_) {},
                        styling: styling,
                        chapters: chapters,
                        playback: playback,
                        messages: messages,
                        visibility: effectiveVisibility,
                        onAnalyticsEvent: onAnalyticsEvent,
                      ),
                    if (!short)
                      MobileActionRow(
                        controller: controller,
                        isRtl: isRtl,
                        showLabels: showLabels,
                        messages: messages,
                        visibility: effectiveVisibility,
                        episodes: episodes,
                        audioTracks: audioTracks,
                        subtitles: subtitles,
                        onNextEpisode: onNextEpisode,
                        onEpisodesPressed: onEpisodesPressed,
                        onAudioSubtitlesPressed: onAudioSubtitlesPressed,
                        onSpeedPressed: onSpeedPressed,
                        onSettingsPressed: onSettingsPressed,
                      ),
                  ],
                ),
              ),
              if (!short &&
                  constraints.maxHeight > 280 &&
                  effectiveVisibility.showBrightnessSlider &&
                  brightnessListenable != null)
                Positioned(
                  right: 8,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: MobileBrightnessSlider(
                      brightnessListenable: brightnessListenable!,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Phone top row: title, captions, lock, mini player, fullscreen.
class MobileTopBar extends StatelessWidget {
  final String headline;
  final bool isRtl;
  final bool isFullScreen;
  final bool isLive;
  final PlayerStyleConfig? styling;
  final PlayerTextConfig? messages;
  final PlayerVisibilityConfig visibility;
  final List<AudioTrack>? audioTracks;
  final List<SubtitleTrack>? subtitles;
  final VoidCallback? onExitFullscreen;
  final VoidCallback? onEnterFullscreen;
  final VoidCallback? onMiniPlayerPressed;
  final VoidCallback? onAudioSubtitlesPressed;
  final VoidCallback? onLockPressed;

  const MobileTopBar({
    super.key,
    required this.headline,
    required this.isRtl,
    required this.isFullScreen,
    required this.isLive,
    required this.visibility,
    this.styling,
    this.messages,
    this.audioTracks,
    this.subtitles,
    this.onExitFullscreen,
    this.onEnterFullscreen,
    this.onMiniPlayerPressed,
    this.onAudioSubtitlesPressed,
    this.onLockPressed,
  });

  @override
  Widget build(BuildContext context) {
    final hasAudio = onAudioSubtitlesPressed != null &&
        visibility.showAudioSubtitlesButton &&
        ((audioTracks != null && audioTracks!.isNotEmpty) ||
            (subtitles != null && subtitles!.isNotEmpty));

    return Row(
      children: [
        Expanded(
          child: !isFullScreen && visibility.showTitle
              ? Text(
                  headline,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                )
              : const SizedBox.shrink(),
        ),
        if (isLive && visibility.showLiveBadge)
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: Text(
              messages?.liveText ?? 'LIVE',
              style: const TextStyle(
                color: Color(0xFFE50914),
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        if (hasAudio)
          MobileRoundIconButton(
            icon: Icons.closed_caption_outlined,
            tooltip: messages?.audioAndSubtitlesText ??
                (isRtl ? 'الصوت والترجمة' : 'Audio & Subtitles'),
            onTap: onAudioSubtitlesPressed!,
          ),
        if (visibility.showScreenLockButton && onLockPressed != null)
          MobileRoundIconButton(
            icon: Icons.lock_outline_rounded,
            tooltip: isRtl ? 'قفل الشاشة' : 'Lock screen',
            onTap: onLockPressed!,
          ),
        if (visibility.showMiniPlayerButton &&
            onMiniPlayerPressed != null &&
            !isFullScreen)
          MobileRoundIconButton(
            icon: Icons.picture_in_picture_alt_rounded,
            tooltip: messages?.miniPlayerText ?? 'Miniplayer',
            onTap: onMiniPlayerPressed!,
          ),
        if (visibility.showFullscreenButton &&
            isFullScreen &&
            onExitFullscreen != null)
          MobileRoundIconButton(
            icon: Icons.close_rounded,
            tooltip: messages?.exitFullscreenText ?? 'Close',
            onTap: onExitFullscreen!,
          )
        else if (visibility.showFullscreenButton &&
            !isFullScreen &&
            onEnterFullscreen != null)
          MobileRoundIconButton(
            icon: Icons.fullscreen_rounded,
            tooltip: messages?.fullscreenText ?? 'Fullscreen',
            onTap: onEnterFullscreen!,
          ),
      ],
    );
  }
}

/// Phone center transport. Play taps pass through to the player gesture.
class MobileCenterTransport extends StatelessWidget {
  final VideoPlayerController controller;
  final PlayerStyleConfig? styling;
  final PlayerTextConfig? messages;
  final PlayerVisibilityConfig visibility;
  final bool isLive;
  final bool compact;
  final void Function(String event, Map<String, dynamic> data)? onAnalyticsEvent;

  const MobileCenterTransport({
    super.key,
    required this.controller,
    required this.visibility,
    required this.isLive,
    required this.compact,
    this.styling,
    this.messages,
    this.onAnalyticsEvent,
  });

  @override
  Widget build(BuildContext context) {
    final showSkip = visibility.showSkipButtons && !isLive;
    final diameter = compact ? 46.0 : 54.0;
    final skip = visibility.skipDuration;

    return Center(
      child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showSkip)
              MobileSkipButton(
                forward: false,
                diameter: diameter,
                tooltip: messages?.skipBackwardText ?? 'Back',
                onTap: () => _seek(-skip),
              ),
            if (visibility.showCenterPlayPause) ...[
              SizedBox(width: compact ? 28 : 40),
              MobilePlayIcon(controller: controller, styling: styling, compact: compact),
              SizedBox(width: compact ? 28 : 40),
            ],
            if (showSkip)
              MobileSkipButton(
                forward: true,
                diameter: diameter,
                tooltip: messages?.skipForwardText ?? 'Forward',
                onTap: () => _seek(skip),
              ),
          ],
        ),
    );
  }

  void _seek(Duration delta) {
    final target = PlayerChromeUtils.clampSeek(
      position: controller.value.position,
      duration: controller.value.duration,
      delta: delta,
    );
    controller.seekTo(target);
    onAnalyticsEvent?.call(PlayerEvents.videoSeek, {
      PlayerEvents.paramToPosition: target.inSeconds,
    });
  }
}

/// Phone play glyph. Pointers pass through so the video gesture stays in charge.
class MobilePlayIcon extends StatelessWidget {
  final VideoPlayerController controller;
  final PlayerStyleConfig? styling;
  final bool compact;

  const MobilePlayIcon({
    super.key,
    required this.controller,
    required this.compact,
    this.styling,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        return IgnorePointer(
          child: Icon(
            value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            color: styling?.centerButtonColor ?? Colors.white,
            size: compact ? 52 : 64,
          ),
        );
      },
    );
  }
}

/// Phone skip circle.
class MobileSkipButton extends StatelessWidget {
  final bool forward;
  final double diameter;
  final String tooltip;
  final VoidCallback onTap;

  const MobileSkipButton({
    super.key,
    required this.forward,
    required this.diameter,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: diameter,
          height: diameter,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.6),
          ),
          child: Icon(
            forward ? Icons.forward_10_rounded : Icons.replay_10_rounded,
            color: Colors.white,
            size: diameter * 0.62,
          ),
        ),
      ),
    );
  }
}

/// Phone bottom actions.
class MobileActionRow extends StatelessWidget {
  final VideoPlayerController controller;
  final bool isRtl;
  final bool showLabels;
  final PlayerTextConfig? messages;
  final PlayerVisibilityConfig visibility;
  final List<VideoEpisode>? episodes;
  final List<AudioTrack>? audioTracks;
  final List<SubtitleTrack>? subtitles;
  final VoidCallback? onNextEpisode;
  final VoidCallback? onEpisodesPressed;
  final VoidCallback? onAudioSubtitlesPressed;
  final VoidCallback? onSpeedPressed;
  final VoidCallback? onSettingsPressed;

  const MobileActionRow({
    super.key,
    required this.controller,
    required this.isRtl,
    required this.showLabels,
    required this.visibility,
    this.messages,
    this.episodes,
    this.audioTracks,
    this.subtitles,
    this.onNextEpisode,
    this.onEpisodesPressed,
    this.onAudioSubtitlesPressed,
    this.onSpeedPressed,
    this.onSettingsPressed,
  });

  @override
  Widget build(BuildContext context) {
    final hasTracks = (audioTracks != null && audioTracks!.isNotEmpty) ||
        (subtitles != null && subtitles!.isNotEmpty);
    final actions = <Widget>[
      if (visibility.showNextEpisodeButton && onNextEpisode != null)
        MobileLabeledAction(
          icon: Icons.skip_next_rounded,
          label: messages?.nextEpisodeText ??
              (isRtl ? 'الحلقة التالية' : 'Next Episode'),
          showLabel: showLabels,
          onTap: onNextEpisode!,
        ),
      if (visibility.showAudioSubtitlesButton &&
          onAudioSubtitlesPressed != null &&
          hasTracks)
        MobileLabeledAction(
          icon: Icons.subtitles_outlined,
          label: messages?.audioAndSubtitlesText ??
              (isRtl ? 'الصوت والترجمة' : 'Audio & Subtitles'),
          showLabel: showLabels,
          onTap: onAudioSubtitlesPressed!,
        ),
      if (visibility.showEpisodesButton &&
          onEpisodesPressed != null &&
          episodes != null &&
          episodes!.isNotEmpty)
        MobileLabeledAction(
          icon: Icons.video_library_outlined,
          label: messages?.episodesText ?? (isRtl ? 'الحلقات' : 'Episodes'),
          showLabel: showLabels,
          onTap: onEpisodesPressed!,
        ),
      if (visibility.showSpeedButton && onSpeedPressed != null)
        ValueListenableBuilder<VideoPlayerValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            final rateLabel = PlayerChromeUtils.playbackRateLabel(value.playbackSpeed);
            return MobileLabeledAction(
              icon: Icons.speed_rounded,
              label: isRtl ? 'السرعة ($rateLabel)' : 'Speed ($rateLabel)',
              showLabel: showLabels,
              onTap: onSpeedPressed!,
            );
          },
        ),
      if (visibility.showSettingsButton && onSettingsPressed != null)
        MobileLabeledAction(
          icon: Icons.settings_outlined,
          label: messages?.playerSettingsText ?? (isRtl ? 'الإعدادات' : 'Settings'),
          showLabel: showLabels,
          onTap: onSettingsPressed!,
        ),
    ];

    if (actions.isEmpty) return const SizedBox(height: 4);

    return SizedBox(
      height: showLabels ? 76 : 40,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var index = 0; index < actions.length; index++) ...[
                    if (index > 0) const SizedBox(width: 28),
                    actions[index],
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Phone action with an icon and a short label.
class MobileLabeledAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool showLabel;
  final VoidCallback onTap;

  const MobileLabeledAction({
    super.key,
    required this.icon,
    required this.label,
    required this.showLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 88,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            if (showLabel) ...[
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  height: 1.15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Phone top-bar icon.
class MobileRoundIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const MobileRoundIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 22),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

/// Phone brightness slider. The dimmer itself lives on the player stack.
class MobileBrightnessSlider extends StatelessWidget {
  final ValueNotifier<double> brightnessListenable;

  const MobileBrightnessSlider({super.key, required this.brightnessListenable});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: brightnessListenable,
      builder: (context, value, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wb_sunny_rounded, color: Colors.white, size: 14),
            const SizedBox(height: 4),
            SizedBox(
              width: 22,
              height: 88,
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: RotatedBox(
                  quarterTurns: 3,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 2,
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: Colors.white24,
                      thumbColor: Colors.white,
                      overlayShape: SliderComponentShape.noOverlay,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 5),
                    ),
                    child: Slider(
                      value: value.clamp(0.15, 1.0),
                      min: 0.15,
                      max: 1.0,
                      onChanged: (next) => brightnessListenable.value = next,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
