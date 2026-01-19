import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrcodeScanView extends StatefulWidget {
  const QrcodeScanView({super.key});
  @override
  State<QrcodeScanView> createState() => _QrcodeScanViewState();
}

class _QrcodeScanViewState extends State<QrcodeScanView> {
  // ポップされたかどうかを管理するフラグ
  // popが複数回呼ばれないようにするため
  bool _hasPopped = false;

  @override
  void initState() {
    super.initState();
    _hasPopped = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR')),
      body: MobileScanner(
        controller: MobileScannerController(
          detectionSpeed: DetectionSpeed.noDuplicates,
        ),
        onDetect: (capture) {
          if (_hasPopped) return;

          final barcodes = capture.barcodes;
          if (barcodes.isEmpty) return;

          final raw = barcodes.first.rawValue;
          if (raw == null) return;

          final address = _extractBitcoinAddress(raw);
          if (address == null) return;

          _hasPopped = true;
          Navigator.pop(context, address);
        },
      ),
    );
  }

  String? _extractBitcoinAddress(String qr) {
    // BIP21: bitcoin:tb1xxxx?amount=...
    if (qr.startsWith('bitcoin:')) {
      final uri = Uri.tryParse(qr);
      return uri?.path;
    }

    // 生アドレス
    if (qr.startsWith('m') || qr.startsWith('n') || qr.startsWith('tb1')) {
      return qr;
    }

    return null;
  }
}
