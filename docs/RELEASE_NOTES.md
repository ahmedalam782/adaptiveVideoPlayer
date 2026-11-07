# adaptive_video_player 2.0.1

Release draft: use after the version has been published and verified.

Since the published 1.3.3 baseline, the package adds browser fullscreen and desktop window handling, expanded PiP integration, chapter timelines, capsule controls, hold-to-2× playback, audio/subtitle panels, a speed picker, episodes, and optional caching/capture controls. It also introduces unified configuration, native Android/iOS integration and a refreshed example app.

PiP, caching, codecs and capture controls depend on the OS, browser, backend and host setup. Web automatic PiP is not guaranteed. macOS desktop window services need host method-channel integration. Capture controls are not DRM, and YouTube embedding permissions still apply.

Migration: import `package:adaptive_video_player/adaptive_video_player.dart`, configure through `VideoConfig`, review removed legacy/internal imports, and complete the platform setup. See [branch and migration details](BRANCH_CHANGES.md), [README](../README.md) and [CHANGELOG](../CHANGELOG.md).

Before publishing this note, add the final verification results, actual device/browser test evidence and the official score for the published version. Use real screenshots alongside any image labeled as a concept mockup.
