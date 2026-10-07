// This file imports testable library source files to ensure they are included
// in the coverage report. Platform-dependent widget files that require
// native platform channels (InAppWebView, video_player)
// are excluded as they require integration tests.

// ignore_for_file: unused_import

import 'package:flutter_test/flutter_test.dart';

// Models
import 'package:adaptive_video_player/src/normal_video_player/models/video_config.dart';
import 'package:adaptive_video_player/src/youtube_player/models/youtube_player_config.dart';

// Cubit
import 'package:adaptive_video_player/src/youtube_player/cubit/youtube_player_cubit.dart';
import 'package:adaptive_video_player/src/youtube_player/cubit/youtube_player_state.dart';

// Utils
import 'package:adaptive_video_player/src/youtube_player/utils/duration_formatter.dart';
import 'package:adaptive_video_player/src/youtube_player/utils/player_utils.dart';
import 'package:adaptive_video_player/src/youtube_player/utils/youtube_web_stub.dart';

// Core & Coordinators
import 'package:adaptive_video_player/src/core/contracts/i_video_player_controller.dart';
import 'package:adaptive_video_player/src/core/contracts/i_fullscreen_service.dart';
import 'package:adaptive_video_player/src/core/contracts/i_analytics_service.dart';
import 'package:adaptive_video_player/src/core/factory/player_controller_factory.dart';
import 'package:adaptive_video_player/src/normal_video_player/coordinator/normal_fullscreen_coordinator.dart';

// Testable Widgets
import 'package:adaptive_video_player/src/normal_video_player/widgets/normal_fullscreen_overlay.dart';
import 'package:adaptive_video_player/src/normal_video_player/widgets/normal_player_error_widget.dart';
import 'package:adaptive_video_player/src/normal_video_player/widgets/normal_player_loading_widget.dart';
import 'package:adaptive_video_player/src/youtube_player/widgets/player_error_widget.dart';
import 'package:adaptive_video_player/src/youtube_player/widgets/player_loading_widget.dart';
import 'package:adaptive_video_player/src/youtube_player/widgets/youtube_live_badge.dart';
import 'package:adaptive_video_player/src/youtube_player/widgets/youtube_replay_overlay.dart';
import 'package:adaptive_video_player/src/youtube_player/widgets/player_controls.dart';
import 'package:adaptive_video_player/src/youtube_player/widgets/player_settings_helper.dart';
import 'package:adaptive_video_player/src/youtube_player/widgets/player_settings_sheet.dart';
import 'package:adaptive_video_player/src/youtube_player/widgets/setting_item.dart';

void main() {
  test('all testable library files are importable', () {
    expect(true, isTrue);
  });

  test('youtube_web_stub functions', () {
    registerYoutubeWebIframe('viewId', 'videoId', true);
    final widget = buildYoutubeWebIframe('viewId');
    expect(widget, isNotNull);
  });
}
