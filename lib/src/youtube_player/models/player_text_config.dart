import 'package:flutter/widgets.dart';

/// Configuration model for player localization, text labels, and error messages (SRP).
/// All UI labels in the package are driven dynamically by this configuration
/// so developers can provide any language, text direction, or wording they want.
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
    this.unmuteAudioText = 'إلغاء كتم الصوت',
    this.noQualitiesAvailableText = 'لا توجد جودات متاحة',
    this.noSubtitlesAvailableText = 'لا توجد ترجمات متاحة',
    this.qualityText = 'الجودة (الدقة)',
    this.subtitlesText = 'الترجمة',
    this.playbackSpeedText = 'سرعة التشغيل',
    this.normalSpeedText = 'عادي',
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
    this.backText = 'رجوع',
    this.volumeText = 'مستوى الصوت',
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

  /// Spanish (Español - LTR) localization preset
  const PlayerTextConfig.spanish({
    this.languageCode = 'es',
    this.textDirection = TextDirection.ltr,
    this.invalidYoutubeUrlText = 'URL de YouTube no válida',
    this.videoLoadFailedText = 'Error al cargar el vídeo',
    this.videoUnavailableText = 'Vídeo no disponible',
    this.videoNotCompatibleText = 'Formato de vídeo no compatible',
    this.videoCannotBeLoadedSecurityPolicyText =
        'No se puede cargar el vídeo debido a la política de seguridad',
    this.playerSettingsText = 'Ajustes del reproductor',
    this.autoPlayText = 'Reproducción automática',
    this.loopVideoText = 'Repetir vídeo',
    this.forceHdQualityText = 'Forzar calidad HD',
    this.enableCaptionsText = 'Activar subtítulos',
    this.muteAudioText = 'Silenciar audio',
    this.unmuteAudioText = 'Activar audio',
    this.noQualitiesAvailableText = 'No hay calidades disponibles',
    this.noSubtitlesAvailableText = 'No hay subtítulos disponibles',
    this.qualityText = 'Calidad (Resolución)',
    this.subtitlesText = 'Subtítulos',
    this.playbackSpeedText = 'Velocidad de reproducción',
    this.normalSpeedText = 'Normal',
    this.autoText = 'Automático',
    this.offText = 'Desactivado',
    this.skipBackwardText = 'Retroceder 10s',
    this.skipForwardText = 'Avanzar 10s',
    this.miniPlayerText = 'Minirreproductor',
    this.restorePlayerText = 'Restaurar reproductor',
    this.expandPlayerText = 'Expandir reproductor',
    this.closeMiniPlayerText = 'Cerrar minirreproductor',
    this.playText = 'Reproducir',
    this.pauseText = 'Pausar',
    this.fullscreenText = 'Pantalla completa',
    this.exitFullscreenText = 'Salir de pantalla completa',
    this.liveText = 'EN DIRECTO',
    this.goLiveText = 'IR AL DIRECTO',
    this.speed2xText = '2x',
    this.backText = 'Atrás',
    this.volumeText = 'Volumen',
  });

  /// French (Français - LTR) localization preset
  const PlayerTextConfig.french({
    this.languageCode = 'fr',
    this.textDirection = TextDirection.ltr,
    this.invalidYoutubeUrlText = 'URL YouTube non valide',
    this.videoLoadFailedText = 'Échec du chargement de la vidéo',
    this.videoUnavailableText = 'Vidéo non disponible',
    this.videoNotCompatibleText = 'Format vidéo non compatible',
    this.videoCannotBeLoadedSecurityPolicyText =
        'La vidéo ne peut pas être chargée en raison de la politique de sécurité',
    this.playerSettingsText = 'Paramètres du lecteur',
    this.autoPlayText = 'Lecture automatique',
    this.loopVideoText = 'Répéter la vidéo',
    this.forceHdQualityText = 'Forcer la qualité HD',
    this.enableCaptionsText = 'Activer les sous-titres',
    this.muteAudioText = 'Couper le son',
    this.unmuteAudioText = 'Rétablir le son',
    this.noQualitiesAvailableText = 'Aucune qualité disponible',
    this.noSubtitlesAvailableText = 'Aucun sous-titre disponible',
    this.qualityText = 'Qualité (Résolution)',
    this.subtitlesText = 'Sous-titres',
    this.playbackSpeedText = 'Vitesse de lecture',
    this.normalSpeedText = 'Normal',
    this.autoText = 'Automatique',
    this.offText = 'Désactivé',
    this.skipBackwardText = 'Reculer de 10s',
    this.skipForwardText = 'Avancer de 10s',
    this.miniPlayerText = 'Mini-lecteur',
    this.restorePlayerText = 'Restaurer le lecteur',
    this.expandPlayerText = 'Agrandir le lecteur',
    this.closeMiniPlayerText = 'Fermer le mini-lecteur',
    this.playText = 'Lire',
    this.pauseText = 'Pause',
    this.fullscreenText = 'Plein écran',
    this.exitFullscreenText = 'Quitter le plein écran',
    this.liveText = 'EN DIRECT',
    this.goLiveText = 'PASSER AU DIRECT',
    this.speed2xText = '2x',
    this.backText = 'Retour',
    this.volumeText = 'Volume',
  });

  /// German (Deutsch - LTR) localization preset
  const PlayerTextConfig.german({
    this.languageCode = 'de',
    this.textDirection = TextDirection.ltr,
    this.invalidYoutubeUrlText = 'Ungültige YouTube-URL',
    this.videoLoadFailedText = 'Fehler beim Laden des Videos',
    this.videoUnavailableText = 'Video nicht verfügbar',
    this.videoNotCompatibleText = 'Videoformat nicht kompatibel',
    this.videoCannotBeLoadedSecurityPolicyText =
        'Video kann aufgrund von Sicherheitsrichtlinien nicht geladen werden',
    this.playerSettingsText = 'Player-Einstellungen',
    this.autoPlayText = 'Automatische Wiedergabe',
    this.loopVideoText = 'Video wiederholen',
    this.forceHdQualityText = 'HD-Qualität erzwingen',
    this.enableCaptionsText = 'Untertitel aktivieren',
    this.muteAudioText = 'Stummschalten',
    this.unmuteAudioText = 'Stummschaltung aufheben',
    this.noQualitiesAvailableText = 'Keine Qualitäten verfügbar',
    this.noSubtitlesAvailableText = 'Keine Untertitel verfügbar',
    this.qualityText = 'Qualität (Auflösung)',
    this.subtitlesText = 'Untertitel',
    this.playbackSpeedText = 'Wiedergabegeschwindigkeit',
    this.normalSpeedText = 'Normal',
    this.autoText = 'Automatisch',
    this.offText = 'Aus',
    this.skipBackwardText = '10s zurück',
    this.skipForwardText = '10s vor',
    this.miniPlayerText = 'Miniplayer',
    this.restorePlayerText = 'Player wiederherstellen',
    this.expandPlayerText = 'Player vergrößern',
    this.closeMiniPlayerText = 'Miniplayer schließen',
    this.playText = 'Wiedergabe',
    this.pauseText = 'Pause',
    this.fullscreenText = 'Vollbild',
    this.exitFullscreenText = 'Vollbild beenden',
    this.liveText = 'LIVE',
    this.goLiveText = 'ZUM LIVE-STREAM',
    this.speed2xText = '2x',
    this.backText = 'Zurück',
    this.volumeText = 'Lautstärke',
  });

  /// Turkish (Türkçe - LTR) localization preset
  const PlayerTextConfig.turkish({
    this.languageCode = 'tr',
    this.textDirection = TextDirection.ltr,
    this.invalidYoutubeUrlText = 'Geçersiz YouTube URL\'si',
    this.videoLoadFailedText = 'Video yüklenemedi',
    this.videoUnavailableText = 'Video kullanılamıyor',
    this.videoNotCompatibleText = 'Video formatı uyumlu değil',
    this.videoCannotBeLoadedSecurityPolicyText =
        'Güvenlik politikası nedeniyle video yüklenemiyor',
    this.playerSettingsText = 'Oynatıcı Ayarları',
    this.autoPlayText = 'Otomatik Oynat',
    this.loopVideoText = 'Videoyu Döngüye Al',
    this.forceHdQualityText = 'HD Kaliteye Zorla',
    this.enableCaptionsText = 'Altyazıları Aç',
    this.muteAudioText = 'Sesi Kapat',
    this.unmuteAudioText = 'Sesi Aç',
    this.noQualitiesAvailableText = 'Kullanılabilir kalite yok',
    this.noSubtitlesAvailableText = 'Kullanılabilir altyazı yok',
    this.qualityText = 'Kalite (Çözünürlük)',
    this.subtitlesText = 'Altyazılar',
    this.playbackSpeedText = 'Oynatma Hızı',
    this.normalSpeedText = 'Normal',
    this.autoText = 'Otomatik',
    this.offText = 'Kapalı',
    this.skipBackwardText = '10 sn geri sar',
    this.skipForwardText = '10 sn ileri sar',
    this.miniPlayerText = 'Mini Oynatıcı',
    this.restorePlayerText = 'Oynatıcıyı Geri Yükle',
    this.expandPlayerText = 'Oynatıcıyı Genişlet',
    this.closeMiniPlayerText = 'Mini Oynatıcıyı Kapat',
    this.playText = 'Oynat',
    this.pauseText = 'Duraklat',
    this.fullscreenText = 'Tam Ekran',
    this.exitFullscreenText = 'Tam Ekrandan Çık',
    this.liveText = 'CANLI',
    this.goLiveText = 'CANLI YAYINA GEÇ',
    this.speed2xText = '2x',
    this.backText = 'Geri',
    this.volumeText = 'Ses Seviyesi',
  });

  /// Factory creating language configuration dynamically from ISO language code.
  factory PlayerTextConfig.fromLanguageCode(String? code) {
    if (code == null) return const PlayerTextConfig.english();
    final clean = code.trim().toLowerCase();
    switch (clean) {
      case 'ar':
        return const PlayerTextConfig.arabic();
      case 'es':
        return const PlayerTextConfig.spanish();
      case 'fr':
        return const PlayerTextConfig.french();
      case 'de':
        return const PlayerTextConfig.german();
      case 'tr':
        return const PlayerTextConfig.turkish();
      default:
        if (_rtlLanguageCodes.contains(clean)) {
          return PlayerTextConfig.arabic(languageCode: clean);
        }
        return PlayerTextConfig.english(languageCode: clean);
    }
  }

  /// Factory creating configuration dynamically matching a Flutter [Locale].
  factory PlayerTextConfig.forLocale(Locale locale) {
    return PlayerTextConfig.fromLanguageCode(locale.languageCode);
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
  ///
  /// Any language can be dynamically created.
  /// Text direction automatically resolves to RTL for Arabic ('ar') and RTL scripts,
  /// and to LTR (same direction as English) for all other languages.
  ///
  /// Example:
  /// ```dart
  /// PlayerTextConfig.tr(
  ///   (key) => tr(key),
  ///   languageCode: context.locale.languageCode,
  /// )
  /// ```
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
    if (languageCode != null && languageCode!.trim().isNotEmpty) {
      final clean = languageCode!.trim().toLowerCase();
      return _rtlLanguageCodes.contains(clean);
    }
    const arabicConfig = PlayerTextConfig.arabic();
    if (qualityText == arabicConfig.qualityText ||
        playerSettingsText == arabicConfig.playerSettingsText ||
        subtitlesText == arabicConfig.subtitlesText ||
        playText == arabicConfig.playText) {
      return true;
    }
    return RegExp(r'[\u0590-\u08FF]').hasMatch(
      '$playerSettingsText$qualityText$subtitlesText$playText$miniPlayerText',
    );
  }

  /// Resolves the effective text direction from explicit config, language code, ambient context, or text content.
  ///
  /// Only Arabic ('ar') and related RTL scripts resolve to RTL.
  /// All other languages resolve to LTR (same direction as English).
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
    const arabicConfig = PlayerTextConfig.arabic();
    if (qualityText == arabicConfig.qualityText ||
        playerSettingsText == arabicConfig.playerSettingsText ||
        subtitlesText == arabicConfig.subtitlesText ||
        playText == arabicConfig.playText) {
      return TextDirection.rtl;
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
