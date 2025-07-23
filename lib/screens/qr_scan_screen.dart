import 'package:flutter/material.dart';

class QrScanScreen extends StatelessWidget {
  const QrScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Сканировать QR')),
      body: const Center(child: Text('QR-сканер')),
    );
  }
}
