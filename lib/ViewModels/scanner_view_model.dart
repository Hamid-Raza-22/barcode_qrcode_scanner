// lib/view_models/scanner_view_model.dart
import 'package:get/get.dart';
import '../models/scan_result.dart';
import '../Repositories/scanner_repository.dart';

class ScannerViewModel extends GetxController {
  final ScannerRepository _repository = ScannerRepository();

  final RxBool isLoading = false.obs;
  final Rx<ScanResult> scanResult = ScanResult().obs;

  Future<void> startScan() async {
    try {
      isLoading.value = true;
      scanResult.value = ScanResult(); // Reset to empty result

      final result = await _repository.scan();
      scanResult.value = result;
    } finally {
      isLoading.value = false;
    }
  }
}