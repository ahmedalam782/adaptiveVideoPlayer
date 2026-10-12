import '../models/video_episode.dart';

/// Shared calculations for the mobile design and the responsive window design.
class PlayerChromeUtils {
  const PlayerChromeUtils._();

  static String headline({String? title, String? episodeTitle}) {
    if (episodeTitle != null && episodeTitle.isNotEmpty) return episodeTitle;
    if (title != null && title.isNotEmpty) return title;
    return '';
  }

  /// Episode line under the title. Omitted when the title already includes it.
  static String? episodeSubtitle({String? title, String? episodeTitle}) {
    if (episodeTitle == null || episodeTitle.isEmpty) return null;
    if (title != null && title.contains(episodeTitle)) return null;
    return episodeTitle;
  }

  static Duration clampSeek({
    required Duration position,
    required Duration duration,
    required Duration delta,
  }) {
    var target = position + delta;
    if (target < Duration.zero) return Duration.zero;
    if (duration > Duration.zero && target > duration) return duration;
    return target;
  }

  static String playbackRateLabel(double rate) {
    if ((rate - rate.roundToDouble()).abs() < 0.001) {
      return '${rate.toStringAsFixed(0)}x';
    }
    return '${rate}x';
  }

  static double nearestSpeed(double speed, List<double> speeds) {
    return speeds.reduce(
      (best, candidate) => (candidate - speed).abs() < (best - speed).abs()
          ? candidate
          : best,
    );
  }

  /// Speed index under a horizontal drag, snapping to the nearest column.
  ///
  /// [dx] is measured from the left edge. [rtl] keeps the slowest speed on
  /// the right.
  static int speedIndexAt({
    required double dx,
    required double width,
    required int count,
    required bool rtl,
  }) {
    if (count <= 1 || width <= 0) return 0;
    final fromLeft =
        ((dx / (width / count)) - 0.5).round().clamp(0, count - 1).toInt();
    return rtl ? count - 1 - fromLeft : fromLeft;
  }

  static String clockLabel(Duration? duration) {
    if (duration == null || duration == Duration.zero) return '';
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  static String seasonKey(VideoEpisode episode) {
    return episode.extra?['season']?.toString() ?? '';
  }

  static Map<String, List<VideoEpisode>> groupBySeason(
    List<VideoEpisode> episodes,
  ) {
    final groups = <String, List<VideoEpisode>>{};
    for (final episode in episodes) {
      groups.putIfAbsent(seasonKey(episode), () => []).add(episode);
    }
    return groups;
  }

  static String seasonLabel({
    required String season,
    required bool isRtl,
    required String episodesLabel,
  }) {
    if (season.isEmpty) return episodesLabel;
    return isRtl ? 'موسم $season' : 'Season $season';
  }
}
