import 'package:flutter/material.dart';
import 'package:adaptive_video_player/adaptive_video_player.dart';

import '../models/demo_showcase_item.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import '../widgets/language_picker_sheet.dart';

/// Cinematic Player Page with Real-time Event Log Inspector
class StudioPlayerPage extends StatefulWidget {
  final DemoShowcaseItem demo;
  final VoidCallback? onToggleLanguage;
  final String? currentLanguageCode;
  final ValueChanged<String>? onSelectLanguage;

  const StudioPlayerPage({
    super.key,
    required this.demo,
    this.onToggleLanguage,
    this.currentLanguageCode,
    this.onSelectLanguage,
  });

  @override
  State<StudioPlayerPage> createState() => _StudioPlayerPageState();
}

class _StudioPlayerPageState extends State<StudioPlayerPage> {
  final List<String> _eventLogs = [];
  final ScrollController _logScrollController = ScrollController();
  final GlobalKey _playerKey = GlobalKey(debugLabel: 'StudioPlayerKey');

  @override
  void initState() {
    super.initState();
    NativePipService.setPipEnabled(true);
    NativePipService.isInPip.addListener(_onPipStateChanged);
  }

  void _onPipStateChanged() {
    if (mounted) setState(() {});
  }

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
    NativePipService.isInPip.removeListener(_onPipStateChanged);
    NativePipService.setPipEnabled(false);
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
      return VideoQuality(title: translatedTitle, url: q.url, isLive: q.isLive);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final demo = widget.demo;
    final activeCode = context.locale.languageCode;
    final selectedLang = LanguagePickerSheet.getLanguage(activeCode);
    final isRtl = selectedLang.isRtl;

    final basePlayerConfig = demo.config.playerConfig;
    final effectiveTextConfig = basePlayerConfig.text.isDefaultUnmodified
        ? PlayerTextConfig.tr(
            (key) => context.tr(key),
            languageCode: activeCode,
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          )
        : basePlayerConfig.text;

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

    final localizedQualities = _localizeDemoQualities(
      demo.config.qualities,
      isRtl,
    );
    final localizedInitialQuality =
        demo.config.initialQuality != null &&
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
      chapters: demo.config.chapters,
      viewerCount: localizedViewerCount,
      controlsBuilder: demo.config.controlsBuilder,
      subtitleBuilder: demo.config.subtitleBuilder,
      playerConfig: effectivePlayerConfig,
      onAnalyticsEvent: (event, data) {
        _recordEvent(event, data);
        demo.config.onAnalyticsEvent?.call(event, data);
      },
    );

    final playerWidget = KeyedSubtree(
      key: _playerKey,
      child: AdaptiveVideoPlayer(config: configWithAnalytics),
    );

    if (NativePipService.isInPip.value) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: SizedBox.expand(child: playerWidget)),
      );
    }

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
            InkWell(
              onTap: () {
                LanguagePickerSheet.show(
                  context,
                  currentLanguageCode: context.locale.languageCode,
                  onLanguageSelected: (lang) {
                    context.setLocale(Locale(lang.code));
                    widget.onSelectLanguage?.call(lang.code);
                  },
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white12),
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
                      selectedLang.code.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: Colors.cyanAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Ambient Glow & Video Frame
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Container(
                        width: double.infinity,
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
                            width: double.infinity,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight:
                                    MediaQuery.sizeOf(context).height * 0.70,
                              ),
                              child: playerWidget,
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
                                  color: demo.accentColor.withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: demo.accentColor.withValues(
                                      alpha: 0.4,
                                    ),
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
                                const Expanded(
                                  child: Text(
                                    'Live Analytics Stream',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
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
                                          color: Colors.white.withValues(
                                            alpha: 0.35,
                                          ),
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
        ),
      ),
    );
  }
}
