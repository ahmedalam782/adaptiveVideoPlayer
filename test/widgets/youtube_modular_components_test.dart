import 'package:adaptive_video_player/src/youtube_player/widgets/player_error_widget.dart';
import 'package:adaptive_video_player/src/youtube_player/widgets/player_loading_widget.dart';
import 'package:adaptive_video_player/src/youtube_player/widgets/youtube_live_badge.dart';
import 'package:adaptive_video_player/src/youtube_player/widgets/youtube_replay_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('YouTube Modular Components Tests', () {
    testWidgets('PlayerLoadingWidget renders circular progress indicator',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PlayerLoadingWidget(
            loadingIndicatorColor: Colors.red,
            backgroundColor: Colors.black,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('PlayerErrorWidget renders message and error icon',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PlayerErrorWidget(
            errorMessage: 'Failed to load video',
            errorIconColor: Colors.red,
            backgroundColor: Colors.black,
            textColor: Colors.white,
          ),
        ),
      );

      expect(find.text('Failed to load video'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('YouTubeReplayOverlay triggers onRestart callback',
        (tester) async {
      bool restarted = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Stack(
            children: [
              YouTubeReplayOverlay(
                onRestart: () => restarted = true,
                iconColor: Colors.white,
              ),
            ],
          ),
        ),
      );

      expect(find.byIcon(Icons.replay), findsOneWidget);
      await tester.tap(find.byIcon(Icons.replay));
      expect(restarted, isTrue);
    });

    testWidgets('YouTubeLiveBadge renders LIVE badge and viewer count',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: YouTubeLiveBadge(
            isLive: true,
            viewerCount: '1.2K',
          ),
        ),
      );

      expect(find.text('LIVE'), findsOneWidget);
      expect(find.text('1.2K'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('YouTubeLiveBadge returns empty box when not live and no viewers',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: YouTubeLiveBadge(
            isLive: false,
            viewerCount: null,
          ),
        ),
      );

      expect(find.text('LIVE'), findsNothing);
      expect(find.byIcon(Icons.person), findsNothing);
    });
  });
}
