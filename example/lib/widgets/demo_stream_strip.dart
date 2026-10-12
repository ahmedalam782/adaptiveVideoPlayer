import 'package:flutter/material.dart';

class DemoStreamChoice {
  final String title;
  final bool isLive;
  final bool isYouTube;
  final bool selected;
  final VoidCallback onTap;

  const DemoStreamChoice({
    required this.title,
    required this.onTap,
    this.isLive = false,
    this.isYouTube = false,
    this.selected = false,
  });
}

class DemoStreamStrip extends StatelessWidget {
  final List<DemoStreamChoice> streams;
  final bool customSelected;
  final VoidCallback onCustomUrl;

  const DemoStreamStrip({
    super.key,
    required this.streams,
    required this.customSelected,
    required this.onCustomUrl,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: streams.length + 1,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return DemoStreamCard(
              title: customSelected ? 'Custom URL' : 'Paste a URL',
              detail: 'MP4, HLS, or YouTube',
              icon: Icons.add_link_rounded,
              accent: const Color(0xFF22D3EE),
              selected: customSelected,
              onTap: onCustomUrl,
            );
          }
          final stream = streams[index - 1];
          return DemoStreamCard(
            title: stream.title,
            detail: stream.isYouTube
                ? 'YouTube'
                : (stream.isLive ? 'Live' : 'Video'),
            icon: stream.isYouTube
                ? Icons.smart_display_rounded
                : (stream.isLive
                    ? Icons.sensors_rounded
                    : Icons.movie_filter_rounded),
            accent: stream.isYouTube
                ? const Color(0xFFEF4444)
                : (stream.isLive
                    ? const Color(0xFFF43F5E)
                    : const Color(0xFF818CF8)),
            selected: stream.selected,
            onTap: stream.onTap,
          );
        },
      ),
    );
  }
}

class DemoStreamCard extends StatelessWidget {
  final String title;
  final String detail;
  final IconData icon;
  final Color accent;
  final bool selected;
  final VoidCallback onTap;

  const DemoStreamCard({
    super.key,
    required this.title,
    required this.detail,
    required this.icon,
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: 210,
      child: Material(
        color: selected
            ? accent.withValues(alpha: isDark ? 0.16 : 0.10)
            : (isDark ? const Color(0xFF0F1522) : const Color(0xFFF8FAFC)),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected
                    ? accent
                    : (isDark ? const Color(0xFF2A3348) : const Color(0xFFE2E8F0)),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(icon, color: accent, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          detail,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white54 : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
