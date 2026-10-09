/// Centralized constants and JavaScript templates for HLS web playback.
class HlsJsConstants {
  const HlsJsConstants._();

  /// CDN URL for the hls.js library.
  static const String hlsCdnScriptUrl =
      'https://cdn.jsdelivr.net/npm/hls.js@latest';

  /// Script element ID used to avoid duplicate script injection in the DOM.
  static const String hlsScriptElementId = 'hls-js-cdn-script';

  /// DOM attribute name marking video elements that have been processed for HLS.
  static const String hlsAttachedAttribute = 'data-hls-attached';

  /// Generates the self-executing JavaScript snippet that attaches Hls.js
  /// to video elements in browsers without native HLS support.
  static String generateAttachHlsScript(String sourceUrl) => '''
    (function() {
      var sourceUrl = "$sourceUrl";
      var attempts = 0;
      function tryAttachHls() {
        var videos = document.querySelectorAll('video');
        for (var i = 0; i < videos.length; i++) {
          var v = videos[i];
          if (v._hlsSource === sourceUrl) continue;

          // Safari supports HLS natively; do not attach hls.js
          if (v.canPlayType && (v.canPlayType('application/vnd.apple.mpegurl') === 'probably' || v.canPlayType('application/vnd.apple.mpegurl') === 'maybe')) {
            v._hlsSource = sourceUrl;
            v.setAttribute('$hlsAttachedAttribute', 'native');
            return;
          }

          // Non-Safari browsers (Chrome, Edge, Firefox): attach Hls.js
          if (window.Hls && window.Hls.isSupported()) {
            try {
              if (v._hlsInstance) {
                try { v._hlsInstance.destroy(); } catch (_) {}
                v._hlsInstance = null;
              }
              v.removeAttribute('src');
              var hls = new window.Hls({
                enableWorker: true,
                lowLatencyMode: true,
                backBufferLength: 90
              });
              hls.loadSource(sourceUrl);
              hls.attachMedia(v);
              v.setAttribute('$hlsAttachedAttribute', 'true');
              v._hlsInstance = hls;
              v._hlsSource = sourceUrl;
              return;
            } catch(err) {
              console.warn('[AdaptiveVideoPlayer Web HLS] Error attaching Hls.js:', err);
            }
          }
        }
        if (attempts++ < 60) {
          setTimeout(tryAttachHls, 100);
        }
      }
      tryAttachHls();
    })();
  ''';
}
