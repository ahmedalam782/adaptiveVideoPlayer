package com.example.example

import android.app.PictureInPictureParams
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.res.Configuration
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
                pipChannel?.invokeMethod("onPipAction", "toggle_play")
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
                .setActions(emptyList())

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
