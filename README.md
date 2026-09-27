# 🎥 Adaptive Video Player

A comprehensive Flutter video player package that seamlessly handles both **YouTube videos** and **direct video URLs** with adaptive player selection. Works on **Android, iOS, macOS, Windows, Linux, and Web** — with platform-specific engines tuned for each target.

[![pub package](https://img.shields.io/pub/v/adaptive_video_player.svg)](https://pub.dev/packages/adaptive_video_player)
[![Flutter](https://img.shields.io/badge/Flutter-3.1.0%2B-02569B?logo=flutter)](https://flutter.dev)
[![Platforms](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20macOS%20%7C%20Windows%20%7C%20Linux%20%7C%20Web-blue)](https://flutter.dev)
[![WASM Ready](https://img.shields.io/badge/WASM-Ready-brightgreen)](https://dart.dev/web/wasm)
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

*(Just drop it in — it automatically adapts to YouTube or direct MP4/HLS streams!)*

---

## 🎥 Demo

| Android | iOS | Windows | macOS | Web |
|:---:|:---:|:---:|:---:|:---:|
| ![Android Demo](assets/demo/android.gif) | ![iOS Demo](assets/demo/ios.gif) | ![Windows Demo](assets/demo/windows.gif) | ![macOS Demo](assets/demo/macos.gif) | ![Web Demo](assets/demo/web.gif) |

---

## ✨ Features

### 🎬 Adaptive Video Player
- **Smart Detection** — automatically detects YouTube vs. direct video URLs
- **Unified API** — a single `AdaptiveVideoPlayer` widget for all video types
- **Cross-Platform** — runs on Android, iOS, macOS, Windows, Linux, and Web

### 📺 YouTube Player
- Full YouTube video support with a native-like experience
- Custom controls on mobile (seek, settings, fullscreen)
- Native YouTube controls on Desktop & Web
- Auto-play, loop, captions, mute, force HD
- Force Desktop Mode on mobile (`forceDesktopMode: true` to use WebViews on Android/iOS)
- Settings panel with runtime toggles
- Fullscreen mode with state preservation
- Safe external link handling (opens YouTube URLs in the system browser)
- Live stream support with a "LIVE" indicator and viewer count

### 🎞️ Normal Video Player
- Supports MP4, MOV, AVI, MKV, WebM, M4V, 3GP, and more
- Network streaming, local file, and in-memory bytes playback
- Built-in adaptive controls with double-tap-to-seek (±10s)
- Error handling with customizable messages
- Quality selection (resolution/source picker)
- Subtitle/CC support (SRT/VTT) with custom subtitle builder
- Analytics callback hook (`onAnalyticsEvent`)

---

## 🖥️ Platform Support

| Platform | YouTube Engine | Direct Video Engine | Notes |
|---|---|---|---|
| **Android / iOS** | `youtube_player_flutter` (native-like) | `video_player` | Full custom controls overlay |
| **Windows** | `flutter_inappwebview` via localhost | `video_player_win` | Requires NuGet (see setup) |
| **macOS** | `flutter_inappwebview` (best-effort) | `video_player` | Native AVFoundation playback |
| **Linux** | `flutter_inappwebview` (best-effort) | `video_player_media_kit` | Initialized via `AdaptiveVideoPlayerPlatform.ensureInitialized()` |
| **Web** | HTML iframe | `video_player` | CORS must be enabled on your video host |

> **Why localhost for desktop YouTube?** YouTube blocks iframe embedding from `data:`/`file://` origins (Error 153). Serving via `http://localhost` provides a trusted origin YouTube allows.

---

## 🆚 Comparison

| Feature | `adaptive_video_player` | `youtube_player_flutter` | `chewie` | `video_player` |
|---|---|---|---|---|
| YouTube + direct URLs in one widget | ✅ | ❌ | ❌ | ❌ |
| Desktop support | ✅ | ❌ | ⚠️ | ⚠️ |
| Live stream indicator | ✅ | ❌ | ❌ | ❌ |
| Quality selection | ✅ | ❌ | ❌ | ❌ |
| Subtitle / CC support | ✅ | ❌ | ✅ | ❌ |
| External link safety | ✅ | ❌ | ❌ | ❌ |

---

## 📦 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  adaptive_video_player: ^2.0.0
```

## 🔒 Platform Permissions & Setup

### 🤖 Android
Ensure you have the `INTERNET` permission in `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```
For `http://` URLs **and** `forceDesktopMode: true`:
```xml
<application
    ...
    android:usesCleartextTraffic="true">
```

### 🍎 iOS
Add to `ios/Runner/Info.plist`:
```xml
<key>io.flutter.embedded_views_preview</key>
<true/>
```
*(Optional, for `http://` video URLs)*
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
In both `macos/Runner/DebugProfile.entitlements` and `macos/Runner/Release.entitlements`:
```xml
<key>com.apple.security.network.client</key>
<true/>
```

### 🪟 Windows
YouTube playback on Windows requires **NuGet** for building `flutter_inappwebview`:
```powershell
winget install Microsoft.NuGet
```

### 🐧 Linux
Requires WebKit/GTK (e.g. `libwebkit2gtk-4.1-dev` on Ubuntu/Debian).

Initialize the platform engine in your `main()` before `runApp()`:
```dart
import 'package:adaptive_video_player/adaptive_video_player.dart';

void main() {
  AdaptiveVideoPlayerPlatform.ensureInitialized();
  runApp(const MyApp());
}
```

### 🌐 Web
No extra permission files needed. Ensure direct video hosts have CORS enabled. Fully WASM-compatible.

---

## 🚀 Quick Start

```dart
import 'package:adaptive_video_player/adaptive_video_player.dart';

// YouTube — detected automatically
AdaptiveVideoPlayer(
  config: VideoConfig(
    videoUrl: 'https://www.youtube.com/watch?v=2Or3_FX1KrA',
  ),
);

// Direct video — detected automatically
AdaptiveVideoPlayer(
  config: VideoConfig(
    videoUrl: 'https://upload.mp3quran.net/group1_pbuh/maher.mp4',
  ),
);
```

---

## 📖 Usage Examples

### 1. Quality Picker & Multi-Language Subtitles
```dart
AdaptiveVideoPlayer(
  config: VideoConfig(
    videoUrl: 'https://www.mp3quran.net/uploads/videos/group1_pbuh/maher.mp4',
    qualities: const [
      VideoQuality(
        title: 'Auto (HLS)',
        url: 'https://upload.mp3quran.net/group1_pbuh/maher.mp4',
      ),
      VideoQuality(
        title: 'HD',
        url: 'https://upload.mp3quran.net/group1_pbuh/maher.mp4',
      ),
      VideoQuality(
        title: 'SD',
        url: 'https://upload.mp3quran.net/group1_pbuh/maher.mp4',
      ),
    ],
    initialQuality: const VideoQuality(
      title: 'Auto (HLS)',
      url: 'https://upload.mp3quran.net/group1_pbuh/maher.mp4',
    ),
    subtitles: const [
      SubtitleTrack(
        id: 'en',
        title: 'English',
        content: '''
1
00:00:01,000 --> 00:00:04,000
This is a sample English subtitle.
        ''',
      ),
      SubtitleTrack(
        id: 'ar',
        title: 'عربي',
        content: '''
1
00:00:01,000 --> 00:00:04,000
هذه ترجمة تجريبية باللغة العربية.
        ''',
      ),
    ],
    initialSubtitle: const SubtitleTrack(
      id: 'en',
      title: 'English',
    ),
    onAnalyticsEvent: (event, data) {
      debugPrint('Analytics: $event - Data: $data');
    },
  ),
);
```

### 2. Recorded vs. Live Stream Switcher
```dart
AdaptiveVideoPlayer(
  config: const VideoConfig(
    videoUrl: 'https://upload.mp3quran.net/group1_pbuh/maher.mp4',
    viewerCount: '93k VIEWERS',
    qualities: [
      VideoQuality(
        title: 'Recorded (MP4)',
        url: 'https://upload.mp3quran.net/group1_pbuh/maher.mp4',
        isLive: false,
      ),
      VideoQuality(
        title: 'HLS Stream (.m3u8)',
        url: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
        isLive: true,
      ),
    ],
  ),
);
```

### 3. YouTube with Custom Configuration & Forced Desktop Mode
```dart
AdaptiveVideoPlayer(
  config: VideoConfig(
    videoUrl: 'https://www.youtube.com/watch?v=2Or3_FX1KrA',
    playerConfig: YouTubePlayerConfig(
      playback: const PlayerPlaybackConfig(
        autoPlay: true,
        loop: false,
        forceHD: true,
        enableCaption: true,
        forceDesktopMode: true, // Uses WebViews on Android/iOS
      ),
      style: const PlayerStyleConfig(
        iconColor: Colors.white,
        progressBarPlayedColor: Colors.red,
        progressBarHandleColor: Colors.redAccent,
        backgroundColor: Colors.black,
      ),
      visibility: const PlayerVisibilityConfig(
        showSettingsButton: true,
        showFullscreenButton: true,
      ),
      text: const PlayerTextConfig(
        playerSettingsText: 'Settings',
        autoPlayText: 'Auto Play',
        loopVideoText: 'Loop',
        forceHdQualityText: 'Force HD',
        enableCaptionsText: 'Captions',
        muteAudioText: 'Mute',
      ),
    ),
  ),
);
```

### 4. YouTube Live Stream
```dart
AdaptiveVideoPlayer(
  config: const VideoConfig(
    videoUrl: 'https://www.youtube.com/watch?v=bNyUyrR0PHo',
    isLive: true,
    viewerCount: '15.4K',
  ),
);
```

### 5. Local Video File & Memory Bytes
```dart
// From local file
AdaptiveVideoPlayer(
  config: VideoConfig(
    videoUrl: '/path/to/local/video.mp4',
    isFile: true,
  ),
);

// From in-memory Uint8List bytes
AdaptiveVideoPlayer(
  config: VideoConfig(
    videoUrl: '',
    videoBytes: myUint8ListBytes,
  ),
);
```

---

## 🎛️ Configuration Reference

### VideoConfig

| Property | Type | Default | Description |
|---|---|---|---|
| `videoUrl` | `String` | required | Video target URL |
| `isFile` | `bool` | `false` | True if the URL is a local file path |
| `isLive` | `bool` | `false` | Enables LIVE indicator and disables seek bar |
| `viewerCount` | `String?` | `null` | Displayed when `isLive` is true |
| `videoBytes` | `Uint8List?` | `null` | In-memory video bytes buffer |
| `qualities` | `List<VideoQuality>?` | `null` | Available qualities or sources |
| `initialQuality` | `VideoQuality?` | `null` | Initial active quality |
| `subtitles` | `List<SubtitleTrack>?` | `null` | Available subtitle tracks |
| `initialSubtitle` | `SubtitleTrack?` | `null` | Initial active subtitle track |
| `controlsBuilder` | `AdaptiveControlsBuilder?` | `null` | Custom controls overlay builder |
| `subtitleBuilder` | `SubtitleBuilder?` | `null` | Custom subtitles UI builder |
| `onAnalyticsEvent` | `void Function(String, Map<String, dynamic>)?` | `null` | External analytics hook |
| `playerConfig` | `YouTubePlayerConfig` | `const YouTubePlayerConfig()` | YouTube-specific settings |

### YouTubePlayerConfig

#### PlayerPlaybackConfig
| Property | Type | Default | Description |
|---|---|---|---|
| `autoPlay` | `bool` | `false` | Auto-start playback |
| `loop` | `bool` | `false` | Loop video |
| `mute` | `bool` | `false` | Start muted |
| `forceHD` | `bool` | `false` | Force HD quality |
| `enableCaption` | `bool` | `false` | Enable captions |
| `forceDesktopMode` | `bool` | `false` | Use WebView player on Android/iOS |
| `allowExternalLinks` | `bool` | `true` | Open external links in system browser |

#### PlayerStyleConfig
| Property | Type | Default | Description |
|---|---|---|---|
| `progressBarPlayedColor` | `Color` | `Colors.red` | Progress bar color |
| `progressBarHandleColor` | `Color` | `Colors.redAccent` | Handle color |
| `iconColor` | `Color` | `Colors.white` | Control icons color |
| `textColor` | `Color` | `Colors.white` | Text color |
| `backgroundColor` | `Color` | `#1D1D1D` | Player background |
| `loadingIndicatorColor` | `Color` | `Colors.red` | Loading spinner color |
| `errorIconColor` | `Color` | `Colors.red` | Error icon color |
| `settingsBackgroundColor` | `Color` | `#1D1D1D` | Settings sheet background |

#### PlayerTextConfig
| Property | Type | Default | Description |
|---|---|---|---|
| `invalidYoutubeUrlText` | `String` | `"Invalid YouTube URL"` | Error when YouTube URL is invalid |
| `videoLoadFailedText` | `String` | `"Failed to load video"` | Error when video fails to load |
| `playerSettingsText` | `String` | `"Player Settings"`        | Settings sheet header title |
| `autoPlayText` | `String` | `"Auto Play"` | Auto-play toggle label |
| `loopVideoText` | `String` | `"Loop Video"` | Loop toggle label |
| `forceHdQualityText` | `String` | `"Force HD Quality"` | Force HD toggle label |
| `enableCaptionsText` | `String` | `"Enable Captions"` | Captions toggle label |
| `muteAudioText` | `String` | `"Mute Audio"` | Mute toggle label |
| `qualityText` | `String` | `"Quality (Resolution)"` | Quality selector menu title |
| `autoText` | `String` | `"Auto"` | Automatic resolution option |
| `subtitlesText` | `String` | `"Subtitles"` | Subtitles menu title |
| `offText` | `String` | `"Off"` | Disabled subtitle option |
| `noQualitiesAvailableText` | `String` | `"No qualities available"` | Notice when no resolutions exist |
| `noSubtitlesAvailableText` | `String` | `"No subtitles available"` | Notice when no subtitles exist |

#### PlayerVisibilityConfig
| Property | Type | Default |
|---|---|---|
| `showControls` | `bool` | `true` |
| `showFullscreenButton` | `bool` | `true` |
| `showSettingsButton` | `bool` | `true` |
| `showAutoPlaySetting` | `bool` | `true` |
| `showLoopSetting` | `bool` | `true` |
| `showForceHDSetting` | `bool` | `true` |
| `showCaptionsSetting` | `bool` | `true` |
| `showMuteSetting` | `bool` | `true` |

---

## 🏛️ Architecture

```text
lib/
├── adaptive_video_player.dart              # Package exports & Smart YouTube/direct video detection
└── src/
    ├── platform_init.dart                  # Desktop platform initialization
    ├── normal_video_player/
    │   ├── normal_video_player.dart        # Native video player component
    │   ├── adaptive_controls.dart          # Core UI controls overlay builder (double-tap seek, UI)
    │   └── model/
    │       └── video_config.dart           # Video configuration model
    └── youtube_player/
        ├── youtube_video_player.dart       # Main YouTube player (platform-aware)
        ├── cubit/
        │   ├── youtube_player_cubit.dart   # ValueNotifier state management
        │   └── youtube_player_state.dart
        ├── models/
        │   └── player_config.dart          # YouTube player config models
        ├── utils/
        │   ├── player_utils.dart           # Player utility functions
        │   ├── youtube_web_actual.dart     # Web iframe implementation
        │   ├── youtube_web_export.dart     # Conditional export
        │   └── youtube_web_stub.dart       # Stub for non-web
        └── widgets/
            ├── youtube_controls_overlay.dart # Controls overlay
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

**YouTube URLs:** `youtube.com/watch?v=...` · `youtu.be/...` · `youtube.com/embed/...` · `m.youtube.com/watch?v=...` · direct video IDs

**Video Files:** MP4 · MOV · AVI · MKV · WebM · M4V · 3GP · FLV · WMV

---

## ❓ FAQ

**Q: I get "Error 153" on Windows Desktop.**  
A: Handled automatically — the package serves YouTube via `http://localhost` to bypass the restriction.

**Q: I get "NuGet is not installed" on Windows.**  
A: Run `winget install Microsoft.NuGet` and restart your IDE.

**Q: MP4 videos don't play on Linux.**  
A: Add `AdaptiveVideoPlayerPlatform.ensureInitialized()` in your `main()` before `runApp()`.

**Q: Does it work on macOS/Linux?**  
A: Direct videos work out of the box on macOS via AVFoundation and on Linux via `media_kit`. YouTube WebView support on macOS/Linux relies on `flutter_inappwebview` platform coverage.

---

## 🔮 Roadmap

- [x] Double-tap-to-seek gesture (±10s)
- [ ] Playback speed control in the UI
- [ ] External `AdaptiveVideoController`: `play()`, `pause()`, `seekTo()`, `setSpeed()`
- [ ] Granular analytics callbacks: `onPlay`, `onPause`, `onCompleted`, `onPositionChanged`
- [ ] Custom HTTP headers for protected/authenticated video streams
- [ ] Automatic quality selection from HLS (.m3u8) manifests
- [ ] Picture-in-Picture (Android & iOS)
- [ ] `AdaptiveVideoPlaylist(videos: [...])`
- [ ] Poster/thumbnail before playback starts
- [ ] Keyboard shortcuts on desktop
- [ ] Built-in Arabic (RTL) localization

Got a feature request? [Open an issue](https://github.com/ahmedalam782/vidoes_player/issues).

---

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📝 License

Licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**Ahmed Mohamed Alam** · GitHub: [@ahmedalam782](https://github.com/ahmedalam782)

## 🙏 Dependencies

- [youtube_player_flutter](https://pub.dev/packages/youtube_player_flutter) — YouTube player for mobile
- [flutter_inappwebview](https://pub.dev/packages/flutter_inappwebview) — WebView for desktop YouTube
- [video_player](https://pub.dev/packages/video_player) — Flutter's official video player
- [video_player_platform_interface](https://pub.dev/packages/video_player_platform_interface) — Platform interface
- [video_player_media_kit](https://pub.dev/packages/video_player_media_kit) — Linux playback via media_kit
- [video_player_win](https://pub.dev/packages/video_player_win) — Windows playback via Media Foundation
- [url_launcher](https://pub.dev/packages/url_launcher) — Launching external URLs safely
- [web](https://pub.dev/packages/web) — Modern Web APIs for WASM compatibility
