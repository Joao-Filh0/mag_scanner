import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'mag_scanner_platform_interface.dart';

/// An implementation of [MagScannerPlatform] that uses method channels.
class MethodChannelMagScanner extends MagScannerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('mag_scanner');

  @override
  Future<void> playSound() => methodChannel.invokeMethod<void>('playSound');
}
