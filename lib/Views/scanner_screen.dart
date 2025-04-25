import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../ViewModels/scanner_view_model.dart';
import 'Components/scanner_app_bar.dart';
import 'Components/scanner_debug_info.dart';
import 'Components/scanner_overlay.dart';


class ScannerScreen extends StatelessWidget {
  ScannerScreen({Key? key}) : super(key: key);

  final ScannerViewModel viewModel = Get.put(ScannerViewModel());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(
            () => Stack(
          children: [
            if (viewModel.isControllerReady.value)
              MobileScanner(
                controller: viewModel.cameraController,
                onDetect: viewModel.handleBarcode,
                fit: BoxFit.contain,
              ),
            if (!viewModel.isControllerReady.value)
              const Center(child: CircularProgressIndicator(color: Colors.white)),
            const ScannerOverlay(),
            ScannerAppBar(viewModel: viewModel),
            if (viewModel.isControllerReady.value)
              ScannerDebugInfo(viewModel: viewModel),
          ],
        ),
      ),
    );
  }
}
