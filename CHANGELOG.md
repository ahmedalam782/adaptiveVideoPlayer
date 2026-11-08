## 2.0.3

- **Fix (WASM import graph):** Removed direct `dart:io` platform checks from shared PiP/player code, conditionally exported the local HTTP server, and kept the native caching package export out of web builds.
- **Compatibility:** Requires Flutter 3.44+ and Dart 3.12+ for the plugin-author Kotlin migration. Android hosts using legacy AGP must supply Kotlin 2.0+; the example uses Kotlin 2.2.20.
- **Fix (Android Built-in Kotlin):** Configured JVM 17 through `kotlin.compilerOptions` and removed legacy Kotlin plugin and `android.kotlinOptions` configuration.
- **Quality Assurance:** 260 unit and widget tests pass; `flutter analyze` reports no issues.

## 2.0.2

- **Fix (Android Built-in Kotlin):**
  - Migrated `android/build.gradle` from legacy `buildscript {}` + `apply plugin:` pattern to modern declarative `plugins {}` block, resolving the pub.dev "Legacy Kotlin configuration detected" warning.
- **Quality Assurance:**
  - 100% test pass rate across 260 unit and widget tests with zero static analysis warnings.

## 2.0.1

- **Feature (Background Auto-PiP across Native Platforms):**
  - Added automatic Picture-in-Picture mode when the application is minimized or backgrounded during active playback across all native platforms (**Android, iOS, Windows, macOS, and Linux**).
  - **Web (Chrome 120+ / Edge)**: Added standard `autopictureinpicture` HTML attribute support with continuous `MutationObserver` synchronization. Supported Chromium browsers now automatically pop out the video into native OS PiP upon switching tabs or navigating away during active playback.
  - **Windows & macOS**: Seamlessly transitions minimized/backgrounded windows into a compact, always-on-top floating PiP window (`380x214`) positioned at the bottom-right corner without enlarging or getting stuck in full-size.
  - **iOS 14.2+**: Enabled seamless native inline auto-PiP using `AVPictureInPictureController.canStartPictureInPictureAutomaticallyFromInline`, synchronous background playback coordination, and automatic unmute/mute state handoff.
  - **Android 12+ (API 31+)**: Enabled native seamless transitions via `PictureInPictureParams.Builder.setAutoEnterEnabled(true)`.
  - **Android 8.0–11 (API 26–30)**: Added `onUserLeaveHint` listener support in `AdaptiveVideoPlayerPlugin` and example `MainActivity`.
  - **Linux**: Gracefully transitions to in-app floating mini-player overlay during background lifecycle events.
- **Enhancement (Universal PiP Controls in Normal Video Player):**
  - Enabled on-screen Picture-in-Picture (PiP / mini-player) button across all platforms (phones, tablets, desktop, and web) in `NormalVideoPlayer`.
  - Resolved YouTube desktop PiP re-sync issue on Windows, ensuring the PiP button immediately restores upon closing PiP without requiring fullscreen toggling.
- **Fix (PiP & Compact Layout Responsive Overflow):**
  - Resolved `RenderFlex` overflow errors in `MobilePlayerChrome` by dynamically adjusting vertical padding, hiding top bar when height < 95px, and scaling transport controls with `FittedBox`.
- **Quality Assurance:**
  - 100% test pass rate across 260 unit and widget tests with zero static analysis warnings.

## 2.0.0

- **Feature (Anti-Screen Capture Shield):**
  - Added `preventScreenCapture` toggle in `VideoConfig`.
  - Automatically turns the window/video surface solid black in screenshots and screen recordings on Android (`FLAG_SECURE`) and Windows (`SetWindowDisplayAffinity(WDA_MONITOR)`).
  - Managed by reference-counted `ScreenProtectionService` with automatic cleanup across player disposal and route transitions.
- **Feature (Offline Disk Caching):**
  - Added `enableCache` toggle in `VideoConfig` leveraging `CachedVideoPlayerPlus` for caching network streams locally for instant replay and offline playback.
- **Enhancement (Horizontal Scroller & Mouse Drag):**
  - Added persistent horizontal `Scrollbar`, navigation chevron buttons (`<` / `>`), auto-scroll to selected item, and global mouse-drag support (`PointerDeviceKind.mouse`) across web and desktop.
- **Architectural Overhaul:**
  - Netflix-style bold percentage circular loader, dual-column audio and subtitle picker, episodes drawer, and speed stepper popups.
  - Zero static analysis warnings and 100% test pass rate across all 246 tests.

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
