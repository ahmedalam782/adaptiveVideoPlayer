import 'package:adaptive_video_player/adaptive_video_player.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VideoFileExtension enum tests', () {
    test('detects standard MP4 video format', () {
      final format = VideoFileExtension.fromPath('https://example.com/video.mp4');
      expect(format, VideoFileExtension.mp4);
      expect(format?.extension, '.mp4');
      expect(format?.mimeType, 'video/mp4');
      expect(format?.isStreaming, isFalse);
    });

    test('detects HLS streaming format (.m3u8)', () {
      final format = VideoFileExtension.fromPath('https://example.com/master.m3u8');
      expect(format, VideoFileExtension.hls);
      expect(format?.extension, '.m3u8');
      expect(format?.mimeType, 'application/x-mpegURL');
      expect(format?.isStreaming, isTrue);
    });

    test('detects DASH streaming format (.mpd)', () {
      final format = VideoFileExtension.fromPath('https://example.com/manifest.mpd');
      expect(format, VideoFileExtension.dash);
      expect(format?.isStreaming, isTrue);
    });

    test('isSupported validates video files correctly', () {
      expect(VideoFileExtension.isSupported('video.mov'), isTrue);
      expect(VideoFileExtension.isSupported('video.mkv'), isTrue);
      expect(VideoFileExtension.isSupported('video.webm'), isTrue);
      expect(VideoFileExtension.isSupported('video.avi'), isTrue);
      expect(VideoFileExtension.isSupported('document.pdf'), isFalse);
      expect(VideoFileExtension.isSupported('image.png'), isFalse);
    });

    test('handles URLs with query parameters and fragments', () {
      final format = VideoFileExtension.fromPath(
          'https://example.com/stream.m3u8?token=xyz#segment1');
      expect(format, VideoFileExtension.hls);
    });
  });

  group('VideoSourceType enum tests', () {
    test('detects network, file, bytes, and youtube sources', () {
      expect(
        VideoSourceType.detect(source: 'https://example.com/video.mp4'),
        VideoSourceType.network,
      );
      expect(
        VideoSourceType.detect(source: '/storage/emulated/0/video.mp4', isFile: true),
        VideoSourceType.file,
      );
      expect(
        VideoSourceType.detect(source: '', isBytes: true),
        VideoSourceType.bytes,
      );
      expect(
        VideoSourceType.detect(source: 'https://youtube.com/watch?v=123', isYouTube: true),
        VideoSourceType.youtube,
      );
      expect(
        VideoSourceType.detect(source: 'data:video/mp4;base64,AAAA...'),
        VideoSourceType.dataUrl,
      );
    });
  });
}
