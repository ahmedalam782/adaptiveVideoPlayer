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
    const DemoShowcaseItem(
      title: 'واجهة عربية ودعم RTL كامل',
      subtitle: 'ترجمة فورية باللغة العربية مع إعدادات المشغل المعربة بالكامل',
      category: 'Arabic / RTL',
      tags: ['عربي', 'RTL', 'ترجمة عربية', 'إعدادات معربة'],
      icon: Icons.language_rounded,
      accentColor: Color(0xFF0EA5E9),
      config: VideoConfig(
        videoUrl: 'https://upload.mp3quran.net/group1_pbuh/maher.mp4',
        playerConfig: YouTubePlayerConfig(
          text: PlayerTextConfig.arabic(),
        ),
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
  ];
}
