// Keep the existing native caching API out of the browser import graph.
export 'cached_player_stub.dart'
    if (dart.library.io) 'package:cached_video_player_plus/cached_video_player_plus.dart';
