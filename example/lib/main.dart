import 'package:flutter/material.dart';
import 'package:adaptive_video_player/adaptive_video_player.dart';

void main() {
  AdaptiveVideoPlayerPlatform.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    const primarySeed = Color(0xFF6366F1); // Indigo

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Adaptive Video Player Studio',
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: primarySeed,
          brightness: Brightness.light,
          surface: Colors.white,
          surfaceContainerHigh: const Color(0xFFEDF2F7),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF090D16),
        colorScheme: ColorScheme.fromSeed(
          seedColor: primarySeed,
          brightness: Brightness.dark,
          surface: const Color(0xFF111726),
          surfaceContainerHigh: const Color(0xFF182032),
        ),
      ),
      home: ShowcaseScreen(
        isDark: _themeMode == ThemeMode.dark,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

/// Catalog item representation
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

class ShowcaseScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const ShowcaseScreen({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  State<ShowcaseScreen> createState() => _ShowcaseScreenState();
}

class _ShowcaseScreenState extends State<ShowcaseScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'YouTube',
    'Direct Stream',
    'HLS Live',
    'Captions',
  ];

  List<DemoShowcaseItem> _buildDemos() {
    return [
      DemoShowcaseItem(
        title: 'Multi-Res MP4 & Dual Subtitles',
        subtitle: 'Quality picker (Auto/HD/SD) + Arabic & English sync captions',
        category: 'Captions',
        tags: const ['MP4', 'Quality Picker', 'SRT Subtitles', 'Analytics'],
        icon: Icons.subtitles_rounded,
        accentColor: const Color(0xFF6366F1),
        config: VideoConfig(
          videoUrl:
              'https://www.mp3quran.net/uploads/videos/group1_pbuh/maher.mp4',
          subtitles: const [
            SubtitleTrack(
              id: 'en',
              title: 'English CC',
              content: '''
1
00:00:01,000 --> 00:00:04,000
Adaptive Video Player in action.

2
00:00:04,500 --> 00:00:08,000
Real-time subtitle overlays synced perfectly.
              ''',
            ),
            SubtitleTrack(
              id: 'ar',
              title: 'عربي (Arabic)',
              content: '''
1
00:00:01,000 --> 00:00:04,000
مشغل الفيديو التكيفي فائق الأداء.

2
00:00:04,500 --> 00:00:08,000
دعم ترجمة مدمجة ثنائية اللغة وتوافق كامل.
              ''',
            ),
          ],
          initialSubtitle: const SubtitleTrack(
            id: 'en',
            title: 'English CC',
          ),
          qualities: const [
            VideoQuality(
              title: 'Auto (HLS)',
              url: 'https://upload.mp3quran.net/group1_pbuh/maher.mp4',
            ),
            VideoQuality(
              title: '1080p HD',
              url: 'https://upload.mp3quran.net/group1_pbuh/maher.mp4',
            ),
            VideoQuality(
              title: '720p SD',
              url: 'https://upload.mp3quran.net/group1_pbuh/maher.mp4',
            ),
          ],
          initialQuality: const VideoQuality(
            title: 'Auto (HLS)',
            url: 'https://upload.mp3quran.net/group1_pbuh/maher.mp4',
          ),
        ),
      ),
      const DemoShowcaseItem(
        title: 'HLS Live Stream & Recording Switcher',
        subtitle: 'Seamless switching between recorded MP4 and live HLS stream',
        category: 'HLS Live',
        tags: ['HLS .m3u8', 'Live Stream', 'Dynamic Switching'],
        icon: Icons.sensors_rounded,
        accentColor: Color(0xFFEC4899),
        config: VideoConfig(
          videoUrl: 'https://upload.mp3quran.net/group1_pbuh/maher.mp4',
          viewerCount: '142k VIEWERS',
          qualities: [
            VideoQuality(
              title: 'Recorded Episode (MP4)',
              url: 'https://upload.mp3quran.net/group1_pbuh/maher.mp4',
              isLive: false,
            ),
            VideoQuality(
              title: 'Mux HLS Stream (.m3u8)',
              url: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
              isLive: true,
            ),
          ],
        ),
      ),
      DemoShowcaseItem(
        title: 'YouTube Native & Desktop WebView Mode',
        subtitle:
            'Platform-aware player with runtime settings sheet & force desktop mode',
        category: 'YouTube',
        tags: const ['YouTube', 'Desktop Mode', 'Settings Panel', 'Safe Links'],
        icon: Icons.smart_display_rounded,
        accentColor: const Color(0xFFEF4444),
        config: VideoConfig(
          videoUrl: 'https://www.youtube.com/watch?v=aqz-KE-bpKQ',
          playerConfig: const YouTubePlayerConfig(
            playback: PlayerPlaybackConfig(
              forceDesktopMode: true,
              autoPlay: true,
            ),
            text: PlayerTextConfig(
              playerSettingsText: 'Settings & Quality',
              autoPlayText: 'Auto Play Next',
              loopVideoText: 'Loop Playback',
              forceHdQualityText: 'Force HD Quality',
              enableCaptionsText: 'Captions (CC)',
              muteAudioText: 'Mute Audio',
            ),
          ),
        ),
      ),
      const DemoShowcaseItem(
        title: 'YouTube Live Stream (Continuous)',
        subtitle: 'Live indicator badge with stream viewer counter',
        category: 'YouTube',
        tags: ['YouTube Live', 'Continuous Feed', 'Live Badge'],
        icon: Icons.stream_rounded,
        accentColor: Color(0xFFF59E0B),
        config: VideoConfig(
          videoUrl: 'https://www.youtube.com/watch?v=bNyUyrR0PHo',
          isLive: true,
          viewerCount: '15.4K',
        ),
      ),
      const DemoShowcaseItem(
        title: 'Direct Fast MP4 Stream',
        subtitle: 'Hardware-accelerated direct streaming with double-tap seek',
        category: 'Direct Stream',
        tags: ['Direct Stream', 'Double-Tap ±10s', 'Smooth Scrubbing'],
        icon: Icons.movie_filter_rounded,
        accentColor: Color(0xFF10B981),
        config: VideoConfig(
          videoUrl: 'https://upload.mp3quran.net/group1_pbuh/maher.mp4',
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = widget.isDark;
    final allDemos = _buildDemos();
    final filteredDemos = _selectedCategory == 'All'
        ? allDemos
        : allDemos.where((d) => d.category == _selectedCategory).toList();

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Elegant Floating Header
          SliverAppBar(
            pinned: true,
            expandedHeight: 250,
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            actions: [
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
              const SizedBox(width: 16),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            const Color(0xFF1E1B4B).withValues(alpha: 0.7),
                            const Color(0xFF0F172A).withValues(alpha: 0.9),
                            theme.scaffoldBackgroundColor,
                          ]
                        : [
                            const Color(0xFFEEF2FF),
                            const Color(0xFFF1F5F9),
                            theme.scaffoldBackgroundColor,
                          ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Version & Status Pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1)
                                .withValues(alpha: isDark ? 0.2 : 0.12),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: const Color(0xFF6366F1)
                                  .withValues(alpha: 0.35),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'v2.0.0 • Pure ValueNotifier • 0 Dependencies',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF6366F1),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Title
                        Text(
                          'Adaptive Video Player',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'YouTube & Direct URLs in one seamless, cross-platform engine.',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.65)
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

          // Feature Highlights Strip
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildMetricBadge(
                    icon: Icons.devices_rounded,
                    label: '6 Platforms',
                    value: 'Web, Win, Mac, Linux, Mobile',
                    isDark: isDark,
                  ),
                  const SizedBox(width: 10),
                  _buildMetricBadge(
                    icon: Icons.bolt_rounded,
                    label: 'Ultra Light',
                    value: 'Native ValueNotifier',
                    isDark: isDark,
                  ),
                  const SizedBox(width: 10),
                  _buildMetricBadge(
                    icon: Icons.tune_rounded,
                    label: 'Adaptive UI',
                    value: 'Live CC & Quality Picker',
                    isDark: isDark,
                  ),
                  const SizedBox(width: 10),
                  _buildMetricBadge(
                    icon: Icons.touch_app_rounded,
                    label: 'Gestures',
                    value: 'Double-Tap ±10s Seek',
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),

          // Category Chips
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _categories.map((cat) {
                    final isSelected = cat == _selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedCategory = cat);
                          }
                        },
                        showCheckmark: false,
                        selectedColor: const Color(0xFF6366F1),
                        labelStyle: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                  ? Colors.white70
                                  : const Color(0xFF475569)),
                        ),
                        backgroundColor: isDark
                            ? const Color(0xFF1E293B).withValues(alpha: 0.6)
                            : const Color(0xFFE2E8F0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isSelected
                                ? Colors.transparent
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.black.withValues(alpha: 0.04)),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          // Cards List
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            sliver: SliverList.separated(
              itemCount: filteredDemos.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final demo = filteredDemos[index];
                return _CreativeDemoCard(demo: demo, isDark: isDark);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricBadge({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131A2A) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF6366F1)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 10,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.5)
                      : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CreativeDemoCard extends StatelessWidget {
  final DemoShowcaseItem demo;
  final bool isDark;

  const _CreativeDemoCard({
    required this.demo,
    required this.isDark,
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
                builder: (_) => StudioPlayerPage(demo: demo),
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
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            demo.accentColor,
                            demo.accentColor.withValues(alpha: 0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: demo.accentColor.withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(demo.icon, color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 16),
                    // Title and subtitle
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
                              height: 1.4,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.6)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
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
                          fontWeight: isLive ? FontWeight.w700 : FontWeight.w500,
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

/// Cinematic Player Page with Real-time Event Log Inspector
class StudioPlayerPage extends StatefulWidget {
  final DemoShowcaseItem demo;

  const StudioPlayerPage({super.key, required this.demo});

  @override
  State<StudioPlayerPage> createState() => _StudioPlayerPageState();
}

class _StudioPlayerPageState extends State<StudioPlayerPage> {
  final List<String> _eventLogs = [];
  final ScrollController _logScrollController = ScrollController();

  void _recordEvent(String event, Map<String, dynamic> data) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final timeStr = TimeOfDay.now().format(context);
      setState(() {
        _eventLogs.insert(0, '[$timeStr] $event $data');
        if (_eventLogs.length > 50) _eventLogs.removeLast();
      });
    });
  }

  @override
  void dispose() {
    _logScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final demo = widget.demo;

    // Attach real-time analytics logger to config
    final configWithAnalytics = VideoConfig(
      videoUrl: demo.config.videoUrl,
      isFile: demo.config.isFile,
      isLive: demo.config.isLive,
      videoBytes: demo.config.videoBytes,
      qualities: demo.config.qualities,
      initialQuality: demo.config.initialQuality,
      subtitles: demo.config.subtitles,
      initialSubtitle: demo.config.initialSubtitle,
      viewerCount: demo.config.viewerCount,
      controlsBuilder: demo.config.controlsBuilder,
      subtitleBuilder: demo.config.subtitleBuilder,
      playerConfig: demo.config.playerConfig,
      onAnalyticsEvent: (event, data) {
        _recordEvent(event, data);
        demo.config.onAnalyticsEvent?.call(event, data);
      },
    );

    return Scaffold(
      backgroundColor: const Color(0xFF07090E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          demo.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ambient Glow & Video Frame
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: demo.accentColor.withValues(alpha: 0.25),
                        blurRadius: 36,
                        spreadRadius: -4,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      color: Colors.black,
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: AdaptiveVideoPlayer(config: configWithAnalytics),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Video Meta Details
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: demo.accentColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: demo.accentColor.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Text(
                            demo.category.toUpperCase(),
                            style: TextStyle(
                              color: demo.accentColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (demo.config.viewerCount != null) ...[
                          const Icon(
                            Icons.visibility_rounded,
                            size: 16,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            demo.config.viewerCount!,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      demo.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      demo.subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.6),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Live Analytics & Events Log
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF101420),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.terminal_rounded,
                            size: 18,
                            color: Color(0xFF10B981),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Live Analytics Stream',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${_eventLogs.length} events',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 140,
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF090D15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: _eventLogs.isEmpty
                            ? Center(
                                child: Text(
                                  'Interact with player (play, pause, seek, settings)\nto view live analytics stream here.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.35),
                                    height: 1.4,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                controller: _logScrollController,
                                itemCount: _eventLogs.length,
                                itemBuilder: (context, i) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 2,
                                    ),
                                    child: Text(
                                      _eventLogs[i],
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 11,
                                        color: Color(0xFF34D399),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
