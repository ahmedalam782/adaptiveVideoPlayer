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
  static const String onOpenPip = 'onOpenPip';
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
    int? controls,
  }) {
    if (controls != null) {
      return "initPlayer('$videoId', $autoPlay, $mute, $startAt, '$lang', '$dir', $controls);";
    }
    return "initPlayer('$videoId', $autoPlay, $mute, $startAt, '$lang', '$dir');";
  }

  /// Shows or hides the YouTube Picture-in-Picture button on the host page.
  static String setShowMiniPlayer(bool show) =>
      'if (typeof setShowMiniPlayer === "function") { setShowMiniPlayer(${show ? 'true' : 'false'}); }';

  /// Phone and tablet place the button from the fullscreen control.
  /// Desktop keeps the fixed corner offset.
  static String setPipButtonCompact(bool compact) =>
      'if (typeof setPipButtonCompact === "function") { setPipButtonCompact(${compact ? 'true' : 'false'}); }';

  /// Asks the already-playing YouTube video, including inside the embed iframe,
  /// to enter Picture-in-Picture without loading a second player.
  static const String enterPictureInPicture = r"""
(function() {
  function forward(win) {
    try { win.postMessage({ type: 'adaptive-enter-pip' }, '*'); } catch (e) {}
  }
  forward(window);
  var frames = document.querySelectorAll('iframe');
  for (var i = 0; i < frames.length; i++) {
    try { forward(frames[i].contentWindow); } catch (e) {}
  }
})();
""";
}

/// Pre-bundled JavaScript user scripts and permission definitions for YouTube WebView.
class YouTubeJsScripts {
  const YouTubeJsScripts._();

  /// Standard desktop Chrome User-Agent string used for Desktop player rendering.
  static const String desktopUserAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36';

  /// Permissions allowed for embedded iframe elements.
  static const String iframeAllowPermissions =
      'camera; microphone; playing; fullscreen; autoplay; encrypted-media; gyroscope; accelerometer; clipboard-write; picture-in-picture';

  /// Full injected client script that strips unwanted YouTube chrome.
  ///
  /// On iOS the embedded video stays eligible for Picture-in-Picture. Other
  /// platforms keep the system PiP control hidden. The script also observes
  /// controls visibility and bridges touch activity back to Flutter.
  static const String injectedPlayerScript = r"""
(function() {
  var isIOSWebKit = /iPad|iPhone|iPod/.test(navigator.userAgent) ||
    (navigator.platform === 'MacIntel' && navigator.maxTouchPoints > 1);

  function enterVideoPip(video) {
    try {
      video.disablePictureInPicture = false;
      video.removeAttribute('disablePictureInPicture');
      var controls = video.getAttribute('controlsList') || '';
      video.setAttribute('controlsList', controls.replace(/\bnopip\b/g, '').replace(/\s+/g, ' ').trim());
      if (typeof video.webkitSetPresentationMode === 'function') {
        if (video.webkitPresentationMode !== 'picture-in-picture') {
          video.webkitSetPresentationMode('picture-in-picture');
        }
        return true;
      }
      if (document.pictureInPictureElement !== video &&
          typeof video.requestPictureInPicture === 'function') {
        video.requestPictureInPicture();
        return true;
      }
    } catch (e) {}
    return false;
  }

  function isEmbedPlayerDocument() {
    try {
      var host = String(location.hostname || '').toLowerCase();
      var path = String(location.pathname || '');
      if (host === '127.0.0.1' || host === 'localhost') return true;
      return path.indexOf('/embed') !== -1;
    } catch (e) {
      return false;
    }
  }

  window.addEventListener('message', function(event) {
    var data = event.data;
    if (!data || data.type !== 'adaptive-enter-pip') return;
    var videos = document.querySelectorAll('video');
    for (var i = 0; i < videos.length; i++) {
      enterVideoPip(videos[i]);
    }
    var frames = document.querySelectorAll('iframe');
    for (var f = 0; f < frames.length; f++) {
      try {
        frames[f].contentWindow.postMessage({ type: 'adaptive-enter-pip' }, '*');
      } catch (e) {}
    }
  });

  function updatePlayerStyles() {
    try {
      var vids = document.querySelectorAll('video');
      for (var i = 0; i < vids.length; i++) {
        var v = vids[i];
        if (isIOSWebKit) {
          v.disablePictureInPicture = false;
          v.removeAttribute('disablePictureInPicture');
          continue;
        }
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
      var css = '.ytp-autonav-toggle-button, .ytp-autonav-toggle-button-container, .ytp-autonav-endscreen-button-container, [class*="autonav" i], button[aria-label*="autoplay" i], button[aria-label*="تشغيل تلقائي" i], button[title*="autoplay" i], button[title*="تشغيل تلقائي" i], .ytp-volume-slider, .ytp-volume-slider-handle { display: none !important; opacity: 0 !important; visibility: hidden !important; pointer-events: none !important; width: 0 !important; height: 0 !important; }';

      var nodes = document.querySelectorAll('button, a, div[role="button"], [role="button"], .ytp-button');
      for (var b = 0; b < nodes.length; b++) {
        var n = nodes[b];
        var rawHtml = '';
        try { rawHtml = (n.outerHTML || '').toLowerCase(); } catch(_) {}
        var label = ((n.getAttribute('aria-label') || '') + ' ' + (n.getAttribute('title') || '') + ' ' + (n.getAttribute('data-tooltip-target-id') || '') + ' ' + (n.getAttribute('data-title-no-tooltip') || '') + ' ' + (typeof n.className === 'string' ? n.className : '')).toLowerCase();
        var shouldHide = (
          label.indexOf('autonav') !== -1 ||
          label.indexOf('autoplay') !== -1 ||
          label.indexOf('تشغيل تلقائي') !== -1 ||
          rawHtml.indexOf('autonav') !== -1
        );

        if (shouldHide) {
          n.style.setProperty('display', 'none', 'important');
          n.style.setProperty('opacity', '0', 'important');
          n.style.setProperty('visibility', 'hidden', 'important');
          n.style.setProperty('pointer-events', 'none', 'important');
          n.style.setProperty('width', '0', 'important');
          n.style.setProperty('height', '0', 'important');
        }
      }

      if (isRtl) {
        css += ' .ytp-progress-bar-container, .ytp-progress-bar { transform: scaleX(-1) !important; }';
      }

      if (!existing) {
        var st = document.createElement('style');
        st.id = styleId;
        st.textContent = css;
        (document.head || document.documentElement).appendChild(st);
      } else if (existing.textContent !== css) {
        existing.textContent = css;
      }
    } catch(e) {}
  }
  if (!isEmbedPlayerDocument()) return;
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
    var lastFullscreenNotify = 0;
    function sendToFlutter(payload) {
      var message = { type: 'YouTubePlayerHandler' };
      try {
        var keys = Object.keys(payload || {});
        for (var k = 0; k < keys.length; k++) message[keys[k]] = payload[keys[k]];
      } catch(e) {}
      try {
        if (window.flutter_inappwebview) {
          window.flutter_inappwebview.callHandler('YouTubePlayerHandler', message);
        }
      } catch(e) {}
      try {
        if (window.parent && window.parent !== window) window.parent.postMessage(message, '*');
      } catch(e) {}
      try {
        if (window.top && window.top !== window && window.top !== window.parent) window.top.postMessage(message, '*');
      } catch(e) {}
    }
    function notifyFullscreenToggle() {
      var now = Date.now();
      if (now - lastFullscreenNotify < 500) return;
      lastFullscreenNotify = now;
      sendToFlutter({ 'event': 'onToggleFullscreen' });
    }
    function ensurePipButton() {
      try {
        var host = String(location.hostname || '').toLowerCase();
        if (host === '127.0.0.1' || host === 'localhost') return;
        var fs = null;
        var bestScore = -1;
        var nodes = document.querySelectorAll('button, [role="button"], .ytp-fullscreen-button');
        for (var i = 0; i < nodes.length; i++) {
          if (!isFullscreenControl(nodes[i])) continue;
          var box = nodes[i].getBoundingClientRect();
          if (box.width < 8 || box.height < 8 || box.width > 80 || box.height > 80) continue;
          var style = window.getComputedStyle(nodes[i]);
          if (style.display === 'none' || style.visibility === 'hidden' || parseFloat(style.opacity || '1') < 0.05) continue;
          var score = box.right + box.bottom;
          if (score > bestScore) {
            fs = nodes[i];
            bestScore = score;
          }
        }
        if (!fs) return;
        var rect = fs.getBoundingClientRect();
        var visible = true;
        var rtl = false;
        try { rtl = (document.documentElement.dir || '') === 'rtl'; } catch (e) {}
        var anchor = {
          type: 'adaptive-pip-anchor',
          top: rect.top,
          left: rect.left,
          width: rect.width,
          height: rect.height,
          visible: visible,
          rtl: rtl
        };
        try {
          if (window.parent && window.parent !== window) window.parent.postMessage(anchor, '*');
        } catch (e) {}
        try {
          if (window.top && window.top !== window && window.top !== window.parent) window.top.postMessage(anchor, '*');
        } catch (e) {}
        if (btn && btn.ownerDocument === document) {
          btn.style.setProperty('display', 'none', 'important');
        }
      } catch (e) {}
    }
    function isFullscreenControl(el) {
      if (!el || el.nodeType !== 1) return false;
      var tag = String(el.tagName || '').toLowerCase();
      var role = '';
      try { role = el.getAttribute('role') || ''; } catch (e) {}
      var cls = '';
      try {
        cls = (el.className && el.className.baseVal) || el.className || '';
        if (typeof cls !== 'string') cls = '';
      } catch(e) { cls = ''; }
      cls = String(cls).toLowerCase();
      var isButton = tag === 'button' || role === 'button' || cls.indexOf('fullscreen-button') !== -1;
      if (!isButton) return false;
      var label = '';
      try {
        label = ((el.getAttribute('aria-label') || '') + ' ' + (el.getAttribute('title') || '') + ' ' + (el.getAttribute('data-title-no-tooltip') || '') + ' ' + (el.getAttribute('data-tooltip-target-id') || '') + ' ' + (el.getAttribute('aria-keyshortcuts') || '')).toLowerCase();
      } catch(e) {}
      return cls.indexOf('ytp-fullscreen') !== -1 ||
        cls.indexOf('fullscreen-button') !== -1 ||
        label.indexOf('full screen') !== -1 ||
        label.indexOf('fullscreen') !== -1 ||
        label.indexOf('exit full') !== -1 ||
        label === 'f' ||
        label.indexOf('ملء') !== -1 ||
        label.indexOf('شاشة كاملة') !== -1;
    }
    function eventHitsFullscreen(e) {
      var path = [];
      try { path = e.composedPath ? e.composedPath() : []; } catch(err) {}
      if (!path || !path.length) path = [e.target];
      for (var i = 0; i < path.length && i < 8; i++) {
        if (isFullscreenControl(path[i])) return true;
      }
      return false;
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
    window.addEventListener('click', function(e) {
      if (!eventHitsFullscreen(e)) return;
      e.preventDefault();
      e.stopPropagation();
      notifyFullscreenToggle();
    }, true);
    try {
      var elProto = Element.prototype;
      ['requestFullscreen', 'webkitRequestFullscreen'].forEach(function(name) {
        var original = elProto[name];
        if (!original) return;
        elProto[name] = function() {
          notifyFullscreenToggle();
          return Promise.resolve();
        };
      });
      var videoProto = window.HTMLVideoElement && HTMLVideoElement.prototype;
      if (videoProto && videoProto.webkitEnterFullscreen) {
        videoProto.webkitEnterFullscreen = function() {
          notifyFullscreenToggle();
        };
      }
    } catch(e) {}
    window.addEventListener('mousemove', onUserMoveActivity, { passive: true, capture: true });
    window.addEventListener('pointermove', onUserMoveActivity, { passive: true, capture: true });

    var lastVisibility = null;
    function checkControlsVisibility() {
      try {
        var player = document.querySelector('.html5-video-player') || document.getElementById('movie_player');
        ensurePipButton();
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
