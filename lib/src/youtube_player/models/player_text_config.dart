/// Configuration model for player localization, text labels, and error messages (SRP)
class PlayerTextConfig {
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

  const PlayerTextConfig({
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
  });

  /// Arabic (RTL) localization preset
  const PlayerTextConfig.arabic({
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
  });

  /// English (LTR) localization preset
  const PlayerTextConfig.english({
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
  });

  /// Creates a copy with updated values
  PlayerTextConfig copyWith({
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
  }) {
    return PlayerTextConfig(
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
    );
  }
}
