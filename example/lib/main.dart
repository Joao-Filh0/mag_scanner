import 'package:flutter/material.dart';
import 'package:mag_scanner/mag_scanner.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mag Scanner',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class ScanRecord {
  const ScanRecord(this.value, this.format, this.elapsed);

  final String value;
  final BarcodeFormat format;

  /// Time from opening the scanner to this read.
  final Duration elapsed;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<ScanRecord> _history = [];

  Future<void> _openScanner() async {
    final record = await Navigator.of(context).push<ScanRecord>(
      MaterialPageRoute(builder: (_) => const ScannerPage()),
    );
    if (record == null || !mounted) return;
    setState(() => _history.insert(0, record));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mag Scanner')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openScanner,
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Escanear'),
      ),
      body: _history.isEmpty
          ? const Center(child: Text('Nenhum código lido ainda'))
          : ListView.separated(
              itemCount: _history.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final record = _history[index];
                return ListTile(
                  leading: const Icon(Icons.qr_code_2),
                  title: Text(record.value),
                  subtitle: Text(
                    '${record.format.name} · lido em '
                    '${record.elapsed.inMilliseconds} ms',
                  ),
                );
              },
            ),
    );
  }
}

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final _controller = MagScanner.createController();
  final _stopwatch = Stopwatch()..start();
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final barcode = capture.barcodes.first;
    final value = barcode.rawValue;
    if (_handled || value == null) return;
    _handled = true;
    Navigator.of(context).pop(
      ScanRecord(value, barcode.format, _stopwatch.elapsed),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        actions: [
          ValueListenableBuilder(
            valueListenable: _controller,
            builder: (context, state, _) {
              if (state.torchState == TorchState.unavailable) {
                return const SizedBox.shrink();
              }
              return IconButton(
                onPressed: _controller.toggleTorch,
                icon: Icon(
                  state.torchState == TorchState.on
                      ? Icons.flash_on
                      : Icons.flash_off,
                ),
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          const horizontalPadding = 16.0;
          final scanWindow = Rect.fromCenter(
            center: constraints.biggest.center(Offset.zero),
            width: constraints.maxWidth - horizontalPadding * 2,
            height: constraints.maxWidth * 0.75 * 0.7,
          );
          return MagScannerView(
            controller: _controller,
            onDetect: _onDetect,
            scanWindow: scanWindow,
            overlayBuilder: (context, _) => _ScanWindowOverlay(scanWindow),
            errorBuilder: (context, error) => Center(
              child: Text(
                'Erro na câmera: ${error.errorCode.name}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ScanWindowOverlay extends StatelessWidget {
  const _ScanWindowOverlay(this.window);

  final Rect window;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _ScanWindowPainter(window),
      ),
    );
  }
}

class _ScanWindowPainter extends CustomPainter {
  _ScanWindowPainter(this.window);

  final Rect window;

  @override
  void paint(Canvas canvas, Size size) {
    final frame = RRect.fromRectAndRadius(window, const Radius.circular(16));
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Offset.zero & size),
        Path()..addRRect(frame),
      ),
      Paint()..color = Colors.black54,
    );
    canvas.drawRRect(
      frame,
      Paint()
        ..color = Colors.red
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(_ScanWindowPainter oldDelegate) =>
      oldDelegate.window != window;
}
