---
name: adaptive-video-player
description: >-
  Provides comprehensive knowledge, architecture guidelines, directory structure, and development workflows for the adaptive_video_player codebase. Use this skill when inspecting, developing, debugging, refactoring, or testing the video player components (Normal Video Player, YouTube Player, Fullscreen Coordinators, Adaptive Controls, and Win32 Desktop integrations).
---

# Adaptive Video Player Architecture & Development Guide

This skill guides any agent working on the `adaptive_video_player` (repo: `vidoes_player`) Flutter package.

---

## 1. Project Overview & Architecture

The package provides a unified, cross-platform video player supporting:
- **Normal Video Player**: HLS (`.m3u8`), DASH (`.mpd`), MP4, network URLs, local files, and in-memory bytes with quality selector, subtitle parser, volume HUD, and gesture seeking.
- **YouTube Player**: Embedded HTML5 player with mobile WebView (`webview_flutter`) and desktop Windows/macOS/Linux local HTTP server + `flutter_inappwebview` integration.
- **Native Fullscreen**: Win32 borderless window mode on Windows desktop covering the taskbar without window borders; browser fullscreen on Web; system UI immersive mode on mobile.

```text
lib/
├── adaptive_video_player.dart                  # Main public library export
└── src/
    ├── core/                                   # Domain contracts & DI architecture
    │   ├── contracts/                          # Interfaces (SRP / ISP)
    │   │   ├── i_video_player_controller.dart
    │   │   ├── i_fullscreen_service.dart
    │   │   ├── i_playback_controls.dart
    │   │   ├── i_quality_manageable.dart
    │   │   ├── i_subtitle_manageable.dart
    │   │   └── i_volume_controls.dart
    │   ├── adapters/                           # Concrete adapters
    │   │   ├── native_player_adapter.dart
    │   │   └── youtube_player_adapter.dart
    │   ├── di/                                 # Service locator & scope
    │   │   ├── service_locator.dart
    │   │   └── player_scope.dart
    │   └── mixins/                             # Shared behaviors
    ├── normal_video_player/                    # Native video player implementation
    │   ├── coordinator/                        # Fullscreen overlay management
    │   │   └── normal_fullscreen_coordinator.dart
    │   ├── models/                             # Video config, quality, subtitle models
    │   │   ├── video_config.dart
    │   │   ├── video_quality.dart
    │   │   └── subtitle_track.dart
    │   ├── views/                              # Presentation views
    │   │   └── normal_player_view.dart
    │   ├── widgets/                            # Modular composite controls (OOP/SRP)
    │   │   ├── adaptive_controls_layer.dart    # Controls overlay & movable dialog
    │   │   ├── adaptive_bottom_bar.dart        # Play, volume, time, settings, fs buttons
    │   │   ├── adaptive_top_bar.dart           # Back button, title, live viewer badge
    │   │   ├── adaptive_video_surface.dart     # Keyed VideoPlayer surface + captions
    │   │   ├── adaptive_player_settings_sheet.dart # Quality & subtitle selector
    │   │   ├── adaptive_seek_feedback_overlay.dart # Double-tap seek HUD (+10s, +20s)
    │   │   ├── adaptive_volume_hud_overlay.dart    # Volume HUD overlay
    │   │   └── normal_fullscreen_overlay.dart # Fullscreen container with Esc listener
    │   ├── utils/
    │   │   ├── adaptive_player_keyboard_handler.dart # Keyboard shortcuts (Esc, Space, F, etc.)
    │   │   ├── fullscreen_utils_io.dart        # Win32 FindWindowExW borderless fullscreen
    │   │   └── subtitle_parser.dart            # WebVTT / SRT parser
    │   ├── adaptive_controls.dart              # BaseAdaptiveVideoPlayer widget
    │   └── normal_video_player.dart            # NormalVideoPlayer StatefulWidget
    └── youtube_player/                         # YouTube player implementation
        ├── coordinator/
        │   └── youtube_fullscreen_coordinator.dart # Persistent GlobalKey fullscreen
        ├── models/                             # YouTube player configurations
        ├── views/
        │   ├── youtube_desktop_player_view.dart # Desktop WebView with local server
        │   └── youtube_mobile_player_view.dart  # Mobile WebView
        ├── widgets/                            # Overlay, live badge, replay overlay
        └── youtube_video_player.dart           # YouTubeVideoPlayer StatefulWidget
```

---

## 2. Core Principles & Critical Invariants

### A. Fullscreen Coordination & Reactive Rebuilds
- `NormalFullscreenCoordinator` extends `ChangeNotifier` and hosts an `OverlayEntry`.
- The overlay is wrapped in `ListenableBuilder(listenable: this, builder: ...)`.
- **Rule**: Any state mutation in `NormalVideoPlayerState` (`setState()`) must call `_fullscreenCoordinator.rebuildOverlay()` so fullscreen displays the updated controller, resolution, and subtitle state.
- **Escape Key**: Handled by `CallbackShortcuts(bindings: { SingleActivator(LogicalKeyboardKey.escape): onExitFullscreen })`.

### B. Resolution / Quality Switching
- `_changeQuality(newQuality)` immediately updates `_currentQuality` in state for instant UI feedback (checkmark in the settings dialog).
- It asynchronously initializes the new `VideoPlayerController`, sets position/speed/volume/loop, and only disposes the old controller once the new controller is active.
- `BaseAdaptiveVideoPlayerState` must implement `didUpdateWidget` to swap controller listeners without memory leaks.
- `AdaptiveVideoSurface` passes `key: ValueKey(controller)` to `VideoPlayer` to force native texture refresh.

### C. Movable Settings / Quality Dialog
- Located in `AdaptiveControlsLayer`.
- Wrapped with `Transform.translate(offset: _settingsMenuOffset, ...)`.
- Includes a drag handle with `MouseRegion(cursor: SystemMouseCursors.move)`.
- Dragging uses `onPanUpdate` with boundary clamping against `LayoutBuilder` constraints so the dialog can never be dragged off-screen.
- Double-tapping the handle resets the dialog position back to `Offset.zero`.

### D. Windows Desktop Native Fullscreen
- Implemented in `fullscreen_utils_io.dart` using Win32 API calls via `dart:ffi`.
- Target window class is `FLUTTER_RUNNER_WIN32_WINDOW` matched to `GetCurrentProcessId()`.
- Modifies `GWL_STYLE` (`WS_OVERLAPPEDWINDOW` removal) and calls `SetWindowPos` to span monitor bounds over the taskbar.

---

## 3. Standard Verification & Testing Workflow

Before committing any changes, always run the standard verification pipeline:

```bash
# 1. Static Analysis (must have 0 issues)
flutter analyze

# 2. Automated Test Suite (all tests must pass)
flutter test

# 3. Specific Component Tests
flutter test test/widgets/normal_modular_components_test.dart
flutter test test/widgets/youtube_modular_components_test.dart
```

---

## 4. Coding Conventions
- **Single Responsibility (SRP)**: Keep control elements in dedicated widget files in `widgets/`.
- **Preserve Documentation**: Maintain all dartdoc comments and API signatures.
- **Web-Safe Imports**: Conditional exports via `fullscreen_utils_export.dart` and `video_player_web_safe.dart`.
- **Platform Agnostic**: Use platform checks (`kIsWeb`, `defaultTargetPlatform`, `Platform.isWindows`) safely.
