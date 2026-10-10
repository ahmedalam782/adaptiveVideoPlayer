package com.example.example

import android.app.PendingIntent
import android.app.PictureInPictureParams
import android.app.RemoteAction
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.res.Configuration
import android.graphics.drawable.Icon
import android.os.Build
import android.util.Rational
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "adaptive_video_player/pip"
    private val ACTION_PIP_CONTROL = "com.example.example.PIP_ACTION"
    private var pipChannel: MethodChannel? = null
    private var isPipMode = false
    private var pipEnabled = false
    private var isPlaying = true

    private val pipReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            if (intent?.action == ACTION_PIP_CONTROL) {
                val action = intent.getStringExtra("action") ?: "toggle_play"
                pipChannel?.invokeMethod("onPipAction", action)
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        pipChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        pipChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "enterPip" -> {
                    val success = enterPipMode()
                    result.success(success)
                }
                "exitPip" -> {
                    exitPipMode()
                    result.success(true)
                }
                "closePip" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
                        isInPictureInPictureMode
                    ) {
                        moveTaskToBack(true)
                    }
                    result.success(true)
                }
                "isPipSupported" -> {
                    result.success(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                }
                "isInPip" -> {
                    result.success(isPipMode)
                }
                "setPipEnabled" -> {
                    pipEnabled = call.arguments as? Boolean ?: false
                    updateAutoEnterPip()
                    result.success(true)
                }
                "updatePlaybackState" -> {
                    val map = call.arguments as? Map<*, *>
                    val newPlaying = map?.get("isPlaying") as? Boolean ?: true
                    if (newPlaying != isPlaying) {
                        isPlaying = newPlaying
                        updatePipParams()
                    }
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        val securityChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "adaptive_video_player/security")
        securityChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "setSecureMode" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    if (enabled) {
                        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    } else {
                        window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    }
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        val filter = IntentFilter(ACTION_PIP_CONTROL)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(pipReceiver, filter, Context.RECEIVER_EXPORTED)
        } else {
            registerReceiver(pipReceiver, filter)
        }
    }

    override fun onDestroy() {
        try {
            unregisterReceiver(pipReceiver)
        } catch (_: Exception) {}
        super.onDestroy()
    }

    private fun buildPipParams(): PictureInPictureParams? {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val builder = PictureInPictureParams.Builder()
                .setAspectRatio(Rational(16, 9))

            val actions = ArrayList<RemoteAction>()

            // 1. Rewind 10s
            val rewindIntent = Intent(ACTION_PIP_CONTROL).apply {
                setPackage(packageName)
                putExtra("action", "seek_backward")
            }
            val rewindPendingIntent = PendingIntent.getBroadcast(
                this,
                101,
                rewindIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)
            )
            val rewindIcon = Icon.createWithResource(this, android.R.drawable.ic_media_rew)
            actions.add(RemoteAction(rewindIcon, "Rewind 10s", "Rewind 10s", rewindPendingIntent))

            // 2. Play / Pause
            val playPauseIntent = Intent(ACTION_PIP_CONTROL).apply {
                setPackage(packageName)
                putExtra("action", "toggle_play")
            }
            val playPausePendingIntent = PendingIntent.getBroadcast(
                this,
                102,
                playPauseIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)
            )
            val iconRes = if (isPlaying) android.R.drawable.ic_media_pause else android.R.drawable.ic_media_play
            val title = if (isPlaying) "Pause" else "Play"
            val playPauseIcon = Icon.createWithResource(this, iconRes)
            actions.add(RemoteAction(playPauseIcon, title, title, playPausePendingIntent))

            // 3. Fast Forward 10s
            val forwardIntent = Intent(ACTION_PIP_CONTROL).apply {
                setPackage(packageName)
                putExtra("action", "seek_forward")
            }
            val forwardPendingIntent = PendingIntent.getBroadcast(
                this,
                103,
                forwardIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)
            )
            val forwardIcon = Icon.createWithResource(this, android.R.drawable.ic_media_ff)
            actions.add(RemoteAction(forwardIcon, "Forward 10s", "Forward 10s", forwardPendingIntent))

            builder.setActions(actions)

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                builder.setAutoEnterEnabled(pipEnabled)
            }
            return builder.build()
        }
        return null
    }

    private fun updatePipParams() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            try {
                val params = buildPipParams()
                if (params != null) {
                    setPictureInPictureParams(params)
                }
            } catch (_: Exception) {}
        }
    }

    private fun updateAutoEnterPip() {
        updatePipParams()
    }

    private fun exitPipMode() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O || !isInPictureInPictureMode) {
            return
        }
        val intent = Intent(this, javaClass).apply {
            flags = Intent.FLAG_ACTIVITY_REORDER_TO_FRONT or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        startActivity(intent)
    }

    private fun enterPipMode(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return false
        if (isInPictureInPictureMode) return true
        if (!lifecycle.currentState.isAtLeast(androidx.lifecycle.Lifecycle.State.RESUMED)) {
            return false
        }
        return try {
            val params = buildPipParams() ?: return false
            setPictureInPictureParams(params)
            enterPictureInPictureMode(params)
        } catch (_: Exception) {
            false
        }
    }

    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        if (pipEnabled) {
            enterPipMode()
        }
    }

    override fun onPictureInPictureModeChanged(
        isInPictureInPictureMode: Boolean,
        newConfig: Configuration
    ) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig)
        isPipMode = isInPictureInPictureMode
        if (isInPictureInPictureMode) {
            window.clearFlags(WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE)
            window.clearFlags(WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE)
        }
        pipChannel?.invokeMethod("onPipModeChanged", isInPictureInPictureMode)
    }
}
