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

  Future<void> _typeCode() async {
    final textController = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Digitar código'),
        content: TextField(
          controller: textController,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Linha digitável'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(textController.text),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    textController.dispose();
    if (!mounted || value == null || value.trim().isEmpty || _handled) return;
    _handled = true;
    Navigator.of(context).pop(
      ScanRecord(value.trim(), BarcodeFormat.unknown, _stopwatch.elapsed),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          const padding = 16.0;
          final scanWindow = Rect.fromCenter(
            center: constraints.biggest.center(Offset.zero),
            width: constraints.maxWidth * 0.4,
            height: constraints.maxHeight - padding * 2,
          );
          final gutterWidth = scanWindow.left;
          return Stack(
            fit: StackFit.expand,
            children: [
              // No scanWindow on the scanner: like the reference, the barcode
              // only needs to cross the red line, it can overflow the window.
              MagScannerView(
                controller: _controller,
                onDetect: _onDetect,
                errorBuilder: (context, error) => Center(
                  child: Text(
                    'Erro na câmera: ${error.errorCode.name}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              IgnorePointer(
                child: CustomPaint(painter: _ScanMaskPainter(scanWindow)),
              ),
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: gutterWidth,
                child: Center(
                  child: RotatedBox(
                    quarterTurns: 1,
                    child: TextButton(
                      onPressed: _typeCode,
                      style: TextButton.styleFrom(
                        foregroundColor: _accentPink,
                      ),
                      child: const Text(
                        'DIGITAR CÓDIGO',
                        style: TextStyle(fontSize: 15, letterSpacing: 0.5),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: gutterWidth,
                child: const Center(
                  child: RotatedBox(
                    quarterTurns: 1,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'Posicione o Código de Barras de suas contas sobre a '
                        'linha vermelha e aguarde a leitura automática',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: SafeArea(
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

const _accentPink = Color(0xFFFF5A79);

/// Dark mask with a rounded vertical window and a red line along its center.
class _ScanMaskPainter extends CustomPainter {
  _ScanMaskPainter(this.window);

  final Rect window;

  @override
  void paint(Canvas canvas, Size size) {
    final frame = RRect.fromRectAndRadius(window, const Radius.circular(24));
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Offset.zero & size),
        Path()..addRRect(frame),
      ),
      Paint()..color = const Color(0xD91E1E1E),
    );
    canvas.drawLine(
      Offset(window.center.dx, window.top),
      Offset(window.center.dx, window.bottom),
      Paint()
        ..color = Colors.red
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_ScanMaskPainter oldDelegate) =>
      oldDelegate.window != window;
}
