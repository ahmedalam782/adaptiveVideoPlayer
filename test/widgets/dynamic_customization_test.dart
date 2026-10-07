import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_player/video_player.dart';
import 'package:adaptive_video_player/adaptive_video_player.dart';
import 'package:adaptive_video_player/src/normal_video_player/widgets/adaptive_center_play_pause.dart';
import 'package:adaptive_video_player/src/normal_video_player/widgets/adaptive_controls_layer.dart';
import 'package:adaptive_video_player/src/normal_video_player/widgets/adaptive_player_settings_sheet.dart';
import 'package:adaptive_video_player/src/normal_video_player/widgets/adaptive_progress_bar.dart';

class _FakeVideoPlayerController extends VideoPlayerController {
  _FakeVideoPlayerController({
    Duration duration = const Duration(seconds: 100),
    Duration position = const Duration(seconds: 30),
  }) : super.networkUrl(Uri.parse('https://example.com/test.mp4')) {
    value = value.copyWith(
      duration: duration,
      position: position,
      isInitialized: true,
      isPlaying: true,
    );
  }

  @override
  Future<void> initialize() async {}

  @override
  Future<void> seekTo(Duration position) async {
    value = value.copyWith(position: position);
  }

  @override
  Future<void> play() async {
    value = value.copyWith(isPlaying: true);
  }

  @override
  Future<void> pause() async {
    value = value.copyWith(isPlaying: false);
  }

  @override
  Future<void> setVolume(double volume) async {
    value = value.copyWith(volume: volume);
  }

  @override
  Future<void> setLooping(bool looping) async {
    value = value.copyWith(isLooping: looping);
  }
}

void main() {
  group('Dynamic Localization & Directionality Tests', () {
    testWidgets('PlayerTextConfig resolveTextDirection detects RTL from ambient or config',
        (tester) async {
      // Explicit Arabic preset -> RTL
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                const arabicConfig = PlayerTextConfig.arabic();
                final dir = arabicConfig.resolveTextDirection(context);
                expect(dir, TextDirection.rtl);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      // Explicit Spanish preset -> LTR
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                const spanishConfig = PlayerTextConfig.spanish();
                final dir = spanishConfig.resolveTextDirection(context);
                expect(dir, TextDirection.ltr);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      // Verify that ONLY Arabic/RTL is RTL, and all other languages have same direction as English (LTR)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                // Arabic is RTL
                final arConfig = PlayerTextConfig.fromLanguageCode('ar');
                expect(arConfig.resolveTextDirection(context), TextDirection.rtl);
                expect(arConfig.isRtl, true);

                // English is LTR
                final enConfig = PlayerTextConfig.fromLanguageCode('en');
                expect(enConfig.resolveTextDirection(context), TextDirection.ltr);
                expect(enConfig.isRtl, false);

                // Turkish, French, German, Spanish, Italian, Russian are all LTR (same as English)
                for (final code in ['tr', 'fr', 'de', 'es', 'it', 'ru', 'ja', 'zh']) {
                  final cfg = PlayerTextConfig.fromLanguageCode(code);
                  expect(cfg.resolveTextDirection(context), TextDirection.ltr,
                      reason: '$code must have LTR direction like en');
                  expect(cfg.isRtl, false,
                      reason: '$code is not an RTL language');
                  expect(cfg.resolveLanguageCode(context), code);
                }

                return const SizedBox();
              },
            ),
          ),
        ),
      );

      // Test PlayerTextConfig.tr() dynamic localization with custom translations
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final translations = {
                  'player_settings': 'Ayarlar',
                  'quality': 'Kalite',
                  'subtitles': 'Altyazılar',
                  'play': 'Oynat',
                  'pause': 'Duraklat',
                };

                final trConfig = PlayerTextConfig.tr(
                  (key) => translations[key] ?? key,
                  languageCode: 'tr',
                );

                expect(trConfig.languageCode, 'tr');
                expect(trConfig.resolveTextDirection(context), TextDirection.ltr);
                expect(trConfig.playerSettingsText, 'Ayarlar');
                expect(trConfig.qualityText, 'Kalite');
                expect(trConfig.subtitlesText, 'Altyazılar');
                expect(trConfig.playText, 'Oynat');
                expect(trConfig.pauseText, 'Duraklat');
                // Unspecified keys fallback to default English
                expect(trConfig.fullscreenText, 'Fullscreen');

                // Arabic dynamic translation with tr()
                final arabicTranslations = {
                  'play': 'تشغيل',
                  'pause': 'إيقاف مؤقت',
                  'player_settings': 'إعدادات المشغل',
                };
                final arabicTrConfig = PlayerTextConfig.tr(
                  (key) => arabicTranslations[key] ?? key,
                  languageCode: 'ar',
                );

                expect(arabicTrConfig.languageCode, 'ar');
                expect(arabicTrConfig.resolveTextDirection(context), TextDirection.rtl);
                expect(arabicTrConfig.isRtl, true);
                expect(arabicTrConfig.playText, 'تشغيل');
                expect(arabicTrConfig.pauseText, 'إيقاف مؤقت');
                expect(arabicTrConfig.playerSettingsText, 'إعدادات المشغل');
                // Untranslated keys fallback cleanly to English default
                expect(arabicTrConfig.fullscreenText, 'Fullscreen');

                return const SizedBox();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('AdaptiveBottomBar displays localized tooltips in Arabic and Spanish',
        (tester) async {
      final controller = _FakeVideoPlayerController();

      // Test with Arabic configuration
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveBottomBar(
              controller: controller,
              isFullScreen: false,
              messages: const PlayerTextConfig.arabic(),
            ),
          ),
        ),
      );

      // Verify pause button tooltip in Arabic
      final pauseFinder = find.byTooltip('إيقاف مؤقت');
      expect(pauseFinder, findsOneWidget);

      // Test with Spanish configuration
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveBottomBar(
              controller: controller,
              isFullScreen: false,
              messages: const PlayerTextConfig.spanish(),
            ),
          ),
        ),
      );

      // Verify pause button tooltip in Spanish
      final pauseSpanishFinder = find.byTooltip('Pausar');
      expect(pauseSpanishFinder, findsOneWidget);

      await controller.dispose();
    });
  });

  group('Dynamic Visibility Config Tests', () {
    testWidgets('AdaptiveBottomBar hides volume and time display when visibility flags are false',
        (tester) async {
      final controller = _FakeVideoPlayerController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveBottomBar(
              controller: controller,
              isFullScreen: false,
              visibility: const PlayerVisibilityConfig(
                showVolumeButton: false,
                showTimeDisplay: false,
                showMiniPlayerButton: false,
                showFullscreenButton: false,
                showSettingsButton: false,
              ),
            ),
          ),
        ),
      );

      // Volume slider/icon should not be rendered
      expect(find.byIcon(Icons.volume_up_rounded), findsNothing);
      // Duration text should not be rendered
      expect(find.text('00:30'), findsNothing);
      // Fullscreen and settings buttons should not be rendered
      expect(find.byIcon(Icons.fullscreen_rounded), findsNothing);
      expect(find.byIcon(Icons.settings_outlined), findsNothing);

      await controller.dispose();
    });

    testWidgets('AdaptiveControlsLayer hides center play/pause and progress bar when disabled',
        (tester) async {
      final controller = _FakeVideoPlayerController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveControlsLayer(
              controller: controller,
              isFullScreen: false,
              visibility: const PlayerVisibilityConfig(
                showCenterPlayPause: false,
                showProgressBar: false,
              ),
            ),
          ),
        ),
      );

      // Verify Center Play/Pause button and ProgressBar are hidden
      expect(find.byType(AdaptiveCenterPlayPause), findsNothing);
      expect(find.byType(AdaptiveProgressBar), findsNothing);

      await controller.dispose();
    });

    testWidgets('AdaptivePlayerSettingsSheet respects quality and subtitle visibility flags',
        (tester) async {
      // Both false -> neither shown
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdaptivePlayerSettingsSheet(
              visibility: PlayerVisibilityConfig(
                showQualitySetting: false,
                showSubtitlesSetting: false,
              ),
              qualities: [
                VideoQuality(title: '1080p HD', url: 'https://example.com/1080.mp4'),
              ],
              subtitles: [
                SubtitleTrack(id: 'en', title: 'English'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Quality (Resolution)'), findsNothing);
      expect(find.text('Subtitles'), findsNothing);

      // Quality true, Subtitles false -> Quality shown, Subtitles hidden
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdaptivePlayerSettingsSheet(
              visibility: PlayerVisibilityConfig(
                showQualitySetting: true,
                showSubtitlesSetting: false,
              ),
              qualities: [
                VideoQuality(title: '1080p HD', url: 'https://example.com/1080.mp4'),
              ],
              subtitles: [
                SubtitleTrack(id: 'en', title: 'English'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Quality (Resolution)'), findsOneWidget);
      expect(find.text('Subtitles'), findsNothing);
    });

  });

  group('Dynamic Styling Config Tests', () {
    testWidgets('AdaptiveBottomBar applies custom controls background color',
        (tester) async {
      final controller = _FakeVideoPlayerController();

      const customPillColor = Color(0xFF00AAFF);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveBottomBar(
              controller: controller,
              isFullScreen: false,
              styling: const PlayerStyleConfig(
                controlsBackgroundColor: customPillColor,
              ),
            ),
          ),
        ),
      );

      // Find containers with BoxDecoration matching controlsBackgroundColor
      final containers = tester.widgetList<Container>(find.byType(Container));
      final hasCustomPill = containers.any((c) {
        final dec = c.decoration;
        return dec is BoxDecoration && dec.color == customPillColor;
      });

      expect(hasCustomPill, isTrue);

      await controller.dispose();
    });

    testWidgets('AdaptiveProgressBar respects mirrorProgressBarInRtl configuration',
        (tester) async {
      final controller = _FakeVideoPlayerController();

      // Default without playback config: in Arabic -> RTL
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveProgressBar(
              controller: controller,
              dragPosition: null,
              onDragChanged: (_) {},
              onDragEnd: (_) {},
              messages: const PlayerTextConfig.arabic(),
            ),
          ),
        ),
      );

      Directionality dirWidget = tester.widget(find.descendant(
        of: find.byType(AdaptiveProgressBar),
        matching: find.byType(Directionality),
      ).first);
      expect(dirWidget.textDirection, TextDirection.rtl);

      // Explicit opt-out: mirrorProgressBarInRtl = false -> LTR even in Arabic
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveProgressBar(
              controller: controller,
              dragPosition: null,
              onDragChanged: (_) {},
              onDragEnd: (_) {},
              messages: const PlayerTextConfig.arabic(),
              playback: const PlayerPlaybackConfig(mirrorProgressBarInRtl: false),
            ),
          ),
        ),
      );

      dirWidget = tester.widget(find.descendant(
        of: find.byType(AdaptiveProgressBar),
        matching: find.byType(Directionality),
      ).first);
      expect(dirWidget.textDirection, TextDirection.ltr);

      // Explicit: mirrorProgressBarInRtl = true in Arabic -> RTL
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveProgressBar(
              controller: controller,
              dragPosition: null,
              onDragChanged: (_) {},
              onDragEnd: (_) {},
              messages: const PlayerTextConfig.arabic(),
              playback: const PlayerPlaybackConfig(mirrorProgressBarInRtl: true),
            ),
          ),
        ),
      );

      dirWidget = tester.widget(find.descendant(
        of: find.byType(AdaptiveProgressBar),
        matching: find.byType(Directionality),
      ).first);
      expect(dirWidget.textDirection, TextDirection.rtl);

      await controller.dispose();
    });
  });
}
