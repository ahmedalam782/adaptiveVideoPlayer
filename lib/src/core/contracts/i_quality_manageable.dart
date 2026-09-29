import '../../normal_video_player/models/video_config.dart';

/// Segregated interface for managing video resolutions/qualities (ISP)
abstract class IQualityManageable {
  /// Available video quality resolutions
  List<VideoQuality>? get qualities;

  /// Currently active video quality
  VideoQuality? get currentQuality;

  /// Change active quality
  Future<void> changeQuality(VideoQuality quality);
}
