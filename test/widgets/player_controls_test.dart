import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_video_player/src/youtube_player/widgets/player_controls.dart';

void main() {
  group('SeekButton', () {
    testWidgets('renders and taps', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SeekButton(
              icon: Icons.forward_10,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.forward_10), findsOneWidget);
      await tester.tap(find.byType(InkWell));
      expect(tapped, true);
    });

    testWidgets('custom size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SeekButton(
              icon: Icons.replay_10,
              onTap: () {},
              size: 48,
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.replay_10));
      expect(icon.size, 48);
    });
  });

  group('SeekButtonsOverlay', () {
    testWidgets('renders both buttons and triggers callbacks', (tester) async {
      bool forwarded = false;
      bool backwarded = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SeekButtonsOverlay(
              onSeekForward: () => forwarded = true,
              onSeekBackward: () => backwarded = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.forward_10_rounded), findsOneWidget);
      expect(find.byIcon(Icons.replay_10_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.forward_10_rounded));
      expect(forwarded, true);

      await tester.tap(find.byIcon(Icons.replay_10_rounded));
      expect(backwarded, true);
    });
  });

  group('PlayerLoadingWidget', () {
    testWidgets('renders loading indicator', (tester) async {
      await tester.pumpWidget(
        // ignore: prefer_const_constructors
        MaterialApp(
          // ignore: prefer_const_constructors
          home: Scaffold(
            // ignore: prefer_const_constructors
            body: PlayerLoadingWidget(
              loadingIndicatorColor: Colors.red,
              backgroundColor: Colors.black,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('PlayerErrorWidget', () {
    testWidgets('renders error icon and message', (tester) async {
      await tester.pumpWidget(
        // ignore: prefer_const_constructors
        MaterialApp(
          // ignore: prefer_const_constructors
          home: Scaffold(
            // ignore: prefer_const_constructors
            body: PlayerErrorWidget(
              errorMessage: 'Test error',
              errorIconColor: Colors.red,
              backgroundColor: Colors.black,
              textColor: Colors.white,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Test error'), findsOneWidget);
    });

    testWidgets('renders with custom errorTextStyle', (tester) async {
      await tester.pumpWidget(
        // ignore: prefer_const_constructors
        MaterialApp(
          // ignore: prefer_const_constructors
          home: Scaffold(
            // ignore: prefer_const_constructors
            body: PlayerErrorWidget(
              errorMessage: 'Styled error',
              errorIconColor: Colors.red,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              // ignore: prefer_const_constructors
              errorTextStyle: TextStyle(color: Colors.yellow, fontSize: 16),
            ),
          ),
        ),
      );

      expect(find.text('Styled error'), findsOneWidget);
      final text = tester.widget<Text>(find.text('Styled error'));
      expect((text.style as TextStyle).color, Colors.yellow);
    });
  });
}
