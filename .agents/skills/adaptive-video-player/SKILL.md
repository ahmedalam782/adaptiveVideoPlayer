---
name: adaptive-video-player
description: >-
  Provides comprehensive knowledge, architecture guidelines, directory structure, and development workflows for the adaptive_video_player codebase. Use this skill when inspecting, developing, debugging, refactoring, or testing the video player components (Normal Video Player, YouTube Player, Mixins, Fullscreen/PiP Services, Adaptive Controls, and Win32 Desktop integrations).
---

# Adaptive Video Player Architecture & Development Guide

This skill guides any agent working on the `adaptive_video_player` (repo: `vidoes_player`) Flutter package.

---

## 1. Project Overview & Architecture

The package provides a unified, cross-platform video player supporting:
- **Normal Video Player**: HLS (`.m3u8`), DASH (`.mpd`), MP4, network URLs, local files, and in-memory bytes with quality selector, subtitle parser, volume HUD, gesture seeking, timeline hover/scrub pills, hold-to-2x speed, and chapters.
- **YouTube Player**: Unified native engine architecture:
  - **Mobile (Android/iOS) & Desktop (Windows/macOS/Linux)**: Native `flutter_inappwebview` with an embedded localized HTTP server (`http://localhost`) providing a trusted origin that bypasses YouTube Error 150/153 and preserves full controls, gestures, and PiP.
  - **Web**: Native browser `HTMLIFrameElement`.
- **Native Fullscreen & PiP**:
  - **Windows Desktop**: Win32 borderless window mode (`WS_OVERLAPPEDWINDOW` removal, monitor rect spanning over taskbar) and always-on-top OS-level Picture-in-Picture window (`HWND_TOPMOST`).
  - **Web**: Native browser HTML5 fullscreen and `document.pictureInPictureElement`.
  - **Mobile / General**: Draggable in-app floating miniplayer overlay across navigation routes and Android/iOS native PiP integration.

```text
lib/
├── adaptive_video_player.dart                  # Main public library export
└── src/
    ├── core/                                   # Domain contracts, DI, constants & adapters
    │   ├── contracts/                          # Interfaces (SRP / ISP)
    │   │   ├── i_video_player_controller.dart
    │   │   ├── i_fullscreen_service.dart
    │   │   ├── i_playback_controls.dart
    │   │   ├── i_quality_manageable.dart
    │   │   ├── i_subtitle_manageable.dart
    │   │   ├── i_volume_controls.dart
    │   │   └── i_analytics_service.dart
    │   ├── adapters/                           # Concrete adapters (Adapter Pattern)
    │   │   ├── native_player_adapter.dart
    │   │   └── youtube_player_adapter.dart
    │   ├── constants/                          # Centralized JavaScript & constants
    │   │   ├── hls_js_constants.dart
    │   │   ├── youtube_js_constants.dart
    │   │   └── constants.dart
    │   ├── di/                                 # Service locator & scope
    │   │   ├── service_locator.dart
    │   │   └── player_scope.dart
    │   ├── factory/                            # Polymorphic controller factory
    │   │   └── player_controller_factory.dart
    │   ├── models/                             # Player state enum & models
    │   └── services/                           # Platform services (Fullscreen, Analytics, Native PiP)
    ├── normal_video_player/                    # Normal video player implementation
    │   ├── mixins/                             # Modular State mixins (SRP)
    │   │   ├── normal_player_controller_mixin.dart
    │   │   ├── normal_player_subtitles_mixin.dart
    │   │   ├── normal_player_playback_resilience_mixin.dart
    │   │   ├── normal_player_fullscreen_mixin.dart
    │   │   └── normal_player_pip_mixin.dart
    │   ├── models/                             # Video config, quality, chapters, display mode
    │   │   ├── video_config.dart               # Unified configuration model with copyWith
    │   │   ├── video_quality.dart
    │   │   ├── video_chapter.dart
    │   │   ├── subtitle_track.dart
    │   │   └── normal_player_display_mode.dart # Presentation enum for switch expressions
    │   ├── views/                              # Presentation views
    │   │   └── normal_player_view.dart
    │   ├── widgets/                            # Modular composite controls (OOP/SRP)
    │   │   ├── adaptive_controls_layer.dart    # Controls overlay
    │   │   ├── adaptive_bottom_bar.dart        # Pill controls, volume, timestamp, settings
    │   │   ├── adaptive_top_bar.dart           # Back button, title, live viewer badge
    │   │   ├── adaptive_video_surface.dart     # Keyed VideoPlayer surface + captions
    │   │   ├── adaptive_player_settings_sheet.dart # Draggable quality & subtitle selector
    │   │   ├── adaptive_seek_feedback_overlay.dart # Double-tap seek HUD (+10s, +20s)
    │   │   ├── adaptive_progress_bar.dart      # Scrubbing timeline with chapter markers
    │   │   ├── normal_fullscreen_overlay.dart # Fullscreen container with Esc listener
    │   │   ├── normal_mini_player_placeholder.dart # In-place placeholder when floating
    │   │   └── normal_native_pip_view.dart     # Native PiP viewport
    │   ├── utils/
    │   │   ├── win32_window_ffi.dart           # Pure Win32 FFI bindings & helpers
    │   │   ├── win32_fullscreen_service.dart   # Dedicated Windows fullscreen manager
    │   │   ├── win32_desktop_pip_service.dart  # Dedicated Windows PiP manager
    │   │   ├── fullscreen_utils_io.dart        # Facade exporting Win32 services
    │   │   ├── subtitle_parser.dart            # WebVTT / SRT parser
    │   │   └── hls_web_helper_web.dart         # Safe HLS injection using constants
    │   ├── adaptive_controls.dart              # BaseAdaptiveVideoPlayer widget
    │   └── normal_video_player.dart            # NormalVideoPlayer StatefulWidget
    └── youtube_player/                         # YouTube player implementation
        ├── mixins/                             # Modular State mixins (SRP)
        │   ├── youtube_player_pip_mixin.dart
        │   └── youtube_player_web_iframe_mixin.dart
        ├── services/                           # Localhost origin server service
        │   └── youtube_local_server_service.dart
        ├── models/                             # YouTube player configurations
        │   ├── youtube_player_config.dart
        │   └── player_text_config.dart
        ├── views/
        │   ├── youtube_desktop_player_view.dart
        │   └── youtube_desktop_player_with_overlay.dart
        ├── widgets/                            # Overlay, live badge, replay, controls
        └── youtube_video_player.dart           # YouTubeVideoPlayer StatefulWidget
```

---

## 2. Core Architectural Patterns & Guidelines

### A. Unified Configuration Model (`VideoConfig`)
- `NormalVideoPlayer` receives a single unified `VideoConfig config` property instead of 22 loose arguments.
- Instantiation options:
  - `NormalVideoPlayer.fromConfig(config: config)` (const constructor).
  - `NormalVideoPlayer(config: config)`.
  - `NormalVideoPlayer(videoSource: '...', subtitles: ...)` (backwards-compatible factory).
- All properties (`videoSource`, `subtitles`, `isLive`, `styling`, etc.) are exposed as clean delegated getters on `NormalVideoPlayer` mapping to `config.*`.
- `VideoConfig` includes `copyWith(...)` for immutable state updates.

### B. Modular Mixins over Monoliths (SRP)
Both player widgets decompose their state logic across dedicated, testable mixins:
- `NormalPlayerControllerMixin`: VideoPlayerController lifecycle, URL validation, and seamless resolution changes.
- `NormalPlayerSubtitlesMixin`: VTT/SRT loading, caching, track switching, and timeline synchronization.
- `NormalPlayerPlaybackResilienceMixin`: Preserves playback across state transitions, minimizing buffering glitches.
- `NormalPlayerFullscreenMixin`: Coordinates overlay-based fullscreen, orientation locking, and Esc listeners.
- `NormalPlayerPipMixin`: Floating draggable miniplayer and desktop PiP window lifecycle.
- `YouTubePlayerPipMixin`: Handles PiP overlay for YouTube playback.
- `YouTubePlayerWebIframeMixin`: Manages `HTMLIFrameElement` registrations and DOM communication on Web.

### C. Declarative Switch Expressions for Widget Rendering
- Replace procedural `if/else if` ladders in `.build()` methods with declarative switch expressions evaluated against presentation enums (e.g. `NormalPlayerDisplayMode`).
- Extract specialized sub-views into dedicated widgets (`NormalMiniPlayerPlaceholder`, `NormalNativePipView`, `NormalPlayerErrorWidget`, `NormalPlayerLoadingWidget`).

### D. Centralized Native Scripts & Constants
- Never write multi-line inline JavaScript strings inside Flutter widgets or helper classes.
- Centralize all scripts in `lib/src/core/constants/`:
  - `hls_js_constants.dart` (`hlsJsCdnScript`, `hlsJsInlineBundle`, `hlsInitScriptTemplate`).
  - `youtube_js_constants.dart` (`youtubeIframeApiScript`, `youtubeHtmlTemplate`).

### E. Win32 Desktop Integrations (DIP & Single Responsibility)
- Segregate Windows desktop platform logic into discrete files:
  - `win32_window_ffi.dart`: Low-level `dart:ffi` type definitions (`WINDOWPLACEMENT`, `RECT`, `user32.dll` lookups).
  - `win32_fullscreen_service.dart`: Borderless fullscreen styling, multi-monitor geometry, and restoration.
  - `win32_desktop_pip_service.dart`: Topmost window resizing, dragging, and hot-restart restoration.
  - `fullscreen_utils_io.dart`: Facade layer providing clean public API delegating to the services.

### F. YouTube Unified Engine Architecture
- YouTube embedding does **not** use `youtube_player_flutter`.
- On **Mobile & Desktop**: Powered by `flutter_inappwebview` with a local HTTP server (`YouTubeLocalServerService`) serving from `http://localhost`. This eliminates YouTube embedding restrictions (Error 150/153) and ensures reliable playback across Android, iOS, Windows, macOS, and Linux.
- On **Web**: Powered by native `HTMLIFrameElement` via `ui_web.platformViewRegistry`.

---

## 3. Standard Verification & Testing Workflow

Before committing any changes, always run the full verification pipeline:

```bash
# 1. Static Analysis (must have 0 warnings and 0 errors)
flutter analyze

# 2. Automated Test Suite (all tests must pass)
flutter test

# 3. Example Project Build (verify native compilation)
cd example
flutter build windows --debug
```

---

## 4. Coding Conventions
- **Single Responsibility (SRP)**: Keep UI elements, buttons, and dialogs in dedicated widget files under `widgets/`.
- **Zero Raw Strings for Logic**: Use strongly-typed enums (`NormalPlayerDisplayMode`, `VideoFileExtension`, `VideoSourceType`, `PlayerState`).
- **Web-Safe Imports**: Always route web-specific code through conditional exports (`video_player_web_safe.dart`, `platform_init.dart`, `fullscreen_utils_export.dart`).
- **Preserve Documentation**: Maintain complete dartdoc comments (`///`) on all public APIs, types, and exported models.
