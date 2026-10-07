/// Centralized constants for Native JavaScript interop used in YouTube WebView integrations.
///
/// Follows Clean Architecture, OOP, and the Single Responsibility Principle (SRP)
/// by keeping raw JavaScript scripts, commands, handler names, and event strings
/// decoupled from Flutter presentation widgets.
library;

/// JavaScript handler name and event keys for YouTube WebView interop.
class YouTubeJsHandler {
  const YouTubeJsHandler._();

  /// Channel handler name registered with `addJavaScriptHandler`.
  static const String handlerName = 'YouTubePlayerHandler';

  // Events dispatched from JavaScript to Flutter
  static const String onReady = 'onReady';
  static const String onTimeUpdate = 'onTimeUpdate';
  static const String onStateChange = 'onStateChange';
  static const String onError = 'onError';
  static const String onEnterFullscreen = 'onEnterFullscreen';
  static const String onExitFullscreen = 'onExitFullscreen';
  static const String onEscapeKey = 'onEscapeKey';
  static const String onSeekForward = 'onSeekForward';
  static const String onSeekBackward = 'onSeekBackward';
  static const String onToggleFullscreen = 'onToggleFullscreen';
  static const String onTouchActivity = 'onTouchActivity';
  static const String onControlsVisibilityChanged =
      'onControlsVisibilityChanged';
}

/// Executable JavaScript commands and queries evaluated against the WebView.
class YouTubeJsCommands {
  const YouTubeJsCommands._();

  /// JavaScript command to start video playback.
  static const String playVideo = 'playVideo();';

  /// JavaScript command to pause video playback.
  static const String pauseVideo = 'pauseVideo();';

  /// JavaScript command to mute audio.
  static const String muteVideo = 'muteVideo();';

  /// JavaScript command to unmute audio.
  static const String unMuteVideo = 'unMuteVideo();';

  /// JavaScript snippet to exit HTML5 fullscreen mode safely.
  static const String exitFullscreen =
      'if (document.fullscreenElement) { document.exitFullscreen(); } '
      'else if (document.webkitFullscreenElement) { document.webkitExitFullscreen(); }';

  /// JavaScript expression to query the current playback position in seconds.
  static const String getCurrentTime =
      "player && typeof player.getCurrentTime === 'function' ? Math.round(player.getCurrentTime()) : 0;";

  /// JavaScript expression to query whether the player is currently in playing or buffering state.
  static const String isPlaying =
      "player && typeof player.getPlayerState === 'function' ? (player.getPlayerState() === 1 || player.getPlayerState() === 3) : false;";

  /// Generates JavaScript command to seek to a given [seconds] mark.
  static String seekTo(int seconds) => 'seekTo($seconds);';

  /// Generates JavaScript command to set playback speed.
  static String setPlaybackRate(double rate) =>
      'if (player && typeof player.setPlaybackRate === "function") { player.setPlaybackRate($rate); }';

  /// Generates JavaScript command to sync player language and layout direction.
  static String setLanguage(String lang, String dir) =>
      "setLanguage('$lang', '$dir');";

  /// Generates JavaScript command to initialize the player once the host page is loaded.
  static String initPlayer({
    required String videoId,
    required int autoPlay,
    required int mute,
    required int startAt,
    required String lang,
    required String dir,
  }) {
    return "initPlayer('$videoId', $autoPlay, $mute, $startAt, '$lang', '$dir');";
  }
}

/// Pre-bundled JavaScript user scripts and permission definitions for YouTube WebView.
class YouTubeJsScripts {
  const YouTubeJsScripts._();

  /// Standard desktop Chrome User-Agent string used for Desktop player rendering.
  static const String desktopUserAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36';

  /// Permissions allowed for embedded iframe elements.
  static const String iframeAllowPermissions =
      'camera; microphone; playing; fullscreen; autoplay; encrypted-media; gyroscope; accelerometer; clipboard-write';

  /// Full injected client script that strips unwanted YouTube chrome, suppresses OS PiP,
  /// observes controls visibility, and bridges touch/pointer activity back to Flutter.
  static const String injectedPlayerScript = r"""
(function() {
  function updatePlayerStyles() {
    try {
      var vids = document.querySelectorAll('video');
      for (var i = 0; i < vids.length; i++) {
        var v = vids[i];
        v.disablePictureInPicture = true;
        v.setAttribute('disablePictureInPicture', '');
        var cl = v.getAttribute('controlsList') || '';
        if (cl.indexOf('nopip') === -1) {
          v.setAttribute('controlsList', (cl + ' nopip').trim());
        }
      }

      var isRtl = false;
      try {
        var doc = document.documentElement;
        var lang = (doc && (doc.getAttribute('lang') || doc.lang)) || '';
        var dir = (doc && (doc.getAttribute('dir') || doc.dir)) || '';
        var loc = window.location ? (window.location.search || window.location.href || '') : '';
        if (dir === 'rtl' || lang.toLowerCase().indexOf('ar') === 0 || loc.indexOf('hl=ar') !== -1) {
          isRtl = true;
        } else {
          try {
            if (window.parent && window.parent !== window && window.parent.document) {
              var pDoc = window.parent.document.documentElement;
              if (pDoc && (pDoc.dir === 'rtl' || (pDoc.lang && pDoc.lang.toLowerCase().indexOf('ar') === 0))) {
                isRtl = true;
              }
            }
          } catch (_) {}
        }
      } catch (_) {}

      var styleId = 'yt-custom-injected-style';
      var existing = document.getElementById(styleId);
      var css = '.ytp-fullscreen-button, .ytp-share-button, .ytp-watch-later-button, .ytp-copylink-button, .ytp-copy-link-button, .ytp-button-copylink, .ytp-overflow-button, .ytp-share-panel-link, .ytp-share-icon, .ytp-share-panel, [class*="copylink" i], [class*="copy-link" i], [class*="ytp-share" i], [class*="share-button" i], [data-tooltip-target-id*="copy" i], [data-tooltip-target-id*="share" i], [data-tooltip-target-id*="link" i], [data-title-no-tooltip*="copy" i], [data-title-no-tooltip*="share" i], [data-title-no-tooltip*="link" i], [data-title-no-tooltip*="نسخ" i], [data-title-no-tooltip*="رابط" i], [data-title-no-tooltip*="مشاركة" i], button[aria-label*="copy" i], button[aria-label*="link" i], button[aria-label*="share" i], button[aria-label*="نسخ" i], button[aria-label*="رابط" i], button[aria-label*="مشاركة" i], button[title*="copy" i], button[title*="link" i], button[title*="share" i], button[title*="نسخ" i], button[title*="رابط" i], button[title*="مشاركة" i], a[aria-label*="copy" i], a[aria-label*="link" i], a[aria-label*="share" i], a[aria-label*="نسخ" i], a[aria-label*="رابط" i], a[aria-label*="مشاركة" i], a[title*="copy" i], a[title*="link" i], a[title*="share" i], a[title*="نسخ" i], a[title*="رابط" i], a[title*="مشاركة" i] { display: none !important; opacity: 0 !important; visibility: hidden !important; pointer-events: none !important; width: 0 !important; height: 0 !important; min-width: 0 !important; max-width: 0 !important; padding: 0 !important; margin: 0 !important; }';

      var nodes = document.querySelectorAll('button, a, div[role="button"], [role="button"], .ytp-button');
      for (var b = 0; b < nodes.length; b++) {
        var n = nodes[b];
        var rawHtml = '';
        try { rawHtml = (n.outerHTML || '').toLowerCase(); } catch(_) {}
        var label = ((n.getAttribute('aria-label') || '') + ' ' + (n.getAttribute('title') || '') + ' ' + (n.getAttribute('data-tooltip-target-id') || '') + ' ' + (n.getAttribute('data-title-no-tooltip') || '') + ' ' + (typeof n.className === 'string' ? n.className : '')).toLowerCase();
        var shouldHide = (
          label.indexOf('share') !== -1 ||
          label.indexOf('copy') !== -1 ||
          label.indexOf('link') !== -1 ||
          label.indexOf('نسخ') !== -1 ||
          label.indexOf('رابط') !== -1 ||
          label.indexOf('مشاركة') !== -1 ||
          label.indexOf('watch later') !== -1 ||
          label.indexOf('full screen') !== -1 ||
          label.indexOf('fullscreen') !== -1 ||
          rawHtml.indexOf('copylink') !== -1 ||
          rawHtml.indexOf('copy-link') !== -1 ||
          rawHtml.indexOf('share-button') !== -1 ||
          rawHtml.indexOf('aria-label="copy') !== -1 ||
          rawHtml.indexOf('title="copy') !== -1 ||
          rawHtml.indexOf('نسخ') !== -1 ||
          rawHtml.indexOf('رابط') !== -1
        );

        if (!shouldHide) {
          var svgs = n.querySelectorAll('svg, path, title, use');
          for (var s = 0; s < svgs.length; s++) {
            var sTxt = ((svgs[s].getAttribute('aria-label') || '') + ' ' + (svgs[s].getAttribute('title') || '') + ' ' + (svgs[s].textContent || '')).toLowerCase();
            if (
              sTxt.indexOf('share') !== -1 ||
              sTxt.indexOf('copy') !== -1 ||
              sTxt.indexOf('link') !== -1 ||
              sTxt.indexOf('نسخ') !== -1 ||
              sTxt.indexOf('رابط') !== -1 ||
              sTxt.indexOf('مشاركة') !== -1
            ) {
              shouldHide = true;
              break;
            }
          }
        }

        if (shouldHide) {
          n.style.setProperty('display', 'none', 'important');
          n.style.setProperty('opacity', '0', 'important');
          n.style.setProperty('visibility', 'hidden', 'important');
          n.style.setProperty('pointer-events', 'none', 'important');
          n.style.setProperty('width', '0', 'important');
          n.style.setProperty('height', '0', 'important');
        }
      }

      var leftControls = document.querySelectorAll('.ytp-left-controls button, .ytp-left-controls a, .ytp-left-controls [role="button"], .ytp-left-controls .ytp-button');
      for (var l = 0; l < leftControls.length; l++) {
        var item = leftControls[l];
        var isEssential = item.classList.contains('ytp-play-button') ||
                          item.classList.contains('ytp-mute-button') ||
                          item.classList.contains('ytp-volume-area') ||
                          item.classList.contains('ytp-time-display') ||
                          item.classList.contains('ytp-live-badge');
        if (!isEssential) {
          item.style.setProperty('display', 'none', 'important');
          item.style.setProperty('opacity', '0', 'important');
          item.style.setProperty('visibility', 'hidden', 'important');
          item.style.setProperty('pointer-events', 'none', 'important');
          item.style.setProperty('width', '0', 'important');
          item.style.setProperty('height', '0', 'important');
        }
      }

      if (isRtl) {
        css += ' .ytp-progress-bar-container, .ytp-progress-bar { transform: scaleX(-1) !important; }';
      }

      if (!existing) {
        var st = document.createElement('style');
        st.id = styleId;
        st.innerHTML = css;
        (document.head || document.documentElement).appendChild(st);
      } else if (existing.innerHTML !== css) {
        existing.innerHTML = css;
      }
    } catch(e) {}
  }
  updatePlayerStyles();
  if (window.MutationObserver) {
    new MutationObserver(updatePlayerStyles).observe(document.documentElement || document.body, {
      childList: true,
      subtree: true
    });
  }
  window.addEventListener('load', updatePlayerStyles);
  setInterval(updatePlayerStyles, 600);

  try {
    var lastActivityTime = 0;
    function sendToFlutter(payload) {
      try {
        if (window.flutter_inappwebview) {
          window.flutter_inappwebview.callHandler('YouTubePlayerHandler', payload);
        }
      } catch(e) {}
      try {
        if (window.parent && window.parent !== window) {
          window.parent.postMessage({ type: 'YouTubePlayerHandler', ...payload }, '*');
        }
      } catch(e) {}
    }
    function onUserTouchActivity() {
      sendToFlutter({ 'event': 'onTouchActivity' });
    }
    function onUserMoveActivity() {
      var now = Date.now();
      if (now - lastActivityTime > 200) {
        lastActivityTime = now;
        onUserTouchActivity();
        checkControlsVisibility();
      }
    }
    window.addEventListener('touchstart', onUserTouchActivity, { passive: true, capture: true });
    window.addEventListener('pointerdown', onUserTouchActivity, { passive: true, capture: true });
    window.addEventListener('click', onUserTouchActivity, { passive: true, capture: true });
    window.addEventListener('mousemove', onUserMoveActivity, { passive: true, capture: true });
    window.addEventListener('pointermove', onUserMoveActivity, { passive: true, capture: true });

    var lastVisibility = null;
    function checkControlsVisibility() {
      try {
        var player = document.querySelector('.html5-video-player') || document.getElementById('movie_player');
        if (player) {
          var isVisible = !player.classList.contains('ytp-autohide');
          if (lastVisibility !== isVisible) {
            lastVisibility = isVisible;
            sendToFlutter({
              'event': 'onControlsVisibilityChanged',
              'visible': isVisible
            });
          }
        }
      } catch(e) {}
    }

    if (window.MutationObserver) {
      var obs = new MutationObserver(checkControlsVisibility);
      function attachPlayerObserver() {
        var player = document.querySelector('.html5-video-player') || document.getElementById('movie_player');
        if (player) {
          obs.observe(player, { attributes: true, attributeFilter: ['class'] });
          checkControlsVisibility();
        } else {
          setTimeout(attachPlayerObserver, 300);
        }
      }
      attachPlayerObserver();
      setInterval(checkControlsVisibility, 150);
    }
  } catch(e) {}
})();
""";
}
