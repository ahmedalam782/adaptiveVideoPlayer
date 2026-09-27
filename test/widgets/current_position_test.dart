import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:adaptive_video_player/src/youtube_player/widgets/current_position.dart';

class MockYoutubePlayerController extends Mock
    implements YoutubePlayerController {}

void main() {
  group('CurrentPosition', () {
    late MockYoutubePlayerController controller;
    late StreamController<YoutubeVideoState> videoStateStreamController;

    setUp(() {
      controller = MockYoutubePlayerController();
      videoStateStreamController =
          StreamController<YoutubeVideoState>.broadcast();
      when(() => controller.videoStateStream)
          .thenAnswer((_) => videoStateStreamController.stream);
    });

    tearDown(() {
      videoStateStreamController.close();
    });

    testWidgets('renders with explicit controller', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CurrentPosition(controller: controller),
          ),
        ),
      );

      expect(find.text('00:00'), findsOneWidget);
    });

    testWidgets('disposes listener on widget dispose', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CurrentPosition(controller: controller),
          ),
        ),
      );

      expect(find.text('00:00'), findsOneWidget);

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
            body: CurrentPosition(controller: controller),
          ),
        ),
      );

      expect(find.text('00:00'), findsOneWidget);

      videoStateStreamController.add(const YoutubeVideoState(
        position: Duration(seconds: 90),
      ));
      await tester.pump();

      expect(find.text('01:30'), findsOneWidget);
    });
  });
}
