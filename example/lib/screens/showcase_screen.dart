import 'package:flutter/material.dart';
import 'package:adaptive_video_player/adaptive_video_player.dart';

import '../data/demo_catalog.dart';
import '../models/demo_showcase_item.dart';
import '../widgets/language_picker_sheet.dart';
import 'studio_player_page.dart';

/// One studio screen: pick a source, keep the same player and features.
class ShowcaseScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;
  final String currentLanguageCode;
  final ValueChanged<String> onSelectLanguage;

  const ShowcaseScreen({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
    required this.currentLanguageCode,
    required this.onSelectLanguage,
  });

  @override
  State<ShowcaseScreen> createState() => _ShowcaseScreenState();
}

class _ShowcaseScreenState extends State<ShowcaseScreen> {
  late final List<StudioSource> _sources;
  final GlobalKey _stageKey = GlobalKey();
  int _selected = 0;

  @override
  void initState() {
    super.initState();
    _sources = studioSources();
    NativePipService.isInPip.addListener(_onPipChanged);
  }

  @override
  void dispose() {
    NativePipService.isInPip.removeListener(_onPipChanged);
    super.dispose();
  }

  void _onPipChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = widget.isDark;
    final currentLang =
        LanguagePickerSheet.getLanguage(widget.currentLanguageCode);
    final selected = _sources[_selected];
    final stage = StudioStage(
      key: _stageKey,
      source: selected,
      isDark: isDark,
      currentLanguageCode: widget.currentLanguageCode,
    );

    if (NativePipService.isInPip.value) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SizedBox.expand(child: stage),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 168,
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            actions: [
              InkWell(
                onTap: () {
                  LanguagePickerSheet.show(
                    context,
                    currentLanguageCode: widget.currentLanguageCode,
                    onLanguageSelected: (lang) =>
                        widget.onSelectLanguage(lang.code),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.black12,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.translate_rounded,
                        size: 15,
                        color: Colors.cyanAccent,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        currentLang.code.toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: isDark ? Colors.cyanAccent : Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: isDark ? 'Switch to Light' : 'Switch to Dark',
                style: IconButton.styleFrom(
                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.05),
                ),
                icon: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: isDark ? Colors.amberAccent : Colors.indigo,
                ),
                onPressed: widget.onToggleTheme,
              ),
              const SizedBox(width: 12),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? const [
                            Color(0xFF1E1B4B),
                            Color(0xFF0F172A),
                            Color(0xFF020617),
                          ]
                        : const [
                            Color(0xFFEEF2FF),
                            Color(0xFFE0E7FF),
                            Color(0xFFF8FAFC),
                          ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Adaptive Video Player Studio',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.4,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'One player. Choose a normal URL, a live stream, YouTube, or YouTube live.',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.6)
                                : const Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    for (var i = 0; i < _sources.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          selected: i == _selected,
                          showCheckmark: false,
                          avatar: Icon(
                            _sources[i].icon,
                            size: 16,
                            color: i == _selected
                                ? Colors.white
                                : _sources[i].accentColor,
                          ),
                          label: Text(_sources[i].label),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: i == _selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: i == _selected
                                ? Colors.white
                                : (isDark ? Colors.white70 : Colors.black87),
                          ),
                          selectedColor: _sources[i].accentColor,
                          backgroundColor: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.04),
                          side: BorderSide(
                            color: i == _selected
                                ? _sources[i].accentColor
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.black.withValues(alpha: 0.06)),
                          ),
                          onSelected: (_) => setState(() => _selected = i),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: stage),
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
        ],
      ),
    );
  }
}
