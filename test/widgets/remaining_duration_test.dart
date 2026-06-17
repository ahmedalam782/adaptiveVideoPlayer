import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:adaptive_video_player/src/youtube_player/widgets/remaining_duration.dart';

class MockYoutubePlayerController extends Mock implements YoutubePlayerController {}
class MockYoutubeMetaData extends Mock implements YoutubeMetaData {}

void main() {
  group('RemainingDuration', () {
    late MockYoutubePlayerController controller;
    late MockYoutubeMetaData metadata;
    late StreamController<YoutubeVideoState> videoStateStreamController;

    setUp(() {
      controller = MockYoutubePlayerController();
      metadata = MockYoutubeMetaData();
      videoStateStreamController = StreamController<YoutubeVideoState>.broadcast();
      when(() => controller.videoStateStream).thenAnswer((_) => videoStateStreamController.stream);
      when(() => controller.metadata).thenReturn(metadata);
      when(() => metadata.duration).thenReturn(const Duration(seconds: 120));
    });

    tearDown(() {
      videoStateStreamController.close();
    });

    testWidgets('renders with explicit controller', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RemainingDuration(controller: controller),
          ),
        ),
      );

      expect(find.textContaining('02:00'), findsOneWidget);
    });

    testWidgets('disposes listener on widget dispose', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RemainingDuration(controller: controller),
          ),
        ),
      );

      expect(find.textContaining('02:00'), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SizedBox()),
        ),
      );

      await tester.pumpAndSettle();
    });

    testWidgets('stream triggers setState', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RemainingDuration(controller: controller),
          ),
        ),
      );

      expect(find.textContaining('02:00'), findsOneWidget);

      videoStateStreamController.add(const YoutubeVideoState(
        position: Duration(seconds: 30),
      ));
      await tester.pump();

      expect(find.textContaining('01:30'), findsOneWidget);
    });
  });
}
