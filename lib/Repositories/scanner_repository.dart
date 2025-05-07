// lib/repositories/scanner_repository.dart
import 'package:get/get.dart';
import '../Services/google_code_scanner.dart';
import '../models/scan_result.dart';


class ScannerRepository {
  final GoogleCodeScanner _scanner = GoogleCodeScanner();

  Future<ScanResult> scan() async {
    try {
      final result = await _scanner.scan();
      return ScanResult.fromMap(result ?? {});
    } catch (e) {
      Get.snackbar('Error', 'Failed to scan: $e');
      return ScanResult(); // Returns empty result
    }
  }
}