import 'package:flutter_test/flutter_test.dart';
import 'package:mag_scanner/mag_scanner.dart';
import 'package:mag_scanner/mag_scanner_platform_interface.dart';
import 'package:mag_scanner/mag_scanner_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockMagScannerPlatform
    with MockPlatformInterfaceMixin
    implements MagScannerPlatform {
  int beeps = 0;

  @override
  Future<void> playSound() async => beeps++;
}

void main() {
  final MagScannerPlatform initialPlatform = MagScannerPlatform.instance;

  test('$MethodChannelMagScanner is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelMagScanner>());
  });

  test('playSound delegates to the platform', () async {
    final fakePlatform = MockMagScannerPlatform();
    MagScannerPlatform.instance = fakePlatform;

    await MagScanner().playSound();

    expect(fakePlatform.beeps, 1);
  });

  test('createController matches the reference app defaults', () {
    final controller = MagScanner.createController(autoStart: false);

    expect(controller.detectionSpeed, DetectionSpeed.normal);
    expect(controller.detectionTimeoutMs, 250);
    expect(controller.formats, isEmpty);
    expect(controller.cameraResolution, isNull);
    expect(controller.returnImage, isFalse);
  });
}
