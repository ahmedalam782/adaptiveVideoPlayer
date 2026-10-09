import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:adaptive_video_player/adaptive_video_player.dart';

import '../models/demo_showcase_item.dart';

// Real-world video streams (VOD MP4, Adaptive HLS, and YouTube)
const _bigBuckBunnyUrl =
    'https://dash.akamaized.net/akamai/bbb_30fps/bbb_30fps_1280x720_4000k.mp4';
const _bbb1080pUrl =
    'https://dash.akamaized.net/akamai/bbb_30fps/bbb_30fps_1920x1080_8000k.mp4';
const _bbb720pUrl =
    'https://dash.akamaized.net/akamai/bbb_30fps/bbb_30fps_1280x720_4000k.mp4';
const _bbb360pUrl =
    'https://dash.akamaized.net/akamai/bbb_30fps/bbb_30fps_640x360_1000k.mp4';
const _oceansTrailerUrl =
    'https://vjs.zencdn.net/v/oceans.mp4';
const _quranUrl =
    'https://upload.mp3quran.net/group1_pbuh/maher.mp4';

// Real-world Adaptive HLS live and VOD streams (with Web MP4 fallbacks for non-Safari browsers)
const _muxHlsUrl =
    'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8';
const _muxWebFallbackUrl =
    'https://interactive-examples.mdn.mozilla.net/media/cc0-videos/friday.mp4';
const _flowerNatureUrl =
    'https://interactive-examples.mdn.mozilla.net/media/cc0-videos/flower.mp4';
const _akamaiLiveHlsUrl =
    'https://cph-p2p-msl.akamaized.net/hls/live/2000341/test/master.m3u8';
const _akamaiWebFallbackUrl =
    'https://dash.akamaized.net/akamai/bbb_30fps/bbb_30fps_1920x1080_8000k.mp4';

// Real-world YouTube videos and live streams
const _youtubeCostaRica4k =
    'https://www.youtube.com/watch?v=LXb3EKWsInQ';
const _youtubeBigBuckBunny =
    'https://www.youtube.com/watch?v=aqz-KE-bpKQ';
const _youtubeLofiLive =
    'https://www.youtube.com/watch?v=jfKfPfyJRdk';
const _youtubeNasaLive =
    'https://www.youtube.com/watch?v=21X5lGlDOfg';

/// Rich real-world catalog for the studio player showcasing every feature.
List<StudioSource> studioSources() {
  return [
    // 0. Cached Stream (CachedVideoPlayerPlus)
    StudioSource(
      id: 'cached_bunny',
      label: 'Cached Stream (Disk Cache)',
      description:
          'Zero-buffering video using CachedVideoPlayerPlus with persistent local disk storage.',
      icon: Icons.offline_bolt_rounded,
      accentColor: const Color(0xFF06B6D4),
      features: const [
        'CachedVideoPlayerPlus',
        'Persistent Disk Cache',
        'Instant Zero-Lag Replay',
        'Offline Playback Support',
      ],
      config: const VideoConfig(
        videoUrl: _oceansTrailerUrl,
        title: 'Cached Oceans Nature (Zero Lag)',
        enableCache: true,
      ),
    ),

    // 1. Big Buck Bunny - Full Featured Movie
    StudioSource(
      id: 'big_buck_bunny',
      label: 'Big Buck Bunny (MP4)',
      description:
          'HD open movie with multi-resolution qualities, chapters, subtitles, and episodes.',
      icon: Icons.movie_filter_rounded,
      accentColor: const Color(0xFF6366F1),
      features: const [
        'Multi-Quality (HD/720p/480p)',
        'Persistent Disk Cache',
        'Chapters timeline',
        'Dual subtitles',
        'Multi-Audio',
        'Episodes drawer',
        'Speed stepper',
      ],
      config: VideoConfig(
        videoUrl: _bigBuckBunnyUrl,
        title: 'Big Buck Bunny (HD)',
        enableCache: true,
        qualities: const [
          VideoQuality(title: 'Auto (1080p)', url: _bbb1080pUrl),
          VideoQuality(title: '720p HD', url: _bbb720pUrl),
          VideoQuality(title: '360p SD', url: _bbb360pUrl),
        ],
        initialQuality: const VideoQuality(
            title: 'Auto (1080p)', url: _bbb1080pUrl),
        audioTracks: const [
          AudioTrack(
            id: 'en_stereo',
            label: 'English [Original Stereo]',
            language: 'en',
            isOriginal: true,
            isDefault: true,
          ),
          AudioTrack(
            id: 'es_dub',
            label: 'Español (Doblaje)',
            language: 'es',
          ),
          AudioTrack(
            id: 'ar_dub',
            label: 'العربية (دبلجة)',
            language: 'ar',
          ),
        ],
        currentAudioTrack: const AudioTrack(
          id: 'en_stereo',
          label: 'English [Original Stereo]',
          language: 'en',
          isOriginal: true,
          isDefault: true,
        ),
        episodes: const [
          VideoEpisode(
            id: 'bunny_ep1',
            number: 1,
            title: 'Episode 1: Big Buck Bunny (720p)',
            description: 'Bunny awakens and greets the woodland creatures in HD.',
            duration: Duration(minutes: 9, seconds: 56),
            watchedProgress: 0.75,
            videoUrl: _bbb720pUrl,
          ),
          VideoEpisode(
            id: 'bunny_ep2',
            number: 2,
            title: 'Episode 2: Oceans Documentary',
            description: 'Deep ocean life and coastal coral reefs in cinema clarity.',
            duration: Duration(seconds: 46),
            watchedProgress: 0.25,
            videoUrl: _oceansTrailerUrl,
          ),
          VideoEpisode(
            id: 'bunny_ep3',
            number: 3,
            title: 'Episode 3: Butterfly Flutter',
            description: 'A butterfly flutters peacefully through the garden.',
            duration: Duration(seconds: 10),
            watchedProgress: 0.0,
            videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
          ),
        ],
        currentEpisode: const VideoEpisode(
          id: 'bunny_ep1',
          number: 1,
          title: 'Episode 1: Big Buck Bunny (720p)',
          description: 'Bunny awakens and greets the woodland creatures in HD.',
          duration: Duration(minutes: 9, seconds: 56),
          watchedProgress: 0.75,
          videoUrl: _bbb720pUrl,
        ),
        subtitles: const [
          SubtitleTrack(
            id: 'en_cc',
            title: 'English (CC)',
            content: '''
1
00:00:01,000 --> 00:00:05,000
A serene morning in the animated forest.

2
00:00:06,000 --> 00:00:11,000
Big Buck Bunny steps out into the sunshine.

3
00:00:12,000 --> 00:00:18,000
Testing adaptive video player streaming features!
''',
          ),
          SubtitleTrack(
            id: 'ar_cc',
            title: 'العربية',
            content: '''
1
00:00:01,000 --> 00:00:05,000
صباح هادئ وجميل في الغابة السحرية.

2
00:00:06,000 --> 00:00:11,000
الأرنب الضخم يبدأ مغامرته الشيقة.
''',
          ),
        ],
        chapters: const [
          VideoChapter(title: 'Opening & Wake Up', startTime: Duration.zero),
          VideoChapter(title: 'Meeting the Butterflies', startTime: Duration(seconds: 10)),
          VideoChapter(title: 'The Forest Journey', startTime: Duration(seconds: 20)),
          VideoChapter(title: 'Finale', startTime: Duration(seconds: 28)),
        ],
      ),
    ),

    // 2. Sintel - Fantasy Open Movie
    StudioSource(
      id: 'sintel',
      label: 'Sintel (Fantasy)',
      description: 'Acclaimed fantasy animation with dramatic score and action scenes.',
      icon: Icons.auto_awesome_rounded,
      accentColor: const Color(0xFFF59E0B),
      features: const [
        'Cinematic 1080p',
        'Dual-column Subtitles',
        'Chapters timeline',
        'Top-bar actions',
      ],
      config: const VideoConfig(
        videoUrl: _oceansTrailerUrl,
        title: 'Oceans Nature Documentary',
        enableCache: true,
        chapters: [
          VideoChapter(title: 'Coastal Waves', startTime: Duration.zero),
          VideoChapter(title: 'Deep Ocean Life', startTime: Duration(seconds: 15)),
          VideoChapter(title: 'Coral Reefs', startTime: Duration(seconds: 30)),
        ],
      ),
    ),

    // 3. Big Buck Bunny Trailer
    StudioSource(
      id: 'bunny_trailer',
      label: 'Bunny Teaser (1080p)',
      description: 'Cinema-grade 1080p MP4 served over Akamai global CDN.',
      icon: Icons.movie_rounded,
      accentColor: const Color(0xFF06B6D4),
      features: const [
        'Persistent Disk Cache',
        'Akamai Global CDN',
        'Full Controls',
        'Chapters',
        'PiP Support',
      ],
      config: const VideoConfig(
        videoUrl: _bbb1080pUrl,
        title: 'Big Buck Bunny - 1080p Cinema',
        enableCache: true,
        chapters: [
          VideoChapter(title: 'Morning Awakening', startTime: Duration.zero),
          VideoChapter(title: 'The Forest Journey', startTime: Duration(seconds: 15)),
        ],
      ),
    ),

    // 4. Blooming Flowers - Nature HD Video
    const StudioSource(
      id: 'nature_flower',
      label: 'Nature Flowers (HD MP4)',
      description: 'Nature blooming time-lapse video hosted on Mozilla CDN with full web CORS.',
      icon: Icons.nature_rounded,
      accentColor: Color(0xFF10B981),
      features: [
        'Mozilla MDN Official CDN',
        'Cross-Platform Web Compatible',
        'Timeline Scrubbing',
        'PiP Support',
      ],
      config: VideoConfig(
        videoUrl: _flowerNatureUrl,
        title: 'Blooming Flower Time-lapse (MDN HD)',
      ),
    ),

    // 5. Mux HLS Test Stream
    StudioSource(
      id: 'mux_hls',
      label: kIsWeb ? 'City Life Stream (HD MP4)' : 'Mux HLS Stream',
      description: kIsWeb
          ? 'High-speed urban life video hosted on Mozilla CDN with instant buffering.'
          : 'Adaptive HLS video with audio/video stream synchronization.',
      icon: Icons.sensors_rounded,
      accentColor: const Color(0xFFEC4899),
      features: const [
        'HLS Stream',
        'Buffered Percentage',
        'Volume Gestures',
        'Fullscreen',
      ],
      config: VideoConfig(
        videoUrl: kIsWeb ? _muxWebFallbackUrl : _muxHlsUrl,
        title: kIsWeb
            ? 'City Life Urban Stream (MDN HD)'
            : 'Mux CDN Multi-Bitrate HLS Stream',
        extension: kIsWeb ? VideoFileExtension.mp4 : VideoFileExtension.hls,
      ),
    ),

    // 6. Akamai Live Stream
    StudioSource(
      id: 'akamai_live',
      label: kIsWeb ? 'Akamai 24/7 (HD Live)' : 'Akamai 24/7 (Live HLS)',
      description:
          'Real 24/7 broadcast stream with LIVE badge & viewer count simulation.',
      icon: Icons.live_tv_rounded,
      accentColor: const Color(0xFFE11D48),
      features: const [
        'Live Broadcast Badge',
        'Live Viewer Count',
        'Continuous Ingestion',
        'Audio Control',
      ],
      config: VideoConfig(
        videoUrl: kIsWeb ? _akamaiWebFallbackUrl : _akamaiLiveHlsUrl,
        title: 'Akamai Global CDN 24/7 Live Stream',
        isLive: true,
        viewerCount: '89.4K LIVE',
        extension: kIsWeb ? VideoFileExtension.mp4 : VideoFileExtension.hls,
      ),
    ),

    // 7. Quran Recitation - Maher Al Muaiqly MP4
    StudioSource(
      id: 'quran_recitation',
      label: 'Quran Recitation (MP4)',
      description: 'Soulful Quran recitation with synchronized Arabic & English subtitles.',
      icon: Icons.menu_book_rounded,
      accentColor: const Color(0xFF14B8A6),
      features: const [
        'Dual Subtitles (AR / EN)',
        'Audio Clarity',
        'Episodes',
        'Chapters',
      ],
      config: VideoConfig(
        videoUrl: _quranUrl,
        title: 'Quran Recitation - Sheikh Maher Al Muaiqly',
        subtitles: [
          SubtitleTrack.fromAsset(
            id: 'ar_asset',
            title: 'العربية (SRT)',
            assetPath: 'assets/subtitles/avengers_endgame_ar.srt',
          ),
          const SubtitleTrack(
            id: 'en_quran',
            title: 'English Translation',
            content: '''
1
00:00:01,000 --> 00:00:06,000
In the Name of Allah, the Most Compassionate, the Most Merciful.

2
00:00:07,000 --> 00:00:15,000
Praise be to Allah, Lord of all the worlds.
''',
          ),
        ],
        chapters: const [
          VideoChapter(title: 'Surah Opening', startTime: Duration.zero),
          VideoChapter(title: 'Recitation Part I', startTime: Duration(seconds: 45)),
          VideoChapter(title: 'Recitation Part II', startTime: Duration(minutes: 2)),
        ],
      ),
    ),

    // 8. YouTube 4K Costa Rica Nature
    const StudioSource(
      id: 'yt_costa_rica',
      label: 'Costa Rica 4K (YouTube)',
      description: 'Ultra HD 4K 60fps wildlife & rainforest showcase on YouTube.',
      icon: Icons.smart_display_rounded,
      accentColor: Color(0xFFEF4444),
      features: [
        'YouTube 4K Ultra HD',
        'Playback Speed Stepper',
        'Hold-to-2x Speed',
        'Fullscreen & PiP',
      ],
      config: VideoConfig(
        videoUrl: _youtubeCostaRica4k,
        title: 'Costa Rica 4K 60fps Wildlife Showcase',
      ),
    ),

    // 9. YouTube Big Buck Bunny 60fps
    const StudioSource(
      id: 'yt_bunny',
      label: 'Big Buck Bunny (YouTube)',
      description: '60fps animation streaming through the embedded YouTube engine.',
      icon: Icons.play_circle_fill_rounded,
      accentColor: Color(0xFFF97316),
      features: [
        'YouTube Embed',
        'Instant Seeking',
        'Fullscreen Toggle',
      ],
      config: VideoConfig(
        videoUrl: _youtubeBigBuckBunny,
        title: 'Big Buck Bunny 60fps Animation (YouTube)',
      ),
    ),

    // 10. YouTube Lofi Girl 24/7 Live
    const StudioSource(
      id: 'yt_lofi_live',
      label: 'Lofi Girl 24/7 (YT Live)',
      description: 'Worldwide famous 24/7 live stream with relaxing beats & live badge.',
      icon: Icons.radio_rounded,
      accentColor: Color(0xFF8B5CF6),
      features: [
        'YouTube 24/7 Live Stream',
        'Live Badge',
        'Viewer Count',
        'Background Audio',
      ],
      config: VideoConfig(
        videoUrl: _youtubeLofiLive,
        isLive: true,
        viewerCount: '48.2K VIEWERS',
        title: 'Lofi Girl - Relaxing Beats 24/7 Live',
      ),
    ),

    // 11. YouTube NASA Live - Earth from Orbit
    const StudioSource(
      id: 'yt_nasa_live',
      label: 'NASA Earth Orbit (YT Live)',
      description: 'Live International Space Station views of Earth from space.',
      icon: Icons.public_rounded,
      accentColor: Color(0xFF3B82F6),
      features: [
        'Live ISS Space Feed',
        'Viewer Count',
        'Live Badge',
      ],
      config: VideoConfig(
        videoUrl: _youtubeNasaLive,
        isLive: true,
        viewerCount: '12.5K VIEWERS',
        title: 'NASA Live - Views of Earth from Orbit',
      ),
    ),
  ];
}
