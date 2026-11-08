import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_video_player/src/youtube_player/widgets/player_settings_helper.dart';

void main() {
  testWidgets('showPlayerSettingsSheet displays sheet', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showPlayerSettingsSheet(
                  context: context,
                  autoPlay: false,
                  loop: false,
                  forceHD: false,
                  enableCaption: false,
                  isMuted: false,
                  settingsBackgroundColor: Colors.black,
                  settingItemBackgroundColor: Colors.grey,
                  iconColor: Colors.white,
                  textColor: Colors.white,
                  playerSettingsText: 'Settings Modal',
                  autoPlayText: 'Auto',
                  loopVideoText: 'Loop',
                  forceHdQualityText: 'HD',
                  enableCaptionsText: 'CC',
                  muteAudioText: 'Mute',
                  showAutoPlaySetting: true,
                  showLoopSetting: true,
                  showForceHDSetting: true,
                  showCaptionsSetting: true,
                  showMuteSetting: true,
                  onAutoPlayChanged: (_) async {},
                  onLoopChanged: (_) async {},
                  onForceHDChanged: (_) async {},
                  onEnableCaptionChanged: (_) async {},
                  onMutedChanged: (_) {},
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Settings Modal'), findsOneWidget);
    expect(find.text('Auto'), findsOneWidget);
  });
}
