import 'dart:js_interop';
import 'package:web/web.dart' as web;

import '../../core/constants/hls_js_constants.dart';

@JS('eval')
external JSAny? _eval(String code);

/// Attaches Hls.js to HTML video elements on Web browsers without native HLS (e.g. Chrome, Firefox, Edge).
void setupHlsForWeb(String url, int playerId) {
  if (!url.contains('.m3u8')) return;

  // 1. Inject hls.js from CDN if not already loaded in the document
  final existing =
      web.document.querySelector('#${HlsJsConstants.hlsScriptElementId}');
  if (existing == null) {
    final script = web.HTMLScriptElement()
      ..id = HlsJsConstants.hlsScriptElementId
      ..src = HlsJsConstants.hlsCdnScriptUrl
      ..async = false;
    web.document.head?.appendChild(script);
  }

  // 2. Poll briefly until the video element is mounted in the DOM, then attach Hls.js if native HLS is missing
  final jsCode = HlsJsConstants.generateAttachHlsScript(url);

  _eval(jsCode);
}
