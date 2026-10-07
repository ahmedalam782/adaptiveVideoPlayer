import 'package:flutter/material.dart';

void registerYoutubeWebIframe(
  String viewId,
  String videoId,
  bool autoPlay, {
  bool mute = false,
  bool loop = false,
  bool enableCaption = false,
  String languageCode = 'en',
  bool showControls = true,
}) {}

Widget buildYoutubeWebIframe(String viewId, {Key? key}) {
  return const SizedBox();
}

void sendYoutubeWebCommand(
  String viewId,
  String command, [
  List<dynamic> args = const [],
]) {}

void toggleYoutubeWebFullscreen(String viewId) {}

bool isYoutubeWebFullscreen() => false;

typedef YoutubeWebInfoCallback = void Function({
  double? currentTime,
  double? duration,
  int? playerState,
  bool? isMuted,
});

void listenToYoutubeWebMessages(String viewId, YoutubeWebInfoCallback callback) {}
