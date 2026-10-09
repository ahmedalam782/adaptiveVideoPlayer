import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:adaptive_video_player/adaptive_video_player.dart';

import '../data/demo_catalog.dart';
import '../models/demo_showcase_item.dart';
import '../widgets/language_picker_sheet.dart';
import 'full_features_example_screen.dart';
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
  final ScrollController _chipsScrollController = ScrollController();
  int _selected = 0;

  @override
  void initState() {
    super.initState();
    _sources = studioSources();
    NativePipService.isInPip.addListener(_onPipChanged);
  }

  void _scrollChips(double offsetDelta) {
    if (!_chipsScrollController.hasClients) return;
    final target = (_chipsScrollController.offset + offsetDelta).clamp(
      0.0,
      _chipsScrollController.position.maxScrollExtent,
    );
    _chipsScrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
  }

  void _onSelectSource(int index) {
    if (_selected == index) return;
    setState(() => _selected = index);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_chipsScrollController.hasClients) return;
      final target = (index * 170.0 - 100.0).clamp(
        0.0,
        _chipsScrollController.position.maxScrollExtent,
      );
      _chipsScrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _chipsScrollController.dispose();
    NativePipService.isInPip.removeListener(_onPipChanged);
    super.dispose();
  }

  void _onPipChanged() {
    if (mounted) setState(() {});
  }

  void _showCustomUrlDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.add_link_rounded, color: Colors.indigoAccent),
              SizedBox(width: 8),
              Text('Play Custom Video URL', style: TextStyle(fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter any direct stream URL (MP4, HLS .m3u8, DASH .mpd) or YouTube URL:',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'https://...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.link_rounded),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Play'),
              onPressed: () {
                final text = controller.text.trim();
                if (text.isEmpty) return;
                Navigator.pop(ctx);
                setState(() {
                  final isYt = text.contains('youtube.com') || text.contains('youtu.be');
                  final isHls = text.contains('.m3u8');
                  final customSource = StudioSource(
                    id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                    label: isYt ? 'Custom YouTube' : (isHls ? 'Custom HLS' : 'Custom Video'),
                    description: text,
                    icon: isYt
                        ? Icons.smart_display_rounded
                        : (isHls ? Icons.sensors_rounded : Icons.play_circle_filled_rounded),
                    accentColor: isYt
                        ? Colors.redAccent
                        : (isHls ? Colors.pinkAccent : Colors.tealAccent),
                    features: const ['Custom URL', 'Adaptive Controls', 'PiP & Fullscreen'],
                    config: VideoConfig(
                      videoUrl: text,
                      title: 'Custom User Stream',
                      extension: isHls ? VideoFileExtension.hls : null,
                    ),
                  );
                  _sources.insert(0, customSource);
                  _selected = 0;
                });
              },
            ),
          ],
        );
      },
    );
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

    final screenH = MediaQuery.sizeOf(context).height;
    final isCompact = screenH < 750;
    final expandedHeight = isCompact ? 116.0 : 168.0;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: expandedHeight,
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            actions: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FullFeaturesExampleScreen(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.10)
                            : Colors.white.withValues(alpha: 0.60),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.18)
                              : Colors.black.withValues(alpha: 0.08),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(alpha: isDark ? 0.25 : 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.auto_awesome_rounded,
                            size: 15,
                            color: Colors.pinkAccent,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'All Features',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              color: isDark
                                  ? Colors.pinkAccent
                                  : Colors.purple,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: InkWell(
                    onTap: () {
                      LanguagePickerSheet.show(
                        context,
                        currentLanguageCode: widget.currentLanguageCode,
                        onLanguageSelected: (lang) =>
                            widget.onSelectLanguage(lang.code),
                      );
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.10)
                            : Colors.white.withValues(alpha: 0.60),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.18)
                              : Colors.black.withValues(alpha: 0.08),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(alpha: isDark ? 0.25 : 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
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
                              color: isDark
                                  ? Colors.cyanAccent
                                  : Colors.blueAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.10)
                          : Colors.white.withValues(alpha: 0.60),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.18)
                            : Colors.black.withValues(alpha: 0.08),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: isDark ? 0.25 : 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      tooltip: isDark ? 'Switch to Light' : 'Switch to Dark',
                      icon: Icon(
                        isDark
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        color: isDark ? Colors.amberAccent : Colors.indigo,
                      ),
                      onPressed: widget.onToggleTheme,
                    ),
                  ),
                ),
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
                    padding: EdgeInsets.fromLTRB(
                      20,
                      isCompact ? 10 : 16,
                      20,
                      isCompact ? 8 : 12,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Adaptive Video Player Studio',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: isCompact ? 18 : 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.4,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(height: isCompact ? 2 : 4),
                        Text(
                          'One player. Choose a normal URL, a live stream, YouTube, or YouTube live.',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: isCompact ? 11.5 : 13,
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
              padding: EdgeInsets.fromLTRB(
                8,
                isCompact ? 6 : 14,
                8,
                isCompact ? 6 : 12,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded, size: 24),
                    tooltip: 'Scroll left',
                    splashRadius: 18,
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _scrollChips(-260),
                  ),
                  Expanded(
                    child: Scrollbar(
                      controller: _chipsScrollController,
                      thumbVisibility: true,
                      thickness: 4,
                      radius: const Radius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: SingleChildScrollView(
                          controller: _chipsScrollController,
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        avatar: const Icon(
                          Icons.add_link_rounded,
                          size: 16,
                          color: Colors.cyanAccent,
                        ),
                        label: const Text('+ Custom URL'),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.cyanAccent : Colors.teal.shade800,
                        ),
                        backgroundColor: isDark
                            ? Colors.cyanAccent.withValues(alpha: 0.12)
                            : Colors.cyan.withValues(alpha: 0.15),
                        side: BorderSide(
                          color: Colors.cyanAccent.withValues(alpha: 0.35),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onPressed: _showCustomUrlDialog,
                      ),
                    ),
                    for (var i = 0; i < _sources.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: FilterChip(
                              selected: i == _selected,
                              showCheckmark: false,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
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
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.white.withValues(alpha: 0.65),
                              side: BorderSide(
                                color: i == _selected
                                    ? _sources[i].accentColor
                                    : (isDark
                                        ? Colors.white.withValues(alpha: 0.15)
                                        : Colors.black.withValues(alpha: 0.08)),
                              ),
                              onSelected: (_) => _onSelectSource(i),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right_rounded, size: 24),
          tooltip: 'Scroll right',
          splashRadius: 18,
          visualDensity: VisualDensity.compact,
          onPressed: () => _scrollChips(260),
        ),
      ],
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
