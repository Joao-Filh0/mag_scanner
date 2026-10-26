import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mag_scanner/mag_scanner_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelMagScanner platform = MethodChannelMagScanner();
  const MethodChannel channel = MethodChannel('mag_scanner');
  final calls = <String>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          calls.add(methodCall.method);
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('playSound invokes the native beep', () async {
    await platform.playSound();
    expect(calls, ['playSound']);
  });
}
