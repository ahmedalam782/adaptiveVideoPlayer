import 'package:adaptive_video_player/src/core/constants/hls_js_constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HlsJsConstants Tests', () {
    test('constants have expected values', () {
      expect(HlsJsConstants.hlsCdnScriptUrl,
          contains('https://cdn.jsdelivr.net/npm/hls.js@latest'));
      expect(HlsJsConstants.hlsScriptElementId, equals('hls-js-cdn-script'));
      expect(HlsJsConstants.hlsAttachedAttribute, equals('data-hls-attached'));
    });

    test('generateAttachHlsScript interpolates sourceUrl and attributes', () {
      const testUrl = 'https://example.com/playlist.m3u8';
      final script = HlsJsConstants.generateAttachHlsScript(testUrl);

      expect(script, contains(testUrl));
      expect(script, contains(HlsJsConstants.hlsAttachedAttribute));
      expect(script, contains('window.Hls'));
      expect(script, contains('tryAttachHls'));
    });
  });
}
