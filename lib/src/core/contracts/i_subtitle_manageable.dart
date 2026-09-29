import '../../normal_video_player/models/video_config.dart';

/// Segregated interface for managing subtitles / closed captions (ISP)
abstract class ISubtitleManageable {
  /// Available subtitle tracks
  List<SubtitleTrack>? get subtitles;

  /// Currently active subtitle track
  SubtitleTrack? get currentSubtitle;

  /// Change active subtitle track (null to disable)
  Future<void> changeSubtitle(SubtitleTrack? track);
}
