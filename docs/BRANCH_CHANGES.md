# v2.0.1 branch preview

Prepared November 7, 2026. Compare `master` (v1.3.3) with `feature/html5-fullscreen-controls` at `2875131`. The local comparison contains **22 commits, 273 files changed, 44,695 insertions and 6,706 deletions**. These totals include examples, tests, generated files and documentation; they are not a measure of production code or quality. Local launch-document edits are additional.

[Review the branch on GitHub](https://github.com/ahmedalam782/vidoes_player/compare/master...feature/html5-fullscreen-controls) · [Launch guide](LAUNCH_GUIDE.md) · [Changelog](../CHANGELOG.md)

## What users gain

| Area | Change in this branch | How to use it |
|---|---|---|
| Fullscreen | HTML5 fullscreen integration, desktop window services and playback restoration | Use the fullscreen control; test Esc and quality changes while fullscreen |
| Picture-in-Picture | Native/mobile integration, desktop floating windows, in-app mini-player and background lifecycle handling | Use the PiP button; `autoPipOnBackground` defaults to `true` in `VideoConfig` |
| Playback controls | Capsule buttons, ±10s seeking, volume feedback, keyboard controls and hold-to-2× gesture | Tap, use desktop shortcuts, or hold on the player |
| Timeline | Chapter segments and hover/scrub timestamps | Pass `chapters: [VideoChapter(...)]` |
| Media panels | Audio/subtitle columns, speed stepper and episodes drawer | Provide `audioTracks`, `subtitles`, `episodes` and the relevant callbacks |
| Caching | Optional cached-player backend | Set `enableCache: true`; validate your source and backend's caching support |
| Capture controls | Native capture controls with web deterrents and fallback handling | Set `preventScreenCapture: true`; behavior depends on the OS and capture method |
| YouTube | Mobile/desktop WebView with local HTTP origin, browser iframe, PiP overlays and live UI | Pass a YouTube URL through `VideoConfig`; complete native setup |
| Integration | Unified config, adapters, lifecycle mixins and native Android/iOS plugin code | Import the public library; use `VideoConfig.copyWith` for updates |
| Example | Studio/showcase screens, stream catalog and translation assets | Run the example and select a demo source |

These are changes across the entire branch since v1.3.3, including the 2.0.0 and 2.0.1 changelog entries. They are not all newly introduced in the 2.0.1 patch.

## Minimal branch example

Install the Git dependency in the [README](../README.md#try-this-branch), then:

```dart
import 'package:adaptive_video_player/adaptive_video_player.dart';

AdaptiveVideoPlayer(
  config: const VideoConfig(
    videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    title: 'Branch preview',
    autoPipOnBackground: true,
    enableCache: false,
    preventScreenCapture: false,
    chapters: [
      VideoChapter(title: 'Introduction', startTime: Duration.zero),
      VideoChapter(title: 'Details', startTime: Duration(seconds: 2)),
    ],
  ),
);
```

Caching and capture controls are opt-in. Audio track and episode menus expose selection callbacks; your app must implement its source switching. Source codecs, CORS, embedding permissions and backend capabilities still apply.

## Platform boundaries

| Platform | PiP implementation / setup to verify |
|---|---|
| Android | Native PiP requires supported Android versions and activity manifest configuration; test Home/return and playback actions |
| iOS | Native AVPictureInPictureController, supported OS/device and background audio setup; test playback handoff on a device |
| Windows | Win32 floating/topmost window and fullscreen restoration; test closing PiP and multiple monitors |
| macOS | Desktop method-channel window integration is implemented in `example/macos/Runner/MainFlutterWindow.swift`; host apps need equivalent integration for those services |
| Linux | In-app overlay; it does not create an OS window visible over other applications. Verify native/WebView backend availability |
| Web | Browser fullscreen/PiP availability and user activation rules apply. Setting `autopictureinpicture` is not a guarantee of automatic PiP on tab switching |

The capture flag is not DRM. Web deterrents cannot block OS capture, and native protection varies by OS and recording method. A local YouTube origin can address origin-related embedding errors; it cannot override a video's embedding restrictions.

## Migration from master / 1.3.3

- Use `package:adaptive_video_player/adaptive_video_player.dart`. The legacy `lib/videos_player.dart` entry point was removed in this branch.
- Configure the public player with `AdaptiveVideoPlayer(config: VideoConfig(videoUrl: ...))`. Review old direct-player constructor calls and any imports of internal `src/` files; models and controls were reorganized.
- The YouTube backend no longer uses `youtube_player_flutter`; review any app code that depends on its controller or types.
- Complete the README's Android activity/PiP and iOS background setup. Verify both iOS CocoaPods and Swift Package Manager integration as applicable.
- Initialize desktop backends through `AdaptiveVideoPlayerPlatform.ensureInitialized()` before `runApp`. Check macOS host window integration above.
- Re-test app lifecycle, navigation, subtitles, quality switching and custom builders. Consult [the release gate](LAUNCH_GUIDE.md) before upgrading production apps.

## Package milestone and evidence

The user-supplied screenshot shows **19 likes, 160 points and 1.09k downloads**. Its capture date and download window were not supplied. Do not describe this as unique users or lifetime downloads.

On November 7, 2026, the [public API](https://pub.dev/api/packages/adaptive_video_player) returned **1.3.3** as the latest published version. The [score page](https://pub.dev/packages/adaptive_video_player/score) showed **160/160 points, 19 likes and 940 downloads** when checked. Counters can change and retrieved snapshots can differ. Recheck immediately before posting.

That 160/160 belongs to the published version. The branch must pass its own analysis and publishing checks; see [pub.dev scoring guidance](https://pub.dev/help/scoring). A test pass rate is not code coverage and does not prove stability on every platform.
