import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'mag_scanner_platform_interface.dart';

export 'package:mobile_scanner/mobile_scanner.dart';

/// Native helpers (the beep) exposed by the plugin.
class MagScanner {
  Future<void> playSound() {
    return MagScannerPlatform.instance.playSound();
  }

  /// Controller with the same settings the reference app ends up with: mobile_scanner 7.2.0
  /// defaults on the Dart side, which the native side turns into CameraX `KEEP_ONLY_LATEST`
  /// analysis at 1920x1080 feeding the bundled ML Kit model.
  static MobileScannerController createController({
    DetectionSpeed detectionSpeed = DetectionSpeed.normal,
    int detectionTimeoutMs = 250,
    List<BarcodeFormat> formats = const <BarcodeFormat>[],
    bool torchEnabled = false,
    bool autoStart = true,
  }) {
    return MobileScannerController(
      autoStart: autoStart,
      // No cameraResolution: the native side then uses its own 1920x1080 default.
      detectionSpeed: detectionSpeed,
      detectionTimeoutMs: detectionTimeoutMs,
      formats: formats,
      torchEnabled: torchEnabled,
    );
  }
}

/// Camera preview that reads barcodes, beeps and vibrates on every detection,
/// the same flow as the reference app (`mobile_scanner` + native `playSound`).
class MagScannerView extends StatefulWidget {
  const MagScannerView({
    super.key,
    required this.onDetect,
    this.controller,
    this.beep = true,
    this.vibrate = true,
    this.scanWindow,
    this.overlayBuilder,
    this.errorBuilder,
  });

  final void Function(BarcodeCapture capture) onDetect;

  /// When null, a controller from [MagScanner.createController] is used.
  final MobileScannerController? controller;
  final bool beep;
  final bool vibrate;
  final Rect? scanWindow;
  final LayoutWidgetBuilder? overlayBuilder;
  final Widget Function(BuildContext, MobileScannerException)? errorBuilder;

  @override
  State<MagScannerView> createState() => _MagScannerViewState();
}

class _MagScannerViewState extends State<MagScannerView> {
  final _plugin = MagScanner();
  MobileScannerController? _ownController;

  MobileScannerController get _controller =>
      widget.controller ?? (_ownController ??= MagScanner.createController());

  @override
  void dispose() {
    _ownController?.dispose();
    super.dispose();
  }

  void _handleDetect(BarcodeCapture capture) {
    if (capture.barcodes.isEmpty) return;
    if (widget.beep) _plugin.playSound();
    if (widget.vibrate) HapticFeedback.mediumImpact();
    widget.onDetect(capture);
  }

  @override
  Widget build(BuildContext context) {
    return MobileScanner(
      controller: _controller,
      onDetect: _handleDetect,
      scanWindow: widget.scanWindow,
      overlayBuilder: widget.overlayBuilder,
      errorBuilder: widget.errorBuilder,
    );
  }
}
