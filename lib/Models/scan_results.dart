class ScanResult {
  final String content;
  final String type;
  final DateTime scanTime;

  ScanResult({
    required this.content,
    required this.type,
  }) : scanTime = DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'type': type,
      'scanTime': scanTime.toIso8601String(),
    };
  }
}