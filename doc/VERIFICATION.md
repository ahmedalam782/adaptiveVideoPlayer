# Release candidate verification

## 2.0.3 platform-score repair — November 8, 2026

The supplied pub.dev report lost 10 platform points because the public library reached `dart:io` during WASM analysis. Shared PiP and desktop view platform checks now use Flutter's platform APIs. The local HTTP server has a conditional native implementation and browser stub. The public cache API conditionally exports its native package so it does not enter the web import graph.

Android's plugin Gradle script no longer applies KGP or uses `android.kotlinOptions`; it uses `kotlin.compilerOptions` with JVM 17. This follows [Flutter's plugin-author migration](https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-plugin-authors) and requires **Flutter 3.44+ / Dart 3.12+**. The example's existing AGP 8.11.1 / Kotlin 2.2.20 host builds successfully; a fully built-in-Kotlin AGP 9 host was not tested. Flutter warns that the example's AGP/Kotlin versions will need upgrading in the future.

| Check | Result |
|---|---|
| Official pana 0.23.19 WASM tagger | `is:wasm-ready` |
| Official pana 0.23.19 Kotlin plugin tagger | `is:built-in-kotlin` |
| `flutter analyze --no-pub` | Passed, no issues |
| `flutter test --no-pub` | Passed, 260 tests |
| Windows example debug build | Passed |
| Web/WASM example build | Passed |
| Android example debug APK build | Passed; host/toolchain warnings noted above |
| Chrome public-API regression test | Compiled and launched Chrome, then stalled before a result; stopped, not counted as passing |

Raising the Dart minimum selects the newer formatter and enables newer lint rules. Formatting was updated across `lib/` and `test/`, with mechanical lint fixes to keep analysis clean.

The full pana CLI fails on Windows because its sandbox runner rejects drive-letter paths containing `:`. Its unmodified `Tagger.wasmReadyTag` and `Tagger.kotlinPluginTag` were invoked directly against the package to verify both compatibility checks. Local logs are `build/pana-wasm-tags.log`, `build/wasm-fix-analysis-final.log`, `build/wasm-fix-tests-final.log`, and `build/wasm-fix-{android,windows,web}.log`.

The specific 10-point WASM failure is repaired locally. The complete score must be confirmed by pub.dev after publishing a new version. The existing 150/160 analysis does not change until pub.dev analyzes the fixed package.

## Earlier launch checks

Checked on November 7, 2026 from `feature/html5-fullscreen-controls` at base comparison `master` / commit `2875131`.

| Check | Result | Evidence |
|---|---|---|
| `flutter analyze --no-pub` | Passed: no issues found | Local Flutter SDK |
| `flutter test --no-pub --reporter expanded` | Passed: 260 tests | `build/launch-tests-final.log` (local ignored build output) |
| `flutter build windows --debug --no-pub` in `example` | Passed | Local Windows example build |
| `flutter build web --wasm --no-pub` in `example` | Passed | Local WebAssembly example build; Flutter labels WASM compilation new and advises understanding details before production deployment |
| `dart format --output=none --set-exit-if-changed lib test` | Passed after formatting 4 flagged files | Final run formatted 210 files, 0 changes |
| `flutter pub publish --dry-run` | Failed with 3 package warnings and 1 version hint | `build/launch-publish-final.log`; Flutter SDK metadata error is cleared, but rerun from the clean reviewed branch |
| Native Android/iOS/macOS/Linux device checks | Not run | Requires platform-appropriate device/host testing |

The first publish check reported the plugin metadata error because `environment.sdk.flutter` was missing. The root manifest now declares Flutter `>=3.13.0`, consistent with the Dart 3.1 minimum; the error no longer appears. The final dry-run still exits unsuccessfully with warnings about 25 gitignored files tracked in the current Git state, six modified tracked files, and the plural `doc/` layout. It also hints that `2.0.1` follows `1.3.3` without a published `2.0.0`. `.pubignore` excludes the removed showcase screenshots and GIFs from the package, but the warning remains while those deletions are uncommitted. Review these points on the clean release commit and rerun the dry-run; publishing has not been verified.

The checked-in test suite passing does not establish 100% code coverage. Do not publish that claim without a coverage measurement and stated scope. The published-package 160/160 score does not establish the score or stability of this candidate.
