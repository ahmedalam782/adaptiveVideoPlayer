import 'package:flutter/widgets.dart';

/// Configuration model for player localization, text labels, and error messages (SRP).
/// All UI labels in the package are driven dynamically by this configuration
/// so developers can provide any language they want.
class PlayerTextConfig {
  /// Optional ISO language code (e.g. 'en', 'ar', 'fr', 'es', 'tr', 'de', 'ur')
  final String? languageCode;

  /// Optional explicit text direction for menus and overlays
  final TextDirection? textDirection;

  /// Text for invalid YouTube URL error
  final String invalidYoutubeUrlText;

  /// Text for video load failed error
  final String videoLoadFailedText;

  /// Text for video unavailable error
  final String videoUnavailableText;

  /// Text for video not compatible error
  final String videoNotCompatibleText;

  /// Text for video cannot be loaded due to security policy
  final String videoCannotBeLoadedSecurityPolicyText;

  /// Text for player settings title
  final String playerSettingsText;

  /// Text for auto play setting
  final String autoPlayText;

  /// Text for loop video setting
  final String loopVideoText;

  /// Text for force HD quality setting
  final String forceHdQualityText;

  /// Text for enable captions setting
  final String enableCaptionsText;

  /// Text for mute audio setting
  final String muteAudioText;

  /// Text when no video qualities are available
  final String noQualitiesAvailableText;

  /// Text when no subtitles are available
  final String noSubtitlesAvailableText;

  /// Text for quality setting title
  final String qualityText;

  /// Text for subtitles setting title
  final String subtitlesText;

  /// Text for auto quality
  final String autoText;

  /// Text for off subtitle
  final String offText;

  /// Tooltip / label for skip backward 10s button
  final String skipBackwardText;

  /// Tooltip / label for skip forward 10s button
  final String skipForwardText;

  /// Tooltip / label for miniplayer (PiP) button
  final String miniPlayerText;

  /// Button label to restore player from miniplayer
  final String restorePlayerText;

  /// Tooltip for expanding miniplayer
  final String expandPlayerText;

  /// Tooltip for closing miniplayer
  final String closeMiniPlayerText;

  /// Tooltip / label for play button
  final String playText;

  /// Tooltip / label for pause button
  final String pauseText;

  /// Tooltip / label for fullscreen button
  final String fullscreenText;

  /// Tooltip / label for exit fullscreen button
  final String exitFullscreenText;

  /// Badge text for live stream indicator
  final String liveText;

  /// Button text to switch to live stream
  final String goLiveText;

  /// Badge text for hold-to-2x speed indicator
  final String speed2xText;

  const PlayerTextConfig({
    this.languageCode,
    this.textDirection,
    this.invalidYoutubeUrlText = 'Invalid YouTube URL',
    this.videoLoadFailedText = 'Failed to load video',
    this.videoUnavailableText = 'Video unavailable',
    this.videoNotCompatibleText = 'Video format not compatible',
    this.videoCannotBeLoadedSecurityPolicyText =
        'Video cannot be loaded due to security policy',
    this.playerSettingsText = 'Player Settings',
    this.autoPlayText = 'Auto Play',
    this.loopVideoText = 'Loop Video',
    this.forceHdQualityText = 'Force HD Quality',
    this.enableCaptionsText = 'Enable Captions',
    this.muteAudioText = 'Mute Audio',
    this.noQualitiesAvailableText = 'No qualities available',
    this.noSubtitlesAvailableText = 'No subtitles available',
    this.qualityText = 'Quality (Resolution)',
    this.subtitlesText = 'Subtitles',
    this.autoText = 'Auto',
    this.offText = 'Off',
    this.skipBackwardText = 'Rewind 10s',
    this.skipForwardText = 'Forward 10s',
    this.miniPlayerText = 'Miniplayer',
    this.restorePlayerText = 'Restore Player',
    this.expandPlayerText = 'Expand player',
    this.closeMiniPlayerText = 'Close miniplayer',
    this.playText = 'Play',
    this.pauseText = 'Pause',
    this.fullscreenText = 'Fullscreen',
    this.exitFullscreenText = 'Exit Fullscreen',
    this.liveText = 'LIVE',
    this.goLiveText = 'GO LIVE',
    this.speed2xText = '2x',
  });

  /// Arabic (RTL) localization preset
  const PlayerTextConfig.arabic({
    this.languageCode = 'ar',
    this.textDirection = TextDirection.rtl,
    this.invalidYoutubeUrlText = 'رابط يوتيوب غير صالح',
    this.videoLoadFailedText = 'فشل تحميل الفيديو',
    this.videoUnavailableText = 'الفيديو غير متاح',
    this.videoNotCompatibleText = 'صيغة الفيديو غير مدعومة',
    this.videoCannotBeLoadedSecurityPolicyText =
        'تعذر تحميل الفيديو بسبب سياسة الأمان',
    this.playerSettingsText = 'إعدادات المشغل',
    this.autoPlayText = 'التشغيل التلقائي',
    this.loopVideoText = 'تكرار الفيديو',
    this.forceHdQualityText = 'فرض جودة عالية HD',
    this.enableCaptionsText = 'تفعيل الترجمة',
    this.muteAudioText = 'كتم الصوت',
    this.noQualitiesAvailableText = 'لا توجد جودات متاحة',
    this.noSubtitlesAvailableText = 'لا توجد ترجمات متاحة',
    this.qualityText = 'الجودة (الدقة)',
    this.subtitlesText = 'الترجمة',
    this.autoText = 'تلقائي',
    this.offText = 'إيقاف',
    this.skipBackwardText = 'تأخير 10 ثواني',
    this.skipForwardText = 'تقديم 10 ثواني',
    this.miniPlayerText = 'المشغل المصغر',
    this.restorePlayerText = 'استعادة المشغل',
    this.expandPlayerText = 'تكبير المشغل',
    this.closeMiniPlayerText = 'إغلاق المشغل المصغر',
    this.playText = 'تشغيل',
    this.pauseText = 'إيقاف مؤقت',
    this.fullscreenText = 'ملء الشاشة',
    this.exitFullscreenText = 'إنهاء ملء الشاشة',
    this.liveText = 'مباشر',
    this.goLiveText = 'البث المباشر',
    this.speed2xText = '2x',
  });

  /// English (LTR) localization preset
  const PlayerTextConfig.english({
    this.languageCode = 'en',
    this.textDirection = TextDirection.ltr,
    this.invalidYoutubeUrlText = 'Invalid YouTube URL',
    this.videoLoadFailedText = 'Failed to load video',
    this.videoUnavailableText = 'Video unavailable',
    this.videoNotCompatibleText = 'Video format not compatible',
    this.videoCannotBeLoadedSecurityPolicyText =
        'Video cannot be loaded due to security policy',
    this.playerSettingsText = 'Player Settings',
    this.autoPlayText = 'Auto Play',
    this.loopVideoText = 'Loop Video',
    this.forceHdQualityText = 'Force HD Quality',
    this.enableCaptionsText = 'Enable Captions',
    this.muteAudioText = 'Mute Audio',
    this.noQualitiesAvailableText = 'No qualities available',
    this.noSubtitlesAvailableText = 'No subtitles available',
    this.qualityText = 'Quality (Resolution)',
    this.subtitlesText = 'Subtitles',
    this.autoText = 'Auto',
    this.offText = 'Off',
    this.skipBackwardText = 'Rewind 10s',
    this.skipForwardText = 'Forward 10s',
    this.miniPlayerText = 'Miniplayer',
    this.restorePlayerText = 'Restore Player',
    this.expandPlayerText = 'Expand player',
    this.closeMiniPlayerText = 'Close miniplayer',
    this.playText = 'Play',
    this.pauseText = 'Pause',
    this.fullscreenText = 'Fullscreen',
    this.exitFullscreenText = 'Exit Fullscreen',
    this.liveText = 'LIVE',
    this.goLiveText = 'GO LIVE',
    this.speed2xText = '2x',
  });

  static const Set<String> _rtlLanguageCodes = {
    'ar',
    'fa',
    'ur',
    'he',
    'ps',
    'sd',
    'ug',
    'yi',
    'ku',
  };

  /// Resolves the effective text direction from explicit config, ambient context, or locale.
  TextDirection resolveTextDirection(
    BuildContext context, {
    TextDirection? ambientDirection,
  }) {
    if (textDirection != null) return textDirection!;
    if (languageCode != null &&
        _rtlLanguageCodes.contains(languageCode!.toLowerCase())) {
      return TextDirection.rtl;
    }
    const arabicConfig = PlayerTextConfig.arabic();
    if (qualityText == arabicConfig.qualityText ||
        playerSettingsText == arabicConfig.playerSettingsText ||
        subtitlesText == arabicConfig.subtitlesText) {
      return TextDirection.rtl;
    }
    final localeCode = Localizations.maybeLocaleOf(context)?.languageCode;
    if (localeCode != null &&
        _rtlLanguageCodes.contains(localeCode.toLowerCase())) {
      return TextDirection.rtl;
    }
    if (ambientDirection != null) return ambientDirection;
    return Directionality.maybeOf(context) ?? TextDirection.ltr;
  }

  /// Resolves the effective ISO language code for any language configured by the user.
  String resolveLanguageCode(
    BuildContext context, {
    TextDirection? ambientDirection,
  }) {
    if (languageCode != null && languageCode!.trim().isNotEmpty) {
      return languageCode!.trim();
    }
    final localeCode = Localizations.maybeLocaleOf(context)?.languageCode;
    if (localeCode != null && localeCode.trim().isNotEmpty) {
      return localeCode.trim();
    }
    return resolveTextDirection(context, ambientDirection: ambientDirection) ==
            TextDirection.rtl
        ? 'ar'
        : 'en';
  }

  /// Whether this configuration uses the default untouched constructor values.
  bool get isDefaultUnmodified {
    const def = PlayerTextConfig();
    return languageCode == null &&
        textDirection == null &&
        invalidYoutubeUrlText == def.invalidYoutubeUrlText &&
        videoLoadFailedText == def.videoLoadFailedText &&
        playerSettingsText == def.playerSettingsText &&
        qualityText == def.qualityText &&
        subtitlesText == def.subtitlesText &&
        autoText == def.autoText &&
        offText == def.offText &&
        skipBackwardText == def.skipBackwardText &&
        skipForwardText == def.skipForwardText &&
        miniPlayerText == def.miniPlayerText &&
        restorePlayerText == def.restorePlayerText &&
        liveText == def.liveText;
  }

  /// Creates a copy with updated values
  PlayerTextConfig copyWith({
    String? languageCode,
    TextDirection? textDirection,
    String? invalidYoutubeUrlText,
    String? videoLoadFailedText,
    String? videoUnavailableText,
    String? videoNotCompatibleText,
    String? videoCannotBeLoadedSecurityPolicyText,
    String? playerSettingsText,
    String? autoPlayText,
    String? loopVideoText,
    String? forceHdQualityText,
    String? enableCaptionsText,
    String? muteAudioText,
    String? noQualitiesAvailableText,
    String? noSubtitlesAvailableText,
    String? qualityText,
    String? subtitlesText,
    String? autoText,
    String? offText,
    String? skipBackwardText,
    String? skipForwardText,
    String? miniPlayerText,
    String? restorePlayerText,
    String? expandPlayerText,
    String? closeMiniPlayerText,
    String? playText,
    String? pauseText,
    String? fullscreenText,
    String? exitFullscreenText,
    String? liveText,
    String? goLiveText,
    String? speed2xText,
  }) {
    return PlayerTextConfig(
      languageCode: languageCode ?? this.languageCode,
      textDirection: textDirection ?? this.textDirection,
      invalidYoutubeUrlText:
          invalidYoutubeUrlText ?? this.invalidYoutubeUrlText,
      videoLoadFailedText: videoLoadFailedText ?? this.videoLoadFailedText,
      videoUnavailableText: videoUnavailableText ?? this.videoUnavailableText,
      videoNotCompatibleText:
          videoNotCompatibleText ?? this.videoNotCompatibleText,
      videoCannotBeLoadedSecurityPolicyText:
          videoCannotBeLoadedSecurityPolicyText ??
              this.videoCannotBeLoadedSecurityPolicyText,
      playerSettingsText: playerSettingsText ?? this.playerSettingsText,
      autoPlayText: autoPlayText ?? this.autoPlayText,
      loopVideoText: loopVideoText ?? this.loopVideoText,
      forceHdQualityText: forceHdQualityText ?? this.forceHdQualityText,
      enableCaptionsText: enableCaptionsText ?? this.enableCaptionsText,
      muteAudioText: muteAudioText ?? this.muteAudioText,
      noQualitiesAvailableText:
          noQualitiesAvailableText ?? this.noQualitiesAvailableText,
      noSubtitlesAvailableText:
          noSubtitlesAvailableText ?? this.noSubtitlesAvailableText,
      qualityText: qualityText ?? this.qualityText,
      subtitlesText: subtitlesText ?? this.subtitlesText,
      autoText: autoText ?? this.autoText,
      offText: offText ?? this.offText,
      skipBackwardText: skipBackwardText ?? this.skipBackwardText,
      skipForwardText: skipForwardText ?? this.skipForwardText,
      miniPlayerText: miniPlayerText ?? this.miniPlayerText,
      restorePlayerText: restorePlayerText ?? this.restorePlayerText,
      expandPlayerText: expandPlayerText ?? this.expandPlayerText,
      closeMiniPlayerText: closeMiniPlayerText ?? this.closeMiniPlayerText,
      playText: playText ?? this.playText,
      pauseText: pauseText ?? this.pauseText,
      fullscreenText: fullscreenText ?? this.fullscreenText,
      exitFullscreenText: exitFullscreenText ?? this.exitFullscreenText,
      liveText: liveText ?? this.liveText,
      goLiveText: goLiveText ?? this.goLiveText,
      speed2xText: speed2xText ?? this.speed2xText,
    );
  }
}
