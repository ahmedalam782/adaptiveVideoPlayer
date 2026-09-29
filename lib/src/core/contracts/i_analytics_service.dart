/// Interface for reporting player analytics and lifecycle events (SRP & DIP)
abstract class IAnalyticsService {
  /// Track a video playback event with optional metadata
  void logEvent(String eventName, [Map<String, dynamic>? data]);
}
