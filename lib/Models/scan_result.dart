// lib/models/scan_result.dart
class ScanResult {
  final String? rawValue;
  final String? format;
  final DateTime? timestamp;

  ScanResult({
    this.rawValue,
    this.format,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory ScanResult.fromMap(Map<String, dynamic> map) {
    return ScanResult(
      rawValue: map['rawValue']?.toString(),
      format: map['format']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rawValue': rawValue,
      'format': format,
      'timestamp': timestamp?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return rawValue ?? 'No result';
  }
}