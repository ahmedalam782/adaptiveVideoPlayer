/// Raw HTML string for the YouTube iframe player desktop local server.
/// Kept in the same folder as [YouTubeWebViewPlayer].
const String kYouTubePlayerHtml = r'''<!DOCTYPE html>
<html>

<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
    <meta name="referrer" content="strict-origin-when-cross-origin" />
    <style>
        html,
        body {
            margin: 0;
            padding: 0;
            overflow: hidden;
            height: 100%;
            width: 100%;
            background-color: #000;
        }

        #player {
            position: fixed;
            z-index: 1;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
        }

        #adaptive-pip-button {
            position: fixed;
            z-index: 2147483647;
            right: 70px;
            bottom: 75px;
            width: 32px;
            height: 32px;
            margin: 0;
            padding: 0;
            border: 0;
            border-radius: 50%;
            background: rgba(0, 0, 0, 0.2);
            color: #fff;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            pointer-events: auto;
            box-shadow: 0 0 0 1px rgba(255, 255, 255, 0.2);
        }

        @media (min-width: 800px) and (min-height: 500px) {
            #adaptive-pip-button {
                right: 75px;
                bottom: 85px;
                width: 36px;
                height: 36px;
            }
        }

        #adaptive-pip-button svg {
            width: 20px;
            height: 20px;
            display: block;
        }

        video::-webkit-media-controls,
        video::-webkit-media-controls-picture-in-picture-button,
        .ytp-autonav-toggle-button,
        .ytp-autonav-toggle-button-container,
        .ytp-autonav-endscreen-button-container,
        [class*="autonav" i],
        button[aria-label*="autoplay" i],
        button[aria-label*="تشغيل تلقائي" i],
        button[title*="autoplay" i],
        button[title*="تشغيل تلقائي" i],
        .ytp-volume-slider,
        .ytp-volume-slider-handle {
            display: none !important;
            opacity: 0 !important;
            visibility: hidden !important;
            pointer-events: none !important;
            width: 0 !important;
            height: 0 !important;
        }
    </style>
</head>

<body>
    <div id="player"></div>
    <button id="adaptive-pip-button" type="button" aria-label="Picture in picture" title="Picture in picture">
        <svg viewBox="0 0 36 36" aria-hidden="true"><path fill="#fff" d="M25 17H17V23H25V17ZM29 25V10.98C29 9.88 28.1 9 27 9H9C7.9 9 7 9.88 7 10.98V25C7 26.1 7.9 27 9 27H27C28.1 27 29 26.1 29 25ZM27 25.02H9V10.97H27V25.02Z"></path></svg>
    </button>
    <script>
        var tag = document.createElement('script');
        tag.src = "https://www.youtube.com/iframe_api";
        var firstScriptTag = document.getElementsByTagName('script')[0];
        firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

        // Ensure YouTube iframe has proper referrer policy and media permissions to prevent Error 153
        var playerObserver = new MutationObserver(function() {
            var iframe = document.querySelector('#player iframe');
            if (iframe) {
                iframe.setAttribute('referrerpolicy', 'strict-origin-when-cross-origin');
                var currentAllow = iframe.getAttribute('allow') || '';
                if (currentAllow.indexOf('encrypted-media') === -1) {
                    iframe.setAttribute('allow', 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; fullscreen');
                }
            }
        });
        if (document.body) {
            playerObserver.observe(document.body, { childList: true, subtree: true });
        } else {
            document.addEventListener('DOMContentLoaded', function() {
                playerObserver.observe(document.body, { childList: true, subtree: true });
            });
        }

        var player;
        // These will be set from Dart via evaluateJavascript
        var videoId = '';
        var autoplayFlag = 0;
        var muteFlag = 0;
        var startAtFlag = 0;
        var controlsFlag = 1;
        var langFlag = 'en';
        var dirFlag = 'ltr';
        var timeUpdateInterval = null;
        var pendingPlay = false;
        var isPlayerReady = false;

        function updateRtlStyles(isRtl) {
            try {
                var styleId = 'yt-rtl-progress-style';
                var existing = document.getElementById(styleId);
                if (isRtl) {
                    if (!existing) {
                        var st = document.createElement('style');
                        st.id = styleId;
                        st.textContent = '.ytp-progress-bar-container, .ytp-progress-bar { transform: scaleX(-1) !important; }';
                        (document.head || document.documentElement).appendChild(st);
                    }
                } else if (existing) {
                    existing.remove();
                }
            } catch(e) {}
        }

        function setLanguage(lang, dir) {
            var nextLang = (lang && typeof lang === 'string' && lang.trim().length > 0) ? lang.trim() : 'en';
            var nextDir = (dir === 'rtl' || nextLang === 'ar' || nextLang === 'he' || nextLang === 'fa' || nextLang === 'ur') ? 'rtl' : 'ltr';
            document.documentElement.dir = nextDir;
            document.documentElement.lang = nextLang;
            updateRtlStyles(nextDir === 'rtl');
            if (langFlag !== nextLang || dirFlag !== nextDir) {
                langFlag = nextLang;
                dirFlag = nextDir;
                if (typeof placePipButton === 'function') {
                    placePipButton(typeof lastPipAnchor === 'undefined' ? null : lastPipAnchor);
                }
                if (player && typeof player.destroy === 'function') {
                    try {
                        if (typeof player.getCurrentTime === 'function') {
                            startAtFlag = Math.floor(player.getCurrentTime() || 0);
                        }
                        if (typeof player.getPlayerState === 'function') {
                            autoplayFlag = (player.getPlayerState() === 1) ? 1 : 0;
                        }
                        isPlayerReady = false;
                        player.destroy();
                        player = null;
                        createPlayer();
                    } catch (e) {}
                }
            }
        }

        function sendTimeUpdate() {
            if (player && typeof player.getCurrentTime === 'function' && window.flutter_inappwebview) {
                var cur = Math.round(player.getCurrentTime());
                var dur = 0;
                if (typeof player.getDuration === 'function') {
                    dur = Math.round(player.getDuration() || 0);
                }
                window.flutter_inappwebview.callHandler('YouTubePlayerHandler', {
                    'event': 'onTimeUpdate',
                    'currentTime': cur,
                    'duration': dur
                });
            }
        }

        function startTimeTracking() {
            if (timeUpdateInterval) clearInterval(timeUpdateInterval);
            timeUpdateInterval = setInterval(sendTimeUpdate, 500);
        }

        function initPlayer(vid, autoplay, mute, startSeconds, lang, dir, controls) {
            videoId = vid;
            autoplayFlag = autoplay;
            muteFlag = mute;
            startAtFlag = startSeconds || 0;
            if (controls !== undefined && controls !== null) {
                controlsFlag = controls;
            }
            if (lang) {
                langFlag = (typeof lang === 'string' && lang.trim().length > 0) ? lang.trim() : 'en';
                dirFlag = (dir === 'rtl' || langFlag === 'ar' || langFlag === 'he' || langFlag === 'fa' || langFlag === 'ur') ? 'rtl' : 'ltr';
                document.documentElement.dir = dirFlag;
                document.documentElement.lang = langFlag;
                updateRtlStyles(dirFlag === 'rtl');
            }
            if (typeof YT !== 'undefined' && YT.Player) {
                createPlayer();
            }
            // If API not loaded yet, onYouTubeIframeAPIReady will handle it
        }

        function onYouTubeIframeAPIReady() {
            if (videoId) {
                createPlayer();
            }
        }

        function createPlayer() {
            var origin = (window.location && window.location.origin && window.location.origin !== 'null' && window.location.origin !== '')
                ? window.location.origin
                : 'https://www.youtube-nocookie.com';
            var pageUrl = (window.location && window.location.href && window.location.href.indexOf('http') === 0)
                ? window.location.href
                : origin + '/';

            var playerVars = {
                'autoplay': autoplayFlag,
                'mute': muteFlag,
                'playsinline': 1,
                'controls': controlsFlag,
                'fs': 1,
                'rel': 0,
                'cc_load_policy': 0,
                'iv_load_policy': 3,
                'modestbranding': 1,
                'hl': langFlag,
                'enablejsapi': 1,
                'origin': origin,
                'widget_referrer': pageUrl
            };
            if (startAtFlag > 0) {
                playerVars['start'] = startAtFlag;
            }

            isPlayerReady = false;
            player = new YT.Player('player', {
                height: '100%',
                width: '100%',
                videoId: videoId,
                host: 'https://www.youtube-nocookie.com',
                playerVars: playerVars,
                events: {
                    'onReady': onPlayerReady,
                    'onStateChange': onPlayerStateChange,
                    'onError': onPlayerError
                }
            });
        }

        function tryUnmuteIfAllowed() {
            if (muteFlag === 0 && player && typeof player.unMute === 'function') {
                try {
                    player.unMute();
                    if (typeof player.setVolume === 'function') {
                        player.setVolume(100);
                    }
                } catch(e) {}
            }
        }

        function onPlayerReady(event) {
            isPlayerReady = true;
            event.target.setPlaybackQuality('medium');
            if (startAtFlag > 0) {
                var cur = (typeof event.target.getCurrentTime === 'function') ? event.target.getCurrentTime() : 0;
                if (cur < startAtFlag - 1) {
                    event.target.seekTo(startAtFlag, true);
                }
            }
            tryUnmuteIfAllowed();
            if (autoplayFlag === 1 || pendingPlay) {
                pendingPlay = false;
                try {
                    event.target.playVideo();
                } catch(e) {}
                setTimeout(function() {
                    try {
                        if (player && typeof player.getPlayerState === 'function') {
                            var s = player.getPlayerState();
                            if (s === -1 || s === 2 || s === 5) {
                                player.mute();
                                player.playVideo();
                            }
                        }
                    } catch(err) {}
                }, 500);
            }
            startTimeTracking();
            if (window.flutter_inappwebview) {
                window.flutter_inappwebview.callHandler('YouTubePlayerHandler', { 'event': 'onReady' });
            }
        }

        function onPlayerStateChange(event) {
            sendTimeUpdate();
            if (event.data === YT.PlayerState.BUFFERING || event.data === YT.PlayerState.PLAYING) {
                event.target.setPlaybackQuality('medium');
                tryUnmuteIfAllowed();
            }
            if (window.flutter_inappwebview) {
                window.flutter_inappwebview.callHandler('YouTubePlayerHandler', { 'event': 'onStateChange', 'data': event.data });
            }
        }

        function onPlayerError(event) {
            if (window.flutter_inappwebview) {
                window.flutter_inappwebview.callHandler('YouTubePlayerHandler', { 'event': 'onError', 'data': event.data });
            }
        }

        // Fullscreen bridge between YouTube HTML5 player and Flutter
        function handleFullscreenChange() {
            sendTimeUpdate();
            var isFs = !!(document.fullscreenElement || document.webkitFullscreenElement || document.mozFullScreenElement || document.msFullscreenElement);
            if (window.flutter_inappwebview) {
                window.flutter_inappwebview.callHandler('YouTubePlayerHandler', {
                    'event': isFs ? 'onEnterFullscreen' : 'onExitFullscreen'
                });
            }
        }
        document.addEventListener('fullscreenchange', handleFullscreenChange);
        document.addEventListener('webkitfullscreenchange', handleFullscreenChange);
        document.addEventListener('mozfullscreenchange', handleFullscreenChange);
        document.addEventListener('MSFullscreenChange', handleFullscreenChange);

        // Notify Flutter on touch, click, or mousemove activity so controls overlay can reveal/auto-hide smoothly
        function notifyTouchActivity() {
            if (muteFlag === 0 && player && typeof player.unMute === 'function') {
                try { player.unMute(); } catch(e) {}
            }
            if (window.flutter_inappwebview) {
                window.flutter_inappwebview.callHandler('YouTubePlayerHandler', { 'event': 'onTouchActivity' });
            }
        }
        var lastTouchActivity = 0;
        function notifyThrottledActivity() {
            var now = Date.now();
            if (now - lastTouchActivity > 200) {
                lastTouchActivity = now;
                notifyTouchActivity();
            }
        }
        document.addEventListener('touchstart', notifyTouchActivity, { passive: true });
        document.addEventListener('click', notifyTouchActivity, { passive: true });
        document.addEventListener('mousemove', notifyThrottledActivity, { passive: true });

        // Listen for postMessage from inner YouTube iframe
        window.addEventListener('message', function(e) {
            try {
                if (e.data && e.data.type === 'YouTubePlayerHandler' && window.flutter_inappwebview) {
                    window.flutter_inappwebview.callHandler('YouTubePlayerHandler', e.data);
                }
            } catch(err) {}
        });

        // Keyboard handler inside WebView to bridge Esc, Seek, Play/Pause, and Fullscreen to Flutter
        window.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                if (window.flutter_inappwebview) {
                    window.flutter_inappwebview.callHandler('YouTubePlayerHandler', { 'event': 'onEscapeKey' });
                }
            } else if (e.key === 'ArrowRight' || e.key === 'l' || e.key === 'L') {
                if (window.flutter_inappwebview) {
                    window.flutter_inappwebview.callHandler('YouTubePlayerHandler', { 'event': 'onSeekForward' });
                }
            } else if (e.key === 'ArrowLeft' || e.key === 'j' || e.key === 'J') {
                if (window.flutter_inappwebview) {
                    window.flutter_inappwebview.callHandler('YouTubePlayerHandler', { 'event': 'onSeekBackward' });
                }
            } else if (e.key === ' ' || e.key === 'k' || e.key === 'K') {
                if (player && typeof player.getPlayerState === 'function') {
                    var s = player.getPlayerState();
                    if (s === 1) { player.pauseVideo(); }
                    else { player.playVideo(); }
                }
            } else if (e.key === 'f' || e.key === 'F') {
                if (window.flutter_inappwebview) {
                    window.flutter_inappwebview.callHandler('YouTubePlayerHandler', { 'event': 'onToggleFullscreen' });
                }
            } else if (e.key === 'm' || e.key === 'M') {
                if (player && typeof player.isMuted === 'function') {
                    if (player.isMuted()) { player.unMute(); }
                    else { player.mute(); }
                }
            }
        });

        // API calls from Dart
        function playVideo() {
            if (isPlayerReady && player && typeof player.playVideo === 'function') {
                tryUnmuteIfAllowed();
                try {
                    player.playVideo();
                } catch(e) {}
                setTimeout(function() {
                    try {
                        if (player && typeof player.getPlayerState === 'function') {
                            var s = player.getPlayerState();
                            if (s === -1 || s === 2 || s === 5) {
                                player.mute();
                                player.playVideo();
                            }
                        }
                    } catch(err) {}
                }, 500);
            } else {
                pendingPlay = true;
            }
        }
        function pauseVideo() { if (player) { player.pauseVideo(); sendTimeUpdate(); } }
        function seekTo(seconds) { if (player) { player.seekTo(seconds, true); sendTimeUpdate(); } }
        function muteVideo() { if (player) player.mute(); }
        function unMuteVideo() { if (player) player.unMute(); }
        function exitFullscreen() {
            if (document.exitFullscreen) {
                document.exitFullscreen();
            } else if (document.webkitExitFullscreen) {
                document.webkitExitFullscreen();
            }
        }

        var pipButton = document.getElementById('adaptive-pip-button');
        var showMiniPlayerButton = true;
        var pipButtonCompact = false;
        var lastPipAnchor = null;
        function setShowMiniPlayer(show) {
            showMiniPlayerButton = !!show;
            if (!pipButton) return;
            pipButton.style.display = showMiniPlayerButton ? 'flex' : 'none';
            pipButton.style.pointerEvents = showMiniPlayerButton ? 'auto' : 'none';
            if (showMiniPlayerButton) placePipButton(lastPipAnchor);
        }
        function setPipButtonCompact(compact) {
            pipButtonCompact = !!compact;
            placePipButton(lastPipAnchor);
        }
        function phoneSized() {
            var w = window.innerWidth || 0;
            var h = window.innerHeight || 0;
            function inPhone(n) { return n <= 400; }
            return inPhone(w) || inPhone(h);
        }
        function placePipButton(data) {
            if (!pipButton || !showMiniPlayerButton) return;
            if (data && data.visible === false) {
                pipButton.style.display = 'none';
                return;
            }
            var rtl = dirFlag === 'rtl' || !!(data && data.rtl);
            var phone = phoneSized();
            if (data && data.visible && (pipButtonCompact || phone || rtl)) {
                var frame = document.querySelector('iframe');
                var frameBox = frame ? frame.getBoundingClientRect() : { top: 0, left: 0, width: window.innerWidth };
                var frameWidth = frameBox.width || window.innerWidth;
                var buttonSize = Math.round(Math.min(Math.max(data.height || 36, 32), 48));
                var width = buttonSize;
                var height = buttonSize;
                var anchorLeft = frameBox.left + data.left;
                var anchorHeight = data.height || height;
                var centerY = frameBox.top + (typeof data.centerY === 'number'
                    ? data.centerY
                    : (data.top + anchorHeight / 2));
                var fullscreenOnLeft = (data.left + (data.width || width) / 2) < (frameWidth / 2);
                var left = fullscreenOnLeft
                    ? (anchorLeft + (data.width || width) + 6)
                    : (anchorLeft - width - 6);
                if (left < 4) left = 4;
                var top = centerY - height / 2;
                pipButton.style.display = 'flex';
                pipButton.style.right = 'auto';
                pipButton.style.bottom = 'auto';
                pipButton.style.left = Math.round(left) + 'px';
                pipButton.style.top = Math.round(top) + 'px';
                pipButton.style.width = width + 'px';
                pipButton.style.height = height + 'px';
                return;
            }
            pipButton.style.top = 'auto';
            pipButton.style.display = 'flex';
            var inset = pipButtonCompact ? '60px' : (phone ? '60px' : '75px');
            var bottom = pipButtonCompact ? '60px' : (phone ? '60px' : '85px');
            var size = pipButtonCompact ? '40px' : '36px';
            pipButton.style.bottom = bottom;
            pipButton.style.width = size;
            pipButton.style.height = size;
            if (rtl) {
                pipButton.style.right = 'auto';
                pipButton.style.left = inset;
            } else {
                pipButton.style.left = 'auto';
                pipButton.style.right = inset;
            }
        }
        if (pipButton) {
            pipButton.addEventListener('click', function(e) {
                e.preventDefault();
                e.stopPropagation();
                if (window.flutter_inappwebview) {
                    window.flutter_inappwebview.callHandler('YouTubePlayerHandler', {
                        type: 'YouTubePlayerHandler',
                        event: 'onOpenPip'
                    });
                }
            });
        }
        window.addEventListener('message', function(e) {
            var data = e.data;
            if (!data) return;
            if (data.type === 'YouTubePlayerHandler' && data.event === 'onOpenPip') {
                if (window.flutter_inappwebview) {
                    window.flutter_inappwebview.callHandler('YouTubePlayerHandler', data);
                }
                return;
            }
            if (data.type !== 'adaptive-pip-anchor' || !pipButton) return;
            if (!showMiniPlayerButton || data.inline || !data.visible) {
                pipButton.style.display = 'none';
                if (!data.visible) lastPipAnchor = data;
                return;
            }
            lastPipAnchor = data;
            placePipButton(data);
        });
        window.addEventListener('resize', function() {
            placePipButton(lastPipAnchor);
        });
    </script>
</body>

</html>
''';
