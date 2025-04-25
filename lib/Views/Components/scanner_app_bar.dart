import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../ViewModels/scanner_view_model.dart';

class ScannerAppBar extends StatelessWidget {
  final ScannerViewModel viewModel;

  const ScannerAppBar({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(Get.context!).padding.top + 16,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.back<dynamic>(),
          ),
          IconButton(
            icon: Obx(() => Icon(
              viewModel.isTorchOn.value ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
            )),
            onPressed: viewModel.toggleTorch,
          ),
        ],
      ),
    );
  }
}
