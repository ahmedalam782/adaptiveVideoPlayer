# 🎥 Adaptive Video Player

**The only Flutter video player that supports YouTube + Direct videos on ALL platforms with one widget.**

A comprehensive Flutter video player package that seamlessly handles both **YouTube videos** and **direct video URLs** with adaptive player selection. Works beautifully on **Android, iOS, macOS, Windows, Linux, and Web**.

[![pub package](https://img.shields.io/pub/v/adaptive_video_player.svg)](https://pub.dev/packages/adaptive_video_player)
[![Flutter](https://img.shields.io/badge/Flutter-3.1.0+-02569B?logo=flutter)](https://flutter.dev)
[![Platforms](https://img.shields.io/badge/Platforms-Android%20|%20iOS%20|%20macOS%20|%20Windows%20|%20Linux%20|%20Web-blue)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## ⚡ 10-Second Quick Start

```dart
AdaptiveVideoPlayer(
  config: VideoConfig(
    videoUrl: "https://youtu.be/VIDEO_ID",
  ),
);
```

_(Just drop it in and it automatically adapts to YouTube or direct MP4/HLS streams!)_

---

## 🎥 Demo

|                 Android                  |               iOS                |
| :--------------------------------------: | :------------------------------: |
| ![Android Demo](assets/demo/android.gif) | ![iOS Demo](assets/demo/ios.gif) |

|                 Windows                  |                macOS                 |
| :--------------------------------------: | :----------------------------------: |
| ![Windows Demo](assets/demo/windows.gif) | ![macOS Demo](assets/demo/macos.gif) |

|               Web                |
| :------------------------------: |
| ![Web Demo](assets/demo/web.gif) |

---

## ✨ Features

### 🎬 Adaptive Video Player

- **Smart Detection** — Automatically detects YouTube vs direct video URLs
- **Unified API** — Single `AdaptiveVideoPlayer` widget for all video types
- **Cross-Platform** — Runs beautifully on **Android, iOS, macOS, Windows, Linux, and Web**!

### 📺 YouTube Player

- Full YouTube video support with native-like experience
- Custom controls on mobile (seek, settings, fullscreen)
- YouTube native controls on Desktop & Web
- Auto-play, loop, captions, mute, force HD
- Force Desktop Mode on mobile (`forceDesktopMode: true` to use WebViews on Android/iOS)
- Settings panel with runtime toggles
- Fullscreen mode with state preservation
- **Safe External Link Handling** (Opens YouTube external URLs in system browser)
- **Live Stream Support** with "LIVE" indicator and Viewer Count

### 🎞️ Normal Video Player

- Supports MP4, MOV, AVI, MKV, WebM, M4V, 3GP, and more
- Network streaming, local file, and in-memory bytes playback
- Built-in advanced adaptive controls
- Error handling with customizable messages
- **Quality Selection** (Resolution/source picker)
- **Subtitle/CC Support** (SRT/VTT formats)
- **Custom UI Builders** (`controlsBuilder`, `subtitleBuilder`)

---

## 🆚 Why Adaptive Video Player?

Here is how `adaptive_video_player` compares to other popular video packages:

| Feature                  | `adaptive_video_player` | `youtube_player_flutter` | `chewie` | `video_player` |
| ------------------------ | ----------------------- | ------------------------ | -------- | -------------- |
| **YouTube + MP4 URLs**   | ✅                      | ❌                       | ❌       | ❌             |
| **Desktop Support**      | ✅                      | ❌                       | ⚠️       | ⚠️             |
| **Live Stream Support**  | ✅                      | ❌                       | ❌       | ❌             |
| **Unified API**          | ✅                      | ❌                       | ❌       | ❌             |
| **Quality Selection**    | ✅                      | ❌                       | ❌       | ❌             |
| **External Link Safety** | ✅                      | ❌                       | ❌       | ❌             |

---

## 🖥️ Platform-Specific YouTube Behavior

| Platform                    | Engine                            | Controls                                                                             |
| --------------------------- | --------------------------------- | ------------------------------------------------------------------------------------ |
| **Android / iOS**           | `youtube_player_flutter` (v10)    | Premium custom controls overlay (seek overlay, settings sheet, bottom actions bar). Can be forced to Desktop Mode. |
| **macOS / Windows / Linux** | `InAppWebView` + localhost server | YouTube native controls                                                              |
| **Web**                     | HTML iframe (`package:web`)       | YouTube native controls |                                                             |

> **Why localhost on Desktop (Windows, macOS, Linux)?** YouTube blocks iframe embedding from local files like `data:` and `file://` (Error 153). Serving via `http://localhost` provides a trusted origin that YouTube allows.

---

## 📦 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  adaptive_video_player: ^1.3.1
```

## 🔒 Platform Permissions & Setup

To ensure network videos and YouTube play correctly across devices, please configure the required platform permissions:

### 🤖 Android

Ensure you have the `INTERNET` permission in your `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

_(Required)_ For playing `http://` video URLs **AND** for using `forceDesktopMode: true` on Android, you must add `usesCleartextTraffic` to your `<application>` tag:

```xml
<application
    ...
    android:usesCleartextTraffic="true">
```

### 🍎 iOS

To allow the YouTube player (which uses Platform Views) to render without being stuck on a loading screen, add the following to your `ios/Runner/Info.plist`:

```xml
<key>io.flutter.embedded_views_preview</key>
<true/>
```

_(Optional)_ For loading `http://` (unencrypted) video URLs safely, also add:

```xml
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key>
  <true/>
  <key>NSAllowsArbitraryLoadsInWebContent</key>
  <true/>
</dict>
```

### 🍏 macOS

For network video playback and YouTube webview support on macOS, you must grant the application permission to act as a network client.
Open `macos/Runner/DebugProfile.entitlements` and `macos/Runner/Release.entitlements` and add the following:

```xml
<key>com.apple.security.network.client</key>
<true/>
```

### 🪟 Windows

YouTube playback on Windows requires **NuGet** for the `flutter_inappwebview` build:

```powershell
winget install Microsoft.NuGet
```

For normal video playback (MP4s, etc.) on Windows, register the video player plugin in `main()`:

```dart
import 'package:flutter/foundation.dart';
import 'package:video_player_win/video_player_win_plugin.dart';

void main() {
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
    WindowsVideoPlayer.registerWith();
  }
  runApp(const MyApp());
}
```

### 🐧 Linux

Linux requires WebKit for the `flutter_inappwebview` playback. Ensure your system has the necessary GTK/WebKit packages installed (e.g., `libwebkit2gtk-4.1-dev` on Ubuntu/Debian).

### 🌐 Web

No specific permission files are needed. However, ensure that any external direct videos (MP4, MKV) you stream are hosted on servers with **CORS** (Cross-Origin Resource Sharing) enabled. YouTube videos are handled automatically via iframe. The package is fully compatible with Flutter WebAssembly (WASM) builds.

---

## 🚀 Quick Start

```dart
import 'package:adaptive_video_player/adaptive_video_player.dart';

// YouTube video — detected automatically
AdaptiveVideoPlayer(
  config: VideoConfig(
    videoUrl: 'https://www.youtube.com/watch?v=vM2dC8OCZoY',
  ),
)

// Direct video — detected automatically
AdaptiveVideoPlayer(
  config: VideoConfig(
    videoUrl: 'https://example.com/video.mp4',
  ),
)
```

---

## 📖 Usage Examples

### YouTube with Custom Config

```dart
AdaptiveVideoPlayer(
  config: VideoConfig(
    videoUrl: 'https://www.youtube.com/watch?v=vM2dC8OCZoY',
    playerConfig: YouTubePlayerConfig(
      playback: PlayerPlaybackConfig(
        autoPlay: true,
        loop: false,
        forceHD: true,
        enableCaption: true,
        forceDesktopMode: true, // Uses WebViews on Android/iOS instead of native player
      ),
      style: PlayerStyleConfig(
        iconColor: Colors.white,
        progressBarPlayedColor: Colors.red,
        progressBarHandleColor: Colors.redAccent,
        backgroundColor: Colors.black,
      ),
      visibility: PlayerVisibilityConfig(
        showSettingsButton: true,
        showFullscreenButton: true,
      ),
    ),
  ),
)
```

### Local Video File

```dart
AdaptiveVideoPlayer(
  config: VideoConfig(
    videoUrl: '/path/to/local/video.mp4',
    isFile: true,
  ),
)
```

### Video from Memory

```dart
AdaptiveVideoPlayer(
  config: VideoConfig(
    videoUrl: '',
    videoBytes: myUint8ListBytes,
  ),
)
```

### Live Stream Example

```dart
AdaptiveVideoPlayer(
  config: VideoConfig(
    videoUrl: 'https://www.youtube.com/watch?v=YOUR_LIVE_VIDEO_ID',
    isLive: true,
    viewerCount: '1.2K', // Optional viewer count for the LIVE badge
  ),
)
```

---

## 🎛️ Configuration Reference

### VideoConfig

| Property          | Type                       | Default                       | Description                                  |
| ----------------- | -------------------------- | ----------------------------- | -------------------------------------------- |
| `videoUrl`        | `String`                   | required                      | Video target URL                             |
| `isFile`          | `bool`                     | `false`                       | True if the URL is a local file path         |
| `isLive`          | `bool`                     | `false`                       | Enables LIVE indicator and disables seek bar |
| `viewerCount`     | `String?`                  | `null`                        | Displayed when `isLive` is true              |
| `qualities`       | `List<VideoQuality>?`      | `null`                        | Available qualities or sources               |
| `subtitles`       | `List<SubtitleTrack>?`     | `null`                        | Available subtitle tracks                    |
| `controlsBuilder` | `AdaptiveControlsBuilder?` | `null`                        | Custom controls overlay builder              |
| `subtitleBuilder` | `SubtitleBuilder?`         | `null`                        | Custom subtitles UI builder                  |
| `playerConfig`    | `YouTubePlayerConfig`      | `const YouTubePlayerConfig()` | YouTube specific settings                    |

### YouTubePlayerConfig

#### PlayerPlaybackConfig

| Property             | Type   | Default | Description                           |
| -------------------- | ------ | ------- | ------------------------------------- |
| `autoPlay`           | `bool` | `false` | Auto-start playback                   |
| `loop`               | `bool` | `false` | Loop video                            |
| `mute`               | `bool` | `false` | Start muted                           |
| `forceHD`            | `bool` | `false` | Force HD quality                      |
| `enableCaption`      | `bool` | `false` | Enable captions                       |
| `forceDesktopMode`   | `bool` | `false` | Use WebView player on Android/iOS     |
| `allowExternalLinks` | `bool` | `true`  | Open external links in system browser |

#### PlayerStyleConfig

| Property                  | Type    | Default            | Description               |
| ------------------------- | ------- | ------------------ | ------------------------- |
| `progressBarPlayedColor`  | `Color` | `Colors.red`       | Progress bar color        |
| `progressBarHandleColor`  | `Color` | `Colors.redAccent` | Handle color              |
| `iconColor`               | `Color` | `Colors.white`     | Control icons color       |
| `textColor`               | `Color` | `Colors.white`     | Text color                |
| `backgroundColor`         | `Color` | `#1D1D1D`          | Player background         |
| `loadingIndicatorColor`   | `Color` | `Colors.red`       | Loading spinner color     |
| `errorIconColor`          | `Color` | `Colors.red`       | Error icon color          |
| `settingsBackgroundColor` | `Color` | `#1D1D1D`          | Settings sheet background |

#### PlayerTextConfig

| Property                   | Type     | Default                    | Description |
| -------------------------- | -------- | -------------------------- | ----------- |
| `invalidYoutubeUrlText`    | `String` | `"Invalid YouTube URL"`    | Error when YouTube URL is invalid |
| `videoLoadFailedText`      | `String` | `"Failed to load video"`   | Error when video fails to load |
| `playerSettingsText`       | `String` | `"Player Settings"`        | Settings sheet header title |
| `autoPlayText`             | `String` | `"Auto Play"`              | Auto-play toggle label |
| `loopVideoText`            | `String` | `"Loop Video"`             | Loop toggle label |
| `forceHdQualityText`       | `String` | `"Force HD Quality"`       | Force HD toggle label |
| `enableCaptionsText`       | `String` | `"Enable Captions"`        | Captions toggle label |
| `muteAudioText`            | `String` | `"Mute Audio"`             | Mute toggle label |
| `qualityText`              | `String` | `"Quality (Resolution)"`   | Quality selector menu title |
| `autoText`                 | `String` | `"Auto"`                   | Automatic resolution option |
| `subtitlesText`            | `String` | `"Subtitles"`              | Subtitles menu title |
| `offText`                  | `String` | `"Off"`                    | Disabled subtitle option |
| `noQualitiesAvailableText` | `String` | `"No qualities available"` | Notice when no resolutions exist |
| `noSubtitlesAvailableText` | `String` | `"No subtitles available"` | Notice when no subtitles exist |

#### PlayerVisibilityConfig

| Property               | Type   | Default |
| ---------------------- | ------ | ------- |
| `showControls`         | `bool` | `true`  |
| `showFullscreenButton` | `bool` | `true`  |
| `showSettingsButton`   | `bool` | `true`  |
| `showAutoPlaySetting`  | `bool` | `true`  |
| `showLoopSetting`      | `bool` | `true`  |
| `showForceHDSetting`   | `bool` | `true`  |
| `showCaptionsSetting`  | `bool` | `true`  |
| `showMuteSetting`      | `bool` | `true`  |

---

## 🏛️ Architecture

```text
lib/
├── adaptive_video_player.dart              # Package exports & Smart YouTube/direct video detection
└── src/
    ├── normal_video_player/
    │   ├── normal_video_player.dart        # Native video player component
    │   ├── adaptive_controls.dart          # Core UI controls overlay builder
    │   └── model/
    │       └── video_config.dart           # Video configuration model
    └── youtube_player/
        ├── youtube_video_player.dart       # Main YouTube player (platform-aware)
        ├── cubit/
        │   ├── youtube_player_cubit.dart   # BLoC state management
        │   └── youtube_player_state.dart
        ├── models/
        │   └── player_config.dart          # YouTube player config models
        ├── utils/
        │   ├── player_utils.dart           # Player utility functions
        │   ├── youtube_web_actual.dart     # Web iframe implementation
        │   ├── youtube_web_export.dart     # Conditional export
        │   └── youtube_web_stub.dart       # Stub for non-web
        └── widgets/
            ├── youtube_controls_overlay.dart # Premium custom controls overlay (buffering, timer, play/pause, seeks)
            ├── youtube_webview_player.dart   # Desktop WebView player (localhost)
            ├── player_controls.dart          # Seek overlay, loading, error widgets
            ├── player_bottom_actions.dart    # Bottom action bar builder
            ├── player_settings_sheet.dart    # Settings bottom sheet
            ├── player_settings_helper.dart   # Settings helper
            ├── setting_item.dart             # Individual setting toggle
            └── fullscreen_player_page.dart   # Fullscreen player page
```

---

## 🔧 Supported Formats

**YouTube URLs:**
`youtube.com/watch?v=...` · `youtu.be/...` · `youtube.com/embed/...` · `m.youtube.com/watch?v=...` · Direct Video IDs

**Video Files:**
MP4 · MOV · AVI · MKV · WebM · M4V · 3GP · FLV · WMV

---

## ❓ FAQ

**Q: I get "Error 153" on Windows Desktop.**  
A: This is handled automatically. The package serves YouTube via `http://localhost` to bypass the restriction.

**Q: I get "NuGet is not installed" on Windows.**  
A: Run `winget install Microsoft.NuGet` and restart your IDE.

**Q: MP4 videos don't play on Windows.**  
A: Add `WindowsVideoPlayer.registerWith()` in your `main()` before `runApp()`.

**Q: Does it work on macOS/Linux?**  
A: Desktop support uses `InAppWebView` which primarily supports Windows. macOS/Linux support depends on `flutter_inappwebview` platform availability.

---

## 🔮 Roadmap (Future Features)

We are actively working to make this the ultimate video player. Upcoming features:

1. **Playlist Support:** `AdaptiveVideoPlaylist(videos: [...])`
2. **Analytics Callbacks:** `onPlay`, `onPause`, `onCompleted`, `onError`
3. **Picture in Picture (PiP):** Native PiP support for Android & iOS.

_(Got a feature request? Open an issue!)_

---

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📝 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

## 👨💻 Author

**Ahmed Mohamed Alam** · GitHub: [@ahmedalam782](https://github.com/ahmedalam782)

## 🙏 Dependencies

- [youtube_player_flutter](https://pub.dev/packages/youtube_player_flutter) — YouTube player for mobile (v10.x using webview_flutter under the hood)
- [flutter_inappwebview](https://pub.dev/packages/flutter_inappwebview) — WebView for Desktop YouTube
- [video_player](https://pub.dev/packages/video_player) — Flutter's official video player
- [video_player_platform_interface](https://pub.dev/packages/video_player_platform_interface) — Platform interface for video player
- [video_player_media_kit](https://pub.dev/packages/video_player_media_kit) — Linux video playback via media_kit
- [video_player_win](https://pub.dev/packages/video_player_win) — Windows video playback via Media Foundation
- [flutter_bloc](https://pub.dev/packages/flutter_bloc) — State management
- [url_launcher](https://pub.dev/packages/url_launcher) — Launching external URLs safely
- [web](https://pub.dev/packages/web) — Modern Web APIs for WASM compatibility
