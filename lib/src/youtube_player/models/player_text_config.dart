import 'package:flutter/widgets.dart';

/// Configuration model for player localization, text labels, and error messages (SRP).
///
/// In the package, all labels and error messages default strictly to English ('en').
/// Host applications can supply any language, text direction, or wording they need
/// via [PlayerTextConfig], [PlayerTextConfig.fromMap], or [PlayerTextConfig.dynamic].
class PlayerTextConfig {
  /// Optional ISO language code (e.g. 'en', 'ar', 'fr', 'es', 'tr', 'de', 'ur')
  final String? languageCode;

  /// Optional explicit text direction for menus, controls, and overlays
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

  /// Text for mute audio setting / tooltip
  final String muteAudioText;

  /// Text for unmute audio setting / tooltip
  final String unmuteAudioText;

  /// Text when no video qualities are available
  final String noQualitiesAvailableText;

  /// Text when no subtitles are available
  final String noSubtitlesAvailableText;

  /// Text for quality setting title
  final String qualityText;

  /// Text for subtitles setting title
  final String subtitlesText;

  /// Text for playback speed setting title
  final String playbackSpeedText;

  /// Text for normal 1.0x playback speed
  final String normalSpeedText;

  /// Text for auto quality
  final String autoText;

  /// Text for off subtitle
  final String offText;

  /// Tooltip / label for skip backward button
  final String skipBackwardText;

  /// Tooltip / label for skip forward button
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

  /// Tooltip / label for back button
  final String backText;

  /// Tooltip / label for volume slider / button
  final String volumeText;

  /// Creates a player text configuration with default English labels.
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
    this.unmuteAudioText = 'Unmute Audio',
    this.noQualitiesAvailableText = 'No qualities available',
    this.noSubtitlesAvailableText = 'No subtitles available',
    this.qualityText = 'Quality (Resolution)',
    this.subtitlesText = 'Subtitles',
    this.playbackSpeedText = 'Playback Speed',
    this.normalSpeedText = 'Normal',
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
    this.backText = 'Back',
    this.volumeText = 'Volume',
  });

  /// Explicit English (LTR) localization constructor.
  const PlayerTextConfig.english({
    String? languageCode = 'en',
    TextDirection? textDirection = TextDirection.ltr,
    String invalidYoutubeUrlText = 'Invalid YouTube URL',
    String videoLoadFailedText = 'Failed to load video',
    String videoUnavailableText = 'Video unavailable',
    String videoNotCompatibleText = 'Video format not compatible',
    String videoCannotBeLoadedSecurityPolicyText =
        'Video cannot be loaded due to security policy',
    String playerSettingsText = 'Player Settings',
    String autoPlayText = 'Auto Play',
    String loopVideoText = 'Loop Video',
    String forceHdQualityText = 'Force HD Quality',
    String enableCaptionsText = 'Enable Captions',
    String muteAudioText = 'Mute Audio',
    String unmuteAudioText = 'Unmute Audio',
    String noQualitiesAvailableText = 'No qualities available',
    String noSubtitlesAvailableText = 'No subtitles available',
    String qualityText = 'Quality (Resolution)',
    String subtitlesText = 'Subtitles',
    String playbackSpeedText = 'Playback Speed',
    String normalSpeedText = 'Normal',
    String autoText = 'Auto',
    String offText = 'Off',
    String skipBackwardText = 'Rewind 10s',
    String skipForwardText = 'Forward 10s',
    String miniPlayerText = 'Miniplayer',
    String restorePlayerText = 'Restore Player',
    String expandPlayerText = 'Expand player',
    String closeMiniPlayerText = 'Close miniplayer',
    String playText = 'Play',
    String pauseText = 'Pause',
    String fullscreenText = 'Fullscreen',
    String exitFullscreenText = 'Exit Fullscreen',
    String liveText = 'LIVE',
    String goLiveText = 'GO LIVE',
    String speed2xText = '2x',
    String backText = 'Back',
    String volumeText = 'Volume',
  }) : this(
          languageCode: languageCode,
          textDirection: textDirection,
          invalidYoutubeUrlText: invalidYoutubeUrlText,
          videoLoadFailedText: videoLoadFailedText,
          videoUnavailableText: videoUnavailableText,
          videoNotCompatibleText: videoNotCompatibleText,
          videoCannotBeLoadedSecurityPolicyText:
              videoCannotBeLoadedSecurityPolicyText,
          playerSettingsText: playerSettingsText,
          autoPlayText: autoPlayText,
          loopVideoText: loopVideoText,
          forceHdQualityText: forceHdQualityText,
          enableCaptionsText: enableCaptionsText,
          muteAudioText: muteAudioText,
          unmuteAudioText: unmuteAudioText,
          noQualitiesAvailableText: noQualitiesAvailableText,
          noSubtitlesAvailableText: noSubtitlesAvailableText,
          qualityText: qualityText,
          subtitlesText: subtitlesText,
          playbackSpeedText: playbackSpeedText,
          normalSpeedText: normalSpeedText,
          autoText: autoText,
          offText: offText,
          skipBackwardText: skipBackwardText,
          skipForwardText: skipForwardText,
          miniPlayerText: miniPlayerText,
          restorePlayerText: restorePlayerText,
          expandPlayerText: expandPlayerText,
          closeMiniPlayerText: closeMiniPlayerText,
          playText: playText,
          pauseText: pauseText,
          fullscreenText: fullscreenText,
          exitFullscreenText: exitFullscreenText,
          liveText: liveText,
          goLiveText: goLiveText,
          speed2xText: speed2xText,
          backText: backText,
          volumeText: volumeText,
        );

  /// Deprecated convenience constructor.
  /// To localize the player into Arabic, provide Arabic strings in your app using
  /// [PlayerTextConfig.fromMap] or custom language files as demonstrated in the example app.
  @Deprecated('Use app-level language files (see example). Package defaults strictly to English.')
  const PlayerTextConfig.arabic({
    String? languageCode = 'ar',
    TextDirection? textDirection = TextDirection.rtl,
    String invalidYoutubeUrlText = 'رابط يوتيوب غير صالح',
    String videoLoadFailedText = 'فشل تحميل الفيديو',
    String videoUnavailableText = 'الفيديو غير متاح',
    String videoNotCompatibleText = 'صيغة الفيديو غير مدعومة',
    String videoCannotBeLoadedSecurityPolicyText =
        'تعذر تحميل الفيديو بسبب سياسة الأمان',
    String playerSettingsText = 'إعدادات المشغل',
    String autoPlayText = 'التشغيل التلقائي',
    String loopVideoText = 'تكرار الفيديو',
    String forceHdQualityText = 'فرض جودة عالية HD',
    String enableCaptionsText = 'تفعيل الترجمة',
    String muteAudioText = 'كتم الصوت',
    String unmuteAudioText = 'إلغاء كتم الصوت',
    String noQualitiesAvailableText = 'لا توجد جودات متاحة',
    String noSubtitlesAvailableText = 'لا توجد ترجمات متاحة',
    String qualityText = 'الجودة (الدقة)',
    String subtitlesText = 'الترجمة',
    String playbackSpeedText = 'سرعة التشغيل',
    String normalSpeedText = 'عادي',
    String autoText = 'تلقائي',
    String offText = 'إيقاف',
    String skipBackwardText = 'تأخير 10 ثواني',
    String skipForwardText = 'تقديم 10 ثواني',
    String miniPlayerText = 'المشغل المصغر',
    String restorePlayerText = 'استعادة المشغل',
    String expandPlayerText = 'تكبير المشغل',
    String closeMiniPlayerText = 'إغلاق المشغل المصغر',
    String playText = 'تشغيل',
    String pauseText = 'إيقاف مؤقت',
    String fullscreenText = 'ملء الشاشة',
    String exitFullscreenText = 'إنهاء ملء الشاشة',
    String liveText = 'مباشر',
    String goLiveText = 'البث المباشر',
    String speed2xText = '2x',
    String backText = 'رجوع',
    String volumeText = 'مستوى الصوت',
  }) : this(
          languageCode: languageCode,
          textDirection: textDirection,
          invalidYoutubeUrlText: invalidYoutubeUrlText,
          videoLoadFailedText: videoLoadFailedText,
          videoUnavailableText: videoUnavailableText,
          videoNotCompatibleText: videoNotCompatibleText,
          videoCannotBeLoadedSecurityPolicyText:
              videoCannotBeLoadedSecurityPolicyText,
          playerSettingsText: playerSettingsText,
          autoPlayText: autoPlayText,
          loopVideoText: loopVideoText,
          forceHdQualityText: forceHdQualityText,
          enableCaptionsText: enableCaptionsText,
          muteAudioText: muteAudioText,
          unmuteAudioText: unmuteAudioText,
          noQualitiesAvailableText: noQualitiesAvailableText,
          noSubtitlesAvailableText: noSubtitlesAvailableText,
          qualityText: qualityText,
          subtitlesText: subtitlesText,
          playbackSpeedText: playbackSpeedText,
          normalSpeedText: normalSpeedText,
          autoText: autoText,
          offText: offText,
          skipBackwardText: skipBackwardText,
          skipForwardText: skipForwardText,
          miniPlayerText: miniPlayerText,
          restorePlayerText: restorePlayerText,
          expandPlayerText: expandPlayerText,
          closeMiniPlayerText: closeMiniPlayerText,
          playText: playText,
          pauseText: pauseText,
          fullscreenText: fullscreenText,
          exitFullscreenText: exitFullscreenText,
          liveText: liveText,
          goLiveText: goLiveText,
          speed2xText: speed2xText,
          backText: backText,
          volumeText: volumeText,
        );

  /// Deprecated convenience constructor.
  /// To localize into Spanish, provide Spanish translations in your app via [PlayerTextConfig.fromMap].
  @Deprecated('Use app-level language files (see example). Package defaults strictly to English.')
  const PlayerTextConfig.spanish({
    String? languageCode = 'es',
    TextDirection? textDirection = TextDirection.ltr,
    String invalidYoutubeUrlText = 'URL de YouTube no válida',
    String videoLoadFailedText = 'Error al cargar el vídeo',
    String videoUnavailableText = 'Vídeo no disponible',
    String videoNotCompatibleText = 'Formato de vídeo no compatible',
    String videoCannotBeLoadedSecurityPolicyText =
        'No se puede cargar el vídeo debido a la política de seguridad',
    String playerSettingsText = 'Ajustes del reproductor',
    String autoPlayText = 'Reproducción automática',
    String loopVideoText = 'Repetir vídeo',
    String forceHdQualityText = 'Forzar calidad HD',
    String enableCaptionsText = 'Activar subtítulos',
    String muteAudioText = 'Silenciar audio',
    String unmuteAudioText = 'Activar audio',
    String noQualitiesAvailableText = 'No hay calidades disponibles',
    String noSubtitlesAvailableText = 'No hay subtítulos disponibles',
    String qualityText = 'Calidad (Resolución)',
    String subtitlesText = 'Subtítulos',
    String playbackSpeedText = 'Velocidad de reproducción',
    String normalSpeedText = 'Normal',
    String autoText = 'Automático',
    String offText = 'Desactivado',
    String skipBackwardText = 'Retroceder 10s',
    String skipForwardText = 'Avanzar 10s',
    String miniPlayerText = 'Minirreproductor',
    String restorePlayerText = 'Restaurar reproductor',
    String expandPlayerText = 'Expandir reproductor',
    String closeMiniPlayerText = 'Cerrar minirreproductor',
    String playText = 'Reproducir',
    String pauseText = 'Pausar',
    String fullscreenText = 'Pantalla completa',
    String exitFullscreenText = 'Salir de pantalla completa',
    String liveText = 'EN DIRECTO',
    String goLiveText = 'IR AL DIRECTO',
    String speed2xText = '2x',
    String backText = 'Atrás',
    String volumeText = 'Volumen',
  }) : this(
          languageCode: languageCode,
          textDirection: textDirection,
          invalidYoutubeUrlText: invalidYoutubeUrlText,
          videoLoadFailedText: videoLoadFailedText,
          videoUnavailableText: videoUnavailableText,
          videoNotCompatibleText: videoNotCompatibleText,
          videoCannotBeLoadedSecurityPolicyText:
              videoCannotBeLoadedSecurityPolicyText,
          playerSettingsText: playerSettingsText,
          autoPlayText: autoPlayText,
          loopVideoText: loopVideoText,
          forceHdQualityText: forceHdQualityText,
          enableCaptionsText: enableCaptionsText,
          muteAudioText: muteAudioText,
          unmuteAudioText: unmuteAudioText,
          noQualitiesAvailableText: noQualitiesAvailableText,
          noSubtitlesAvailableText: noSubtitlesAvailableText,
          qualityText: qualityText,
          subtitlesText: subtitlesText,
          playbackSpeedText: playbackSpeedText,
          normalSpeedText: normalSpeedText,
          autoText: autoText,
          offText: offText,
          skipBackwardText: skipBackwardText,
          skipForwardText: skipForwardText,
          miniPlayerText: miniPlayerText,
          restorePlayerText: restorePlayerText,
          expandPlayerText: expandPlayerText,
          closeMiniPlayerText: closeMiniPlayerText,
          playText: playText,
          pauseText: pauseText,
          fullscreenText: fullscreenText,
          exitFullscreenText: exitFullscreenText,
          liveText: liveText,
          goLiveText: goLiveText,
          speed2xText: speed2xText,
          backText: backText,
          volumeText: volumeText,
        );

  /// Deprecated convenience constructor.
  /// To localize into French, provide French translations in your app via [PlayerTextConfig.fromMap].
  @Deprecated('Use app-level language files (see example). Package defaults strictly to English.')
  const PlayerTextConfig.french({
    String? languageCode = 'fr',
    TextDirection? textDirection = TextDirection.ltr,
    String invalidYoutubeUrlText = 'URL YouTube non valide',
    String videoLoadFailedText = 'Échec du chargement de la vidéo',
    String videoUnavailableText = 'Vidéo non disponible',
    String videoNotCompatibleText = 'Format vidéo non compatible',
    String videoCannotBeLoadedSecurityPolicyText =
        'La vidéo ne peut pas être chargée en raison de la politique de sécurité',
    String playerSettingsText = 'Paramètres du lecteur',
    String autoPlayText = 'Lecture automatique',
    String loopVideoText = 'Répéter la vidéo',
    String forceHdQualityText = 'Forcer la qualité HD',
    String enableCaptionsText = 'Activer les sous-titres',
    String muteAudioText = 'Couper le son',
    String unmuteAudioText = 'Rétablir le son',
    String noQualitiesAvailableText = 'Aucune qualité disponible',
    String noSubtitlesAvailableText = 'Aucun sous-titre disponible',
    String qualityText = 'Qualité (Résolution)',
    String subtitlesText = 'Sous-titres',
    String playbackSpeedText = 'Vitesse de lecture',
    String normalSpeedText = 'Normal',
    String autoText = 'Automatique',
    String offText = 'Désactivé',
    String skipBackwardText = 'Reculer de 10s',
    String skipForwardText = 'Avancer de 10s',
    String miniPlayerText = 'Mini-lecteur',
    String restorePlayerText = 'Restaurer le lecteur',
    String expandPlayerText = 'Agrandir le lecteur',
    String closeMiniPlayerText = 'Fermer le mini-lecteur',
    String playText = 'Lire',
    String pauseText = 'Pause',
    String fullscreenText = 'Plein écran',
    String exitFullscreenText = 'Quitter le plein écran',
    String liveText = 'EN DIRECT',
    String goLiveText = 'PASSER AU DIRECT',
    String speed2xText = '2x',
    String backText = 'Retour',
    String volumeText = 'Volume',
  }) : this(
          languageCode: languageCode,
          textDirection: textDirection,
          invalidYoutubeUrlText: invalidYoutubeUrlText,
          videoLoadFailedText: videoLoadFailedText,
          videoUnavailableText: videoUnavailableText,
          videoNotCompatibleText: videoNotCompatibleText,
          videoCannotBeLoadedSecurityPolicyText:
              videoCannotBeLoadedSecurityPolicyText,
          playerSettingsText: playerSettingsText,
          autoPlayText: autoPlayText,
          loopVideoText: loopVideoText,
          forceHdQualityText: forceHdQualityText,
          enableCaptionsText: enableCaptionsText,
          muteAudioText: muteAudioText,
          unmuteAudioText: unmuteAudioText,
          noQualitiesAvailableText: noQualitiesAvailableText,
          noSubtitlesAvailableText: noSubtitlesAvailableText,
          qualityText: qualityText,
          subtitlesText: subtitlesText,
          playbackSpeedText: playbackSpeedText,
          normalSpeedText: normalSpeedText,
          autoText: autoText,
          offText: offText,
          skipBackwardText: skipBackwardText,
          skipForwardText: skipForwardText,
          miniPlayerText: miniPlayerText,
          restorePlayerText: restorePlayerText,
          expandPlayerText: expandPlayerText,
          closeMiniPlayerText: closeMiniPlayerText,
          playText: playText,
          pauseText: pauseText,
          fullscreenText: fullscreenText,
          exitFullscreenText: exitFullscreenText,
          liveText: liveText,
          goLiveText: goLiveText,
          speed2xText: speed2xText,
          backText: backText,
          volumeText: volumeText,
        );

  /// Deprecated convenience constructor.
  /// To localize into German, provide German translations in your app via [PlayerTextConfig.fromMap].
  @Deprecated('Use app-level language files (see example). Package defaults strictly to English.')
  const PlayerTextConfig.german({
    String? languageCode = 'de',
    TextDirection? textDirection = TextDirection.ltr,
    String invalidYoutubeUrlText = 'Ungültige YouTube-URL',
    String videoLoadFailedText = 'Fehler beim Laden des Videos',
    String videoUnavailableText = 'Video nicht verfügbar',
    String videoNotCompatibleText = 'Videoformat nicht kompatibel',
    String videoCannotBeLoadedSecurityPolicyText =
        'Video kann aufgrund von Sicherheitsrichtlinien nicht geladen werden',
    String playerSettingsText = 'Player-Einstellungen',
    String autoPlayText = 'Automatische Wiedergabe',
    String loopVideoText = 'Video wiederholen',
    String forceHdQualityText = 'HD-Qualität erzwingen',
    String enableCaptionsText = 'Untertitel aktivieren',
    String muteAudioText = 'Stummschalten',
    String unmuteAudioText = 'Stummschaltung aufheben',
    String noQualitiesAvailableText = 'Keine Qualitäten verfügbar',
    String noSubtitlesAvailableText = 'Keine Untertitel verfügbar',
    String qualityText = 'Qualität (Auflösung)',
    String subtitlesText = 'Untertitel',
    String playbackSpeedText = 'Wiedergabegeschwindigkeit',
    String normalSpeedText = 'Normal',
    String autoText = 'Automatisch',
    String offText = 'Aus',
    String skipBackwardText = '10s zurück',
    String skipForwardText = '10s vor',
    String miniPlayerText = 'Miniplayer',
    String restorePlayerText = 'Player wiederherstellen',
    String expandPlayerText = 'Player vergrößern',
    String closeMiniPlayerText = 'Miniplayer schließen',
    String playText = 'Wiedergabe',
    String pauseText = 'Pause',
    String fullscreenText = 'Vollbild',
    String exitFullscreenText = 'Vollbild beenden',
    String liveText = 'LIVE',
    String goLiveText = 'ZUM LIVE-STREAM',
    String speed2xText = '2x',
    String backText = 'Zurück',
    String volumeText = 'Lautstärke',
  }) : this(
          languageCode: languageCode,
          textDirection: textDirection,
          invalidYoutubeUrlText: invalidYoutubeUrlText,
          videoLoadFailedText: videoLoadFailedText,
          videoUnavailableText: videoUnavailableText,
          videoNotCompatibleText: videoNotCompatibleText,
          videoCannotBeLoadedSecurityPolicyText:
              videoCannotBeLoadedSecurityPolicyText,
          playerSettingsText: playerSettingsText,
          autoPlayText: autoPlayText,
          loopVideoText: loopVideoText,
          forceHdQualityText: forceHdQualityText,
          enableCaptionsText: enableCaptionsText,
          muteAudioText: muteAudioText,
          unmuteAudioText: unmuteAudioText,
          noQualitiesAvailableText: noQualitiesAvailableText,
          noSubtitlesAvailableText: noSubtitlesAvailableText,
          qualityText: qualityText,
          subtitlesText: subtitlesText,
          playbackSpeedText: playbackSpeedText,
          normalSpeedText: normalSpeedText,
          autoText: autoText,
          offText: offText,
          skipBackwardText: skipBackwardText,
          skipForwardText: skipForwardText,
          miniPlayerText: miniPlayerText,
          restorePlayerText: restorePlayerText,
          expandPlayerText: expandPlayerText,
          closeMiniPlayerText: closeMiniPlayerText,
          playText: playText,
          pauseText: pauseText,
          fullscreenText: fullscreenText,
          exitFullscreenText: exitFullscreenText,
          liveText: liveText,
          goLiveText: goLiveText,
          speed2xText: speed2xText,
          backText: backText,
          volumeText: volumeText,
        );

  /// Deprecated convenience constructor.
  /// To localize into Turkish, provide Turkish translations in your app via [PlayerTextConfig.fromMap].
  @Deprecated('Use app-level language files (see example). Package defaults strictly to English.')
  const PlayerTextConfig.turkish({
    String? languageCode = 'tr',
    TextDirection? textDirection = TextDirection.ltr,
    String invalidYoutubeUrlText = 'Geçersiz YouTube URL\'si',
    String videoLoadFailedText = 'Video yüklenemedi',
    String videoUnavailableText = 'Video kullanılamıyor',
    String videoNotCompatibleText = 'Video formatı uyumlu değil',
    String videoCannotBeLoadedSecurityPolicyText =
        'Güvenlik politikası nedeniyle video yüklenemiyor',
    String playerSettingsText = 'Oynatıcı Ayarları',
    String autoPlayText = 'Otomatik Oynat',
    String loopVideoText = 'Videoyu Döngüye Al',
    String forceHdQualityText = 'HD Kaliteye Zorla',
    String enableCaptionsText = 'Altyazıları Aç',
    String muteAudioText = 'Sesi Kapat',
    String unmuteAudioText = 'Sesi Aç',
    String noQualitiesAvailableText = 'Kullanılabilir kalite yok',
    String noSubtitlesAvailableText = 'Kullanılabilir altyazı yok',
    String qualityText = 'Kalite (Çözünürlük)',
    String subtitlesText = 'Altyazılar',
    String playbackSpeedText = 'Oynatma Hızı',
    String normalSpeedText = 'Normal',
    String autoText = 'Otomatik',
    String offText = 'Kapalı',
    String skipBackwardText = '10 sn geri sar',
    String skipForwardText = '10 sn ileri sar',
    String miniPlayerText = 'Mini Oynatıcı',
    String restorePlayerText = 'Oynatıcıyı Geri Yükle',
    String expandPlayerText = 'Oynatıcıyı Genişlet',
    String closeMiniPlayerText = 'Mini Oynatıcıyı Kapat',
    String playText = 'Oynat',
    String pauseText = 'Duraklat',
    String fullscreenText = 'Tam Ekran',
    String exitFullscreenText = 'Tam Ekrandan Çık',
    String liveText = 'CANLI',
    String goLiveText = 'CANLI YAYINA GEÇ',
    String speed2xText = '2x',
    String backText = 'Geri',
    String volumeText = 'Ses Seviyesi',
  }) : this(
          languageCode: languageCode,
          textDirection: textDirection,
          invalidYoutubeUrlText: invalidYoutubeUrlText,
          videoLoadFailedText: videoLoadFailedText,
          videoUnavailableText: videoUnavailableText,
          videoNotCompatibleText: videoNotCompatibleText,
          videoCannotBeLoadedSecurityPolicyText:
              videoCannotBeLoadedSecurityPolicyText,
          playerSettingsText: playerSettingsText,
          autoPlayText: autoPlayText,
          loopVideoText: loopVideoText,
          forceHdQualityText: forceHdQualityText,
          enableCaptionsText: enableCaptionsText,
          muteAudioText: muteAudioText,
          unmuteAudioText: unmuteAudioText,
          noQualitiesAvailableText: noQualitiesAvailableText,
          noSubtitlesAvailableText: noSubtitlesAvailableText,
          qualityText: qualityText,
          subtitlesText: subtitlesText,
          playbackSpeedText: playbackSpeedText,
          normalSpeedText: normalSpeedText,
          autoText: autoText,
          offText: offText,
          skipBackwardText: skipBackwardText,
          skipForwardText: skipForwardText,
          miniPlayerText: miniPlayerText,
          restorePlayerText: restorePlayerText,
          expandPlayerText: expandPlayerText,
          closeMiniPlayerText: closeMiniPlayerText,
          playText: playText,
          pauseText: pauseText,
          fullscreenText: fullscreenText,
          exitFullscreenText: exitFullscreenText,
          liveText: liveText,
          goLiveText: goLiveText,
          speed2xText: speed2xText,
          backText: backText,
          volumeText: volumeText,
        );

  /// Factory setting language code and resolving default text direction.
  /// Texts remain English by default unless customized.
  factory PlayerTextConfig.fromLanguageCode(String? code) {
    if (code == null) return const PlayerTextConfig.english();
    final clean = code.trim().toLowerCase();
    final isRtl = _rtlLanguageCodes.contains(clean);
    return PlayerTextConfig.english(
      languageCode: clean,
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
    );
  }

  /// Factory creating configuration dynamically matching a Flutter [Locale].
  factory PlayerTextConfig.forLocale(Locale locale) {
    return PlayerTextConfig.fromLanguageCode(locale.languageCode);
  }

  /// Factory creating configuration from a key-value Map (e.g. from JSON or localization files).
  ///
  /// Any keys not provided in [map] will automatically fallback to default English texts.
  factory PlayerTextConfig.fromMap(
    Map<String, String> map, {
    String? languageCode,
    TextDirection? textDirection,
  }) {
    const def = PlayerTextConfig();
    final cleanLang = languageCode?.trim().toLowerCase();
    final resolvedDirection = textDirection ??
        (cleanLang != null
            ? (_rtlLanguageCodes.contains(cleanLang)
                ? TextDirection.rtl
                : TextDirection.ltr)
            : null);

    return PlayerTextConfig(
      languageCode: cleanLang,
      textDirection: resolvedDirection,
      invalidYoutubeUrlText:
          map['invalid_youtube_url'] ?? def.invalidYoutubeUrlText,
      videoLoadFailedText: map['video_load_failed'] ?? def.videoLoadFailedText,
      videoUnavailableText:
          map['video_unavailable'] ?? def.videoUnavailableText,
      videoNotCompatibleText:
          map['video_not_compatible'] ?? def.videoNotCompatibleText,
      videoCannotBeLoadedSecurityPolicyText: map['video_security_policy_error'] ??
          def.videoCannotBeLoadedSecurityPolicyText,
      playerSettingsText: map['player_settings'] ?? def.playerSettingsText,
      autoPlayText: map['auto_play'] ?? def.autoPlayText,
      loopVideoText: map['loop_video'] ?? def.loopVideoText,
      forceHdQualityText: map['force_hd_quality'] ?? def.forceHdQualityText,
      enableCaptionsText: map['enable_captions'] ?? def.enableCaptionsText,
      muteAudioText: map['mute_audio'] ?? def.muteAudioText,
      unmuteAudioText: map['unmute_audio'] ?? def.unmuteAudioText,
      noQualitiesAvailableText:
          map['no_qualities_available'] ?? def.noQualitiesAvailableText,
      noSubtitlesAvailableText:
          map['no_subtitles_available'] ?? def.noSubtitlesAvailableText,
      qualityText: map['quality'] ?? def.qualityText,
      subtitlesText: map['subtitles'] ?? def.subtitlesText,
      playbackSpeedText: map['playback_speed'] ?? def.playbackSpeedText,
      normalSpeedText: map['normal_speed'] ?? def.normalSpeedText,
      autoText: map['auto'] ?? def.autoText,
      offText: map['off'] ?? def.offText,
      skipBackwardText: map['skip_backward'] ?? def.skipBackwardText,
      skipForwardText: map['skip_forward'] ?? def.skipForwardText,
      miniPlayerText: map['mini_player'] ?? def.miniPlayerText,
      restorePlayerText: map['restore_player'] ?? def.restorePlayerText,
      expandPlayerText: map['expand_player'] ?? def.expandPlayerText,
      closeMiniPlayerText:
          map['close_mini_player'] ?? def.closeMiniPlayerText,
      playText: map['play'] ?? def.playText,
      pauseText: map['pause'] ?? def.pauseText,
      fullscreenText: map['fullscreen'] ?? def.fullscreenText,
      exitFullscreenText: map['exit_fullscreen'] ?? def.exitFullscreenText,
      liveText: map['live'] ?? def.liveText,
      goLiveText: map['go_live'] ?? def.goLiveText,
      speed2xText: map['speed_2x'] ?? def.speed2xText,
      backText: map['back'] ?? def.backText,
      volumeText: map['volume'] ?? def.volumeText,
    );
  }

  /// Converts this configuration to a standard key-value map.
  Map<String, String> toMap() {
    return {
      'invalid_youtube_url': invalidYoutubeUrlText,
      'video_load_failed': videoLoadFailedText,
      'video_unavailable': videoUnavailableText,
      'video_not_compatible': videoNotCompatibleText,
      'video_security_policy_error': videoCannotBeLoadedSecurityPolicyText,
      'player_settings': playerSettingsText,
      'auto_play': autoPlayText,
      'loop_video': loopVideoText,
      'force_hd_quality': forceHdQualityText,
      'enable_captions': enableCaptionsText,
      'mute_audio': muteAudioText,
      'unmute_audio': unmuteAudioText,
      'no_qualities_available': noQualitiesAvailableText,
      'no_subtitles_available': noSubtitlesAvailableText,
      'quality': qualityText,
      'subtitles': subtitlesText,
      'playback_speed': playbackSpeedText,
      'normal_speed': normalSpeedText,
      'auto': autoText,
      'off': offText,
      'skip_backward': skipBackwardText,
      'skip_forward': skipForwardText,
      'mini_player': miniPlayerText,
      'restore_player': restorePlayerText,
      'expand_player': expandPlayerText,
      'close_mini_player': closeMiniPlayerText,
      'play': playText,
      'pause': pauseText,
      'fullscreen': fullscreenText,
      'exit_fullscreen': exitFullscreenText,
      'live': liveText,
      'go_live': goLiveText,
      'speed_2x': speed2xText,
      'back': backText,
      'volume': volumeText,
    };
  }

  /// Map of standard translation keys to default English texts.
  /// Useful for exporting to JSON/ARB for localization packages (easy_localization, intl, etc.).
  static const Map<String, String> defaultTranslationKeys = {
    'invalid_youtube_url': 'Invalid YouTube URL',
    'video_load_failed': 'Failed to load video',
    'video_unavailable': 'Video unavailable',
    'video_not_compatible': 'Video format not compatible',
    'video_security_policy_error':
        'Video cannot be loaded due to security policy',
    'player_settings': 'Player Settings',
    'auto_play': 'Auto Play',
    'loop_video': 'Loop Video',
    'force_hd_quality': 'Force HD Quality',
    'enable_captions': 'Enable Captions',
    'mute_audio': 'Mute Audio',
    'unmute_audio': 'Unmute Audio',
    'no_qualities_available': 'No qualities available',
    'no_subtitles_available': 'No subtitles available',
    'quality': 'Quality (Resolution)',
    'subtitles': 'Subtitles',
    'playback_speed': 'Playback Speed',
    'normal_speed': 'Normal',
    'auto': 'Auto',
    'off': 'Off',
    'skip_backward': 'Rewind 10s',
    'skip_forward': 'Forward 10s',
    'mini_player': 'Miniplayer',
    'restore_player': 'Restore Player',
    'expand_player': 'Expand player',
    'close_mini_player': 'Close miniplayer',
    'play': 'Play',
    'pause': 'Pause',
    'fullscreen': 'Fullscreen',
    'exit_fullscreen': 'Exit Fullscreen',
    'live': 'LIVE',
    'go_live': 'GO LIVE',
    'speed_2x': '2x',
    'back': 'Back',
    'volume': 'Volume',
  };

  /// Factory creating dynamic localization configuration using a custom translator callback
  /// (e.g. `tr(key)` from `easy_localization`, `slang`, `intl`, etc.).
  factory PlayerTextConfig.tr(
    String Function(String key) tr, {
    String? languageCode,
    TextDirection? textDirection,
  }) {
    final cleanLang = languageCode?.trim().toLowerCase();
    final resolvedDirection = textDirection ??
        (cleanLang != null
            ? (_rtlLanguageCodes.contains(cleanLang)
                ? TextDirection.rtl
                : TextDirection.ltr)
            : null);

    String resolveKey(String key, String fallback) {
      try {
        final val = tr(key);
        return (val.isNotEmpty && val != key) ? val : fallback;
      } catch (_) {
        return fallback;
      }
    }

    const def = PlayerTextConfig();
    return PlayerTextConfig(
      languageCode: cleanLang,
      textDirection: resolvedDirection,
      invalidYoutubeUrlText:
          resolveKey('invalid_youtube_url', def.invalidYoutubeUrlText),
      videoLoadFailedText:
          resolveKey('video_load_failed', def.videoLoadFailedText),
      videoUnavailableText:
          resolveKey('video_unavailable', def.videoUnavailableText),
      videoNotCompatibleText:
          resolveKey('video_not_compatible', def.videoNotCompatibleText),
      videoCannotBeLoadedSecurityPolicyText: resolveKey(
          'video_security_policy_error',
          def.videoCannotBeLoadedSecurityPolicyText),
      playerSettingsText:
          resolveKey('player_settings', def.playerSettingsText),
      autoPlayText: resolveKey('auto_play', def.autoPlayText),
      loopVideoText: resolveKey('loop_video', def.loopVideoText),
      forceHdQualityText:
          resolveKey('force_hd_quality', def.forceHdQualityText),
      enableCaptionsText:
          resolveKey('enable_captions', def.enableCaptionsText),
      muteAudioText: resolveKey('mute_audio', def.muteAudioText),
      unmuteAudioText: resolveKey('unmute_audio', def.unmuteAudioText),
      noQualitiesAvailableText: resolveKey(
          'no_qualities_available', def.noQualitiesAvailableText),
      noSubtitlesAvailableText: resolveKey(
          'no_subtitles_available', def.noSubtitlesAvailableText),
      qualityText: resolveKey('quality', def.qualityText),
      subtitlesText: resolveKey('subtitles', def.subtitlesText),
      playbackSpeedText:
          resolveKey('playback_speed', def.playbackSpeedText),
      normalSpeedText: resolveKey('normal_speed', def.normalSpeedText),
      autoText: resolveKey('auto', def.autoText),
      offText: resolveKey('off', def.offText),
      skipBackwardText: resolveKey('skip_backward', def.skipBackwardText),
      skipForwardText: resolveKey('skip_forward', def.skipForwardText),
      miniPlayerText: resolveKey('mini_player', def.miniPlayerText),
      restorePlayerText:
          resolveKey('restore_player', def.restorePlayerText),
      expandPlayerText: resolveKey('expand_player', def.expandPlayerText),
      closeMiniPlayerText:
          resolveKey('close_mini_player', def.closeMiniPlayerText),
      playText: resolveKey('play', def.playText),
      pauseText: resolveKey('pause', def.pauseText),
      fullscreenText: resolveKey('fullscreen', def.fullscreenText),
      exitFullscreenText:
          resolveKey('exit_fullscreen', def.exitFullscreenText),
      liveText: resolveKey('live', def.liveText),
      goLiveText: resolveKey('go_live', def.goLiveText),
      speed2xText: resolveKey('speed_2x', def.speed2xText),
      backText: resolveKey('back', def.backText),
      volumeText: resolveKey('volume', def.volumeText),
    );
  }

  /// Factory creating configuration using a custom translator callback that accepts key and fallback.
  factory PlayerTextConfig.dynamic({
    required String Function(String key, String fallback) translate,
    String? languageCode,
    TextDirection? textDirection,
  }) {
    final cleanLang = languageCode?.trim().toLowerCase();
    final resolvedDirection = textDirection ??
        (cleanLang != null
            ? (_rtlLanguageCodes.contains(cleanLang)
                ? TextDirection.rtl
                : TextDirection.ltr)
            : null);

    const def = PlayerTextConfig();
    return PlayerTextConfig(
      languageCode: cleanLang,
      textDirection: resolvedDirection,
      invalidYoutubeUrlText:
          translate('invalid_youtube_url', def.invalidYoutubeUrlText),
      videoLoadFailedText:
          translate('video_load_failed', def.videoLoadFailedText),
      videoUnavailableText:
          translate('video_unavailable', def.videoUnavailableText),
      videoNotCompatibleText:
          translate('video_not_compatible', def.videoNotCompatibleText),
      videoCannotBeLoadedSecurityPolicyText: translate(
          'video_security_policy_error',
          def.videoCannotBeLoadedSecurityPolicyText),
      playerSettingsText:
          translate('player_settings', def.playerSettingsText),
      autoPlayText: translate('auto_play', def.autoPlayText),
      loopVideoText: translate('loop_video', def.loopVideoText),
      forceHdQualityText:
          translate('force_hd_quality', def.forceHdQualityText),
      enableCaptionsText:
          translate('enable_captions', def.enableCaptionsText),
      muteAudioText: translate('mute_audio', def.muteAudioText),
      unmuteAudioText: translate('unmute_audio', def.unmuteAudioText),
      noQualitiesAvailableText: translate(
          'no_qualities_available', def.noQualitiesAvailableText),
      noSubtitlesAvailableText: translate(
          'no_subtitles_available', def.noSubtitlesAvailableText),
      qualityText: translate('quality', def.qualityText),
      subtitlesText: translate('subtitles', def.subtitlesText),
      playbackSpeedText:
          translate('playback_speed', def.playbackSpeedText),
      normalSpeedText: translate('normal_speed', def.normalSpeedText),
      autoText: translate('auto', def.autoText),
      offText: translate('off', def.offText),
      skipBackwardText: translate('skip_backward', def.skipBackwardText),
      skipForwardText: translate('skip_forward', def.skipForwardText),
      miniPlayerText: translate('mini_player', def.miniPlayerText),
      restorePlayerText:
          translate('restore_player', def.restorePlayerText),
      expandPlayerText: translate('expand_player', def.expandPlayerText),
      closeMiniPlayerText:
          translate('close_mini_player', def.closeMiniPlayerText),
      playText: translate('play', def.playText),
      pauseText: translate('pause', def.pauseText),
      fullscreenText: translate('fullscreen', def.fullscreenText),
      exitFullscreenText:
          translate('exit_fullscreen', def.exitFullscreenText),
      liveText: translate('live', def.liveText),
      goLiveText: translate('go_live', def.goLiveText),
      speed2xText: translate('speed_2x', def.speed2xText),
      backText: translate('back', def.backText),
      volumeText: translate('volume', def.volumeText),
    );
  }

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

  /// Whether the configuration specifies or resolves to an RTL language/direction without BuildContext.
  bool get isRtl {
    if (textDirection == TextDirection.rtl) return true;
    if (textDirection == TextDirection.ltr) return false;
    if (RegExp(r'[\u0590-\u08FF]').hasMatch(
      '$playerSettingsText$qualityText$subtitlesText$playText$miniPlayerText',
    )) {
      return true;
    }
    if (languageCode != null && languageCode!.trim().isNotEmpty) {
      final clean = languageCode!.trim().toLowerCase();
      return _rtlLanguageCodes.contains(clean);
    }
    return false;
  }

  /// Resolves the effective text direction from explicit config, language code, ambient context, or text content.
  TextDirection resolveTextDirection(
    BuildContext context, {
    TextDirection? ambientDirection,
  }) {
    if (textDirection != null) return textDirection!;

    final ambient = ambientDirection ?? Directionality.maybeOf(context);
    if (ambient == TextDirection.rtl) return TextDirection.rtl;

    if (languageCode != null && languageCode!.trim().isNotEmpty) {
      final clean = languageCode!.trim().toLowerCase();
      return _rtlLanguageCodes.contains(clean)
          ? TextDirection.rtl
          : TextDirection.ltr;
    }
    // Check if any configured text contains Arabic/Hebrew RTL characters
    if (RegExp(r'[\u0590-\u08FF]').hasMatch(
      '$playerSettingsText$qualityText$subtitlesText$playText$miniPlayerText',
    )) {
      return TextDirection.rtl;
    }
    final localeCode = Localizations.maybeLocaleOf(context)?.languageCode;
    if (localeCode != null && localeCode.trim().isNotEmpty) {
      final clean = localeCode.trim().toLowerCase();
      if (_rtlLanguageCodes.contains(clean)) {
        return TextDirection.rtl;
      }
    }
    if (ambient != null) return ambient;
    return TextDirection.ltr;
  }

  /// Resolves the effective ISO language code for any language configured by the user.
  String resolveLanguageCode(
    BuildContext context, {
    TextDirection? ambientDirection,
  }) {
    if (languageCode != null && languageCode!.trim().isNotEmpty) {
      return languageCode!.trim().toLowerCase();
    }
    final ambient = ambientDirection ?? Directionality.maybeOf(context);
    if (ambient == TextDirection.rtl) {
      return 'ar';
    }
    final localeCode = Localizations.maybeLocaleOf(context)?.languageCode;
    if (localeCode != null && localeCode.trim().isNotEmpty) {
      return localeCode.trim().toLowerCase();
    }
    return resolveTextDirection(context, ambientDirection: ambientDirection) ==
            TextDirection.rtl
        ? 'ar'
        : 'en';
  }

  /// Whether this configuration uses the default untouched constructor values.
  bool get isDefaultUnmodified {
    const def = PlayerTextConfig();
    return (languageCode == null || languageCode == 'en') &&
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
    String? unmuteAudioText,
    String? noQualitiesAvailableText,
    String? noSubtitlesAvailableText,
    String? qualityText,
    String? subtitlesText,
    String? playbackSpeedText,
    String? normalSpeedText,
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
    String? backText,
    String? volumeText,
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
      unmuteAudioText: unmuteAudioText ?? this.unmuteAudioText,
      noQualitiesAvailableText:
          noQualitiesAvailableText ?? this.noQualitiesAvailableText,
      noSubtitlesAvailableText:
          noSubtitlesAvailableText ?? this.noSubtitlesAvailableText,
      qualityText: qualityText ?? this.qualityText,
      subtitlesText: subtitlesText ?? this.subtitlesText,
      playbackSpeedText: playbackSpeedText ?? this.playbackSpeedText,
      normalSpeedText: normalSpeedText ?? this.normalSpeedText,
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
      backText: backText ?? this.backText,
      volumeText: volumeText ?? this.volumeText,
    );
  }
}
