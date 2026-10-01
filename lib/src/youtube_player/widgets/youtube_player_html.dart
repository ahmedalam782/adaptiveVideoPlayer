/// Raw HTML string for the YouTube iframe player desktop local server.
/// Kept in the same folder as [YouTubeWebViewPlayer].
const String kYouTubePlayerHtml = r'''<!DOCTYPE html>
<html>

<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
    <meta name="referrer" content="no-referrer-when-downgrade" />
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
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
        }

        video::-webkit-media-controls,
        video::-webkit-media-controls-picture-in-picture-button,
        video::-webkit-media-controls-fullscreen-button,
        video::-webkit-media-controls-enclosure,
        .ytp-fullscreen-button {
            display: none !important;
        }
    </style>
</head>

<body>
    <div id="player"></div>
    <script>
        var tag = document.createElement('script');
        tag.src = "https://www.youtube.com/iframe_api";
        var firstScriptTag = document.getElementsByTagName('script')[0];
        firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

        // Ensure YouTube iframe has proper referrer policy and media permissions to prevent Error 153
        var playerObserver = new MutationObserver(function() {
            var iframe = document.querySelector('#player iframe');
            if (iframe) {
                if (!iframe.getAttribute('referrerpolicy')) {
                    iframe.setAttribute('referrerpolicy', 'no-referrer-when-downgrade');
                }
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
        var langFlag = 'en';
        var dirFlag = 'ltr';
        var timeUpdateInterval = null;

        function updateRtlStyles(isRtl) {
            try {
                var styleId = 'yt-rtl-progress-style';
                var existing = document.getElementById(styleId);
                if (isRtl) {
                    if (!existing) {
                        var st = document.createElement('style');
                        st.id = styleId;
                        st.innerHTML = '.ytp-progress-bar-container, .ytp-progress-bar { transform: scaleX(-1) !important; }';
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
                if (player && typeof player.destroy === 'function') {
                    try {
                        if (typeof player.getCurrentTime === 'function') {
                            startAtFlag = Math.floor(player.getCurrentTime() || 0);
                        }
                        if (typeof player.getPlayerState === 'function') {
                            autoplayFlag = (player.getPlayerState() === 1) ? 1 : 0;
                        }
                        player.destroy();
                        player = null;
                        createPlayer();
                    } catch (e) {}
                }
            }
        }

        function sendTimeUpdate() {
            if (player && typeof player.getCurrentTime === 'function' && window.flutter_inappwebview) {
                var cur = Math.floor(player.getCurrentTime());
                window.flutter_inappwebview.callHandler('YouTubePlayerHandler', {
                    'event': 'onTimeUpdate',
                    'currentTime': cur
                });
            }
        }

        function startTimeTracking() {
            if (timeUpdateInterval) clearInterval(timeUpdateInterval);
            timeUpdateInterval = setInterval(sendTimeUpdate, 500);
        }

        function initPlayer(vid, autoplay, mute, startSeconds, lang, dir) {
            videoId = vid;
            autoplayFlag = autoplay;
            muteFlag = mute;
            startAtFlag = startSeconds || 0;
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
                : 'https://www.youtube.com';

            var playerVars = {
                'autoplay': autoplayFlag,
                'mute': muteFlag,
                'playsinline': 1,
                'controls': 1,
                'fs': 0,
                'rel': 0,
                'showinfo': 0,
                'modestbranding': 1,
                'hl': langFlag,
                'vq': 'medium',
                'enablejsapi': 1,
                'origin': origin,
                'widget_referrer': origin
            };
            if (startAtFlag > 0) {
                playerVars['start'] = startAtFlag;
            }

            player = new YT.Player('player', {
                height: '100%',
                width: '100%',
                videoId: videoId,
                host: 'https://www.youtube.com',
                playerVars: playerVars,
                events: {
                    'onReady': onPlayerReady,
                    'onStateChange': onPlayerStateChange,
                    'onError': onPlayerError
                }
            });
        }

        function onPlayerReady(event) {
            event.target.setPlaybackQuality('medium');
            if (startAtFlag > 0) {
                event.target.seekTo(startAtFlag, true);
                if (autoplayFlag === 1) {
                    event.target.playVideo();
                }
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

        // Notify Flutter on touch or click activity so controls overlay can reveal/auto-hide smoothly
        function notifyTouchActivity() {
            if (window.flutter_inappwebview) {
                window.flutter_inappwebview.callHandler('YouTubePlayerHandler', { 'event': 'onTouchActivity' });
            }
        }
        document.addEventListener('touchstart', notifyTouchActivity, { passive: true });
        document.addEventListener('click', notifyTouchActivity, { passive: true });

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
        function playVideo() { if (player) player.playVideo(); }
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
    </script>
</body>

</html>
''';
