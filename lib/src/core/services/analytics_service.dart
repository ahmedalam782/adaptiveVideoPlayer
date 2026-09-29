import '../contracts/i_analytics_service.dart';

/// Default analytics implementation delegating to an optional user-supplied callback.
class CallbackAnalyticsService implements IAnalyticsService {
  final void Function(String event, Map<String, dynamic> data)? _onAnalyticsEvent;

  CallbackAnalyticsService([this._onAnalyticsEvent]);

  @override
  void logEvent(String eventName, [Map<String, dynamic>? data]) {
    _onAnalyticsEvent?.call(eventName, data ?? const {});
  }
}
