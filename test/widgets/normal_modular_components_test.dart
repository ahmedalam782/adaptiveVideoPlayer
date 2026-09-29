import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_video_player/src/normal_video_player/coordinator/normal_fullscreen_coordinator.dart';
import 'package:adaptive_video_player/src/normal_video_player/widgets/adaptive_fullscreen_button.dart';
import 'package:adaptive_video_player/src/normal_video_player/widgets/adaptive_settings_button.dart';
import 'package:adaptive_video_player/src/normal_video_player/widgets/normal_fullscreen_overlay.dart';
import 'package:adaptive_video_player/src/normal_video_player/widgets/normal_player_error_widget.dart';
import 'package:adaptive_video_player/src/normal_video_player/widgets/normal_player_loading_widget.dart';

void main() {
  group('Normal Video Player Modular Components Tests', () {
    testWidgets('NormalFullscreenOverlay renders child in directionality and scaffold', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NormalFullscreenOverlay(
            child: Text('Fullscreen Content'),
          ),
        ),
      );

      expect(find.text('Fullscreen Content'), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('NormalPlayerLoadingWidget renders default spinner', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NormalPlayerLoadingWidget(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('NormalPlayerLoadingWidget respects customBuilder', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NormalPlayerLoadingWidget(
              customBuilder: (context) => const Text('Custom Loading...'),
            ),
          ),
        ),
      );

      expect(find.text('Custom Loading...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('NormalPlayerErrorWidget renders error icon and message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NormalPlayerErrorWidget(
              errorMessage: 'Failed to load test stream',
            ),
          ),
        ),
      );

      expect(find.text('Failed to load test stream'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('NormalPlayerErrorWidget respects customBuilder', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NormalPlayerErrorWidget(
              errorMessage: 'Failed to load',
              customBuilder: (context, msg) => Text('Custom Error: $msg'),
            ),
          ),
        ),
      );

      expect(find.text('Custom Error: Failed to load'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsNothing);
    });

    testWidgets('AdaptiveFullscreenButton toggles callback correctly', (tester) async {
      bool enterCalled = false;
      bool exitCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveFullscreenButton(
              isFullScreen: false,
              onEnterFullscreen: () => enterCalled = true,
              onExitFullscreen: () => exitCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AdaptiveFullscreenButton));
      expect(enterCalled, isTrue);
      expect(exitCalled, isFalse);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveFullscreenButton(
              isFullScreen: true,
              onEnterFullscreen: () => enterCalled = true,
              onExitFullscreen: () => exitCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AdaptiveFullscreenButton));
      expect(exitCalled, isTrue);
    });

    testWidgets('AdaptiveSettingsButton renders settings icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdaptiveSettingsButton(),
          ),
        ),
      );

      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    test('NormalFullscreenCoordinator handles initial state and close when not open', () {
      final coordinator = NormalFullscreenCoordinator();
      expect(coordinator.isInFullscreen, isFalse);

      // Should not throw when closing or disposing uninitialized
      coordinator.closeFullscreen();
      expect(coordinator.isInFullscreen, isFalse);

      coordinator.dispose();
      expect(coordinator.isInFullscreen, isFalse);
    });

    testWidgets('NormalFullscreenCoordinator opens overlay and rebuildOverlay updates content', (tester) async {
      final coordinator = NormalFullscreenCoordinator();
      String currentQuality = '720p';

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  coordinator.openFullscreen(
                    context: context,
                    builder: (ctx) => Text('Active Quality: $currentQuality'),
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(coordinator.isInFullscreen, isTrue);
      expect(find.text('Active Quality: 720p'), findsOneWidget);

      // Now change quality and trigger rebuildOverlay
      currentQuality = '1080p';
      coordinator.rebuildOverlay();
      await tester.pumpAndSettle();

      expect(find.text('Active Quality: 1080p'), findsOneWidget);

      coordinator.closeFullscreen();
      await tester.pumpAndSettle();
      expect(coordinator.isInFullscreen, isFalse);
      expect(find.text('Active Quality: 1080p'), findsNothing);

      coordinator.dispose();
    });
  });
}
