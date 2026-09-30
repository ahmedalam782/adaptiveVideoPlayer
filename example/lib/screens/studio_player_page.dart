import 'package:flutter/material.dart';
import 'package:adaptive_video_player/adaptive_video_player.dart';

import '../models/demo_showcase_item.dart';

/// Cinematic Player Page with Real-time Event Log Inspector
class StudioPlayerPage extends StatefulWidget {
  final DemoShowcaseItem demo;
  final VoidCallback? onToggleLanguage;

  const StudioPlayerPage({
    super.key,
    required this.demo,
    this.onToggleLanguage,
  });

  @override
  State<StudioPlayerPage> createState() => _StudioPlayerPageState();
}

class _StudioPlayerPageState extends State<StudioPlayerPage> {
  final List<String> _eventLogs = [];
  final ScrollController _logScrollController = ScrollController();
  bool? _localRtlOverride;

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

  List<VideoQuality>? _localizeDemoQualities(
    List<VideoQuality>? qualities,
    bool isRtl,
  ) {
    if (qualities == null) return null;
    return qualities.map((q) {
      final translatedTitle = switch (q.title) {
        'Auto (HLS)' => isRtl ? 'تلقائي (HLS)' : 'Auto (HLS)',
        '1080p HD' => isRtl ? '1080p عالي الدقة' : '1080p HD',
        '720p SD' => isRtl ? '720p قياسي' : '720p SD',
        'Recorded Episode (MP4)' =>
          isRtl ? 'حلقة مسجلة (MP4)' : 'Recorded Episode (MP4)',
        'Mux HLS Stream (.m3u8)' =>
          isRtl ? 'بث مباشر HLS (.m3u8)' : 'Mux HLS Stream (.m3u8)',
        _ => q.title,
      };
      return VideoQuality(
        title: translatedTitle,
        url: q.url,
        isLive: q.isLive,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final demo = widget.demo;
    final ambientIsRtl = Directionality.of(context) == TextDirection.rtl ||
        Localizations.maybeLocaleOf(context)?.languageCode == 'ar' ||
        demo.config.messages.resolveTextDirection(context) == TextDirection.rtl;
    final isRtl = _localRtlOverride ?? ambientIsRtl;

    final basePlayerConfig = demo.config.playerConfig;
    final effectiveTextConfig = isRtl
        ? const PlayerTextConfig.arabic()
        : (_localRtlOverride == false
            ? const PlayerTextConfig.english()
            : basePlayerConfig.text);

    final effectivePlayerConfig = YouTubePlayerConfig(
      style: basePlayerConfig.style,
      text: effectiveTextConfig,
      visibility: basePlayerConfig.visibility,
      playback: basePlayerConfig.playback,
      loadingBuilder: basePlayerConfig.loadingBuilder,
      errorBuilder: basePlayerConfig.errorBuilder,
      replayBuilder: basePlayerConfig.replayBuilder,
      liveBadgeBuilder: basePlayerConfig.liveBadgeBuilder,
    );

    final localizedQualities =
        _localizeDemoQualities(demo.config.qualities, isRtl);
    final localizedInitialQuality = demo.config.initialQuality != null &&
            localizedQualities != null &&
            localizedQualities.isNotEmpty
        ? localizedQualities.firstWhere(
            (q) => q.url == demo.config.initialQuality!.url,
            orElse: () => localizedQualities.first,
          )
        : null;

    final localizedViewerCount = switch (demo.config.viewerCount) {
      '142k VIEWERS' => isRtl ? '142 ألف مشاهد' : '142k VIEWERS',
      '15.4K' => isRtl ? '15.4 ألف مشاهد' : '15.4K',
      _ => demo.config.viewerCount,
    };

    // Attach real-time analytics logger to config
    final configWithAnalytics = VideoConfig(
      videoUrl: demo.config.videoUrl,
      isFile: demo.config.isFile,
      isLive: demo.config.isLive,
      videoBytes: demo.config.videoBytes,
      qualities: localizedQualities,
      initialQuality: localizedInitialQuality,
      subtitles: demo.config.subtitles,
      initialSubtitle: demo.config.initialSubtitle,
      chapters: demo.config.chapters ??
          (demo.config.isLive
              ? null
              : [
                  VideoChapter(
                    title: isRtl ? 'المقدمة' : 'Intro',
                    startTime: Duration.zero,
                  ),
                  VideoChapter(
                    title: isRtl ? 'المشهد الرئيسي' : 'Main Scene',
                    startTime: const Duration(seconds: 20),
                  ),
                  VideoChapter(
                    title: isRtl ? 'ذروة الأحداث' : 'Action Climax',
                    startTime: const Duration(seconds: 45),
                  ),
                ]),
      viewerCount: localizedViewerCount,
      controlsBuilder: demo.config.controlsBuilder,
      subtitleBuilder: demo.config.subtitleBuilder,
      playerConfig: effectivePlayerConfig,
      onAnalyticsEvent: (event, data) {
        _recordEvent(event, data);
        demo.config.onAnalyticsEvent?.call(event, data);
      },
    );

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
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
          actions: [
            IconButton(
              tooltip: isRtl
                  ? 'Switch to English (LTR)'
                  : 'التبديل إلى العربية (RTL)',
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.08),
              ),
              icon: Text(
                isRtl ? 'EN' : 'عربي',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  color: Colors.cyanAccent,
                ),
              ),
              onPressed: () {
                setState(() {
                  _localRtlOverride = !isRtl;
                });
                widget.onToggleLanguage?.call();
              },
            ),
            const SizedBox(width: 12),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ambient Glow & Video Frame
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          child:
                              AdaptiveVideoPlayer(config: configWithAnalytics),
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
    ),
    );
  }
}
