# Release candidate verification

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

The first publish check reported the plugin metadata error because `environment.sdk.flutter` was missing. The root manifest now declares Flutter `>=3.13.0`, consistent with the Dart 3.1 minimum; the error no longer appears. The final dry-run still exits unsuccessfully with warnings about 25 gitignored files tracked in the current Git state, six modified tracked files, and the plural `docs/` layout. It also hints that `2.0.1` follows `1.3.3` without a published `2.0.0`. `.pubignore` excludes the removed showcase screenshots and GIFs from the package, but the warning remains while those deletions are uncommitted. Review these points on the clean release commit and rerun the dry-run; publishing has not been verified.

The checked-in test suite passing does not establish 100% code coverage. Do not publish that claim without a coverage measurement and stated scope. The published-package 160/160 score does not establish the score or stability of this candidate.
