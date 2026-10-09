import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:adaptive_video_player/adaptive_video_player.dart';

/// Complete, production-grade example demonstrating EVERY feature in
/// `adaptive_video_player`.
///
/// Features demonstrated:
/// 1. Unified Player Engine (MP4, HLS, DASH & YouTube)
/// 2. Netflix-style circular percentage loader with bold percentage readout
/// 3. Top-bar actions cluster (Settings, PiP, Episodes, Audio/Subs, Speed)
/// 4. Netflix-style Episodes Drawer with watched progress
/// 5. Dual-column Audio & Subtitles popup
/// 6. Playback Speed Stepper with hold-to-2x speed boost
/// 7. Chapter markers along the scrubbing timeline
/// 8. Multi-resolution Quality selector
/// 9. Double-tap gesture seeking (±10s, ±20s, ±30s)
/// 10. Floating Miniplayer (in-app PiP) & OS-level PiP
/// 11. Fullscreen toggle & mouse double-click to fullscreen
/// 12. Real-time Analytics & event logging
class FullFeaturesExampleScreen extends StatefulWidget {
  const FullFeaturesExampleScreen({super.key});

  @override
  State<FullFeaturesExampleScreen> createState() =>
      _FullFeaturesExampleScreenState();
}

class _FullFeaturesExampleScreenState extends State<FullFeaturesExampleScreen> {
  // Real-world video streams (VOD MP4, Adaptive HLS, and YouTube)
  static final List<({String title, String url, bool isYouTube, bool isLive, String? viewerCount})>
      _sampleStreams = [
    (
      title: 'Big Buck Bunny (Akamai 720p MP4)',
      url: 'https://dash.akamaized.net/akamai/bbb_30fps/bbb_30fps_1280x720_4000k.mp4',
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
      url: 'https://dash.akamaized.net/akamai/bbb_30fps/bbb_30fps_1920x1080_8000k.mp4',
      isYouTube: false,
      isLive: false,
      viewerCount: null,
    ),
    (
      title: 'Blooming Flower (MDN HD MP4)',
      url: 'https://interactive-examples.mdn.mozilla.net/media/cc0-videos/flower.mp4',
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
    ),
    VideoEpisode(
      id: 'ep2',
      number: 2,
      title: 'Episode 2: Oceans Documentary',
      description: 'Deep ocean life and coastal coral reefs in cinema clarity.',
      duration: Duration(seconds: 46),
      watchedProgress: 0.40,
      videoUrl:
          'https://vjs.zencdn.net/v/oceans.mp4',
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
    ),
    VideoEpisode(
      id: 'ep4',
      number: 4,
      title: 'Episode 4: Sacred Recitation',
      description: 'High-fidelity audio and video recitation stream.',
      duration: Duration(minutes: 10, seconds: 53),
      watchedProgress: 0.0,
      videoUrl:
          'https://upload.mp3quran.net/group1_pbuh/maher.mp4',
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
    AudioTrack(
      id: 'ar',
      label: 'Arabic (العربية)',
      language: 'ar',
    ),
    AudioTrack(
      id: 'fr',
      label: 'French (Français)',
      language: 'fr',
    ),
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
      url: 'https://dash.akamaized.net/akamai/bbb_30fps/bbb_30fps_1920x1080_8000k.mp4',
    ),
    VideoQuality(
      title: '1080p HD',
      url: 'https://dash.akamaized.net/akamai/bbb_30fps/bbb_30fps_1920x1080_8000k.mp4',
    ),
    VideoQuality(
      title: '720p HD',
      url: 'https://dash.akamaized.net/akamai/bbb_30fps/bbb_30fps_1280x720_4000k.mp4',
    ),
    VideoQuality(
      title: '360p SD',
      url: 'https://dash.akamaized.net/akamai/bbb_30fps/bbb_30fps_640x360_1000k.mp4',
    ),
  ];
  late VideoQuality _currentQuality;

  // Chapters
  final List<VideoChapter> _chapters = const [
    VideoChapter(title: 'Opening & Intro', startTime: Duration.zero),
    VideoChapter(title: 'Act I: Discovery', startTime: Duration(seconds: 10)),
    VideoChapter(title: 'Act II: The Encounter', startTime: Duration(seconds: 20)),
    VideoChapter(title: 'Credits', startTime: Duration(seconds: 28)),
  ];

  // Event telemetry logs
  final List<String> _eventLogs = [];
  Key _playerKey = UniqueKey();
  final ScrollController _sampleStreamsScrollController = ScrollController();

  void _scrollSampleStreams(double delta) {
    if (!_sampleStreamsScrollController.hasClients) return;
    final target = (_sampleStreamsScrollController.offset + delta).clamp(
      0.0,
      _sampleStreamsScrollController.position.maxScrollExtent,
    );
    _sampleStreamsScrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _sampleStreamsScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _currentEpisode = _episodes.first;
    _currentAudioTrack = _audioTracks.first;
    _currentSubtitleTrack = _subtitles.last;
    _currentQuality = _qualities.first;
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
            label: const Text('Play Stream'),
            onPressed: () {
              final text = controller.text.trim();
              if (text.isEmpty) return;
              Navigator.pop(ctx);
              setState(() {
                _customStreamUrl = text;
                _playerKey = UniqueKey();
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
            isYouTube: _customStreamUrl!.contains('youtube.com') ||
                _customStreamUrl!.contains('youtu.be'),
            isLive: false,
            viewerCount: null,
          )
        : _sampleStreams[_selectedStreamIndex];

    if (active.isYouTube) {
      return VideoConfig(
        videoUrl: active.url,
        title: active.title,
        aspectRatio: 16 / 9,
        isLive: active.isLive,
        viewerCount: active.viewerCount,
        playerConfig: YouTubePlayerConfig(
          style: PlayerStyleConfig(
            bottomBarLayout: _bottomBarLayout,
            videoFit: _videoFit,
            loadingIndicatorColor: const Color(0xFFE50914),
            showLoadingPercentage: true,
          ),
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
      extension: isHls ? VideoFileExtension.hls : null,
      aspectRatio: 16 / 9,
      episodes: _selectedStreamIndex == 0 ? _episodes : null,
      currentEpisode: _selectedStreamIndex == 0 ? _currentEpisode : null,
      onEpisodeSelected: (ep) {
        setState(() {
          _currentEpisode = ep;
          _playerKey = UniqueKey();
        });
        _recordEvent('episodeSelected', {'number': ep.number, 'title': ep.title});
      },
      onNextEpisode: () {
        final nextIndex = (_episodes.indexOf(_currentEpisode) + 1) % _episodes.length;
        setState(() {
          _currentEpisode = _episodes[nextIndex];
          _playerKey = UniqueKey();
        });
        _recordEvent('nextEpisode', {'number': _currentEpisode.number});
      },
      audioTracks: _audioTracks,
      currentAudioTrack: _currentAudioTrack,
      onAudioTrackSelected: (track) {
        setState(() => _currentAudioTrack = track);
        _recordEvent('audioTrackChanged', {'id': track.id, 'label': track.label});
      },
      subtitles: _subtitles,
      initialSubtitle: _currentSubtitleTrack,
      qualities: _qualities,
      initialQuality: _currentQuality,
      chapters: _chapters,
      onAnalyticsEvent: _recordEvent,
      playerConfig: YouTubePlayerConfig(
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
        playback: const PlayerPlaybackConfig(
          autoPlay: false,
          loop: false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Features Real Example',
          style: TextStyle(fontWeight: FontWeight.bold),
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
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. The Video Player Canvas
            Container(
              color: Colors.black,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: AdaptiveVideoPlayer(
                  key: _playerKey,
                  config: _createVideoConfig(),
                ),
              ),
            ),

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
                          const Text(
                            'Select Video Stream / Preset',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left_rounded, size: 24),
                            tooltip: 'Scroll left',
                            splashRadius: 18,
                            visualDensity: VisualDensity.compact,
                            onPressed: () => _scrollSampleStreams(-250),
                          ),
                          Expanded(
                            child: Scrollbar(
                              controller: _sampleStreamsScrollController,
                              thumbVisibility: true,
                              thickness: 4,
                              radius: const Radius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: SingleChildScrollView(
                                  controller: _sampleStreamsScrollController,
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8),
                                        child: ActionChip(
                                          avatar: const Icon(Icons.add_link_rounded,
                                              size: 16, color: Colors.cyanAccent),
                                          label: Text(
                                            _customStreamUrl != null
                                                ? 'Custom URL (Active)'
                                                : '+ Custom URL',
                                          ),
                                          labelStyle: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.cyanAccent,
                                          ),
                                          backgroundColor: isDark
                                              ? Colors.cyanAccent.withValues(alpha: 0.12)
                                              : Colors.cyan.withValues(alpha: 0.15),
                                          side: BorderSide(
                                            color: Colors.cyanAccent.withValues(alpha: 0.35),
                                          ),
                                          onPressed: _showCustomUrlDialog,
                                        ),
                                      ),
                                      for (var i = 0; i < _sampleStreams.length; i++)
                                        Padding(
                                          padding: const EdgeInsets.only(right: 8),
                                          child: FilterChip(
                                            selected: _customStreamUrl == null &&
                                                _selectedStreamIndex == i,
                                            label: Text(_sampleStreams[i].title),
                                            onSelected: (_) {
                                              setState(() {
                                                _customStreamUrl = null;
                                                _selectedStreamIndex = i;
                                                _playerKey = UniqueKey();
                                              });
                                            },
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
                            onPressed: () => _scrollSampleStreams(250),
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
                          const Text(
                            'Live Configuration Toggles',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
                                _playerKey = UniqueKey();
                              });
                            },
                          ),
                          FilterChip(
                            label: Text(_bottomBarLayout == BottomBarLayout.inline
                                ? 'Layout: Inline Capsule'
                                : 'Layout: YouTube Pills'),
                            selected: _bottomBarLayout == BottomBarLayout.inline,
                            onSelected: (val) {
                              setState(() {
                                _bottomBarLayout = val
                                    ? BottomBarLayout.inline
                                    : BottomBarLayout.youtubePills;
                                _playerKey = UniqueKey();
                              });
                            },
                          ),
                          FilterChip(
                            label: Text(_videoFit == BoxFit.cover
                                ? 'Fit: Cover (No Black Bars)'
                                : 'Fit: Contain'),
                            selected: _videoFit == BoxFit.cover,
                            onSelected: (val) {
                              setState(() {
                                _videoFit = val ? BoxFit.cover : BoxFit.contain;
                                _playerKey = UniqueKey();
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
                            label: Text(_enableCache
                                ? 'Disk Cache: ON'
                                : 'Disk Cache: OFF'),
                            selected: _enableCache,
                            onSelected: (val) {
                              setState(() {
                                _enableCache = val;
                                _playerKey = UniqueKey();
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
                                    content: Text('Video disk cache cleared successfully.'),
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

            // 3. Feature Highlights
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Active Features in this Example',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _FeatureTile(
                    icon: Icons.offline_bolt_rounded,
                    title: 'Persistent Disk Cache (CachedVideoPlayerPlus)',
                    description:
                        'Local filesystem caching for zero-delay instant replays and offline-ready playback.',
                    accentColor: const Color(0xFF06B6D4),
                  ),
                  _FeatureTile(
                    icon: Icons.timelapse_rounded,
                    title: 'Netflix-Style Circular Percentage Loader',
                    description:
                        'Red arc with rounded stroke caps and bold centered percentage readout (77% style).',
                    accentColor: const Color(0xFFE50914),
                  ),
                  _FeatureTile(
                    icon: Icons.vertical_align_top_rounded,
                    title: 'Top-Bar Actions Positioning',
                    description:
                        'Secondary controls (Settings, PiP, Episodes, Subs, Speed) move to the top-end to leave the bottom bar uncluttered.',
                    accentColor: Colors.indigoAccent,
                  ),
                  _FeatureTile(
                    icon: Icons.video_library_rounded,
                    title: 'Netflix Episodes Drawer',
                    description:
                        'Slide-out drawer displaying episode list, watched progress bars, and episode descriptions.',
                    accentColor: Colors.deepPurpleAccent,
                  ),
                  _FeatureTile(
                    icon: Icons.subtitles_rounded,
                    title: 'Dual-Column Audio & Subtitles Popup',
                    description:
                        'Simultaneously select multi-language audio tracks and SRT/WebVTT subtitles in a side-by-side popup.',
                    accentColor: Colors.teal,
                  ),
                  _FeatureTile(
                    icon: Icons.speed_rounded,
                    title: 'Discrete Speed Stepper & Hold-to-2x',
                    description:
                        'Tap the speed icon for preset speeds (0.5x to 2.0x), or hold down on the video for instant 2x fast-forward.',
                    accentColor: Colors.amber,
                  ),
                  _FeatureTile(
                    icon: Icons.bookmarks_rounded,
                    title: 'Interactive Chapter Scrubbing',
                    description:
                        'Timeline slider displays chapter breaks and titles dynamically while dragging or hovering.',
                    accentColor: Colors.cyan,
                  ),
                  _FeatureTile(
                    icon: Icons.picture_in_picture_alt_rounded,
                    title: 'Picture-in-Picture (OS + In-App)',
                    description:
                        'Seamless floating window on Windows Desktop and Android/iOS, with draggable in-app miniplayer.',
                    accentColor: Colors.blueAccent,
                  ),
                ],
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
                          const Text(
                            'Real-Time Telemetry & Event Logs',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_eventLogs.isNotEmpty)
                            TextButton(
                              onPressed: () => setState(() => _eventLogs.clear()),
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

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color accentColor;

  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: accentColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : const Color(0xFF475569),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
