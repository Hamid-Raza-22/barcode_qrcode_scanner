import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../Models/scanner_state.dart';
import '../Repositories/scanner_repository.dart';
import '../ViewModels/scanner_view_model.dart';

class ScannerScreen extends StatelessWidget {
  ScannerScreen({super.key});

  final ScannerController controller = Get.put(
    ScannerController(Get.find<ScannerRepository>()),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildCameraPreview(),
          _buildScannerOverlay(context),
          _buildAppBar(),
          _buildStatusIndicator(),
          _buildBottomControls(),
          // _buildHelpButton(),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    return Obx(() {
      if (controller.state.value == ScannerState.error) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 48),
              const SizedBox(height: 16),
              Text(
                'Camera Error',
                style: Theme.of(Get.context!).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please check camera permissions',
                style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  foregroundColor: Colors.black,
                ),
                onPressed: controller.initializeCamera,
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }

      if (controller.cameraController.value == null ||
          !controller.cameraController.value!.value.isInitialized) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.greenAccent),
              SizedBox(height: 16),
              Text(
                'Initializing camera...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        );
      }

      return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: controller.cameraController.value!.value.previewSize?.width ??
                Get.width,
            height:
            controller.cameraController.value!.value.previewSize?.height ??
                Get.height,
            child: MobileScanner(
              controller: controller.mobileScannerController.value,
              onDetect: controller.onBarcodeDetected,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildScannerOverlay(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scannerBoxWidth = size.width * 0.7;
    final scannerBoxHeight = scannerBoxWidth;
    final scannerBoxTop = size.height / 2 - scannerBoxHeight / 2;

    return Obx(() {
      // Animated scanner line
      final scanLine =
      Positioned(
        top: scannerBoxTop + (scannerBoxHeight * controller.scanLinePosition.value),
        left: size.width * 0.15,
        right: size.width * 0.15,
        child: Container(
          height: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.greenAccent.withOpacity(0),
                Colors.greenAccent,
                Colors.greenAccent.withOpacity(0),
              ],
              stops: const [0.1, 0.5, 0.9],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.greenAccent.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 8,
              ),
            ],
          ),
        ),
      );

      // Scanner frame
      final frame = Center(
        child: Container(
          width: scannerBoxWidth,
          height: scannerBoxHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.greenAccent.withOpacity(0.5),
              width: 2,
            ),
          ),
        ),
      );

      // Corner indicators
      final cornerLength = 20.0;
      final cornerWidth = 4.0;
      final topLeftCorner = Positioned(
        top: scannerBoxTop,
        left: size.width * 0.15,
        child: _buildCornerIndicator(cornerLength, cornerWidth, true, true),
      );
      final topRightCorner = Positioned(
        top: scannerBoxTop,
        right: size.width * 0.15,
        child: _buildCornerIndicator(cornerLength, cornerWidth, false, true),
      );
      final bottomLeftCorner = Positioned(
        top: scannerBoxTop + scannerBoxHeight - cornerLength,
        left: size.width * 0.15,
        child: _buildCornerIndicator(cornerLength, cornerWidth, true, false),
      );
      final bottomRightCorner = Positioned(
        top: scannerBoxTop + scannerBoxHeight - cornerLength,
        right: size.width * 0.15,
        child: _buildCornerIndicator(cornerLength, cornerWidth, false, false),
      );

      // Dimmed area around scanner box
      final dimmedArea = Column(
        children: [
          Container(
            height: scannerBoxTop,
            color: Colors.black.withOpacity(0.6),
          ),
          Container(
            height: scannerBoxHeight,
            color: Colors.transparent,
          ),
          Expanded(
            child: Container(
              color: Colors.black.withOpacity(0.6),
            ),
          ),
        ],
      );

      // Barcode detected indicator
      final barcodeIndicator = controller.detectedBarcodeOffset.value != Offset.zero
          ? Positioned(
        left: controller.detectedBarcodeOffset.value.dx * size.width,
        top: controller.detectedBarcodeOffset.value.dy * size.height,
        child: Container(
          width: controller.detectedBarcodeSize.value.width * size.width,
          height: controller.detectedBarcodeSize.value.height * size.height,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.greenAccent.withOpacity(0.8),
              width: 2,
            ),
          ),
        ),
      )
          : const SizedBox();
// Add the zoom indicator here (new code)
      final zoomIndicator = controller.isZoomed.value
          ? Positioned(
        bottom: 100,
        right: 20,
        child: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Zoom ${controller.currentZoomLevel.value.toStringAsFixed(1)}x',
            style: TextStyle(color: Colors.white),
          ),
        ),
      )
          : SizedBox();
      return Stack(
        children: [
          dimmedArea,
          frame,
          if (controller.state.value == ScannerState.ready) scanLine,
          topLeftCorner,
          topRightCorner,
          bottomLeftCorner,
          bottomRightCorner,
          barcodeIndicator,
        ],
      );
    });
  }

  Widget _buildCornerIndicator(
      double length, double width, bool isLeft, bool isTop) {
    return SizedBox(
      width: length,
      height: length,
      child: CustomPaint(
        painter: _CornerPainter(
          color: Colors.greenAccent,
          strokeWidth: width,
          isLeft: isLeft,
          isTop: isTop,
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Positioned(
      top: MediaQuery.of(Get.context!).padding.flipped.top,
      left: 0,
      right: 0,
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Obx(() {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _getTitleText(controller.state.value),
              key: ValueKey(controller.state.value),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: Get.back,
        ),
        actions: [
          Obx(() {
            if (controller.state.value == ScannerState.paused) {
              return IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: _shareResult,
              );
            }
            return const SizedBox();
          }),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return Positioned(
      top: MediaQuery.of(Get.context!).padding.top + kToolbarHeight + 16,
      left: 0,
      right: 0,
      child: Obx(() {
        if (controller.state.value == ScannerState.ready ||
            controller.state.value == ScannerState.initializing) {
          return Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (controller.state.value == ScannerState.initializing)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.greenAccent,
                      ),
                    ),
                  if (controller.state.value == ScannerState.initializing)
                    const SizedBox(width: 8),
                  Text(
                    _getStatusText(controller.state.value),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox();
      }),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 30,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Column(
          children: [
            Obx(() => AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: controller.lastScanResult.value != null
                  ? _buildResultPreview()
                  : const SizedBox(key: ValueKey('empty')),
            )),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 80),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _ControlButton(
                    icon: controller.flashEnabled.value
                        ? Icons.flash_on
                        : Icons.flash_off,
                    label: 'Flash',
                    onTap: controller.toggleFlash,
                    isActive: controller.flashEnabled.value,
                  ),
                  // _ControlButton(
                  //   icon: controller.state.value == ScannerState.paused
                  //       ? Icons.qr_code_scanner
                  //       : Icons.camera,
                  //   label: controller.state.value == ScannerState.paused
                  //       ? 'Scan Again'
                  //       : 'Capture',
                  //   onTap: controller.state.value == ScannerState.paused
                  //       ? controller.resumeScanning
                  //       : null,
                  //   isPrimary: true,
                  // ),
                  _ControlButton(
                    icon: controller.isZoomed.value
                        ? Icons.zoom_out
                        : Icons.zoom_in,
                    label: 'Zoom',
                    onTap: controller.toggleZoom,
                    isActive: controller.isZoomed.value,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultPreview() {
    return Container(
      key: const ValueKey('result-preview'),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.greenAccent.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                  controller.lastScanResult.value?.type == 'QR Code'
                      ? Icons.qr_code
                      : Icons.barcode_reader,
                  color: Colors.greenAccent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Scanned ${controller.lastScanResult.value?.type}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: controller.resumeScanning,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(
              controller.lastScanResult.value?.content ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _copyToClipboard,
                child: const Text(
                  'COPY',
                  style: TextStyle(color: Colors.greenAccent),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHelpButton() {
    return Positioned(
      bottom: 100,
      right: 20,
      child: FloatingActionButton.small(
        backgroundColor: Colors.black.withOpacity(0.6),
        foregroundColor: Colors.white,
        heroTag: 'help',
        onPressed: _showHelpDialog,
        child: const Icon(Icons.help_outline),
      ),
    );
  }

  String _getStatusText(ScannerState state) {
    return switch (state) {
      ScannerState.initializing => 'Initializing scanner...',
      ScannerState.ready => 'Align the code within the frame',
      ScannerState.scanning => 'Scanning...',
      ScannerState.paused => 'Scan complete',
      ScannerState.error => 'Error occurred',
    };
  }

  String _getTitleText(ScannerState state) {
    return switch (state) {
      ScannerState.initializing => 'Scanner',
      ScannerState.ready => 'Scan Code',
      ScannerState.scanning => 'Scanning...',
      ScannerState.paused => 'Scan Result',
      ScannerState.error => 'Error',
    };
  }

  void _copyToClipboard() async {
    if (controller.lastScanResult.value?.content != null) {
      await Clipboard.setData(
          ClipboardData(text: controller.lastScanResult.value!.content));
      Get.snackbar(
        'Copied',
        'Text copied to clipboard',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.greenAccent,
        colorText: Colors.black,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void _shareResult() {
    // Implement share functionality
    if (controller.lastScanResult.value?.content != null) {
      // Share.share(controller.lastScanResult.value!.content);
      Get.snackbar(
        'Share',
        'Sharing functionality would be implemented here',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _showHelpDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Scanning Help', style: TextStyle(color: Colors.white)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How to scan:',
              style: TextStyle(color: Colors.greenAccent, fontSize: 16),
            ),
            SizedBox(height: 8),
            _HelpItem(icon: Icons.crop_free, text: 'Align the code within the frame'),
            _HelpItem(icon: Icons.lightbulb_outline, text: 'Use flash in low light'),
            _HelpItem(icon: Icons.zoom_in, text: 'Zoom if code is too small'),
            SizedBox(height: 16),
            Text(
              'Supported formats:',
              style: TextStyle(color: Colors.greenAccent, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text('• QR Codes', style: TextStyle(color: Colors.white)),
            Text('• Barcodes', style: TextStyle(color: Colors.white)),
            Text('• EAN-13', style: TextStyle(color: Colors.white)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('GOT IT', style: TextStyle(color: Colors.greenAccent)),
          ),
        ],
      ),
    );
  }
}

class _HelpItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HelpItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.greenAccent, size: 20),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final bool isLeft;
  final bool isTop;

  _CornerPainter({
    required this.color,
    required this.strokeWidth,
    required this.isLeft,
    required this.isTop,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    if (isTop) {
      if (isLeft) {
        path.moveTo(size.width, 0);
        path.lineTo(0, 0);
        path.lineTo(0, size.height);
      } else {
        path.moveTo(0, 0);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, size.height);
      }
    } else {
      if (isLeft) {
        path.moveTo(0, 0);
        path.lineTo(0, size.height);
        path.lineTo(size.width, size.height);
      } else {
        path.moveTo(size.width, 0);
        path.lineTo(size.width, size.height);
        path.lineTo(0, size.height);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isActive;
  final bool isPrimary;

  const _ControlButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.isActive = false,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: isPrimary ? 60 : 50,
            height: isPrimary ? 60 : 50,
            decoration: BoxDecoration(
              color:
              isPrimary
                  ? Colors.greenAccent.withOpacity(0.9)
                  : Colors.white.withOpacity(isActive ? 0.2 : 0.1),
              shape: BoxShape.circle,
              border:
              isPrimary
                  ? Border.all(color: Colors.greenAccent, width: 2)
                  : null,
            ),
            child: Icon(
              icon,
              color: isPrimary ? Colors.black : Colors.white,
              size: isPrimary ? 30 : 24,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
        ),
      ],
    );
  }
}