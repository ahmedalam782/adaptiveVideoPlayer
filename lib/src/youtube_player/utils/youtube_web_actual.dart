import 'dart:convert';
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

import '../../core/constants/youtube_js_constants.dart';

void registerYoutubeWebIframe(
  String viewId,
  String videoId,
  bool autoPlay, {
  bool mute = false,
  bool loop = false,
  bool enableCaption = false,
  String languageCode = 'en',
  bool showControls = true,
}) {
  ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
    final loopParams = loop ? '&loop=1&playlist=$videoId' : '';
    final ccParams = enableCaption
        ? '&cc_load_policy=1&cc_lang_pref=$languageCode'
        : '&cc_load_policy=0';
    final controlsParam = showControls ? '&controls=1' : '&controls=0';

    final iframe = web.HTMLIFrameElement()
      ..id = viewId
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..src =
          'https://www.youtube.com/embed/$videoId?enablejsapi=1&autoplay=${autoPlay ? 1 : 0}&mute=${mute ? 1 : 0}&playsinline=1&rel=0&iv_load_policy=3&vq=medium&hl=$languageCode&fs=1$loopParams$ccParams$controlsParam'
      ..allowFullscreen = true
      ..allow = YouTubeJsScripts.iframeAllowPermissions;
    return iframe;
  });
}

Widget buildYoutubeWebIframe(String viewId, {Key? key}) {
  return HtmlElementView(key: key, viewType: viewId);
}

web.HTMLIFrameElement? _findIframeElement(String viewId) {
  try {
    // 1. Direct document lookup
    final direct = web.document.getElementById(viewId);
    if (direct != null) return direct as web.HTMLIFrameElement;

    // 2. Search inside all elements with a shadowRoot (such as flutter-view, flt-glass-pane, flt-platform-view)
    final allNodes = web.document.querySelectorAll('*');
    for (var i = 0; i < allNodes.length; i++) {
      final node = allNodes.item(i);
      if (node != null) {
        final element = node as web.Element;
        final shadow = element.shadowRoot;
        if (shadow != null) {
          final inShadow = shadow.getElementById(viewId);
          if (inShadow != null) return inShadow as web.HTMLIFrameElement;

          final shadowIframes = shadow.querySelectorAll('iframe');
          for (var j = 0; j < shadowIframes.length; j++) {
            final sIframe = shadowIframes.item(j);
            if (sIframe != null) {
              final iframe = sIframe as web.HTMLIFrameElement;
              if (iframe.id == viewId) return iframe;
            }
          }
        }
      }
    }

    // 3. Fallback: Query all iframes in top-level document
    final iframes = web.document.querySelectorAll('iframe');
    for (var i = 0; i < iframes.length; i++) {
      final item = iframes.item(i);
      if (item != null) {
        final iframe = item as web.HTMLIFrameElement;
        if (iframe.id == viewId) return iframe;
      }
    }
  } catch (_) {}
  return null;
}

void sendYoutubeWebCommand(
  String viewId,
  String command, [
  List<dynamic> args = const [],
]) {
  try {
    final iframe = _findIframeElement(viewId);
    if (iframe != null && iframe.contentWindow != null) {
      final payload = jsonEncode({
        'event': 'command',
        'func': command,
        'args': args,
      });
      iframe.contentWindow!.postMessage(payload.toJS, '*'.toJS);
    }
  } catch (_) {}
}

void toggleYoutubeWebFullscreen(String viewId) {
  try {
    if (web.document.fullscreenElement != null) {
      web.document.exitFullscreen();
    } else {
      final iframe = _findIframeElement(viewId);
      if (iframe != null) {
        iframe.requestFullscreen();
      } else {
        web.document.documentElement?.requestFullscreen();
      }
    }
  } catch (_) {}
}

bool isYoutubeWebFullscreen() {
  try {
    return web.document.fullscreenElement != null;
  } catch (_) {
    return false;
  }
}

typedef YoutubeWebInfoCallback = void Function({
  double? currentTime,
  double? duration,
  int? playerState,
  bool? isMuted,
});

void listenToYoutubeWebMessages(
    String viewId, YoutubeWebInfoCallback callback) {
  try {
    web.window.addEventListener(
      'message',
      (web.MessageEvent event) {
        try {
          final origin = event.origin;
          // Security & stability: Only process messages from youtube.com to prevent breaking DWDS
          if (!origin.contains('youtube.com')) return;

          final data = event.data;
          if (data == null) return;
          final dartData = data.dartify();
          Map<String, dynamic>? map;
          if (dartData is String && dartData.startsWith('{')) {
            final decoded = jsonDecode(dartData);
            if (decoded is Map<String, dynamic>) {
              map = decoded;
            }
          } else if (dartData is Map) {
            map = Map<String, dynamic>.from(dartData);
          }
          if (map != null) {
            final evt = map['event'];
            if (evt == 'infoDelivery') {
              final info = map['info'];
              if (info is Map) {
                final cur = (info['currentTime'] as num?)?.toDouble();
                final dur = (info['duration'] as num?)?.toDouble();
                final state = (info['playerState'] as num?)?.toInt();
                final muted = info['muted'] as bool?;
                callback(
                  currentTime: cur,
                  duration: dur,
                  playerState: state,
                  isMuted: muted,
                );
              }
            }
          }
        } catch (_) {}
      }.toJS,
    );
  } catch (_) {}
}
