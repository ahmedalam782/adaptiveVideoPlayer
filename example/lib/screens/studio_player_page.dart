import 'package:flutter/material.dart';
import 'package:adaptive_video_player/adaptive_video_player.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;

import '../models/demo_showcase_item.dart';
import '../widgets/language_picker_sheet.dart';

/// The one player surface for every source in the example.
///
/// Source choice only changes the URL and live/YouTube flags. Layout,
/// visibility, and playback options stay on this same player.
class StudioStage extends StatefulWidget {
  final StudioSource source;
  final bool isDark;
  final String currentLanguageCode;

  const StudioStage({
    super.key,
    required this.source,
    required this.isDark,
    required this.currentLanguageCode,
  });

  @override
  State<StudioStage> createState() => _StudioStageState();
}

class _StudioStageState extends State<StudioStage> {
  final List<String> _eventLogs = [];
  BottomBarLayout _layout = BottomBarLayout.inline;
  BoxFit _videoFit = BoxFit.contain;
  PlayerVisibilityConfig _visibility = const PlayerVisibilityConfig();
  bool _autoPlay = false;
  bool _loop = false;
  bool _mute = false;
  Color _background = const Color(0xFF000000);
  Color _topColor = const Color(0xCC000000);
  Color _barColor = const Color(0xCC1B313F);
  Color _progress = const Color(0xFFEF4444);
  Color _iconColor = Colors.white;
  Color _centerButton = Colors.white;
  Color _centerIcon = const Color(0xFF1E88E5);
  _IconPack _iconPack = _IconPack.rounded;
  String _playerIdentity = '';
  GlobalKey _playerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    NativePipService.setPipEnabled(true);
    NativePipService.isInPip.addListener(_onPipChanged);
  }

  void _onPipChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant StudioStage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source.id != widget.source.id && _eventLogs.isNotEmpty) {
      setState(() => _eventLogs.clear());
    }
  }

  @override
  void dispose() {
    NativePipService.isInPip.removeListener(_onPipChanged);
    NativePipService.setPipEnabled(false);
    super.dispose();
  }

  void _recordEvent(String event, Map<String, dynamic> data) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final timeStr = TimeOfDay.now().format(context);
      setState(() {
        _eventLogs.insert(0, '[$timeStr] $event $data');
        if (_eventLogs.length > 40) _eventLogs.removeLast();
      });
    });
  }

  String _tr(String key) {
    try {
      return context.tr(key);
    } catch (_) {
      return key;
    }
  }

  VideoConfig _buildConfig(bool isRtl) {
    final source = widget.source.config;
    final text = PlayerTextConfig.tr(
      _tr,
      languageCode: widget.currentLanguageCode,
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
    );
    final viewerCount = switch (source.viewerCount) {
      '142k VIEWERS' => isRtl ? '142 ألف مشاهد' : '142k VIEWERS',
      '15.4K' => isRtl ? '15.4 ألف مشاهد' : '15.4K',
      _ => source.viewerCount,
    };

    return VideoConfig(
      videoUrl: source.videoUrl,
      isFile: source.isFile,
      isLive: source.isLive,
      videoBytes: source.videoBytes,
      qualities: source.qualities,
      initialQuality: source.initialQuality,
      subtitles: source.subtitles,
      initialSubtitle: source.initialSubtitle,
      chapters: source.chapters,
      viewerCount: viewerCount,
      extension: source.extension,
      aspectRatio: _videoFit == BoxFit.cover ? (16 / 9) : source.aspectRatio,
      playerConfig: YouTubePlayerConfig(
        style: PlayerStyleConfig(
          bottomBarLayout: _layout,
          videoFit: _videoFit,
          backgroundColor: _background,
          topBarColor: _topColor,
          centerButtonColor: _centerButton,
          centerIconColor: _centerIcon,
          controlsBackgroundColor: _barColor,
          settingsBackgroundColor: _barColor,
          iconColor: _iconColor,
          textColor: _iconColor,
          progressBarPlayedColor: _progress,
          progressBarHandleColor: _progress,
          loadingIndicatorColor: _progress,
          icons: _iconPack.config,
        ),
        text: text,
        visibility: _visibility,
        playback: PlayerPlaybackConfig(
          autoPlay: _autoPlay,
          loop: _loop,
          mute: _mute,
        ),
      ),
      onAnalyticsEvent: _recordEvent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final source = widget.source;
    final lang = LanguagePickerSheet.getLanguage(widget.currentLanguageCode);
    final config = _buildConfig(lang.isRtl);
    final identity = '${source.id}|$_autoPlay|$_loop|$_mute|$_videoFit';
    if (identity != _playerIdentity) {
      _playerIdentity = identity;
      _playerKey = GlobalKey();
    }
    final player = AdaptiveVideoPlayer(key: _playerKey, config: config);

    if (NativePipService.isInPip.value) {
      return ColoredBox(
        color: Colors.black,
        child: SizedBox.expand(child: player),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PlayerFrame(
          accentColor: source.accentColor,
          background: _background,
          child: player,
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            source.description,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: widget.isDark
                  ? Colors.white.withValues(alpha: 0.65)
                  : const Color(0xFF475569),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final feature in source.features)
                _Tag(label: feature, color: source.accentColor),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _Panel(
          isDark: widget.isDark,
          title: 'Same controls for every source',
          icon: Icons.tune_rounded,
          accent: source.accentColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionLabel('Background', widget.isDark),
              const SizedBox(height: 8),
              _swatches(
                selected: _background,
                colors: const [
                  Color(0xFF000000),
                  Color(0xFF111827),
                  Color(0xFF1E1B4B),
                  Color(0xFF0F172A),
                  Color(0xFFFFFFFF),
                ],
                onPick: (color) => setState(() => _background = color),
              ),
              const SizedBox(height: 14),
              _SectionLabel('Top', widget.isDark),
              const SizedBox(height: 8),
              _swatches(
                selected: _topColor,
                colors: const [
                  Color(0xCC000000),
                  Color(0xCC1E1B4B),
                  Color(0xCC064E3B),
                  Color(0xCC7F1D1D),
                  Color(0xCC0F172A),
                ],
                onPick: (color) => setState(() => _topColor = color),
              ),
              const SizedBox(height: 14),
              _SectionLabel('Play button', widget.isDark),
              const SizedBox(height: 8),
              _swatches(
                selected: _centerButton,
                colors: const [
                  Colors.white,
                  Color(0xFF0F172A),
                  Color(0xFF1E88E5),
                  Color(0xFF111827),
                  Color(0xFFFDE68A),
                ],
                onPick: (color) => setState(() => _centerButton = color),
              ),
              const SizedBox(height: 14),
              _SectionLabel('Play icon', widget.isDark),
              const SizedBox(height: 8),
              _swatches(
                selected: _centerIcon,
                colors: const [
                  Color(0xFF1E88E5),
                  Colors.white,
                  Color(0xFF0F172A),
                  Color(0xFFEF4444),
                  Color(0xFF10B981),
                ],
                onPick: (color) => setState(() => _centerIcon = color),
              ),
              const SizedBox(height: 14),
              _SectionLabel('Control bar', widget.isDark),
              const SizedBox(height: 8),
              _swatches(
                selected: _barColor,
                colors: const [
                  Color(0xCC1B313F),
                  Color(0xE6000000),
                  Color(0xCC312E81),
                  Color(0xCC064E3B),
                  Color(0xF2FFFFFF),
                ],
                onPick: (color) => setState(() => _barColor = color),
              ),
              const SizedBox(height: 14),
              _SectionLabel('Progress', widget.isDark),
              const SizedBox(height: 8),
              _swatches(
                selected: _progress,
                colors: const [
                  Color(0xFFEF4444),
                  Color(0xFF6366F1),
                  Color(0xFF10B981),
                  Color(0xFFF59E0B),
                  Color(0xFF38BDF8),
                ],
                onPick: (color) => setState(() => _progress = color),
              ),
              const SizedBox(height: 14),
              _SectionLabel('Icon color', widget.isDark),
              const SizedBox(height: 8),
              _swatches(
                selected: _iconColor,
                colors: const [
                  Colors.white,
                  Color(0xFFE2E8F0),
                  Color(0xFF0F172A),
                  Color(0xFFFDE68A),
                  Color(0xFF67E8F9),
                ],
                onPick: (color) => setState(() => _iconColor = color),
              ),
              const SizedBox(height: 14),
              _SectionLabel('Icons', widget.isDark),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final pack in _IconPack.values)
                    _Choice(
                      label: pack.label,
                      selected: _iconPack == pack,
                      accent: source.accentColor,
                      isDark: widget.isDark,
                      onTap: () => setState(() => _iconPack = pack),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              _SectionLabel('Video display', widget.isDark),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Choice(
                    label: 'Fill screen (No black bars)',
                    selected: _videoFit == BoxFit.cover,
                    accent: source.accentColor,
                    isDark: widget.isDark,
                    onTap: () => setState(() => _videoFit = BoxFit.cover),
                  ),
                  _Choice(
                    label: 'Fit natural ratio',
                    selected: _videoFit == BoxFit.contain,
                    accent: source.accentColor,
                    isDark: widget.isDark,
                    onTap: () => setState(() => _videoFit = BoxFit.contain),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _SectionLabel('Bottom bar', widget.isDark),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Choice(
                    label: 'Progress on top',
                    selected: _layout == BottomBarLayout.youtubePills,
                    accent: source.accentColor,
                    isDark: widget.isDark,
                    onTap: () =>
                        setState(() => _layout = BottomBarLayout.youtubePills),
                  ),
                  _Choice(
                    label: 'Inline capsule',
                    selected: _layout == BottomBarLayout.inline,
                    accent: source.accentColor,
                    isDark: widget.isDark,
                    onTap: () =>
                        setState(() => _layout = BottomBarLayout.inline),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _SectionLabel('Buttons', widget.isDark),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _toggle('Play overlay', _visibility.showCenterPlayPause, (v) {
                    _visibility = _visibility.copyWith(showCenterPlayPause: v);
                  }, source.accentColor),
                  _toggle('Skip ±10s', _visibility.showSkipButtons, (v) {
                    _visibility = _visibility.copyWith(showSkipButtons: v);
                  }, source.accentColor),
                  _toggle('Volume', _visibility.showVolumeButton, (v) {
                    _visibility = _visibility.copyWith(showVolumeButton: v);
                  }, source.accentColor),
                  _toggle('Fullscreen', _visibility.showFullscreenButton, (v) {
                    _visibility = _visibility.copyWith(showFullscreenButton: v);
                  }, source.accentColor),
                  _toggle('Settings', _visibility.showSettingsButton, (v) {
                    _visibility = _visibility.copyWith(showSettingsButton: v);
                  }, source.accentColor),
                  _toggle('Mini player', _visibility.showMiniPlayerButton, (v) {
                    _visibility = _visibility.copyWith(showMiniPlayerButton: v);
                  }, source.accentColor),
                  _toggle('Live badge', _visibility.showLiveBadge, (v) {
                    _visibility = _visibility.copyWith(showLiveBadge: v);
                  }, source.accentColor),
                  _toggle('Time', _visibility.showTimeDisplay, (v) {
                    _visibility = _visibility.copyWith(showTimeDisplay: v);
                  }, source.accentColor),
                  _toggle('Progress', _visibility.showProgressBar, (v) {
                    _visibility = _visibility.copyWith(showProgressBar: v);
                  }, source.accentColor),
                  _toggle('Stop', _visibility.showStopButton, (v) {
                    _visibility = _visibility.copyWith(showStopButton: v);
                  }, source.accentColor),
                  _toggle('Captions', _visibility.showCaptionsSetting, (v) {
                    _visibility = _visibility.copyWith(showCaptionsSetting: v);
                  }, source.accentColor),
                  _toggle('Quality', _visibility.showQualitySetting, (v) {
                    _visibility = _visibility.copyWith(showQualitySetting: v);
                  }, source.accentColor),
                  _toggle('Speed', _visibility.showPlaybackSpeedSetting, (v) {
                    _visibility = _visibility.copyWith(
                      showPlaybackSpeedSetting: v,
                    );
                  }, source.accentColor),
                  _toggle('Chapters', _visibility.showChapterTitle, (v) {
                    _visibility = _visibility.copyWith(showChapterTitle: v);
                  }, source.accentColor),
                  _toggle('Volume HUD', _visibility.showVolumeFeedback, (v) {
                    _visibility = _visibility.copyWith(showVolumeFeedback: v);
                  }, source.accentColor),
                ],
              ),
              const SizedBox(height: 14),
              _SectionLabel('Playback', widget.isDark),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Choice(
                    label: 'Autoplay',
                    selected: _autoPlay,
                    accent: source.accentColor,
                    isDark: widget.isDark,
                    onTap: () => setState(() => _autoPlay = !_autoPlay),
                  ),
                  _Choice(
                    label: 'Loop',
                    selected: _loop,
                    accent: source.accentColor,
                    isDark: widget.isDark,
                    onTap: () => setState(() => _loop = !_loop),
                  ),
                  _Choice(
                    label: 'Start muted',
                    selected: _mute,
                    accent: source.accentColor,
                    isDark: widget.isDark,
                    onTap: () => setState(() => _mute = !_mute),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _Panel(
          isDark: widget.isDark,
          title: 'Live analytics',
          icon: Icons.terminal_rounded,
          accent: const Color(0xFF10B981),
          trailing: '${_eventLogs.length}',
          child: SizedBox(
            height: 120,
            child: _eventLogs.isEmpty
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Play, pause, seek, or open settings. Events from this player show up here.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: widget.isDark
                            ? Colors.white.withValues(alpha: 0.4)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _eventLogs.length,
                    itemBuilder: (context, i) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        _eventLogs[i],
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: Color(0xFF34D399),
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _swatches({
    required Color selected,
    required List<Color> colors,
    required ValueChanged<Color> onPick,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final color in colors)
          _ColorSwatch(
            color: color,
            selected: color == selected,
            onTap: () => onPick(color),
          ),
      ],
    );
  }

  Widget _toggle(
    String label,
    bool selected,
    ValueChanged<bool> onChanged,
    Color accent,
  ) {
    return _Choice(
      label: label,
      selected: selected,
      accent: accent,
      isDark: widget.isDark,
      onTap: () => setState(() => onChanged(!selected)),
    );
  }
}

enum _IconPack {
  rounded('Rounded'),
  outlined('Outlined'),
  sharp('Sharp');

  final String label;
  const _IconPack(this.label);

  PlayerIconConfig get config {
    IconData play;
    IconData pause;
    IconData volume;
    IconData mute;
    IconData fullscreen;
    IconData settings;
    IconData mini;
    switch (this) {
      case _IconPack.rounded:
        play = Icons.play_arrow_rounded;
        pause = Icons.pause_rounded;
        volume = Icons.volume_up_rounded;
        mute = Icons.volume_off_rounded;
        fullscreen = Icons.fullscreen_rounded;
        settings = Icons.settings_rounded;
        mini = Icons.picture_in_picture_alt_rounded;
      case _IconPack.outlined:
        play = Icons.play_arrow_outlined;
        pause = Icons.pause_outlined;
        volume = Icons.volume_up_outlined;
        mute = Icons.volume_off_outlined;
        fullscreen = Icons.fullscreen_outlined;
        settings = Icons.settings_outlined;
        mini = Icons.picture_in_picture_alt_outlined;
      case _IconPack.sharp:
        play = Icons.play_arrow;
        pause = Icons.pause;
        volume = Icons.volume_up;
        mute = Icons.volume_off;
        fullscreen = Icons.fullscreen;
        settings = Icons.settings;
        mini = Icons.picture_in_picture_alt;
    }
    return PlayerIconConfig(
      playIcon: PlayerIcon.icon(play),
      pauseIcon: PlayerIcon.icon(pause),
      volumeHighIcon: PlayerIcon.icon(volume),
      volumeLowIcon: PlayerIcon.icon(volume),
      volumeMuteIcon: PlayerIcon.icon(mute),
      fullscreenIcon: PlayerIcon.icon(fullscreen),
      exitFullscreenIcon: PlayerIcon.icon(Icons.fullscreen_exit),
      settingsIcon: PlayerIcon.icon(settings),
      miniPlayerIcon: PlayerIcon.icon(mini),
      viewerCountIcon: PlayerIcon.icon(Icons.visibility_outlined),
      skipBackwardIcon: PlayerIcon.icon(Icons.replay_10_rounded),
      skipForwardIcon: PlayerIcon.icon(Icons.forward_10_rounded),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _ColorSwatch({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? const Color(0xFF6366F1) : Colors.white24,
            width: selected ? 2.5 : 1,
          ),
        ),
      ),
    );
  }
}

class _PlayerFrame extends StatelessWidget {
  final Color accentColor;
  final Color background;
  final Widget child;

  const _PlayerFrame({
    required this.accentColor,
    required this.background,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth.clamp(160.0, 1100.0);
          final height = width / (16 / 9);
          return Center(
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.28),
                    blurRadius: 28,
                    spreadRadius: -6,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: ColoredBox(color: background, child: child),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final bool isDark;
  final String title;
  final IconData icon;
  final Color accent;
  final String? trailing;
  final Widget child;

  const _Panel({
    required this.isDark,
    required this.title,
    required this.icon,
    required this.accent,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111726) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ),
                if (trailing != null)
                  Text(
                    trailing!,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white54 : const Color(0xFF64748B),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final bool isDark;

  const _SectionLabel(this.text, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white70 : const Color(0xFF334155),
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  final String label;
  final bool selected;
  final Color accent;
  final bool isDark;
  final VoidCallback onTap;

  const _Choice({
    required this.label,
    required this.selected,
    required this.accent,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final idleText = isDark ? Colors.white70 : const Color(0xFF334155);
    final idleFill = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.04);
    final idleBorder = isDark
        ? Colors.white24
        : Colors.black.withValues(alpha: 0.08);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.22) : idleFill,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? accent : idleBorder,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected
                ? (isDark ? Colors.white : const Color(0xFF0F172A))
                : idleText,
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;

  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
