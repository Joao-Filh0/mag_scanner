package com.magnum.mag_scanner

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.mockito.Mockito
import kotlin.test.Test

/*
 * Run with `./gradlew testDebugUnitTest` in the `example/android/` directory.
 */

internal class MagScannerPluginTest {
    @Test
    fun onMethodCall_unknownMethod_returnsNotImplemented() {
        val plugin = MagScannerPlugin()

        val call = MethodCall("unknown", null)
        val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)
        plugin.onMethodCall(call, mockResult)

        Mockito.verify(mockResult).notImplemented()
    }

    @Test
    fun onMethodCall_playSoundWithoutEngine_completes() {
        val plugin = MagScannerPlugin()

        val call = MethodCall("playSound", null)
        val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)
        plugin.onMethodCall(call, mockResult)

        Mockito.verify(mockResult).success(null)
    }
}
