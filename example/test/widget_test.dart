import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mag_scanner_example/main.dart';

void main() {
  testWidgets('Home shows the scan button and empty history', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Escanear'), findsOneWidget);
    expect(find.text('Nenhum código lido ainda'), findsOneWidget);
    expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);
  });
}
