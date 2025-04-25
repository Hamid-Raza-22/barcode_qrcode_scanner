// widgets/scan_result_dialog.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanResultDialog extends StatelessWidget {
  final String value;
  final BarcodeType? type;
  final VoidCallback onScanAgain;
  final VoidCallback onClose;

  const ScanResultDialog({
    super.key,
    required this.value,
    required this.type,
    required this.onScanAgain,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Title
            Row(
              children: [
                Icon(Icons.qr_code_scanner, color: colorScheme.primary, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Scan Result',
                  style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),

            /// Barcode Type
            _buildLabel('Barcode Type'),
            const SizedBox(height: 4),
            Text(_formatBarcodeType(type), style: textTheme.bodyLarge),
            const SizedBox(height: 16),

            /// Scanned Value
            _buildLabel('Scanned Value'),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(value, style: textTheme.bodyMedium),
            ),
            const SizedBox(height: 24),

            /// Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onClose,
                  child: Text('CLOSE', style: TextStyle(color: colorScheme.onSurface)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onScanAgain,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'SCAN AGAIN',
                    style: TextStyle(color: colorScheme.onPrimary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Formats the barcode type to a readable string.
  String _formatBarcodeType(BarcodeType? type) {
    if (type == null) return 'Unknown';
    return type.toString().split('.').last.replaceAll('_', ' ');
  }

  /// Builds a standard label text style.
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: Get.textTheme.bodySmall?.copyWith(
        color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
      ),
    );
  }
}