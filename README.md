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

---

## 📸 Visual Showcase & Mockups Gallery

### 📱 Mobile Experience (Android & iOS)

| 🎛️ Studio Player Controls | 🎬 Netflix-Style Showcase | 💬 Dual Audio & Subtitles | 📑 Episodes & Stepper |
|:---:|:---:|:---:|:---:|
| <img src="assets/screenshots/android/1.png" width="220" alt="Studio Controls" /> | <img src="assets/screenshots/android/2.png" width="220" alt="Full Streaming" /> | <img src="assets/screenshots/android/3.png" width="220" alt="Dual Audio Subtitles" /> | <img src="assets/screenshots/android/4.png" width="220" alt="Episodes Drawer" /> |
| *Adaptive capsule pills, quick toggles & speed* | *Rich streaming mode with live telemetry* | *Dual-column audio dubs & subtitle picker* | *Netflix-style episode drawer & progress bars* |

### 💻 Desktop & Fullscreen Experience (Windows, macOS, Web)

| 🪟 Immersive Fullscreen | 📌 Always-On-Top OS PiP | ⏱️ Hover Chapters Preview | ⚙️ Resolution & Settings |
|:---:|:---:|:---:|:---:|
| <img src="assets/screenshots/windows/2.png" width="220" alt="Fullscreen Mode" /> | <img src="assets/screenshots/windows/3.png" width="220" alt="Always-On-Top PiP" /> | <img src="assets/screenshots/windows/4.png" width="220" alt="Hover Chapters" /> | <img src="assets/screenshots/windows/5.png" width="220" alt="Settings Dialog" /> |
| *True borderless display with auto-hiding UI* | *Native Win32 topmost floating window* | *Scrub thumb with chapter marker tooltip* | *Multi-quality HLS/MP4 resolution selector* |

### 🎬 Animated Platform Demos

| Android | iOS | Windows | macOS | Web |
|:---:|:---:|:---:|:---:|:---:|
| <img src="assets/demo/android.gif" width="140" alt="Android Demo" /> | <img src="assets/demo/ios.gif" width="140" alt="iOS Demo" /> | <img src="assets/demo/windows.gif" width="140" alt="Windows Demo" /> | <img src="assets/demo/macos.gif" width="140" alt="macOS Demo" /> | <img src="assets/demo/web.gif" width="140" alt="Web Demo" /> |

---

## ✨ Features

### 🎬 Adaptive Video Player Engine
- **Smart Source Detection** — Automatically differentiates YouTube (video IDs, short URLs, embeds) from direct streams (MP4, HLS, DASH).
- **Single Widget API** — Just drop `AdaptiveVideoPlayer(config: VideoConfig(...))` anywhere.
- **Cross-Platform Parity** — Unified design and controls across Android, iOS, Windows, macOS, Linux, and Web.

### 🛡️ Anti-Screen Capture Shield (`preventScreenCapture: true`)
- **Hardware-Enforced Privacy** — Renders the window solid black during screenshot captures or screen recordings.
- **Android (`FLAG_SECURE`)** — Blocks screenshots, screen recorders, and app switcher preview leaks.
- **Windows (`SetWindowDisplayAffinity`)** — Win32 hardware display affinity (`WDA_MONITOR`) blacks out Snipping Tool, OBS, and print screens.
- **Web DOM Shield** — Focus blur detection, clipboard flushing, and print media obscuration.

### 📺 YouTube Player with Unified Native Architecture
- **Error 150/153 Bypass** — Serves embedded player via localized `http://localhost` origin for unrestricted embedding.
- **Unified Controls Pill** — Single clean control pill `[ ⧉ PiP | ⛶ Fullscreen ]` with auto-fading timer and no duplicate fullscreen icons.
- **Picture-in-Picture (PiP)** — Android native PiP with notification actions, Windows always-on-top window (`HWND_TOPMOST`), and in-app draggable miniplayer.
- **Live Stream Ready** — Automatic `LIVE` indicator, viewer count, and live sync.
- **Custom Gestures** — Double-tap seek (±10s, ±20s, ±30s) and touch-to-reveal overlay.

### 🎞️ Normal Video Player (HLS, DASH, MP4, Offline Bytes)
- **YouTube Capsule/Pill Controls** — Modern circular `-10s`, `Play/Pause`, `+10s` pills, hover-expanding Volume slider, and Time + Chapter pill.
- **Timeline Hover & Scrub Timestamp Pill** — Shows active chapter title and preview timestamp above the cursor/thumb with track expansion.
- **Video Chapters (`VideoChapter`)** — Segmented progress bar with chapter gap markers and active chapter indicators.
- **Hold-to-2x Speed Gesture (`2x ⏩`)** — Long-press anywhere on the video to boost playback to `2.0x` and release to restore.
- **Speed Stepper Popup (`AdaptiveSpeedStepperPopup`)** — Granular speed steps (`0.25x`, `0.5x`, `0.75x`, `1.0x`, `1.25x`, `1.5x`, `1.75x`, `2.0x`).
- **Netflix-Style Episodes Drawer** — Next episode queue, thumbnail watched progress bar, and active episode indicator.
- **Dual-Column Audio & Subtitles Modal** — High-fidelity sheet for selecting multi-language audio dubs and SRT/VTT subtitles.
- **Persistent Disk Caching (`enableCache: true`)** — Local storage caching via `CachedVideoPlayerPlus` for instant zero-buffering replays.
- **In-Memory Bytes Playback (`videoBytes`)** — Direct encrypted/in-memory playback without writing video files to disk.
- **Built-in Arabic (`ar`) & English (`en`) Localization** — Full RTL layout support with standard LTR timeline preservation.
- **Desktop Keyboard Shortcuts** — `Space` (Play/Pause), `←`/`→` (Seek ±10s), `↑`/`↓` (Volume), `M` (Mute), `F` / `Esc` (Fullscreen).

---

## 🖥️ Platform Support

| Platform | YouTube Engine | Direct Video Engine | Notes |
|---|---|---|---|
| **Android / iOS** | `flutter_inappwebview` via localhost | `video_player` | Native InAppWebView with local origin server, bypasses Error 150/153, full controls & PiP |
| **Windows** | `flutter_inappwebview` via localhost | `video_player_win` | Native Win32 borderless fullscreen & always-on-top PiP window |
| **macOS** | `flutter_inappwebview` via localhost | `video_player` | Native AVFoundation playback |
| **Linux** | `flutter_inappwebview` via localhost | `video_player_media_kit` | Initialized via `AdaptiveVideoPlayerPlatform.ensureInitialized()` |
| **Web** | HTML iframe | `video_player` | HTML5 Fullscreen, native browser PiP, WASM-ready |

> **Why localhost origin for YouTube?** YouTube restricts iframe embedding from `data:`/`file://` origins (Error 150/153). Serving via a local HTTP origin (`http://localhost`) provides a secure, trusted origin YouTube permits across Mobile and Desktop.

---

## 🆚 Feature Comparison

| Feature | `adaptive_video_player` | `youtube_player_flutter` | `chewie` | `video_player` |
|---|:---:|:---:|:---:|:---:|
| 🎯 Universal Player (YouTube + Direct Streams) | ✅ | ❌ | ❌ | ❌ |
| 🛡️ Hardware Anti-Screen Capture Shield | ✅ | ❌ | ❌ | ❌ |
| 🪟 Full Desktop Support (Windows, macOS, Linux) | ✅ | ❌ | ⚠️ | ⚠️ |
| 🎛️ YouTube-Style Capsule Pill Controls | ✅ | ❌ | ❌ | ❌ |
| ⏱️ Timeline Chapter Scrubbing & Tooltip | ✅ | ❌ | ❌ | ❌ |
| ⏩ Hold-to-2x Speed Boost (`2x ⏩`) | ✅ | ❌ | ❌ | ❌ |
| 📺 Native & In-App Picture-in-Picture (PiP) | ✅ | ❌ | ❌ | ❌ |
| 🔴 YouTube Live Stream Badge & Viewers | ✅ | ❌ | ❌ | ❌ |
| ⚙️ Multi-Quality Switcher & Subtitle Dubs | ✅ | ❌ | ✅ | ❌ |
| 📑 Netflix-Style Episodes Queue Drawer | ✅ | ❌ | ❌ | ❌ |
| 💾 Persistent Disk Caching (Zero Buffering) | ✅ | ❌ | ❌ | ❌ |
| 🌍 Arabic & English RTL/LTR Localization | ✅ | ❌ | ❌ | ❌ |
| 🚀 Zero Native Setup Required | ✅ | ❌ | ❌ | ❌ |

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

### 🛡️ Screenshot & Screen Recording Prevention (Anti-Capture Shield)
Protect premium DRM content and sensitive media from being recorded or screenshotted. When enabled, screenshots, screen recordings, and app switcher snapshots render as a **solid black window**:

```dart
AdaptiveVideoPlayer(
  config: VideoConfig(
    videoUrl: 'https://example.com/movie.mp4',
    preventScreenCapture: true, // 100% hardware-enforced black screen on captures
  ),
);
```

#### 🚀 Zero Native Setup Required:
- **🤖 Android**: **100% Automatic** — Zero Kotlin/Java setup. Handled by `AdaptiveVideoPlayerPlugin` via `WindowManager.LayoutParams.FLAG_SECURE`. Screen recordings, screenshots, and task switcher preview thumbnails are blocked out.
- **🍎 iOS**: **100% Automatic** — Zero Swift/Obj-C setup. Handled by `AdaptiveVideoPlayerPlugin` via secure window sublayer containment.
- **🪟 Windows Desktop**: **100% Automatic** — Zero permissions needed. Invokes Win32 native `SetWindowDisplayAffinity(hwnd, WDA_MONITOR)` via FFI. Snipping Tool, OBS, and Print Screen capture a black rectangle.
- **🌐 Web**: **100% Automatic** — Full-viewport DOM obscuration shield (`z-index: 2147483647`), automatic focus loss/blur detection, clipboard flushing on `PrintScreen`/`Ctrl+Shift+S`, and `@media print` blackouts.
- **🍏 macOS & 🐧 Linux**: Safe, graceful fallback protections with zero crashes.

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

### 6. Anti-Screen Capture Shield & Offline Disk Cache
```dart
AdaptiveVideoPlayer(
  config: VideoConfig(
    videoUrl: 'https://example.com/premium_course.mp4',
    // Prevents screen recording & screenshots (renders black surface on Android & Windows)
    preventScreenCapture: true,
    // Caches video stream locally on disk for zero-latency replay and offline viewing
    enableCache: true,
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
| `enableCache` | `bool` | `false` | Enables disk caching for network videos via `CachedVideoPlayerPlus` |
| `preventScreenCapture` | `bool` | `false` | When true, renders video/window black in screenshots & screen recordings (DRM/privacy shield) |
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
├── adaptive_video_player.dart                  # Public library exports & Smart YouTube/VOD detection
└── src/
    ├── core/                                   # Domain contracts, DI, constants & platform services
    │   ├── contracts/                          # Core interfaces (SRP / ISP)
    │   │   ├── i_video_player_controller.dart
    │   │   ├── i_fullscreen_service.dart
    │   │   ├── i_playback_controls.dart
    │   │   ├── i_quality_manageable.dart
    │   │   ├── i_subtitle_manageable.dart
    │   │   └── i_volume_controls.dart
    │   ├── constants/                          # YouTube & HLS JS constants & strings
    │   ├── models/                             # Shared enums, player state & display modes
    │   └── services/                           # Screen protection, Native PiP & Fullscreen services
    ├── normal_video_player/                    # Normal video player implementation
    │   ├── coordinator/                        # Modular full-screen & PiP coordinators
    │   ├── mixins/                             # State mixins (Controller, Subtitles, Resilience, PiP)
    │   ├── models/                             # VideoConfig, VideoQuality, VideoChapter, VideoEpisode
    │   ├── utils/                              # Win32 FFI & Web fullscreen helpers
    │   └── widgets/                            # Adaptive bottom bar, timeline, popups, episodes drawer
    └── youtube_player/                         # YouTube cross-platform player implementation
        ├── models/                             # YouTubePlayerConfig, PlayerStyleConfig, PlayerVisibility
        ├── utils/                              # Web iframe exports & platform stubs
        ├── views/                              # Desktop & Web player views with unified overlay
        └── widgets/                            # InAppWebView localhost server, buttons, live badge
```

---

## 🔧 Supported Formats

**YouTube URLs:** `youtube.com/watch?v=...` · `youtu.be/...` · `youtube.com/embed/...` · `m.youtube.com/watch?v=...` · direct video IDs

**Video Files & Streams:** MP4 · MOV · AVI · MKV · WebM · M4V · 3GP · HLS (`.m3u8`) · DASH (`.mpd`) · In-Memory Bytes

---

## ❓ FAQ

**Q: I get "Error 153" or "Error 150" with YouTube embeds.**  
A: Handled automatically — the package serves YouTube via an internal `http://localhost` origin that Google trusts, bypassing origin rejections across Android, iOS, Windows, macOS, and Linux.

**Q: Why was there a duplicate fullscreen button in YouTube?**  
A: Resolved in v2.0+ — the internal HTML5 button is hidden and replaced by a unified, luxury floating control pill `[ ⧉ PiP | ⛶ Fullscreen ]` where PiP is cleanly positioned right before Fullscreen.

**Q: How does Anti-Screen Capture work?**  
A: Simply set `preventScreenCapture: true`. Android activates `FLAG_SECURE`, Windows invokes native Win32 `SetWindowDisplayAffinity(WDA_MONITOR)` via FFI, and Web engages an active focus/blur obfuscation shield. Any screenshot or screen recording will capture a solid black frame.

**Q: How does Android Picture-in-Picture handle background controls?**  
A: When entering native PiP on Android, the package registers native OS `RemoteAction`s (Play, Pause, Seek -10s, Seek +10s) in the system PiP window, and automatically suppresses unclickable Flutter UI overlays.

---

## 🔮 Roadmap

- [x] Smart auto-detection of YouTube vs. direct streams
- [x] Double-tap-to-seek gesture (±10s) and `-10s` / `+10s` capsule buttons
- [x] Hold-to-2x speed gesture (`2x ⏩`) on long-press
- [x] Granular Playback Speed Stepper (`AdaptiveSpeedStepperPopup`) (0.25x - 2.0x)
- [x] Timeline hover & scrub timestamp preview pill
- [x] Video Chapters (`VideoChapter`) with segmented progress bar markers
- [x] Netflix-style Episodes Drawer with thumbnail progress bars
- [x] Dual-column Audio Tracks & Subtitles modal
- [x] Hardware Anti-Screen Capture Shield (`preventScreenCapture: true`)
- [x] Persistent Disk Caching for offline replay (`CachedVideoPlayerPlus`)
- [x] In-Memory Bytes Playback (`videoBytes`)
- [x] True OS-Level Picture-in-Picture & Fullscreen (Android `RemoteAction`s, Windows `HWND_TOPMOST`, Web HTML5)
- [x] YouTube Error 150/153 bypass via localhost origin
- [x] Unified YouTube floating control pill `[ ⧉ PiP | ⛶ Fullscreen ]`
- [x] Built-in Arabic (RTL) & English (LTR) localization (`PlayerTextConfig.arabic()`)
- [ ] Custom HTTP headers for authenticated/tokenized video streams
- [ ] Automatic multi-bitrate track switcher directly from HLS manifests
- [ ] Custom poster/thumbnail image before playback starts

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

**Ahmed Mohamed Osman** · GitHub: [@ahmedalam782](https://github.com/ahmedalam782)

## 🙏 Dependencies

- [youtube_player_flutter](https://pub.dev/packages/youtube_player_flutter) — YouTube player for mobile
- [flutter_inappwebview](https://pub.dev/packages/flutter_inappwebview) — WebView for desktop YouTube
- [video_player](https://pub.dev/packages/video_player) — Flutter's official video player
- [video_player_platform_interface](https://pub.dev/packages/video_player_platform_interface) — Platform interface
- [video_player_media_kit](https://pub.dev/packages/video_player_media_kit) — Linux playback via media_kit
- [video_player_win](https://pub.dev/packages/video_player_win) — Windows playback via Media Foundation
- [url_launcher](https://pub.dev/packages/url_launcher) — Launching external URLs safely
- [web](https://pub.dev/packages/web) — Modern Web APIs for WASM compatibility
