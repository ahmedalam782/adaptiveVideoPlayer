import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_video_player/adaptive_video_player.dart';

void main() {
  group('YouTubeJsHandler', () {
    test('handlerName and event constants are correctly defined', () {
      expect(YouTubeJsHandler.handlerName, 'YouTubePlayerHandler');
      expect(YouTubeJsHandler.onReady, 'onReady');
      expect(YouTubeJsHandler.onTimeUpdate, 'onTimeUpdate');
      expect(YouTubeJsHandler.onStateChange, 'onStateChange');
      expect(YouTubeJsHandler.onError, 'onError');
      expect(YouTubeJsHandler.onEnterFullscreen, 'onEnterFullscreen');
      expect(YouTubeJsHandler.onExitFullscreen, 'onExitFullscreen');
      expect(YouTubeJsHandler.onEscapeKey, 'onEscapeKey');
      expect(YouTubeJsHandler.onSeekForward, 'onSeekForward');
      expect(YouTubeJsHandler.onSeekBackward, 'onSeekBackward');
      expect(YouTubeJsHandler.onToggleFullscreen, 'onToggleFullscreen');
      expect(YouTubeJsHandler.onTouchActivity, 'onTouchActivity');
      expect(YouTubeJsHandler.onControlsVisibilityChanged,
          'onControlsVisibilityChanged');
    });
  });

  group('YouTubeJsCommands', () {
    test('command constants are well-formed', () {
      expect(YouTubeJsCommands.playVideo, 'playVideo();');
      expect(YouTubeJsCommands.pauseVideo, 'pauseVideo();');
      expect(YouTubeJsCommands.muteVideo, 'muteVideo();');
      expect(YouTubeJsCommands.unMuteVideo, 'unMuteVideo();');
      expect(YouTubeJsCommands.exitFullscreen, contains('document.exitFullscreen()'));
      expect(YouTubeJsCommands.getCurrentTime, contains('player.getCurrentTime()'));
      expect(YouTubeJsCommands.isPlaying, contains('player.getPlayerState()'));
    });

    test('command factory methods interpolate arguments correctly', () {
      expect(YouTubeJsCommands.seekTo(45), 'seekTo(45);');
      expect(
        YouTubeJsCommands.setLanguage('ar', 'rtl'),
        "setLanguage('ar', 'rtl');",
      );
      final init = YouTubeJsCommands.initPlayer(
        videoId: 'abc123xyz',
        autoPlay: 1,
        mute: 0,
        startAt: 15,
        lang: 'en',
        dir: 'ltr',
      );
      expect(init, "initPlayer('abc123xyz', 1, 0, 15, 'en', 'ltr');");
    });
  });

  group('YouTubeJsScripts', () {
    test('scripts and permissions constants are non-empty and well-formed', () {
      expect(YouTubeJsScripts.desktopUserAgent, contains('Chrome'));
      expect(YouTubeJsScripts.iframeAllowPermissions, contains('fullscreen'));
      expect(YouTubeJsScripts.injectedPlayerScript,
          contains('function updatePlayerStyles()'));
      expect(YouTubeJsScripts.injectedPlayerScript,
          contains('sendToFlutter'));
    });
  });
}
