import 'package:adaptive_video_player/adaptive_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class TestControlsWidget extends StatefulWidget {
  const TestControlsWidget({super.key});

  @override
  State<TestControlsWidget> createState() => TestControlsWidgetState();
}

class TestControlsWidgetState extends State<TestControlsWidget>
    with ControlsVisibilityMixin {
  @override
  Duration get autoHideTimeout => const Duration(milliseconds: 50);

  @override
  Widget build(BuildContext context) {
    return Text('Visible: $isControlsVisible');
  }
}

void main() {
  group('ControlsVisibilityMixin', () {
    testWidgets('auto-hides after timeout and responds to show/hide/toggle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: TestControlsWidget()),
      );

      final state = tester.state<TestControlsWidgetState>(find.byType(TestControlsWidget));
      expect(state.isControlsVisible, isTrue);

      // Wait for autoHideTimeout
      await tester.pump(const Duration(milliseconds: 60));
      expect(state.isControlsVisible, isFalse);

      // Show controls
      state.showControls();
      await tester.pump();
      expect(state.isControlsVisible, isTrue);

      // Hide controls
      state.hideControls();
      await tester.pump();
      expect(state.isControlsVisible, isFalse);

      // Toggle controls
      state.toggleControls();
      await tester.pump();
      expect(state.isControlsVisible, isTrue);
    });
  });
}
