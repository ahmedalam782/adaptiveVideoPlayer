import 'dart:js_interop';
import 'package:web/web.dart' as web;

@JS('eval')
external JSAny? _eval(String code);

/// Attaches Hls.js to HTML video elements on Web browsers without native HLS (e.g. Chrome, Firefox, Edge).
void setupHlsForWeb(String url, int playerId) {
  if (!url.contains('.m3u8')) return;

  // 1. Inject hls.js from CDN if not already loaded in the document
  final existing = web.document.querySelector('#hls-js-cdn-script');
  if (existing == null) {
    final script = web.HTMLScriptElement()
      ..id = 'hls-js-cdn-script'
      ..src = 'https://cdn.jsdelivr.net/npm/hls.js@latest'
      ..async = false;
    web.document.head?.appendChild(script);
  }

  // 2. Poll briefly until the video element is mounted in the DOM, then attach Hls.js if native HLS is missing
  final jsCode = '''
    (function() {
      var sourceUrl = "$url";
      var attempts = 0;
      function tryAttachHls() {
        var videos = document.querySelectorAll('video');
        for (var i = 0; i < videos.length; i++) {
          var v = videos[i];
          if (v.getAttribute('data-hls-attached') === 'true') continue;
          
          // Safari supports HLS natively; do not attach hls.js
          if (v.canPlayType && v.canPlayType('application/vnd.apple.mpegurl')) {
            v.setAttribute('data-hls-attached', 'native');
            return;
          }
          
          // Non-Safari browsers (Chrome, Edge, Firefox): attach Hls.js
          if (window.Hls && window.Hls.isSupported()) {
            try {
              var hls = new window.Hls({
                enableWorker: true,
                lowLatencyMode: true,
                backBufferLength: 90
              });
              hls.loadSource(sourceUrl);
              hls.attachMedia(v);
              v.setAttribute('data-hls-attached', 'true');
              v._hlsInstance = hls;
              return;
            } catch(err) {
              console.warn('[AdaptiveVideoPlayer Web HLS] Error attaching Hls.js:', err);
            }
          }
        }
        if (attempts++ < 40) {
          setTimeout(tryAttachHls, 100);
        }
      }
      tryAttachHls();
    })();
  ''';

  _eval(jsCode);
}
