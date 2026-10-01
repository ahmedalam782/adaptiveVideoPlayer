import 'dart:convert';
import 'package:flutter/services.dart';

/// Represents a subtitle or closed caption track (SRT or VTT format).
class SubtitleTrack {
  final String id;
  final String title;

  /// The subtitle raw content (srt or vtt format)
  final String? content;

  /// A callback to fetch the content if not provided upfront (e.g. from an API or remote source)
  final Future<String> Function()? fetcher;

  const SubtitleTrack({
    required this.id,
    required this.title,
    this.content,
    this.fetcher,
  });

  /// Factory for loading subtitles from a Flutter asset file (e.g. `assets/subtitles/movie_ar.srt`).
  factory SubtitleTrack.fromAsset({
    required String id,
    required String title,
    required String assetPath,
    AssetBundle? bundle,
  }) {
    return SubtitleTrack(
      id: id,
      title: title,
      fetcher: () => (bundle ?? rootBundle).loadString(assetPath),
    );
  }

  /// Factory for loading subtitles directly from a network or API URL.
  factory SubtitleTrack.fromNetwork({
    required String id,
    required String title,
    required String url,
  }) {
    return SubtitleTrack(
      id: id,
      title: title,
      fetcher: () async {
        final uri = Uri.parse(url);
        final bundle = NetworkAssetBundle(uri);
        final byteData = await bundle.load('');
        return utf8.decode(byteData.buffer.asUint8List());
      },
    );
  }

  /// Factory for loading subtitles with a custom asynchronous API call.
  factory SubtitleTrack.fromApi({
    required String id,
    required String title,
    required Future<String> Function() apiCall,
  }) {
    return SubtitleTrack(
      id: id,
      title: title,
      fetcher: apiCall,
    );
  }
}
