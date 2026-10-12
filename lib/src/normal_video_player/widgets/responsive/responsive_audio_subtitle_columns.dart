import 'package:flutter/material.dart';

import '../../models/audio_track.dart';
import '../../models/subtitle_track.dart';

/// Two-column audio and subtitle lists used by the window and tablet panel.
class ResponsiveAudioSubtitleColumns extends StatelessWidget {
  final String subtitlesLabel;
  final String audioLabel;
  final String offLabel;
  final String emptyAudioLabel;
  final List<AudioTrack> audioList;
  final List<SubtitleTrack> subList;
  final SubtitleTrack? selectedSubtitle;
  final AudioTrack? selectedAudio;
  final ValueChanged<SubtitleTrack?> onSubtitleSelected;
  final ValueChanged<AudioTrack> onAudioSelected;

  const ResponsiveAudioSubtitleColumns({
    super.key,
    required this.subtitlesLabel,
    required this.audioLabel,
    required this.offLabel,
    required this.emptyAudioLabel,
    required this.audioList,
    required this.subList,
    required this.selectedSubtitle,
    required this.selectedAudio,
    required this.onSubtitleSelected,
    required this.onAudioSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                    ResponsiveSubtitleOption(
                      label: offLabel,
                      isSelected: selectedSubtitle == null,
                      onTap: () => onSubtitleSelected(null),
                    ),
                    ...subList.map(
                      (track) => ResponsiveSubtitleOption(
                        label: track.title,
                        isSelected: selectedSubtitle?.id == track.id,
                        onTap: () => onSubtitleSelected(track),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 1,
          height: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          color: Colors.white.withValues(alpha: 0.12),
        ),
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
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              emptyAudioLabel,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ]
                      : audioList
                          .map(
                            (audio) => ResponsiveAudioOption(
                              audio: audio,
                              isSelected: selectedAudio?.id == audio.id ||
                                  (selectedAudio == null && audio.isDefault),
                              onTap: () => onAudioSelected(audio),
                            ),
                          )
                          .toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ResponsiveSubtitleOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const ResponsiveSubtitleOption({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _CheckRow(label: label, isSelected: isSelected, onTap: onTap);
  }
}

class ResponsiveAudioOption extends StatelessWidget {
  final AudioTrack audio;
  final bool isSelected;
  final VoidCallback onTap;

  const ResponsiveAudioOption({
    super.key,
    required this.audio,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _CheckRow(label: audio.label, isSelected: isSelected, onTap: onTap);
  }
}

class _CheckRow extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CheckRow({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
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
              const Icon(Icons.check_rounded, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}
