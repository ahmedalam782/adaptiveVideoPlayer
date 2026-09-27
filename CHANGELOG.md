## 2.0.0

- **BREAKING (Architecture & Dependencies):**
  - Removed external dependency `flutter_bloc`.
  - Migrated internal state management to Flutter's native `ValueNotifier` (`YoutubePlayerNotifier`), drastically reducing package weight and eliminating version conflict risks with host applications.
  - Maintained full backwards compatibility with `YoutubePlayerCubit` as a typedef alias.
  - No public API changes for the `AdaptiveVideoPlayer` widget.

## 1.3.3

- **Full WASM Readiness & Platform Support (20/20 on pub.dev):**
  - Resolved `dart:io` leakage into Flutter Web and WASM compiler graphs by migrating `adaptive_controls.dart` to use conditional web-safe video player abstractions.
  - Decoupled platform initialization (`AdaptiveVideoPlayerPlatform`) into `platform_init_io.dart` and `platform_init_stub.dart`, isolating desktop/IO-specific backends (`video_player_media_kit`) from Web and WASM targets.
  - Achieved official **WASM-ready** status on pub.dev and full 20/20 platform support points.
  - Formatted entire repository adhering strictly to standard Dart format guidelines (50/50 static analysis score).

## 1.3.2

- **Feature (Localization):** Added customizable and localizable text labels in `PlayerTextConfig`:
  - `qualityText`: Label for video resolution/quality selection menu (defaults to `'Quality (Resolution)'`).
  - `autoText`: Label for automatic quality resolution (defaults to `'Auto'`).
  - `subtitlesText`: Label for subtitles menu (defaults to `'Subtitles'`).
  - `offText`: Label for disabled subtitles track (defaults to `'Off'`).
  - `noQualitiesAvailableText`: SnackBar feedback message when no resolutions are available (defaults to `'No qualities available'`).
  - `noSubtitlesAvailableText`: SnackBar feedback message when no subtitles are available (defaults to `'No subtitles available'`).
- **Enhancement (UI/UX):**
  - Refactored `AdaptiveControlsLayer` bottom bar with flexible and overflow-safe time layout (`Expanded`, `Flexible`, `FittedBox`), preventing render overflow issues on smaller mobile screens.
  - Reduced control icon button constraints and optimized spacing for a cleaner and more compact player interface.
  - Wrapped fullscreen video player view in explicit LTR directionality to prevent mirror layout bugs when playing videos inside RTL localized apps.
  - Styled feedback SnackBars using player theme's `settingsBackgroundColor` and `settingItemTextStyle` with floating behavior.

## 1.3.1

- **Maintenance:** Achieved full WebAssembly (WASM) compatibility on Flutter Web.
  - Refactored `video_player` imports to conditionally route to a native re-export or a custom web-safe controller/widget implementation.
  - Bypassed the transitive `dart:io` import in the official `video_player` package for web builds.
  - Declared `video_player_platform_interface` explicitly in the dependencies list.

## 1.3.0

- **Maintenance:** Upgraded `youtube_player_flutter` to version `10.0.1`.
  - Migrated controller APIs to use parameters and async duration streams.
  - Rewrote the position display, remaining display, and progress bar to use `StreamBuilder` and listen to `controller.videoStateStream` asynchronously.
- **Maintenance:** Explicitly declared support for all six platforms (`android`, `ios`, `linux`, `macos`, `web`, `windows`) in `pubspec.yaml` to ensure correct scoring on pub.dev.
- **Tests:** Created a fake WebView platform interface implementation to resolve WebView platform assertions in test environments, and upgraded all tests to pass.

## 1.2.3

- **Major Feature:** Added full **Windows** and **Linux** platform support — package now supports **all 6 platforms** (20/20 on pub.dev).
  - **Windows:** Uses `video_player_win` for normal video playback (compatible with `flutter_inappwebview`).
  - **Linux:** Uses `video_player_media_kit` (`media_kit` backend) for normal video playback.
- **New API:** Added `AdaptiveVideoPlayerPlatform.ensureInitialized()` — a single-line setup to enable desktop video playback in your `main()`.
- **Fix:** Moved YouTube player fullscreen button to appear after the YouTube logo in the bottom bar and increased icon size for better visibility.
- **Documentation:** Updated README with new platform support table, combined Windows & Linux setup guide, and updated FAQ.

## 1.1.1

- **Documentation:** Complete README overhaul with comprehensive usage examples, full configuration reference tables, platform permissions & setup guide, FAQ section, architecture overview, and contributing guidelines.
- **Documentation:** Added platform demo GIFs (Android, iOS, Windows, macOS, Web) to the README.
- **Documentation:** Added feature comparison table and platform-specific YouTube behavior details.

## 1.1.0

- **Major Feature:** Added Live Stream support with a dynamic "LIVE" indicator and adjustable Viewer Count (`isLive`, `viewerCount`).
- **Major Feature:** Added Quality Selection (Resolution/source picker) for dynamic MP4/HLS stream switching.
- **Major Feature:** Added Subtitle/CC Support parsing (SRT/VTT formats).
- **Major Feature:** Externalizing Custom UI Builders (`controlsBuilder`, `subtitleBuilder`) for complete custom overlay creation.
- **Enhancement:** Implemented Safe External Link Handling (Now opens YouTube external URLs like logos in the system browser securely rather than breaking the player).
- **Refactoring:** Removed the heavy `chewie` dependency out completely and engineered a fully integrated and adaptive built-in custom video playback control logic.
- **Refactoring:** Replaced `dart:html` with `package:web` completely, making the package **100% WASM ready** for advanced Web platform outputs.
- **Documentation:** Added a comprehensive Flutter example application demonstrating MP4 and YouTube video playback, and updated README instructions for Android.
- **Documentation:** Fixed README.md formatting and pubspec.yaml topic limits to achieve maximum 160 points on pub.dev.

## 1.0.4

- Fix `NormalVideoPlayer` playback on Web not rendering (removed dart:io dependency internally)

## 1.0.3

- Make web platform fully WASM-compatible by replacing dart:html with package:web

## 1.0.2

- Fix web platform compatibility issue from underlying dart:io import

## 1.0.1

- Enhanced platform architecture, fixed displays, and updated utilities and test dependencies

## 1.0.0

- Initial release
- Adaptive video player with automatic YouTube/direct video detection
- YouTube player with native controls on mobile (Android/iOS)
- YouTube player with InAppWebView + localhost server on Windows Desktop (fixes Error 153)
- YouTube player with HTML iframe on Web
- Normal video player powered by Chewie (MP4, MOV, AVI, MKV, WebM, etc.)
- Support for network URLs, local files, and in-memory video bytes
- Customizable player styling, text labels, and control visibility
- BLoC/Cubit state management
- Fullscreen mode with state preservation
- Settings panel (auto-play, loop, force HD, captions, mute)
- Seek forward/backward controls on mobile
- Cross-platform support: Android, iOS, Windows, Web
