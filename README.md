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
- Custom controls on mobile (seek, settings, miniplayer/PiP, fullscreen)
- Native YouTube controls on Desktop & Web with top-right Miniplayer (`i`) button
- **Picture-in-Picture (PiP) & Floating Miniplayer** — always-on-top borderless OS PiP window on Windows (`HWND_TOPMOST`) and draggable floating Miniplayer on Mobile/Desktop
- Auto-play, loop, captions, mute, force HD
- Force Desktop Mode on mobile (`forceDesktopMode: true` to use WebViews on Android/iOS)
- Settings panel with runtime toggles (localized in Arabic & English)
- Fullscreen mode with state preservation
- Safe external link handling (opens YouTube URLs in the system browser)
- Live stream support with a "LIVE" indicator and viewer count

### 🎞️ Normal Video Player
- Supports MP4, MOV, AVI, MKV, WebM, M4V, 3GP, HLS (`.m3u8`), DASH (`.mpd`), and more
- Network streaming, local file, and in-memory bytes playback
- **YouTube Capsule/Pill Controls Design** — circular `-10s`, `Play/Pause`, `+10s` pills, hover-expanding Volume slider pill, Time + Chapter pill, and Right Action pill (`Loop`, `CC`, `Settings`, `Miniplayer`, `Fullscreen`)
- **Timeline Hover & Scrub Timestamp Pill** — shows timestamp and active chapter title above the cursor/thumb with smooth track expansion
- **Video Chapters (`VideoChapter`)** — segmented progress bar with chapter gap markers and active chapter titles
- **Hold-to-2x Speed Gesture (`2x ⏩`)** — long-press anywhere on the video to play at `2.0x` speed and release to restore
- **Picture-in-Picture (PiP) & Background Mini-Player** — native always-on-top OS PiP window on Windows (`HWND_TOPMOST`), native browser PiP on Web (`requestPictureInPicture()`), and persistent draggable in-app Miniplayer across routes with background playback (`allowBackgroundPlayback: true`)
- **Draggable Floating Settings Dialog** — quality/resolution picker and SRT/VTT subtitle selector
- **Built-in Arabic (`ar`) & English (`en`) Localization** — automatic settings sheet RTL/LTR localization while preserving standard LTR video timeline and controls
- **Desktop Keyboard Shortcuts** — `Space` (Play/Pause), `←`/`→` (Seek ±10s), `↑`/`↓` (Volume), `M` (Mute), `F` / `Esc` (Fullscreen)
- Analytics callback hook (`onAnalyticsEvent`)

---

## 🖥️ Platform Support

| Platform | YouTube Engine | Direct Video Engine | Notes |
|---|---|---|---|
| **Android / iOS** | `youtube_player_flutter` (native-like) | `video_player` | Full custom controls overlay & background audio/PiP |
| **Windows** | `flutter_inappwebview` via localhost | `video_player_win` | Native Win32 borderless fullscreen & always-on-top PiP window |
| **macOS** | `flutter_inappwebview` (best-effort) | `video_player` | Native AVFoundation playback |
| **Linux** | `flutter_inappwebview` (best-effort) | `video_player_media_kit` | Initialized via `AdaptiveVideoPlayerPlatform.ensureInitialized()` |
| **Web** | HTML iframe | `video_player` | HTML5 Fullscreen, native browser PiP, WASM-ready |

> **Why localhost for desktop YouTube?** YouTube blocks iframe embedding from `data:`/`file://` origins (Error 153). Serving via `http://localhost` provides a trusted origin YouTube allows.

---

## 🆚 Comparison

| Feature | `adaptive_video_player` | `youtube_player_flutter` | `chewie` | `video_player` |
|---|---|---|---|---|
| YouTube + direct URLs in one widget | ✅ | ❌ | ❌ | ❌ |
| Desktop support (Windows, macOS, Linux) | ✅ | ❌ | ⚠️ | ⚠️ |
| YouTube capsule pill controls (`-10s` / `+10s`) | ✅ | ❌ | ❌ | ❌ |
| Timeline hover timestamp & Video Chapters | ✅ | ❌ | ❌ | ❌ |
| Hold-to-2x speed gesture (`2x ⏩`) | ✅ | ❌ | ❌ | ❌ |
| Picture-in-Picture (PiP) & Background playback | ✅ | ❌ | ❌ | ❌ |
| Live stream indicator & viewer count | ✅ | ❌ | ❌ | ❌ |
| Quality selection & SRT/VTT Subtitles | ✅ | ❌ | ✅ | ❌ |
| Built-in Arabic & English localization | ✅ | ❌ | ❌ | ❌ |
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
Add the required permissions in `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
```
To support **Picture-in-Picture (PiP)**, background playback, and smooth fullscreen transitions without activity restarts, update `<activity>` and `<application>` in `AndroidManifest.xml`:
```xml
<application
    ...
    android:usesCleartextTraffic="true">
    <activity
        android:name=".MainActivity"
        android:supportsPictureInPicture="true"
        android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
        ...>
```

### 🍎 iOS
Add to `ios/Runner/Info.plist` for WebView rendering and **background audio / Picture-in-Picture (PiP)**:
```xml
<key>io.flutter.embedded_views_preview</key>
<true/>
<key>UIBackgroundModes</key>
<array>
  <string>audio</string>
</array>
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
*(Note: Borderless Fullscreen and Always-on-Top Picture-in-Picture on Windows use native Win32 `user32.dll` APIs automatically—no extra permissions needed).*

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
No extra permission files needed. Native HTML5 Fullscreen and `requestPictureInPicture()` work out of the box. Ensure direct video hosts have CORS enabled. Fully WASM-compatible.

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

### 1. Quality Picker, Video Chapters & Multi-Language Subtitles
```dart
AdaptiveVideoPlayer(
  config: VideoConfig(
    videoUrl: 'https://www.mp3quran.net/uploads/videos/group1_pbuh/maher.mp4',
    chapters: const [
      VideoChapter(title: 'Introduction', startTime: Duration.zero),
      VideoChapter(title: 'Main Recitation', startTime: Duration(seconds: 20)),
      VideoChapter(title: 'Conclusion', startTime: Duration(seconds: 45)),
    ],
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
    playerConfig: const YouTubePlayerConfig(
      text: PlayerTextConfig.arabic(), // Or PlayerTextConfig.english()
      visibility: PlayerVisibilityConfig(
        showSkipButtons: true,
        skipDuration: Duration(seconds: 10),
      ),
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
| `chapters` | `List<VideoChapter>?` | `null` | Timeline chapters with gap markers and hover titles |
| `controlsBuilder` | `AdaptiveControlsBuilder?` | `null` | Custom controls overlay builder |
| `subtitleBuilder` | `SubtitleBuilder?` | `null` | Custom subtitles UI builder |
| `onAnalyticsEvent` | `void Function(String, Map<String, dynamic>)?` | `null` | External analytics hook |
| `playerConfig` | `YouTubePlayerConfig` | `const YouTubePlayerConfig()` | Player style, text, visibility, and playback config |

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
| `progressBarPlayedColor` | `Color` | `#FF0033` | Progress bar active color |
| `progressBarHandleColor` | `Color` | `#FF0033` | Progress bar thumb color |
| `iconColor` | `Color` | `Colors.white` | Control icons color |
| `textColor` | `Color` | `Colors.white` | Text color |
| `backgroundColor` | `Color` | `#1D1D1D` | Player background |
| `loadingIndicatorColor` | `Color` | `#FF0033` | Loading spinner color |
| `errorIconColor` | `Color` | `Colors.red` | Error icon color |
| `settingsBackgroundColor` | `Color` | `#1D1D1D` | Settings sheet background |

#### PlayerTextConfig
Defaults strictly to English (`PlayerTextConfig()`), allowing host applications to supply any language and text direction via `PlayerTextConfig.fromMap()` or custom translations (see `example/lib/languages/` for modular language file examples):

| Property | Type | Default | Description |
|---|---|---|---|
| `invalidYoutubeUrlText` | `String` | `"Invalid YouTube URL"` | Error when YouTube URL is invalid |
| `videoLoadFailedText` | `String` | `"Failed to load video"` | Error when video fails to load |
| `playerSettingsText` | `String` | `"Player Settings"` | Settings sheet header title |
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
| `skipBackwardText` | `String` | `"Rewind 10s"` | Tooltip for `-10s` button |
| `skipForwardText` | `String` | `"Forward 10s"` | Tooltip for `+10s` button |

#### PlayerVisibilityConfig
| Property | Type | Default | Description |
|---|---|---|---|
| `showControls` | `bool` | `true` | Show player controls overlay |
| `showFullscreenButton` | `bool` | `true` | Show fullscreen toggle button |
| `showSettingsButton` | `bool` | `true` | Show settings gear button |
| `showSkipButtons` | `bool` | `true` | Show `-10s` and `+10s` seek buttons |
| `skipDuration` | `Duration` | `Duration(seconds: 10)` | Relative seek duration for skip buttons |
| `showAutoPlaySetting` | `bool` | `true` | Show auto-play toggle in settings |
| `showLoopSetting` | `bool` | `true` | Show loop toggle in settings |
| `showForceHDSetting` | `bool` | `true` | Show Force HD toggle in settings |
| `showCaptionsSetting` | `bool` | `true` | Show captions toggle in settings |
| `showMuteSetting` | `bool` | `true` | Show mute toggle in settings |

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

- [x] Double-tap-to-seek gesture (±10s) and `-10s` / `+10s` capsule buttons
- [x] Hold-to-2x speed gesture (`2x ⏩`) on long-press
- [x] Timeline hover & scrub timestamp preview pill
- [x] Video Chapters (`VideoChapter`) with segmented progress bar markers
- [x] Picture-in-Picture (PiP) & Background Mini-Player (Windows OS topmost PiP, Web native PiP, and in-app Miniplayer)
- [x] Keyboard shortcuts on desktop (`Space`, `←`/`→`, `↑`/`↓`, `M`, `F`, `Esc`)
- [x] Built-in Arabic (RTL) & English (LTR) localization (`PlayerTextConfig.arabic()`)
- [ ] Playback speed selector in settings sheet
- [ ] Custom HTTP headers for protected/authenticated video streams
- [ ] Automatic quality selection from HLS (.m3u8) manifests
- [ ] `AdaptiveVideoPlaylist(videos: [...])`
- [ ] Poster/thumbnail before playback starts

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
