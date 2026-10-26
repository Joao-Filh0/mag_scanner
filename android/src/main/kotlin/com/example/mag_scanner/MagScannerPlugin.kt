package com.example.mag_scanner

import android.media.AudioAttributes
import android.media.SoundPool
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * Native side of mag_scanner.
 *
 * Camera and barcode detection come from the `mobile_scanner` package (same as the reference
 * app). The only native code, also like the reference app's MainActivity, is a SoundPool beep
 * preloaded at startup so it plays with no decoding delay right after a detection.
 */
class MagScannerPlugin :
    FlutterPlugin,
    MethodCallHandler {
    // The MethodChannel that will the communication between Flutter and native Android
    //
    // This local reference serves to register the plugin with the Flutter Engine and unregister it
    // when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private var soundPool: SoundPool? = null
    private var beepId = 0
    private var beepLoaded = false

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "mag_scanner")
        channel.setMethodCallHandler(this)

        val pool = SoundPool.Builder()
            .setMaxStreams(1)
            .setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_MEDIA)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build(),
            )
            .build()
        soundPool = pool
        try {
            flutterPluginBinding.applicationContext.assets.openFd(BEEP_ASSET).use { fd ->
                beepId = pool.load(fd, 1)
            }
            beepLoaded = true
        } catch (e: Exception) {
            Log.e(TAG, "Error loading sound: ${e.message}")
            beepLoaded = false
        }
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result
    ) {
        when (call.method) {
            "playSound" -> {
                playSound()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        soundPool?.release()
        soundPool = null
        beepLoaded = false
    }

    private fun playSound() {
        val pool = soundPool
        if (beepLoaded && pool != null) {
            pool.play(beepId, 1f, 1f, 0, 0, 1f)
        } else {
            Log.e(TAG, "Sound not loaded")
        }
    }

    private companion object {
        const val TAG = "MagScannerPlugin"
        const val BEEP_ASSET = "mag_scanner/beep.wav"
    }
}
