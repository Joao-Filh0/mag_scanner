import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'mag_scanner_method_channel.dart';

abstract class MagScannerPlatform extends PlatformInterface {
  /// Constructs a MagScannerPlatform.
  MagScannerPlatform() : super(token: _token);

  static final Object _token = Object();

  static MagScannerPlatform _instance = MethodChannelMagScanner();

  /// The default instance of [MagScannerPlatform] to use.
  ///
  /// Defaults to [MethodChannelMagScanner].
  static MagScannerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [MagScannerPlatform] when
  /// they register themselves.
  static set instance(MagScannerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Plays the preloaded native beep.
  Future<void> playSound() {
    throw UnimplementedError('playSound() has not been implemented.');
  }
}
