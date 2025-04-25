// models/scan_result_model.dart
import 'dart:ui';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanResultModel {
  final String? value;
  final BarcodeType? type;
  final List<Offset>? corners;

  ScanResultModel({
    this.value,
    this.type,
    this.corners,
  });
}