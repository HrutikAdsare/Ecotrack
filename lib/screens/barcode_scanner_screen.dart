// lib/screens/barcode_scanner_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerScreen extends StatelessWidget {
  const BarcodeScannerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        backgroundColor: Colors.green,
      ),
      body: MobileScanner(
        allowDuplicates: false,
        onDetect: (barcode, args) {
          final String code = barcode.rawValue ?? "";
          Navigator.pop(context, code);
        },
      ),
    );
  }
}
