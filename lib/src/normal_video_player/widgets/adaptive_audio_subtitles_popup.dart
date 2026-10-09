import 'package:flutter/material.dart';
import '../../youtube_player/models/player_style_config.dart';
import '../../youtube_player/models/player_text_config.dart';
import '../models/audio_track.dart';
import '../models/subtitle_track.dart';

/// Dual-column popup for Audio and Subtitles selection matching Netflix's interface.
class AdaptiveAudioSubtitlesPopup extends StatefulWidget {
  final List<AudioTrack>? audioTracks;
  final AudioTrack? currentAudioTrack;
  final ValueChanged<AudioTrack>? onAudioTrackSelected;
  final List<SubtitleTrack>? subtitles;
  final SubtitleTrack? currentSubtitleTrack;
  final ValueChanged<SubtitleTrack?>? onSubtitleSelected;
  final PlayerStyleConfig? styling;
  final PlayerTextConfig? messages;
  final VoidCallback? onClose;

  const AdaptiveAudioSubtitlesPopup({
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
  });

  @override
  State<AdaptiveAudioSubtitlesPopup> createState() =>
      _AdaptiveAudioSubtitlesPopupState();
}

class _AdaptiveAudioSubtitlesPopupState
    extends State<AdaptiveAudioSubtitlesPopup> {
  AudioTrack? _selectedAudio;
  SubtitleTrack? _selectedSub;

  @override
  void initState() {
    super.initState();
    _selectedAudio = widget.currentAudioTrack ?? widget.audioTracks?.firstOrNull;
    _selectedSub = widget.currentSubtitleTrack;
  }

  @override
  void didUpdateWidget(covariant AdaptiveAudioSubtitlesPopup oldWidget) {
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

    return Directionality(
      textDirection: textDirection,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 520,
          constraints: const BoxConstraints(maxHeight: 380),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color:
                widget.styling?.settingsBackgroundColor ?? const Color(0xF21F1F1F),
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column 1: Subtitles (الترجمة)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subtitlesLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          // "Off" option
                          _buildSubItem(
                            label: offLabel,
                            isSelected: _selectedSub == null,
                            onTap: () {
                              setState(() => _selectedSub = null);
                              widget.onSubtitleSelected?.call(null);
                            },
                          ),
                          ...subList.map((track) {
                            final isSelected = _selectedSub?.id == track.id;
                            return _buildSubItem(
                              label: track.title,
                              isSelected: isSelected,
                              onTap: () {
                                setState(() => _selectedSub = track);
                                widget.onSubtitleSelected?.call(track);
                              },
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Vertical divider
              Container(
                width: 1,
                height: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                color: Colors.white.withValues(alpha: 0.12),
              ),

              // Column 2: Audio (الصوت)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      audioLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: audioList.isEmpty
                            ? [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    isRtl ? 'افتراضي' : 'Default',
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.7),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ]
                            : audioList.map((audio) {
                                final isSelected =
                                    _selectedAudio?.id == audio.id ||
                                        (_selectedAudio == null &&
                                            audio.isDefault);
                                return _buildAudioItem(
                                  audio: audio,
                                  isSelected: isSelected,
                                  onTap: () {
                                    setState(() => _selectedAudio = audio);
                                    widget.onAudioTrackSelected?.call(audio);
                                  },
                                );
                              }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubItem({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7.0, horizontal: 4.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.75),
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioItem({
    required AudioTrack audio,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7.0, horizontal: 4.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                audio.label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.75),
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}
