# Review, verify, then launch

This is a release candidate checklist for `feature/html5-fullscreen-controls`, targeting `master`. Preparing these files does not merge, tag, publish or post anything. Read [the branch changes and migration notes](BRANCH_CHANGES.md) before review.

## 1. Review the preview

Open [LAUNCH_ALL_IN_ONE.html](../LAUNCH_ALL_IN_ONE.html), review the README mockup and try the example. The graphic is an AI-generated concept; attach real recordings to the release once platform checks have been completed.

```powershell
git status --short
git diff master...HEAD --shortstat
git log --oneline master..HEAD
flutter pub get
```

Review the existing deleted screenshots/GIFs and README edits. Stage only intended changes. Commit and push the reviewed feature branch so users can see the README/image and install it through Git. Use a pull request against `master`; this repository has no `main` branch.

## 2. Check package quality

Run commands separately from the repository root. Stop at a failed check and fix it before continuing.

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test --coverage
flutter pub outdated
flutter pub publish --dry-run
```

Build the example:

```powershell
cd example
flutter pub get
flutter build windows --debug
flutter build web --wasm
```

Build and test Android/iOS/macOS/Linux on appropriate hosts/devices. Existing CI runs analysis, tests and a Web/WASM example build; a green CI job does not replace native device testing. Record actual results in [VERIFICATION.md](VERIFICATION.md). Never substitute an expected test count for the result or equate passing tests with 100% code coverage.

### Maintain the 160/160 target

The published 1.3.3 package already scored 160/160 when checked on November 7, 2026. To preserve that score in the candidate:

| Scoring category | Published score | Candidate action |
|---|---|---|
| Dart file conventions | 30/30 | Keep the license, valid metadata and correct filenames; inspect publish dry-run |
| Documentation | 20/20 | Keep README, changelog, runnable examples and public API documentation accurate |
| Platform support | 20/20 | Confirm platform declarations match working implementations and verify Web/WASM |
| Static analysis | 50/50 | Resolve analysis and formatting findings |
| Dependencies | 40/40 | Review `flutter pub outdated`; verify compatibility before updating |

Follow [official scoring guidance](https://pub.dev/help/scoring). For a local score preview, use the latest `pana` on a **separate copy** of the package. Pana can change files; do not run it on your active working tree. Inspect its full report. The official pub.dev analysis after publication determines the published score; no local result guarantees 160/160.

## Platform smoke tests

Record device/OS/browser, source and result for each. Include MP4, HLS and an embeddable YouTube source where the backend supports them.

- Playback: load, pause/resume, seek, speed, volume and mute; verify buffering/error recovery.
- Fullscreen: enter/exit repeatedly, Esc/back, rotate/resize and change quality without losing position.
- PiP: use the button, navigate away, background/return while playing and while paused; close PiP and check that audio stops or resumes correctly.
- Compact layout: narrow phone sizes, portrait/landscape, RTL, long titles and subtitle text; check for overflow.
- Panels: subtitle timing, language changes, audio selection callbacks, chapters and episode callbacks.
- Opt-in features: caching with a supported source, clean disposal, capture controls and supported fallback paths.
- Native setup: Android manifest/PiP actions, iOS background settings/integration, macOS host method channel, Windows topmost/restore and Linux backend prerequisites.
- Web: check browser support and user activation rules for fullscreen/PiP, CORS errors, WASM build and graceful fallback when APIs are unavailable.

## 3. Review and merge

Use [PR_DESCRIPTION.md](PR_DESCRIPTION.md) for the pull request. Resolve failing CI, migration issues and device-test failures. Merge only after the release evidence has been reviewed. Confirm the version in `pubspec.yaml` and matching changelog before publishing.

## 4. Publish the reviewed revision

After the approved merge, on a clean `master` checkout:

```powershell
git switch master
git pull --ff-only origin master
git status --short
flutter pub get
flutter analyze
flutter test
flutter pub publish --dry-run
```

Confirm the dry-run includes the required package files and README asset. Then publish deliberately with `flutter pub publish`. After successful publication, tag the exact published revision:

```powershell
git tag -a v2.0.1 -m "v2.0.1: fullscreen, PiP and player controls"
git push origin v2.0.1
```

Create the GitHub release from that tag using [RELEASE_NOTES.md](RELEASE_NOTES.md). Verify the pub.dev version and score before claiming the new release is available. If a check fails, keep the release pending and update the evidence.

## 5. Announce and measure

Use the preview text in [linkedin_post.md](linkedin_post.md) before publication, or its launch text after publication. Attach `assets/release/v2-branch-preview.png`; describe it as a concept preview. Refresh download/like counters and their date before posting.

To help adoption: keep one clear install example, link the feature comparison and migration notes, ask testers which platform they use, and respond to reproducible issues. Record the pub.dev download count on release day, then check it weekly and after 30 days alongside likes, GitHub issues and installation feedback. Use the measured release-day count as the baseline for a growth target; the supplied 1.09k screenshot is historical, and growth is an objective rather than a promise.
