import 'package:flutter/material.dart';
import '../../youtube_player/models/player_style_config.dart';
import '../../youtube_player/models/player_text_config.dart';
import '../models/audio_track.dart';
import '../models/subtitle_track.dart';
import 'responsive/responsive_audio_subtitle_columns.dart';

/// Audio and subtitle picker for Windows, web, and tablet.
///
/// [immersive] fills the player on a phone or tablet. Otherwise the card
/// shrinks to [maxWidth] and [maxHeight].
class ResponsiveAudioSubtitlesPanel extends StatefulWidget {
  final List<AudioTrack>? audioTracks;
  final AudioTrack? currentAudioTrack;
  final ValueChanged<AudioTrack>? onAudioTrackSelected;
  final List<SubtitleTrack>? subtitles;
  final SubtitleTrack? currentSubtitleTrack;
  final ValueChanged<SubtitleTrack?>? onSubtitleSelected;
  final PlayerStyleConfig? styling;
  final PlayerTextConfig? messages;
  final VoidCallback? onClose;

  /// Edge-to-edge two-column panel used on phone and tablet.
  final bool immersive;

  /// Caps the floating card so it stays inside smaller windows.
  final double? maxWidth;
  final double? maxHeight;

  const ResponsiveAudioSubtitlesPanel({
    super.key,
    this.audioTracks,
    this.currentAudioTrack,
    this.onAudioTrackSelected,
    this.subtitles,
    this.currentSubtitleTrack,
    this.onSubtitleSelected,
    this.styling,
    this.messages,
    this.onClose,
    this.immersive = false,
    this.maxWidth,
    this.maxHeight,
  });

  @override
  State<ResponsiveAudioSubtitlesPanel> createState() =>
      _ResponsiveAudioSubtitlesPanelState();
}

/// Previous name. Prefer [ResponsiveAudioSubtitlesPanel].
typedef AdaptiveAudioSubtitlesPopup = ResponsiveAudioSubtitlesPanel;

class _ResponsiveAudioSubtitlesPanelState
    extends State<ResponsiveAudioSubtitlesPanel> {
  AudioTrack? _selectedAudio;
  SubtitleTrack? _selectedSub;

  @override
  void initState() {
    super.initState();
    _selectedAudio = widget.currentAudioTrack ?? widget.audioTracks?.firstOrNull;
    _selectedSub = widget.currentSubtitleTrack;
  }

  @override
  void didUpdateWidget(covariant ResponsiveAudioSubtitlesPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentAudioTrack != oldWidget.currentAudioTrack) {
      _selectedAudio = widget.currentAudioTrack;
    }
    if (widget.currentSubtitleTrack != oldWidget.currentSubtitleTrack) {
      _selectedSub = widget.currentSubtitleTrack;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textDirection = widget.messages?.resolveTextDirection(context) ??
        Directionality.maybeOf(context) ??
        TextDirection.ltr;
    final isRtl = textDirection == TextDirection.rtl;

    final audioLabel =
        widget.messages?.audioText ?? (isRtl ? 'الصوت' : 'Audio');
    final subtitlesLabel =
        widget.messages?.subtitlesText ?? (isRtl ? 'الترجمة' : 'Subtitles');
    final offLabel =
        widget.messages?.offText ?? (isRtl ? 'إيقاف التشغيل' : 'Off');

    final audioList = widget.audioTracks ?? const [];
    final subList = widget.subtitles ?? const [];
    final columns = ResponsiveAudioSubtitleColumns(
      subtitlesLabel: subtitlesLabel,
      audioLabel: audioLabel,
      offLabel: offLabel,
      emptyAudioLabel: isRtl ? 'افتراضي' : 'Default',
      audioList: audioList,
      subList: subList,
      selectedSubtitle: _selectedSub,
      selectedAudio: _selectedAudio,
      onSubtitleSelected: (track) {
        setState(() => _selectedSub = track);
        widget.onSubtitleSelected?.call(track);
      },
      onAudioSelected: (audio) {
        setState(() => _selectedAudio = audio);
        widget.onAudioTrackSelected?.call(audio);
      },
    );

    return Directionality(
      textDirection: textDirection,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: widget.immersive ? double.infinity : (widget.maxWidth ?? 520),
          height: widget.immersive ? double.infinity : null,
          constraints: widget.immersive
              ? const BoxConstraints()
              : BoxConstraints(maxHeight: widget.maxHeight ?? 380),
          padding: EdgeInsets.symmetric(
            horizontal: widget.immersive ? 28 : 20,
            vertical: widget.immersive ? 12 : 16,
          ),
          decoration: widget.immersive
              ? const BoxDecoration(color: Color(0xF0141414))
              : BoxDecoration(
                  color: widget.styling?.settingsBackgroundColor ??
                      const Color(0xF21F1F1F),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.65),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                    width: 1,
                  ),
                ),
          child: widget.immersive
              ? Column(
                  children: [
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: IconButton(
                        onPressed: widget.onClose,
                        icon: const Icon(Icons.close_rounded,
                            color: Colors.white),
                      ),
                    ),
                    Expanded(child: columns),
                  ],
                )
              : columns,
        ),
      ),
    );
  }
}
