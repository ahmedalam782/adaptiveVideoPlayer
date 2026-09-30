import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_video_player/src/youtube_player/models/youtube_player_config.dart';

void main() {
  group('PlayerStyleConfig', () {
    test('creates PlayerStyleConfig with default values', () {
      const config = PlayerStyleConfig();

      expect(config.progressBarPlayedColor, Colors.red);
      expect(config.progressBarHandleColor, Colors.redAccent);
      expect(config.loadingIndicatorColor, const Color(0xFFFF0000));
      expect(config.errorIconColor, const Color(0xFFFF0000));
      expect(config.iconColor, Colors.white);
      expect(config.textColor, Colors.white);
      expect(config.backgroundColor, const Color(0xFF1D1D1D));
      expect(config.settingsBackgroundColor, const Color(0xFF1D1D1D));
      expect(config.settingItemBackgroundColor, const Color(0xFF0D0D0D));
      expect(config.switchInactiveThumbColor, isNull);
      expect(config.switchInactiveTrackColor, isNull);
      expect(config.timeTextStyle, isNull);
      expect(config.settingsTitleStyle, isNull);
      expect(config.settingItemTextStyle, isNull);
      expect(config.errorTextStyle, isNull);
      expect(config.progressBarBufferedColor, isNull);
      expect(config.progressBarBackgroundColor, isNull);
      expect(config.controlsBackgroundColor, isNull);
    });

    test('copyWith creates new instance with updated values including new color properties', () {
      const original = PlayerStyleConfig();
      final updated = original.copyWith(
        progressBarPlayedColor: Colors.blue,
        progressBarHandleColor: Colors.green,
        progressBarBufferedColor: Colors.grey,
        progressBarBackgroundColor: Colors.black26,
        controlsBackgroundColor: Colors.black54,
        loadingIndicatorColor: Colors.yellow,
        errorIconColor: Colors.orange,
        iconColor: Colors.purple,
        textColor: Colors.cyan,
        backgroundColor: Colors.brown,
        settingsBackgroundColor: Colors.teal,
        settingItemBackgroundColor: Colors.pink,
        switchInactiveThumbColor: Colors.black,
        switchInactiveTrackColor: Colors.white,
        timeTextStyle: const TextStyle(fontSize: 10),
        settingsTitleStyle: const TextStyle(fontSize: 11),
        settingItemTextStyle: const TextStyle(fontSize: 12),
        errorTextStyle: const TextStyle(fontSize: 13),
        useGlassmorphicControls: false,
      );

      expect(updated.progressBarPlayedColor, Colors.blue);
      expect(updated.progressBarHandleColor, Colors.green);
      expect(updated.progressBarBufferedColor, Colors.grey);
      expect(updated.progressBarBackgroundColor, Colors.black26);
      expect(updated.controlsBackgroundColor, Colors.black54);
      expect(updated.loadingIndicatorColor, Colors.yellow);
      expect(updated.errorIconColor, Colors.orange);
      expect(updated.iconColor, Colors.purple);
      expect(updated.textColor, Colors.cyan);
      expect(updated.backgroundColor, Colors.brown);
      expect(updated.settingsBackgroundColor, Colors.teal);
      expect(updated.settingItemBackgroundColor, Colors.pink);
      expect(updated.switchInactiveThumbColor, Colors.black);
      expect(updated.switchInactiveTrackColor, Colors.white);
      expect(updated.timeTextStyle?.fontSize, 10);
      expect(updated.settingsTitleStyle?.fontSize, 11);
      expect(updated.settingItemTextStyle?.fontSize, 12);
      expect(updated.errorTextStyle?.fontSize, 13);
      expect(updated.useGlassmorphicControls, false);
    });
  });

  group('PlayerTextConfig', () {
    test('creates PlayerTextConfig with default values', () {
      const config = PlayerTextConfig();

      expect(config.invalidYoutubeUrlText, 'Invalid YouTube URL');
      expect(config.videoLoadFailedText, 'Failed to load video');
      expect(config.videoUnavailableText, 'Video unavailable');
      expect(config.videoNotCompatibleText, 'Video format not compatible');
      expect(config.videoCannotBeLoadedSecurityPolicyText,
          'Video cannot be loaded due to security policy');
      expect(config.playerSettingsText, 'Player Settings');
      expect(config.autoPlayText, 'Auto Play');
      expect(config.loopVideoText, 'Loop Video');
      expect(config.forceHdQualityText, 'Force HD Quality');
      expect(config.enableCaptionsText, 'Enable Captions');
      expect(config.muteAudioText, 'Mute Audio');
      expect(config.unmuteAudioText, 'Unmute Audio');
      expect(config.playbackSpeedText, 'Playback Speed');
      expect(config.normalSpeedText, 'Normal');
      expect(config.backText, 'Back');
      expect(config.volumeText, 'Volume');
      expect(config.skipBackwardText, 'Rewind 10s');
      expect(config.skipForwardText, 'Forward 10s');
      expect(config.isRtl, false);
      expect(config.isDefaultUnmodified, true);
    });

    test('creates language presets correctly', () {
      const arabic = PlayerTextConfig.arabic();
      expect(arabic.languageCode, 'ar');
      expect(arabic.textDirection, TextDirection.rtl);
      expect(arabic.isRtl, true);
      expect(arabic.playerSettingsText, 'إعدادات المشغل');

      const spanish = PlayerTextConfig.spanish();
      expect(spanish.languageCode, 'es');
      expect(spanish.textDirection, TextDirection.ltr);
      expect(spanish.isRtl, false);
      expect(spanish.playerSettingsText, 'Ajustes del reproductor');

      const french = PlayerTextConfig.french();
      expect(french.languageCode, 'fr');
      expect(french.isRtl, false);
      expect(french.playerSettingsText, 'Paramètres du lecteur');

      const german = PlayerTextConfig.german();
      expect(german.languageCode, 'de');
      expect(german.isRtl, false);
      expect(german.playerSettingsText, 'Player-Einstellungen');

      const turkish = PlayerTextConfig.turkish();
      expect(turkish.languageCode, 'tr');
      expect(turkish.isRtl, false);
      expect(turkish.playerSettingsText, 'Oynatıcı Ayarları');
    });

    test('fromLanguageCode resolves to correct presets', () {
      expect(PlayerTextConfig.fromLanguageCode('ar').languageCode, 'ar');
      expect(PlayerTextConfig.fromLanguageCode('es').languageCode, 'es');
      expect(PlayerTextConfig.fromLanguageCode('fr').languageCode, 'fr');
      expect(PlayerTextConfig.fromLanguageCode('de').languageCode, 'de');
      expect(PlayerTextConfig.fromLanguageCode('tr').languageCode, 'tr');
      expect(PlayerTextConfig.fromLanguageCode('fa').isRtl, true);
      expect(PlayerTextConfig.fromLanguageCode('ur').isRtl, true);
      expect(PlayerTextConfig.fromLanguageCode('en').languageCode, 'en');
      expect(PlayerTextConfig.fromLanguageCode(null).languageCode, 'en');
    });

    test('forLocale factory resolves correctly', () {
      expect(PlayerTextConfig.forLocale(const Locale('ar')).isRtl, true);
      expect(PlayerTextConfig.forLocale(const Locale('es')).languageCode, 'es');
    });

    test('isRtl detects Arabic characters and explicit RTL direction', () {
      const explicitRtl = PlayerTextConfig(textDirection: TextDirection.rtl);
      expect(explicitRtl.isRtl, true);

      const arabicString = PlayerTextConfig(playerSettingsText: 'إعدادات');
      expect(arabicString.isRtl, true);

      const englishString = PlayerTextConfig(playerSettingsText: 'Settings');
      expect(englishString.isRtl, false);
    });

    test('copyWith creates new instance with updated values', () {
      const original = PlayerTextConfig();
      final updated = original.copyWith(
        invalidYoutubeUrlText: 'invalid',
        videoLoadFailedText: 'failed',
        videoUnavailableText: 'unavailable',
        videoNotCompatibleText: 'incompatible',
        videoCannotBeLoadedSecurityPolicyText: 'security',
        playerSettingsText: 'settings',
        autoPlayText: 'autoplay',
        loopVideoText: 'loop',
        forceHdQualityText: 'forcehd',
        enableCaptionsText: 'captions',
        muteAudioText: 'mute',
        unmuteAudioText: 'unmute',
        playbackSpeedText: 'speed',
        normalSpeedText: 'std',
        backText: 'return',
        volumeText: 'vol',
        skipBackwardText: 'back10',
        skipForwardText: 'fwd10',
        textDirection: TextDirection.rtl,
      );

      expect(updated.invalidYoutubeUrlText, 'invalid');
      expect(updated.videoLoadFailedText, 'failed');
      expect(updated.videoUnavailableText, 'unavailable');
      expect(updated.videoNotCompatibleText, 'incompatible');
      expect(updated.videoCannotBeLoadedSecurityPolicyText, 'security');
      expect(updated.playerSettingsText, 'settings');
      expect(updated.autoPlayText, 'autoplay');
      expect(updated.loopVideoText, 'loop');
      expect(updated.forceHdQualityText, 'forcehd');
      expect(updated.enableCaptionsText, 'captions');
      expect(updated.muteAudioText, 'mute');
      expect(updated.unmuteAudioText, 'unmute');
      expect(updated.playbackSpeedText, 'speed');
      expect(updated.normalSpeedText, 'std');
      expect(updated.backText, 'return');
      expect(updated.volumeText, 'vol');
      expect(updated.skipBackwardText, 'back10');
      expect(updated.skipForwardText, 'fwd10');
      expect(updated.textDirection, TextDirection.rtl);
      expect(updated.isRtl, true);
    });
  });

  group('PlayerVisibilityConfig', () {
    test('creates PlayerVisibilityConfig with default values', () {
      const config = PlayerVisibilityConfig();

      expect(config.showControls, true);
      expect(config.showFullscreenButton, true);
      expect(config.showSettingsButton, true);
      expect(config.showAutoPlaySetting, true);
      expect(config.showLoopSetting, true);
      expect(config.showForceHDSetting, true);
      expect(config.showCaptionsSetting, true);
      expect(config.showMuteSetting, true);
      expect(config.showSkipButtons, true);
      expect(config.showMiniPlayerButton, true);
      expect(config.showVolumeButton, true);
      expect(config.showTimeDisplay, true);
      expect(config.showProgressBar, true);
      expect(config.showCenterPlayPause, true);
      expect(config.showLiveBadge, true);
      expect(config.showQualitySetting, true);
      expect(config.showSubtitlesSetting, true);
      expect(config.showPlaybackSpeedSetting, true);
      expect(config.showChapterTitle, true);
      expect(config.skipDuration, const Duration(seconds: 10));
    });

    test('copyWith creates new instance with updated values including new visibility toggles', () {
      const original = PlayerVisibilityConfig();
      final updated = original.copyWith(
        showControls: false,
        showFullscreenButton: false,
        showSettingsButton: false,
        showAutoPlaySetting: false,
        showLoopSetting: false,
        showForceHDSetting: false,
        showCaptionsSetting: false,
        showMuteSetting: false,
        showSkipButtons: false,
        showMiniPlayerButton: false,
        showVolumeButton: false,
        showTimeDisplay: false,
        showProgressBar: false,
        showCenterPlayPause: false,
        showLiveBadge: false,
        showQualitySetting: false,
        showSubtitlesSetting: false,
        showPlaybackSpeedSetting: false,
        showChapterTitle: false,
        skipDuration: const Duration(seconds: 15),
      );

      expect(updated.showControls, false);
      expect(updated.showFullscreenButton, false);
      expect(updated.showSettingsButton, false);
      expect(updated.showAutoPlaySetting, false);
      expect(updated.showLoopSetting, false);
      expect(updated.showForceHDSetting, false);
      expect(updated.showCaptionsSetting, false);
      expect(updated.showMuteSetting, false);
      expect(updated.showSkipButtons, false);
      expect(updated.showMiniPlayerButton, false);
      expect(updated.showVolumeButton, false);
      expect(updated.showTimeDisplay, false);
      expect(updated.showProgressBar, false);
      expect(updated.showCenterPlayPause, false);
      expect(updated.showLiveBadge, false);
      expect(updated.showQualitySetting, false);
      expect(updated.showSubtitlesSetting, false);
      expect(updated.showPlaybackSpeedSetting, false);
      expect(updated.showChapterTitle, false);
      expect(updated.skipDuration, const Duration(seconds: 15));
    });
  });

  group('PlayerPlaybackConfig', () {
    test('creates PlayerPlaybackConfig with default values', () {
      const config = PlayerPlaybackConfig();

      expect(config.autoPlay, false);
      expect(config.loop, false);
      expect(config.mute, false);
      expect(config.forceHD, false);
      expect(config.enableCaption, false);
      expect(config.forceDesktopMode, false);
    });

    test('copyWith creates new instance with updated values', () {
      const original = PlayerPlaybackConfig();
      final updated = original.copyWith(
        autoPlay: true,
        loop: true,
        mute: true,
        forceHD: true,
        enableCaption: true,
        forceDesktopMode: true,
      );

      expect(updated.autoPlay, true);
      expect(updated.loop, true);
      expect(updated.mute, true);
      expect(updated.forceHD, true);
      expect(updated.enableCaption, true);
      expect(updated.forceDesktopMode, true);
    });
  });

  group('YouTubePlayerConfig', () {
    test('creates default configs', () {
      const config = YouTubePlayerConfig();
      expect(config, isNotNull);
    });

    test('copyWith creates new instance with updated values', () {
      const original = YouTubePlayerConfig();
      final updated = original.copyWith(
        style: const PlayerStyleConfig(progressBarPlayedColor: Colors.blue),
        text: const PlayerTextConfig(playerSettingsText: 'Settings!'),
        visibility: const PlayerVisibilityConfig(showControls: false),
        playback: const PlayerPlaybackConfig(autoPlay: true),
      );

      expect(updated.style.progressBarPlayedColor, Colors.blue);
      expect(updated.text.playerSettingsText, 'Settings!');
      expect(updated.visibility.showControls, false);
      expect(updated.playback.autoPlay, true);
    });
  });
  group('copyWith null fallbacks', () {
    test('PlayerStyleConfig copyWith no args', () {
      const config = PlayerStyleConfig();
      final copy = config.copyWith();
      expect(copy.progressBarPlayedColor, config.progressBarPlayedColor);
      expect(copy.timeTextStyle, config.timeTextStyle);
    });
    test('PlayerTextConfig copyWith no args', () {
      const config = PlayerTextConfig();
      final copy = config.copyWith();
      expect(copy.autoPlayText, config.autoPlayText);
    });
    test('PlayerVisibilityConfig copyWith no args', () {
      const config = PlayerVisibilityConfig();
      final copy = config.copyWith();
      expect(copy.showControls, config.showControls);
    });
    test('PlayerPlaybackConfig copyWith no args', () {
      const config = PlayerPlaybackConfig();
      final copy = config.copyWith();
      expect(copy.autoPlay, config.autoPlay);
    });
    test('YouTubePlayerConfig copyWith no args', () {
      const config = YouTubePlayerConfig();
      final copy = config.copyWith();
      expect(copy.style, config.style);
    });
  });

  group('PlayerBottomActionsConfig & FullScreenResult', () {
    test('creates PlayerBottomActionsConfig', () {
      // ignore: prefer_const_constructors
      final config = PlayerBottomActionsConfig(
        progressBarPlayedColor: Colors.blue,
      );
      expect(config.progressBarPlayedColor, Colors.blue);
      expect(config.progressBarHandleColor, Colors.redAccent);
    });

    test('creates PlayerBottomActionsConfig with defaults', () {
      // ignore: prefer_const_constructors
      final config = PlayerBottomActionsConfig();
      expect(config.iconColor, Colors.white);
      expect(config.textColor, Colors.white);
      expect(config.timeTextStyle, isNull);
    });

    test('creates FullScreenResult', () {
      final res = FullScreenResult(
        position: const Duration(seconds: 1),
        wasPlaying: true,
        isMuted: false,
        autoPlay: true,
        loop: true,
        forceHD: true,
        enableCaption: false,
        videoEnded: true,
      );
      expect(res.position, const Duration(seconds: 1));
      expect(res.videoEnded, true);
    });
  });
}
