import 'package:flutter/material.dart';
import 'package:adaptive_video_player/adaptive_video_player.dart';

/// Catalog item representation for showcase demo
class DemoShowcaseItem {
  final String title;
  final String subtitle;
  final String category;
  final List<String> tags;
  final IconData icon;
  final Color accentColor;
  final VideoConfig config;

  const DemoShowcaseItem({
    required this.title,
    required this.subtitle,
    required this.category,
    required this.tags,
    required this.icon,
    required this.accentColor,
    required this.config,
  });
}
