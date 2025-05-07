// lib/views/scanner_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../ViewModels/scanner_view_model.dart';

class ScannerScreen extends StatelessWidget {
  final ScannerViewModel viewModel = Get.put(ScannerViewModel());

  ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auto Zoom Barcode Scanner')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(() => ElevatedButton(
              onPressed: viewModel.isLoading.value ? null : viewModel.startScan,
              child: viewModel.isLoading.value
                  ? const CircularProgressIndicator()
                  : const Text('Start Scanning'),
            )),
            const SizedBox(height: 20),
            Obx(() {
              if (viewModel.scanResult.value.rawValue != null) {
                return Column(
                  children: [
                    const Text('Scan Result:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    SelectableText(
                      viewModel.scanResult.value.toString(),
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    if (viewModel.scanResult.value.format != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Format: ${viewModel.scanResult.value.format}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                  ],
                );
              }
              return const SizedBox();
            }),
          ],
        ),
      ),
    );
  }
}