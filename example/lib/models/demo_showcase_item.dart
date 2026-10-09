import 'package:flutter/material.dart';
import 'package:adaptive_video_player/adaptive_video_player.dart';

/// One playable source for the single studio player.
///
/// The example keeps every package feature on one player. Choosing a source
/// only swaps the URL and the flags that source needs (live, YouTube, captions).
class StudioSource {
  final String id;
  final String label;
  final String description;
  final IconData icon;
  final Color accentColor;
  final List<String> features;
  final VideoConfig config;

  const StudioSource({
    required this.id,
    required this.label,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.features,
    required this.config,
  });

  bool get isYouTube => config.isYouTube;
  String get videoUrl => config.videoUrl;
}
