import 'package:web/web.dart' as web;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

void registerYoutubeWebIframe(
  String viewId,
  String videoId,
  bool autoPlay, {
  bool mute = false,
  bool loop = false,
  bool enableCaption = true,
  String languageCode = 'en',
}) {
  ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
    final loopParams = loop ? '&loop=1&playlist=$videoId' : '';
    final ccParams = enableCaption
        ? '&cc_load_policy=1&cc_lang_pref=$languageCode'
        : '&cc_load_policy=0';
    final iframe = web.HTMLIFrameElement()
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..src =
          'https://www.youtube.com/embed/$videoId?autoplay=${autoPlay ? 1 : 0}&mute=${mute ? 1 : 0}&rel=0&vq=medium&hl=$languageCode$loopParams$ccParams'
      ..allowFullscreen = true
      ..allow = 'autoplay; fullscreen; picture-in-picture; encrypted-media';
    return iframe;
  });
}

Widget buildYoutubeWebIframe(String viewId, {Key? key}) {
  return HtmlElementView(key: key, viewType: viewId);
}
