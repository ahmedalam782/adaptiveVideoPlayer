import 'package:flutter/material.dart';
import 'package:adaptive_video_player/adaptive_video_player.dart';

import '../models/demo_showcase_item.dart';

/// Predefined showcase demos highlighting player capabilities
List<DemoShowcaseItem> getDemoShowcaseItems() {
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
            'https://upload.mp3quran.net/group1_pbuh/maher.mp4',
        subtitles: [
          SubtitleTrack.fromAsset(
            id: 'ar_avengers',
            title: 'العربية (Avengers SRT Asset)',
            assetPath: 'assets/subtitles/avengers_endgame_ar.srt',
          ),
          SubtitleTrack.fromApi(
            id: 'api_dynamic',
            title: 'ترجمة سحابية (Remote API Fetcher)',
            apiCall: () async {
              // Simulate API latency (e.g. calling your REST API / Cloud CDN)
              await Future.delayed(const Duration(milliseconds: 400));
              return '''
1
00:00:01,000 --> 00:00:04,500
تم جلب ملف الترجمة هذا ديناميكياً من الـ API!

2
00:00:05,000 --> 00:00:09,000
مشغل الفيديو يدعم الترجمة من الـ API و SRT و VTT.
''';
            },
          ),
          const SubtitleTrack(
            id: 'en',
            title: 'English CC (Inline)',
            content: '''
1
00:00:01,000 --> 00:00:04,000
Adaptive Video Player in action.

2
00:00:04,500 --> 00:00:08,000
Real-time subtitle overlays synced perfectly.
            ''',
          ),
        ],
        initialSubtitle: SubtitleTrack.fromAsset(
          id: 'ar_avengers',
          title: 'العربية (Avengers SRT Asset)',
          assetPath: 'assets/subtitles/avengers_endgame_ar.srt',
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
      title: 'Netflix-Style HLS Adaptive Streaming',
      subtitle:
          'Plays single master.m3u8 playlist with automatic 1080p ↔ 720p ↔ 480p bandwidth switching',
      category: 'HLS Master (ABR)',
      tags: ['HLS Master', 'Adaptive Bitrate', 'Netflix-Style', 'Zero Buffering'],
      icon: Icons.auto_awesome_motion_rounded,
      accentColor: Color(0xFFE50914),
      config: VideoConfig(
        videoUrl: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
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
    DemoShowcaseItem(
      title: 'واجهة عربية ودعم RTL كامل',
      subtitle: 'ترجمة فورية باللغة العربية مع إعدادات المشغل المعربة بالكامل',
      category: 'Arabic / RTL',
      tags: ['عربي', 'RTL', 'ترجمة عربية', 'إعدادات معربة'],
      icon: Icons.language_rounded,
      accentColor: Color(0xFF0EA5E9),
      config: VideoConfig(
        videoUrl: 'https://upload.mp3quran.net/group1_pbuh/maher.mp4',
        subtitles: [
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
        initialSubtitle: SubtitleTrack(
          id: 'ar',
          title: 'عربي (Arabic)',
        ),
      ),
    ),
    const DemoShowcaseItem(
      title: 'Dynamic Emerald Theme & Custom Controls',
      subtitle:
          'Dynamic colors, custom text labels, and customized control visibility',
      category: 'Direct Stream',
      tags: ['Dynamic Color', 'Custom Texts', 'Visibility Config', 'Theming'],
      icon: Icons.palette_rounded,
      accentColor: Color(0xFF10B981),
      config: VideoConfig(
        videoUrl: 'https://upload.mp3quran.net/group1_pbuh/maher.mp4',
        playerConfig: YouTubePlayerConfig(
          style: PlayerStyleConfig(
            progressBarPlayedColor: Color(0xFF10B981),
            progressBarHandleColor: Color(0xFF34D399),
            progressBarBufferedColor: Color(0x6610B981),
            controlsBackgroundColor: Color(0x44064E3B),
            iconColor: Color(0xFFE0E7FF),
            textColor: Color(0xFFE0E7FF),
          ),
          text: PlayerTextConfig(
            playerSettingsText: 'Custom Video Controls',
            playbackSpeedText: 'Speed Multiplier',
            skipBackwardText: 'Jump Back 10s',
            skipForwardText: 'Jump Ahead 10s',
          ),
          visibility: PlayerVisibilityConfig(
            showMiniPlayerButton: true,
            showVolumeButton: true,
            showTimeDisplay: true,
            showProgressBar: true,
          ),
        ),
      ),
    ),
  ];
}
