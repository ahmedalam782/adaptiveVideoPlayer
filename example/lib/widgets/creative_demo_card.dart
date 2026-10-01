import 'package:flutter/material.dart';

import '../models/demo_showcase_item.dart';
import '../screens/studio_player_page.dart';

/// Card component representing a demo in the catalog
class CreativeDemoCard extends StatelessWidget {
  final DemoShowcaseItem demo;
  final bool isDark;
  final VoidCallback? onToggleLanguage;
  final String? currentLanguageCode;
  final ValueChanged<String>? onSelectLanguage;

  const CreativeDemoCard({
    super.key,
    required this.demo,
    required this.isDark,
    this.onToggleLanguage,
    this.currentLanguageCode,
    this.onSelectLanguage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131B2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: demo.accentColor.withValues(alpha: isDark ? 0.08 : 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StudioPlayerPage(
                  demo: demo,
                  onToggleLanguage: onToggleLanguage,
                  currentLanguageCode: currentLanguageCode,
                  onSelectLanguage: onSelectLanguage,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon Box
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            demo.accentColor,
                            demo.accentColor.withValues(alpha: 0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(demo.icon, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    // Title & Category
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            demo.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            demo.subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.5)
                                  : const Color(0xFF64748B),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Action button
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: demo.accentColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: demo.accentColor,
                        size: 22,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Tags
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: demo.tags.map((tag) {
                    final isLive = tag.toUpperCase().contains('LIVE');
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isLive
                            ? const Color(0xFFEF4444).withValues(alpha: 0.15)
                            : (isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isLive
                              ? const Color(0xFFEF4444).withValues(alpha: 0.4)
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              isLive ? FontWeight.w700 : FontWeight.w500,
                          color: isLive
                              ? const Color(0xFFEF4444)
                              : (isDark
                                  ? Colors.white.withValues(alpha: 0.7)
                                  : const Color(0xFF475569)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
