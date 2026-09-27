/// Initializes platform-specific video player backends.
///
/// Call this method in your `main()` function before `runApp()`
/// to enable video playback on desktop platforms (Linux).
///
/// Example:
/// ```dart
/// void main() {
///   AdaptiveVideoPlayerPlatform.ensureInitialized();
///   runApp(MyApp());
/// }
/// ```
library;

export 'platform_init_stub.dart' if (dart.library.io) 'platform_init_io.dart';
