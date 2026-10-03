import 'package:flutter/material.dart';
import 'package:adaptive_video_player/adaptive_video_player.dart';

import '../models/demo_showcase_item.dart';

const _normalUrl = 'https://upload.mp3quran.net/group1_pbuh/maher.mp4';
const _hlsUrl = 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8';
const _youtubeUrl = 'https://www.youtube.com/watch?v=aqz-KE-bpKQ';
const _youtubeLiveUrl = 'https://www.youtube.com/watch?v=bNyUyrR0PHo';

/// Four sources for the one studio player.
///
/// Normal and live use the native player (quality, captions, chapters).
/// YouTube and YouTube live use the embedded player. The same control
/// panel underneath applies to whichever source is selected.
List<StudioSource> studioSources() {
  return [
    StudioSource(
      id: 'normal',
      label: 'Normal video',
      description: 'MP4 with quality levels, captions, and chapters',
      icon: Icons.movie_filter_rounded,
      accentColor: const Color(0xFF6366F1),
      features: const [
        'Quality picker',
        'Subtitles',
        'Chapters',
        'Seek ±10s',
        'Volume',
        'Fullscreen',
        'Mini player',
      ],
      config: VideoConfig(
        videoUrl: _normalUrl,
        qualities: const [
          VideoQuality(title: 'Auto', url: _normalUrl),
          VideoQuality(title: '1080p HD', url: _normalUrl),
          VideoQuality(title: '720p SD', url: _normalUrl),
        ],
        initialQuality: const VideoQuality(title: 'Auto', url: _normalUrl),
        subtitles: [
          SubtitleTrack.fromAsset(
            id: 'ar_asset',
            title: 'العربية (SRT asset)',
            assetPath: 'assets/subtitles/avengers_endgame_ar.srt',
          ),
          const SubtitleTrack(
            id: 'en',
            title: 'English CC',
            content: '''
1
00:00:01,000 --> 00:00:04,000
Adaptive Video Player in action.

2
00:00:04,500 --> 00:00:08,000
Quality, captions, and chapters on one player.
''',
          ),
        ],
        initialSubtitle: const SubtitleTrack(
          id: 'en',
          title: 'English CC',
          content: '''
1
00:00:01,000 --> 00:00:04,000
Adaptive Video Player in action.

2
00:00:04,500 --> 00:00:08,000
Quality, captions, and chapters on one player.
''',
        ),
        chapters: const [
          VideoChapter(title: 'Opening', startTime: Duration.zero),
          VideoChapter(title: 'Middle', startTime: Duration(seconds: 30)),
          VideoChapter(title: 'Later', startTime: Duration(minutes: 1)),
        ],
      ),
    ),
    const StudioSource(
      id: 'live',
      label: 'Live stream',
      description: 'HLS live badge, viewer count, and no timeline seek',
      icon: Icons.sensors_rounded,
      accentColor: Color(0xFFEC4899),
      features: [
        'Live badge',
        'Viewer count',
        'HLS',
        'Volume',
        'Fullscreen',
        'Mini player',
      ],
      config: VideoConfig(
        videoUrl: _hlsUrl,
        isLive: true,
        viewerCount: '142k VIEWERS',
        extension: VideoFileExtension.hls,
      ),
    ),
    const StudioSource(
      id: 'youtube',
      label: 'YouTube',
      description: 'YouTube URL with the same controls as a normal video',
      icon: Icons.smart_display_rounded,
      accentColor: Color(0xFFEF4444),
      features: [
        'YouTube embed',
        'Settings',
        'Playback speed',
        'Fullscreen',
        'Captions toggle',
      ],
      config: VideoConfig(videoUrl: _youtubeUrl),
    ),
    const StudioSource(
      id: 'youtube_live',
      label: 'YouTube live',
      description: 'YouTube live URL with the live badge and viewer count',
      icon: Icons.stream_rounded,
      accentColor: Color(0xFFF59E0B),
      features: [
        'YouTube live',
        'Live badge',
        'Viewer count',
        'Fullscreen',
      ],
      config: VideoConfig(
        videoUrl: _youtubeLiveUrl,
        isLive: true,
        viewerCount: '15.4K',
      ),
    ),
  ];
}
