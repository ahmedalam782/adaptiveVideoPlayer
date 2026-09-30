import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart'
    hide FullscreenButton;
import 'package:adaptive_video_player/src/youtube_player/widgets/player_bottom_actions.dart';
import 'package:adaptive_video_player/src/youtube_player/models/youtube_player_config.dart';

class MockYoutubePlayerController extends Mock
    implements YoutubePlayerController {}

void main() {
  group('FullscreenButton', () {
    testWidgets('renders fullscreen icon and taps', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FullscreenButton(
              onTap: () => tapped = true,
              iconColor: Colors.white,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.fullscreen), findsOneWidget);
      await tester.tap(find.byType(GestureDetector));
      expect(tapped, true);
    });

    testWidgets('renders fullscreen_exit when isFullscreen', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FullscreenButton(
              onTap: () {},
              iconColor: Colors.white,
              isFullscreen: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.fullscreen_exit), findsOneWidget);
    });
  });

  group('MuteButton', () {
    testWidgets('renders volume_up when not muted', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MuteButton(
              onTap: () => tapped = true,
              iconColor: Colors.white,
              isMuted: false,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.volume_up), findsOneWidget);
      await tester.tap(find.byType(GestureDetector));
      expect(tapped, true);
    });

    testWidgets('renders volume_off when muted', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MuteButton(
              onTap: () {},
              iconColor: Colors.white,
              isMuted: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.volume_off), findsOneWidget);
    });
  });

  group('SettingsButton', () {
    testWidgets('renders settings icon and taps', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsButton(
              onTap: () => tapped = true,
              iconColor: Colors.white,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.settings), findsOneWidget);
      await tester.tap(find.byType(GestureDetector));
      expect(tapped, true);
    });
  });

  group('TimeSeparator', () {
    testWidgets('renders separator text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TimeSeparator(),
          ),
        ),
      );

      expect(find.text(' / '), findsOneWidget);
    });

    testWidgets('uses custom textStyle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TimeSeparator(
              textStyle: TextStyle(color: Colors.red, fontSize: 20),
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text(' / '));
      expect((text.style as TextStyle).color, Colors.red);
    });

    testWidgets('uses textColor when no textStyle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TimeSeparator(textColor: Colors.green),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text(' / '));
      expect((text.style as TextStyle).color, Colors.green);
    });
  });

  group('PlayerBottomActionsBuilder', () {
    late MockYoutubePlayerController controller;

    setUp(() {
      controller = MockYoutubePlayerController();
    });

    test('builds with all options shown', () {
      final widgets = PlayerBottomActionsBuilder.build(
        controller: controller,
        config: const PlayerBottomActionsConfig(),
        isMuted: false,
        isFullscreen: false,
        showFullscreenButton: true,
        showSettingsButton: true,
        onFullscreenTap: () {},
        onMuteTap: () {},
        onSettingsTap: () {},
      );

      // Should contain: MuteButton, SizedBox, CurrentPosition, TimeSeparator,
      // RemainingDuration, ProgressBar, SizedBox, SettingsButton, SizedBox, FullscreenButton
      expect(widgets.length, 10);
    });

    test('builds without fullscreen and settings', () {
      final widgets = PlayerBottomActionsBuilder.build(
        controller: controller,
        config: const PlayerBottomActionsConfig(),
        isMuted: true,
        showFullscreenButton: false,
        showSettingsButton: false,
        onFullscreenTap: () {},
        onMuteTap: () {},
      );

      // Should contain: MuteButton, SizedBox, CurrentPosition, TimeSeparator,
      // RemainingDuration, ProgressBar (no FullscreenButton, no SettingsButton)
      expect(widgets.length, 6);
    });

    test('settings hidden when onSettingsTap is null', () {
      final widgets = PlayerBottomActionsBuilder.build(
        controller: controller,
        config: const PlayerBottomActionsConfig(),
        isMuted: false,
        showFullscreenButton: true,
        showSettingsButton: true,
        onFullscreenTap: () {},
        onMuteTap: () {},
        onSettingsTap: null,
      );

      // SettingsButton should not be included when onSettingsTap is null
      expect(widgets.length, 8);
    });
  });
}
