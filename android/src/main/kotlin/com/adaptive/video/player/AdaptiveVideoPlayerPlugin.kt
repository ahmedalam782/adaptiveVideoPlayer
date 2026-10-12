package com.adaptive.video.player

import android.app.Activity
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
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class AdaptiveVideoPlayerPlugin : FlutterPlugin, ActivityAware, MethodCallHandler {
    private var securityChannel: MethodChannel? = null
    private var pipChannel: MethodChannel? = null
    private var activity: Activity? = null
    private var context: Context? = null

    private val ACTION_PIP_CONTROL = "com.adaptive.video.player.PIP_ACTION"
    private var isPlaying = true

    private val pipReceiver = object : BroadcastReceiver() {
        override fun onReceive(ctx: Context?, intent: Intent?) {
            if (intent?.action == ACTION_PIP_CONTROL) {
                val action = intent.getStringExtra("action") ?: "toggle_play"
                pipChannel?.invokeMethod("onPipAction", action)
            }
        }
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        securityChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "adaptive_video_player/security")
        securityChannel?.setMethodCallHandler(this)

        pipChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "adaptive_video_player/pip")
        pipChannel?.setMethodCallHandler(this)

        val filter = IntentFilter(ACTION_PIP_CONTROL)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            context?.registerReceiver(pipReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            context?.registerReceiver(pipReceiver, filter)
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        securityChannel?.setMethodCallHandler(null)
        securityChannel = null
        pipChannel?.setMethodCallHandler(null)
        pipChannel = null

        try {
            context?.unregisterReceiver(pipReceiver)
        } catch (_: Exception) {}
        context = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            // Screen Protection / Anti-Capture Shield
            "setSecureMode" -> {
                val enabled = call.argument<Boolean>("enabled") ?: false
                val act = activity
                if (act != null) {
                    act.runOnUiThread {
                        if (enabled) {
                            act.window?.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        } else {
                            act.window?.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        }
                        result.success(true)
                    }
                } else {
                    result.success(false)
                }
            }
            // Picture-in-Picture
            "enterPip" -> {
                val act = activity
                if (act != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    act.runOnUiThread {
                        try {
                            val params = buildPipParams()
                            if (params != null) {
                                act.setPictureInPictureParams(params)
                                val success = act.enterPictureInPictureMode(params)
                                result.success(success)
                            } else {
                                result.success(false)
                            }
                        } catch (e: Exception) {
                            result.success(false)
                        }
                    }
                } else {
                    result.success(false)
                }
            }
            "isPipSupported" -> {
                result.success(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
            }
            "isInPip" -> {
                val act = activity
                if (act != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    result.success(act.isInPictureInPictureMode)
                } else {
                    result.success(false)
                }
            }
            "setPipEnabled" -> {
                // Backgrounding the app must not open PiP. enterPip is explicit.
                result.success(true)
            }
            "updatePlaybackState" -> {
                isPlaying = call.argument<Boolean>("isPlaying") ?: true
                val act = activity
                if (act != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && act.isInPictureInPictureMode) {
                    act.runOnUiThread {
                        try {
                            val params = buildPipParams()
                            if (params != null) {
                                act.setPictureInPictureParams(params)
                            }
                        } catch (_: Exception) {}
                    }
                }
                result.success(true)
            }
            "closePip" -> {
                val act = activity
                if (act != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && act.isInPictureInPictureMode) {
                    act.moveTaskToBack(true)
                }
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }

    private fun buildPipParams(): PictureInPictureParams? {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return null
        val ctx = context ?: activity ?: return null

        val playPauseIcon = if (isPlaying) {
            android.R.drawable.ic_media_pause
        } else {
            android.R.drawable.ic_media_play
        }
        val playPauseTitle = if (isPlaying) "Pause" else "Play"

        val toggleIntent = Intent(ACTION_PIP_CONTROL).putExtra("action", "toggle_play")
        val togglePendingIntent = PendingIntent.getBroadcast(
            ctx,
            1,
            toggleIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        val playPauseAction = RemoteAction(
            Icon.createWithResource(ctx, playPauseIcon),
            playPauseTitle,
            playPauseTitle,
            togglePendingIntent
        )

        val rewIntent = Intent(ACTION_PIP_CONTROL).putExtra("action", "seek_backward")
        val rewPendingIntent = PendingIntent.getBroadcast(
            ctx,
            2,
            rewIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        val rewAction = RemoteAction(
            Icon.createWithResource(ctx, android.R.drawable.ic_media_rew),
            "Rewind 10s",
            "Rewind 10s",
            rewPendingIntent
        )

        val ffIntent = Intent(ACTION_PIP_CONTROL).putExtra("action", "seek_forward")
        val ffPendingIntent = PendingIntent.getBroadcast(
            ctx,
            3,
            ffIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        val ffAction = RemoteAction(
            Icon.createWithResource(ctx, android.R.drawable.ic_media_ff),
            "Forward 10s",
            "Forward 10s",
            ffPendingIntent
        )

        val actions = listOf(rewAction, playPauseAction, ffAction)
        val aspectRatio = Rational(16, 9)

        val builder = PictureInPictureParams.Builder()
            .setAspectRatio(aspectRatio)
            .setActions(actions)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            builder.setAutoEnterEnabled(false)
            builder.setSeamlessResizeEnabled(true)
        }

        return builder.build()
    }
}
