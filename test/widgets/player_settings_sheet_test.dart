import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_video_player/src/youtube_player/widgets/player_settings_sheet.dart';

void main() {
  testWidgets('SettingsBottomSheet renders and updates options', (
    WidgetTester tester,
  ) async {
    bool autoPlayVal = false;
    bool loopVal = false;
    bool hdVal = false;
    bool captionVal = false;
    bool muteVal = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PlayerSettingsSheet(
            autoPlay: false,
            loop: false,
            forceHD: false,
            enableCaption: false,
            isMuted: false,
            onAutoPlayChanged: (val) async {
              autoPlayVal = val;
            },
            onLoopChanged: (val) async {
              loopVal = val;
            },
            onForceHDChanged: (val) async {
              hdVal = val;
            },
            onEnableCaptionChanged: (val) async {
              captionVal = val;
            },
            onMutedChanged: (val) {
              muteVal = val;
            },
            iconColor: Colors.white,
            textColor: Colors.black,
            settingItemBackgroundColor: Colors.grey,
            switchInactiveThumbColor: Colors.red,
            switchInactiveTrackColor: Colors.black,
            playerSettingsText: 'Test Settings',
            autoPlayText: 'Test Auto',
            loopVideoText: 'Test Loop',
            forceHdQualityText: 'Test HD',
            enableCaptionsText: 'Test Captions',
            muteAudioText: 'Test Mute',
            showAutoPlaySetting: true,
            showLoopSetting: true,
            showForceHDSetting: true,
            showCaptionsSetting: true,
            showMuteSetting: true,
          ),
        ),
      ),
    );

    // Verify Title
    expect(find.text('Test Settings'), findsOneWidget);

    // Tap AutoPlay
    expect(find.text('Test Auto'), findsOneWidget);
    final autoPlaySwitch = find.descendant(
      of: find.ancestor(of: find.text('Test Auto'), matching: find.byType(Row)),
      matching: find.byType(Switch),
    );
    await tester.tap(autoPlaySwitch);
    await tester.pumpAndSettle();
    expect(autoPlayVal, true);

    // Tap Loop
    expect(find.text('Test Loop'), findsOneWidget);
    final loopSwitch = find.descendant(
      of: find.ancestor(of: find.text('Test Loop'), matching: find.byType(Row)),
      matching: find.byType(Switch),
    );
    await tester.tap(loopSwitch);
    await tester.pumpAndSettle();
    expect(loopVal, true);

    // Tap HD
    expect(find.text('Test HD'), findsOneWidget);
    final hdSwitch = find.descendant(
      of: find.ancestor(of: find.text('Test HD'), matching: find.byType(Row)),
      matching: find.byType(Switch),
    );
    await tester.tap(hdSwitch);
    await tester.pumpAndSettle();
    expect(hdVal, true);

    // Tap Caption
    expect(find.text('Test Captions'), findsOneWidget);
    final captionSwitch = find.descendant(
      of: find.ancestor(
        of: find.text('Test Captions'),
        matching: find.byType(Row),
      ),
      matching: find.byType(Switch),
    );
    await tester.tap(captionSwitch);
    await tester.pumpAndSettle();
    expect(captionVal, true);

    // Tap Mute
    expect(find.text('Test Mute'), findsOneWidget);
    final muteSwitch = find.descendant(
      of: find.ancestor(of: find.text('Test Mute'), matching: find.byType(Row)),
      matching: find.byType(Switch),
    );
    await tester.tap(muteSwitch);
    await tester.pumpAndSettle();
    expect(muteVal, true);

    // Tap Close to dismiss
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
  });

  testWidgets('SettingsBottomSheet respects visibility flags', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PlayerSettingsSheet(
            autoPlay: false,
            loop: false,
            forceHD: false,
            enableCaption: false,
            isMuted: false,
            showAutoPlaySetting: false,
            showLoopSetting: false,
            showForceHDSetting: false,
            showCaptionsSetting: false,
            showMuteSetting: false,
            onAutoPlayChanged: (_) async {},
            onLoopChanged: (_) async {},
            onForceHDChanged: (_) async {},
            onEnableCaptionChanged: (_) async {},
            onMutedChanged: (_) {},
            iconColor: Colors.white,
            textColor: Colors.black,
            settingItemBackgroundColor: Colors.grey,
            switchInactiveThumbColor: Colors.red,
            switchInactiveTrackColor: Colors.black,
            playerSettingsText: 'Settings',
            forceHdQualityText: 'HD',
            enableCaptionsText: 'CC',
            muteAudioText: 'Mute',
            autoPlayText: 'Hidden Auto',
            loopVideoText: 'Hidden Loop',
          ),
        ),
      ),
    );

    expect(find.text('Hidden Auto'), findsNothing);
    expect(find.text('Hidden Loop'), findsNothing);
  });
}
