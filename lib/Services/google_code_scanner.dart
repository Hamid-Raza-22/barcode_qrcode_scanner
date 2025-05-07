// lib/services/google_code_scanner.dart
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class GoogleCodeScanner {
  static const MethodChannel _channel = MethodChannel('google_code_scanner');

  Future<Map<String, dynamic>> scan() async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>('startScan');
      return result?.cast<String, dynamic>() ?? {};
    } on PlatformException catch (e) {
      Get.snackbar('Error', 'Failed to scan: ${e.message}');
      throw Exception('Failed to scan: ${e.message}');
    }
  }
}