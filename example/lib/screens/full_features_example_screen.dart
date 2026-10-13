import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:adaptive_video_player/adaptive_video_player.dart';
import '../widgets/demo_preview_stage.dart';
import '../widgets/demo_stream_strip.dart';
import '../widgets/language_picker_sheet.dart';

/// Complete, production-grade single screen demonstrating EVERY feature in
/// `adaptive_video_player`.
class FullFeaturesExampleScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback? onToggleTheme;
  final String? currentLanguageCode;
  final ValueChanged<String>? onSelectLanguage;

  const FullFeaturesExampleScreen({
    super.key,
    this.isDark = true,
    this.onToggleTheme,
    this.currentLanguageCode,
    this.onSelectLanguage,
  });

  @override
  State<FullFeaturesExampleScreen> createState() =>
      _FullFeaturesExampleScreenState();
}

class _FullFeaturesExampleScreenState extends State<FullFeaturesExampleScreen> {
  // Real-world video streams (VOD MP4, Adaptive HLS, and YouTube)
  static final List<
    ({
      String title,
      String url,
      bool isYouTube,
      bool isLive,
      String? viewerCount,
    })
  >
  _sampleStreams = [
    (
      title: 'Big Buck Bunny (Akamai 720p MP4)',
      url:
          'https://dash.akamaized.net/akamai/bbb_30fps/bbb_30fps_1280x720_4000k.mp4',
      isYouTube: false,
      isLive: false,
      viewerCount: null,
    ),
    (
      title: 'Oceans Nature (VideoJS CDN MP4)',
      url: 'https://vjs.zencdn.net/v/oceans.mp4',
      isYouTube: false,
      isLive: false,
      viewerCount: null,
    ),
    (
      title: 'Bunny Teaser (Akamai 1080p MP4)',
      url:
          'https://dash.akamaized.net/akamai/bbb_30fps/bbb_30fps_1920x1080_8000k.mp4',
      isYouTube: false,
      isLive: false,
      viewerCount: null,
    ),
    (
      title: 'Blooming Flower (MDN HD MP4)',
      url:
          'https://interactive-examples.mdn.mozilla.net/media/cc0-videos/flower.mp4',
      isYouTube: false,
      isLive: false,
      viewerCount: null,
    ),
    (
      title: kIsWeb
          ? 'City Life Stream (MDN HD MP4)'
          : 'Mux CDN Stream (Adaptive HLS)',
      url: kIsWeb
          ? 'https://interactive-examples.mdn.mozilla.net/media/cc0-videos/friday.mp4'
          : 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
      isYouTube: false,
      isLive: false,
      viewerCount: null,
    ),
    (
      title: kIsWeb
          ? 'Akamai 24/7 Broadcast (HD Stream)'
          : 'Akamai 24/7 Live (HLS)',
      url: kIsWeb
          ? 'https://dash.akamaized.net/akamai/bbb_30fps/bbb_30fps_1920x1080_8000k.mp4'
          : 'https://cph-p2p-msl.akamaized.net/hls/live/2000341/test/master.m3u8',
      isYouTube: false,
      isLive: true,
      viewerCount: '89.4K LIVE',
    ),
    (
      title: 'Quran Recitation (MP4)',
      url: 'https://upload.mp3quran.net/group1_pbuh/maher.mp4',
      isYouTube: false,
      isLive: false,
      viewerCount: null,
    ),
    (
      title: 'Costa Rica 4K HDR (YouTube)',
      url: 'https://www.youtube.com/watch?v=LXb3EKWsInQ',
      isYouTube: true,
      isLive: false,
      viewerCount: null,
    ),
    (
      title: 'Big Buck Bunny 60fps (YouTube)',
      url: 'https://www.youtube.com/watch?v=aqz-KE-bpKQ',
      isYouTube: true,
      isLive: false,
      viewerCount: null,
    ),
    (
      title: 'Lofi Girl 24/7 (YouTube Live)',
      url: 'https://www.youtube.com/watch?v=jfKfPfyJRdk',
      isYouTube: true,
      isLive: true,
      viewerCount: '48.2K VIEWERS',
    ),
    (
      title: 'NASA Earth Orbit (YouTube Live)',
      url: 'https://www.youtube.com/watch?v=21X5lGlDOfg',
      isYouTube: true,
      isLive: true,
      viewerCount: '12.5K VIEWERS',
    ),
  ];

  int _selectedStreamIndex = 0;
  String? _customStreamUrl;

  bool _showActionsInTopBar = true;
  BottomBarLayout _bottomBarLayout = BottomBarLayout.inline;
  BoxFit _videoFit = BoxFit.contain;
  bool _enableCache = true;
  bool _preventScreenCapture = false;

  // Active episodes list pointing to real videos
  final List<VideoEpisode> _episodes = const [
    VideoEpisode(
      id: 'ep1',
      number: 1,
      title: 'Episode 1: Big Buck Bunny (720p)',
      description: 'Bunny awakens and greets the woodland creatures in HD.',
      duration: Duration(minutes: 9, seconds: 56),
      watchedProgress: 0.85,
      videoUrl:
          'https://dash.akamaized.net/akamai/bbb_30fps/bbb_30fps_1280x720_4000k.mp4',
      extra: {'season': '1'},
    ),
    VideoEpisode(
      id: 'ep2',
      number: 2,
      title: 'Episode 2: Oceans Documentary',
      description: 'Deep ocean life and coastal coral reefs in cinema clarity.',
      duration: Duration(seconds: 46),
      watchedProgress: 0.40,
      videoUrl: 'https://vjs.zencdn.net/v/oceans.mp4',
      extra: {'season': '1'},
    ),
    VideoEpisode(
      id: 'ep3',
      number: 3,
      title: 'Episode 3: Big Buck Bunny (1080p)',
      description: 'Cinema-grade 1080p full HD master stream from Akamai.',
      duration: Duration(minutes: 9, seconds: 56),
      watchedProgress: 0.10,
      videoUrl:
          'https://dash.akamaized.net/akamai/bbb_30fps/bbb_30fps_1920x1080_8000k.mp4',
      extra: {'season': '2'},
    ),
    VideoEpisode(
      id: 'ep4',
      number: 4,
      title: 'Episode 4: Sacred Recitation',
      description: 'High-fidelity audio and video recitation stream.',
      duration: Duration(minutes: 10, seconds: 53),
      watchedProgress: 0.0,
      videoUrl: 'https://upload.mp3quran.net/group1_pbuh/maher.mp4',
      extra: {'season': '2'},
    ),
  ];
  late VideoEpisode _currentEpisode;

  // Active audio tracks
  final List<AudioTrack> _audioTracks = const [
    AudioTrack(
      id: 'en_orig',
      label: 'English [Original]',
      language: 'en',
      isOriginal: true,
      isDefault: true,
    ),
    AudioTrack(
      id: 'en_desc',
      label: 'English [Audio Description]',
      language: 'en',
      isAudioDescription: true,
    ),
    AudioTrack(id: 'ar', label: 'Arabic (العربية)', language: 'ar'),
    AudioTrack(id: 'fr', label: 'French (Français)', language: 'fr'),
  ];
  late AudioTrack _currentAudioTrack;

  // Active subtitle tracks
  final List<SubtitleTrack> _subtitles = [
    SubtitleTrack.fromAsset(
      id: 'ar_asset',
      title: 'العربية (SRT Asset)',
      assetPath: 'assets/subtitles/avengers_endgame_ar.srt',
    ),
    const SubtitleTrack(
      id: 'en_cc',
      title: 'English CC',
      content: '''
1
00:00:01,000 --> 00:00:04,500
Adaptive Video Player in action.

2
00:00:05,000 --> 00:00:09,000
Featuring Netflix circular loader and top-end actions!
''',
    ),
  ];
  SubtitleTrack? _currentSubtitleTrack;

  // Quality levels pointing to real resolutions
  final List<VideoQuality> _qualities = const [
    VideoQuality(
      title: 'Auto (1080p)',
      url:
          'https://dash.akamaized.net/akamai/bbb_30fps/bbb_30fps_1920x1080_8000k.mp4',
    ),
    VideoQuality(
      title: '1080p HD',
      url:
          'https://dash.akamaized.net/akamai/bbb_30fps/bbb_30fps_1920x1080_8000k.mp4',
    ),
    VideoQuality(
      title: '720p HD',
      url:
          'https://dash.akamaized.net/akamai/bbb_30fps/bbb_30fps_1280x720_4000k.mp4',
    ),
    VideoQuality(
      title: '360p SD',
      url:
          'https://dash.akamaized.net/akamai/bbb_30fps/bbb_30fps_640x360_1000k.mp4',
    ),
  ];
  late VideoQuality _currentQuality;

  // Chapters
  final List<VideoChapter> _chapters = const [
    VideoChapter(title: 'Opening & Intro', startTime: Duration.zero),
    VideoChapter(title: 'Act I: Discovery', startTime: Duration(seconds: 10)),
    VideoChapter(
      title: 'Act II: The Encounter',
      startTime: Duration(seconds: 20),
    ),
    VideoChapter(title: 'Credits', startTime: Duration(seconds: 28)),
  ];

  // Event telemetry logs
  final List<String> _eventLogs = [];
  Key _playerKey = GlobalKey();

  @override
  void dispose() {
    NativePipService.setPipEnabled(false);
    NativePipService.isInPip.removeListener(_onPipChanged);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _currentEpisode = _episodes.first;
    _currentAudioTrack = _audioTracks.first;
    _currentSubtitleTrack = _subtitles.last;
    _currentQuality = _qualities.first;
    NativePipService.isInPip.addListener(_onPipChanged);
  }

  void _onPipChanged() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  void _recordEvent(String event, Map<String, dynamic> data) {
    if (!mounted) return;
    final time = DateTime.now().toIso8601String().substring(11, 19);
    setState(() {
      _eventLogs.insert(0, '[$time] $event: ${data.isNotEmpty ? data : ''}');
      if (_eventLogs.length > 50) _eventLogs.removeLast();
    });
  }

  void _showCustomUrlDialog() {
    final controller = TextEditingController(text: _customStreamUrl ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.add_link_rounded, color: Colors.cyanAccent),
            SizedBox(width: 8),
            Text('Custom Video Stream URL', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter any video stream URL (MP4, HLS .m3u8, DASH .mpd, or YouTube):',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'https://...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
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
            label: const Text('Play Stream'),
            onPressed: () {
              final text = controller.text.trim();
              if (text.isEmpty) return;
              Navigator.pop(ctx);
              setState(() {
                _customStreamUrl = text;
                _playerKey = GlobalKey();
              });
              _recordEvent('customUrlLoaded', {'url': text});
            },
          ),
        ],
      ),
    );
  }

  VideoConfig _createVideoConfig() {
    final active = _customStreamUrl != null
        ? (
            title: 'Custom User Stream',
            url: _customStreamUrl!,
            isYouTube:
                _customStreamUrl!.contains('youtube.com') ||
                _customStreamUrl!.contains('youtu.be'),
            isLive: false,
            viewerCount: null,
          )
        : _sampleStreams[_selectedStreamIndex];

    final langCode =
        widget.currentLanguageCode ??
        (context.mounted ? context.locale.languageCode : 'en');
    final isRtl = langCode == 'ar' || langCode == 'ur';
    final playerText = PlayerTextConfig.tr(
      (key) => key.tr(),
      languageCode: langCode,
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
    );

    if (active.isYouTube) {
      return VideoConfig(
        videoUrl: active.url,
        title: active.title,
        aspectRatio: 16 / 9,
        isLive: active.isLive,
        viewerCount: active.viewerCount,
        preventScreenCapture: _preventScreenCapture,
        playerConfig: YouTubePlayerConfig(
          text: playerText,
          style: PlayerStyleConfig(
            bottomBarLayout: _bottomBarLayout,
            videoFit: _videoFit,
            loadingIndicatorColor: const Color(0xFFE50914),
            showLoadingPercentage: true,
          ),
          playback: const PlayerPlaybackConfig(autoPlay: true),
          visibility: PlayerVisibilityConfig(
            showActionsInTopBar: _showActionsInTopBar,
          ),
        ),
        onAnalyticsEvent: _recordEvent,
      );
    }

    final isHls = active.url.contains('.m3u8');
    final activeUrl = _customStreamUrl != null
        ? _customStreamUrl!
        : (_selectedStreamIndex == 0
              ? (_currentEpisode.videoUrl ?? active.url)
              : active.url);

    return VideoConfig(
      videoUrl: activeUrl,
      title: active.title,
      isLive: active.isLive,
      viewerCount: active.viewerCount,
      enableCache: _enableCache,
      preventScreenCapture: _preventScreenCapture,
      extension: isHls ? VideoFileExtension.hls : null,
      aspectRatio: 16 / 9,
      episodes: _selectedStreamIndex == 0 ? _episodes : null,
      currentEpisode: _selectedStreamIndex == 0 ? _currentEpisode : null,
      onEpisodeSelected: (ep) {
        setState(() {
          _currentEpisode = ep;
          _playerKey = GlobalKey();
        });
        _recordEvent('episodeSelected', {
          'number': ep.number,
          'title': ep.title,
        });
      },
      onNextEpisode: () {
        final nextIndex =
            (_episodes.indexOf(_currentEpisode) + 1) % _episodes.length;
        setState(() {
          _currentEpisode = _episodes[nextIndex];
          _playerKey = GlobalKey();
        });
        _recordEvent('nextEpisode', {'number': _currentEpisode.number});
      },
      audioTracks: _audioTracks,
      currentAudioTrack: _currentAudioTrack,
      onAudioTrackSelected: (track) {
        setState(() => _currentAudioTrack = track);
        _recordEvent('audioTrackChanged', {
          'id': track.id,
          'label': track.label,
        });
      },
      subtitles: _subtitles,
      initialSubtitle: _currentSubtitleTrack,
      qualities: _qualities,
      initialQuality: _currentQuality,
      chapters: _chapters,
      onAnalyticsEvent: _recordEvent,
      playerConfig: YouTubePlayerConfig(
        text: playerText,
        style: PlayerStyleConfig(
          // Netflix Red Arc & Bold Percentage Loader
          loadingIndicatorColor: const Color(0xFFE50914),
          showLoadingPercentage: true,
          loadingIndicatorSize: 58.0,
          loadingIndicatorStrokeWidth: 4.0,

          // Layout & Styling
          bottomBarLayout: _bottomBarLayout,
          videoFit: _videoFit,
          useGlassmorphicControls: true,
          progressBarPlayedColor: const Color(0xFFE50914),
          progressBarBufferedColor: Colors.white24,
          progressBarBackgroundColor: Colors.white10,
        ),
        visibility: PlayerVisibilityConfig(
          showActionsInTopBar: _showActionsInTopBar,
          showEpisodesButton: _selectedStreamIndex == 0,
        ),
        playback: const PlayerPlaybackConfig(autoPlay: false, loop: false),
      ),
    );
  }

  Widget _livePlayer() {
    return AdaptiveVideoPlayer(key: _playerKey, config: _createVideoConfig());
  }

  String _liveDesignLabel(DemoPreviewMode mode, Size screen) {
    final surface = switch (mode) {
      DemoPreviewMode.phone => 'phone',
      DemoPreviewMode.tablet => 'tablet',
      DemoPreviewMode.desktop => 'desktop',
    };
    final size = '${screen.width.round()}×${screen.height.round()}';
    if (kIsWeb) return 'Web · $surface · $size';
    final host = switch (defaultTargetPlatform) {
      TargetPlatform.android => 'Android',
      TargetPlatform.iOS => 'iOS',
      TargetPlatform.windows => 'Windows',
      TargetPlatform.macOS => 'macOS',
      TargetPlatform.linux => 'Linux',
      TargetPlatform.fuchsia => 'Desktop',
    };
    return '$host · $surface · $size';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = widget.onToggleTheme != null
        ? widget.isDark
        : (theme.brightness == Brightness.dark);
    final currentLang = LanguagePickerSheet.getLanguage(
      widget.currentLanguageCode ??
          (context.mounted ? context.locale.languageCode : 'en'),
    );
    final screen = MediaQuery.sizeOf(context);
    final liveMode = DemoPreviewSpec.forWindow(screen);
    final isPhone = liveMode == DemoPreviewMode.phone;

    // Desktop and Android PiP shrink this window, so only the video should remain.
    // iOS draws PiP in a separate system player.
    final pipKeepsVideoOnly =
        NativePipService.isInPip.value &&
        !kIsWeb &&
        defaultTargetPlatform != TargetPlatform.iOS;
    if (pipKeepsVideoOnly) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SizedBox.expand(child: _livePlayer()),
      );
    }

    final playerWidth = screen.width - (isPhone ? 0 : 32);
    final available = screen.height <= 0 ? 1.0 : screen.height;
    final cap = available * 0.62 < 1 ? 1.0 : available * 0.62;
    final requestedFloor = isPhone ? 220.0 : 240.0;
    final floor = requestedFloor < cap ? requestedFloor : cap;
    final playerHeight = (playerWidth * 9 / 16).clamp(floor, cap);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Adaptive Video Player Studio',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Copy VideoConfig Code',
            icon: const Icon(Icons.code_rounded),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _snippetCode));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('VideoConfig snippet copied to clipboard!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          if (widget.onSelectLanguage != null)
            IconButton(
              tooltip: 'Language (${currentLang.code.toUpperCase()})',
              icon: const Icon(Icons.translate_rounded),
              onPressed: () {
                LanguagePickerSheet.show(
                  context,
                  currentLanguageCode: currentLang.code,
                  onLanguageSelected: (lang) =>
                      widget.onSelectLanguage!(lang.code),
                );
              },
            ),
          if (widget.onToggleTheme != null)
            IconButton(
              tooltip: isDark ? 'Light Theme' : 'Dark Theme',
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: isDark ? Colors.amberAccent : Colors.indigo,
              ),
              onPressed: widget.onToggleTheme,
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(isPhone ? 12 : 16, 12, 16, 0),
              child: Text(
                _liveDesignLabel(liveMode, screen),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isPhone ? 0 : 16),
              child: SizedBox(
                height: playerHeight,
                width: double.infinity,
                child: _livePlayer(),
              ),
            ),
            const SizedBox(height: 12),
            DemoTryRail(mode: liveMode),
            const SizedBox(height: 12),

            // 2. Interactive Quick Toggles
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 0,
                color: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFF1F5F9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.video_collection_rounded,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Select Video Stream / Preset',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      DemoStreamStrip(
                        customSelected: _customStreamUrl != null,
                        onCustomUrl: _showCustomUrlDialog,
                        streams: [
                          for (var i = 0; i < _sampleStreams.length; i++)
                            DemoStreamChoice(
                              title: _sampleStreams[i].title,
                              isLive: _sampleStreams[i].isLive,
                              isYouTube: _sampleStreams[i].isYouTube,
                              selected:
                                  _customStreamUrl == null &&
                                  _selectedStreamIndex == i,
                              onTap: () {
                                setState(() {
                                  _customStreamUrl = null;
                                  _selectedStreamIndex = i;
                                  _playerKey = GlobalKey();
                                });
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            Icons.tune_rounded,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Live Configuration Toggles',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilterChip(
                            label: const Text('Top-Bar Actions'),
                            selected: _showActionsInTopBar,
                            onSelected: (val) {
                              setState(() {
                                _showActionsInTopBar = val;
                                _playerKey = GlobalKey();
                              });
                            },
                          ),
                          FilterChip(
                            label: Text(
                              _bottomBarLayout == BottomBarLayout.inline
                                  ? 'Layout: Inline Capsule'
                                  : 'Layout: YouTube Pills',
                            ),
                            selected:
                                _bottomBarLayout == BottomBarLayout.inline,
                            onSelected: (val) {
                              setState(() {
                                _bottomBarLayout = val
                                    ? BottomBarLayout.inline
                                    : BottomBarLayout.youtubePills;
                                _playerKey = GlobalKey();
                              });
                            },
                          ),
                          FilterChip(
                            label: Text(
                              _videoFit == BoxFit.cover
                                  ? 'Fit: Cover (No Black Bars)'
                                  : 'Fit: Contain',
                            ),
                            selected: _videoFit == BoxFit.cover,
                            onSelected: (val) {
                              setState(() {
                                _videoFit = val ? BoxFit.cover : BoxFit.contain;
                                _playerKey = GlobalKey();
                              });
                            },
                          ),
                          FilterChip(
                            avatar: Icon(
                              _enableCache
                                  ? Icons.offline_bolt_rounded
                                  : Icons.cloud_outlined,
                              size: 16,
                            ),
                            label: Text(
                              _enableCache
                                  ? 'Disk Cache: ON'
                                  : 'Disk Cache: OFF',
                            ),
                            selected: _enableCache,
                            onSelected: (val) {
                              setState(() {
                                _enableCache = val;
                                _playerKey = GlobalKey();
                              });
                            },
                          ),
                          FilterChip(
                            avatar: Icon(
                              _preventScreenCapture
                                  ? Icons.shield_rounded
                                  : Icons.shield_outlined,
                              size: 16,
                            ),
                            label: Text(
                              _preventScreenCapture
                                  ? 'Anti-Capture Shield: ON'
                                  : 'Anti-Capture Shield: OFF',
                            ),
                            selected: _preventScreenCapture,
                            onSelected: (val) {
                              setState(() {
                                _preventScreenCapture = val;
                                _playerKey = GlobalKey();
                              });
                            },
                          ),
                          ActionChip(
                            avatar: const Icon(
                              Icons.delete_sweep_rounded,
                              size: 16,
                            ),
                            label: const Text('Clear Video Cache'),
                            onPressed: () async {
                              await clearVideoDiskCache();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Video disk cache cleared successfully.',
                                    ),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 4. Live Telemetry Event Logs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 0,
                color: isDark
                    ? const Color(0xFF0F172A)
                    : const Color(0xFFE2E8F0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'Real-Time Telemetry & Event Logs',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (_eventLogs.isNotEmpty)
                            TextButton(
                              onPressed: () =>
                                  setState(() => _eventLogs.clear()),
                              child: const Text('Clear'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      if (_eventLogs.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'Interact with the player above to see live events...',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        )
                      else
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 160),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _eventLogs.length,
                            itemBuilder: (context, i) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                _eventLogs[i],
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  static const String _snippetCode = '''
AdaptiveVideoPlayer(
  config: VideoConfig(
    videoUrl: 'https://upload.mp3quran.net/group1_pbuh/maher.mp4',
    title: 'The Witcher: Blood & Wine',
    aspectRatio: 16 / 9,

    // 1. Netflix-style Episodes
    episodes: const [
      VideoEpisode(id: 'ep1', number: 1, title: 'Episode 1', duration: Duration(minutes: 60)),
      VideoEpisode(id: 'ep2', number: 2, title: 'Episode 2', duration: Duration(minutes: 58)),
    ],
    onEpisodeSelected: (ep) => print('Selected episode: \${ep.title}'),
    onNextEpisode: () => print('Next episode triggered'),

    // 2. Multi-Language Audio Tracks
    audioTracks: const [
      AudioTrack(id: 'en', label: 'English [Original]', language: 'en', isDefault: true),
      AudioTrack(id: 'ar', label: 'Arabic (العربية)', language: 'ar'),
    ],
    onAudioTrackSelected: (track) => print('Selected audio: \${track.label}'),

    // 3. Subtitles
    subtitles: const [
      SubtitleTrack(id: 'en_cc', title: 'English CC', content: '...'),
    ],
    onSubtitleSelected: (sub) => print('Selected subtitle: \${sub?.title}'),

    // 4. Quality Levels
    qualities: const [
      VideoQuality(title: 'Auto', url: '...'),
      VideoQuality(title: '1080p HD', url: '...'),
      VideoQuality(title: '720p', url: '...'),
    ],
    onQualitySelected: (q) => print('Selected quality: \${q.title}'),

    // 5. Chapter Markers
    chapters: const [
      VideoChapter(title: 'Intro', startTime: Duration.zero),
      VideoChapter(title: 'Act I', startTime: Duration(seconds: 30)),
    ],

    // 6. Styling: Netflix Loader & Sleek Capsule
    playerConfig: YouTubePlayerConfig(
      style: const PlayerStyleConfig(
        loadingIndicatorColor: Color(0xFFE50914), // Netflix Red
        showLoadingPercentage: true,              // 77% style center text
        bottomBarLayout: BottomBarLayout.inline,
        useGlassmorphicControls: true,
      ),
      visibility: const PlayerVisibilityConfig(
        showActionsInTopBar: true, // Moves secondary actions to top bar
        showSkipButtons: true,
        showSpeedButton: true,
        showEpisodesButton: true,
        showAudioSubtitlesButton: true,
      ),
    ),
  ),
);
''';
}
