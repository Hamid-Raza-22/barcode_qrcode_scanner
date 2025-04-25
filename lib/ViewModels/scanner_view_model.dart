import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../Views/Widgets/scan_result_dialog.dart';
import '../repositories/scanner_repository.dart';

class ScannerViewModel extends GetxController with GetTickerProviderStateMixin {
  final ScannerRepository _repository = ScannerRepository();

  late MobileScannerController cameraController;
  late AnimationController zoomController;
  late Animation<double> zoomAnimation;

  final isCameraInitialized = false.obs;
  final cameraError = ''.obs;
  final isTorchOn = false.obs;
  final hasScanned = false.obs;
  final scannedValue = ''.obs;
  final scannedType = Rx<BarcodeType?>(null);
  final currentZoom = 1.0.obs;
  final shouldAdjustZoom = true.obs;
  final noDetectionCount = 0.obs;
  final lastDetectedBarcodeSize = 0.0.obs;
  final isControllerReady = false.obs;
  final isDialogShowing = false.obs;
  final isZoomed = false.obs;
  final showZoomOutButton = false.obs;
  final countdownSeconds = 10.obs;

  DateTime? _countdownStartTime;
  Timer? _countdownTimer;
  Timer? _zoomTimer;

  @override
  void onInit() {
    super.onInit();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    cameraController = MobileScannerController(
      autoStart: true,
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );

    zoomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    zoomAnimation = Tween<double>(begin: 1.0, end: 2.0).animate(
      CurvedAnimation(parent: zoomController, curve: Curves.easeInOut),
    )..addListener(handleZoomChange);

    try {
      await cameraController.autoStart;
      isControllerReady.value = true;
      startInitialZoom();
    } catch (e) {
      debugPrint('Camera controller error: $e');
    }
  }

  void handleZoomChange() {
    if (!isControllerReady.value || !shouldAdjustZoom.value) return;
    currentZoom.value = zoomAnimation.value;
    _repository.setZoom(cameraController, currentZoom.value).catchError(
          (e) => debugPrint('Error setting zoom: $e'),
    );
  }

  void startInitialZoom() {
    if (hasScanned.value) return;

    _zoomTimer?.cancel();
    _countdownTimer?.cancel();
    countdownSeconds.value = 10;
    _countdownStartTime = DateTime.now();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isControllerReady.value || hasScanned.value) {
        timer.cancel();
        return;
      }
      final elapsed = DateTime.now().difference(_countdownStartTime!).inSeconds;
      countdownSeconds.value = 10 - elapsed;

      if (countdownSeconds.value <= 0) {
        timer.cancel();
        showZoomOutButton.value = true;
        if (shouldAdjustZoom.value) {
          zoomController.animateTo(0.1, duration: const Duration(seconds: 30), curve: Curves.linear).then((_) {
            isZoomed.value = true;
          });
        }
      }
    });

    _zoomTimer = Timer(const Duration(seconds: 10), () {
      if (!hasScanned.value && isControllerReady.value && shouldAdjustZoom.value) {
        zoomController.animateTo(0.1, duration: const Duration(seconds: 30), curve: Curves.linear);
      }
    });
  }

  void zoomOutManually() {
    zoomController.reset();
    zoomController.animateTo(1.0, duration: const Duration(milliseconds: 1000), curve: Curves.easeInOut).then((_) {
      isZoomed.value = false;
      showZoomOutButton.value = false;
      startInitialZoom();
    });
  }

  void handleBarcode(BarcodeCapture barcode) {
    if (!isControllerReady.value || hasScanned.value || barcode.barcodes.isEmpty) {
      noDetectionCount.value++;
      if (noDetectionCount.value > 5 && shouldAdjustZoom.value) {
        adjustZoomForNoDetection();
      }
      return;
    }

    final firstBarcode = barcode.barcodes.first;
    final corners = firstBarcode.corners;
    if (corners.length >= 4) {
      handleSmartZoom(corners);
    }

    hasScanned.value = true;
    scannedValue.value = firstBarcode.rawValue ?? '';
    scannedType.value = firstBarcode.type;
    shouldAdjustZoom.value = false;
    noDetectionCount.value = 0;
    HapticFeedback.mediumImpact();
    _showResultDialog();
  }
  void _showResultDialog() {
    Get.dialog<void>(
      ScaleTransition(
        scale: CurvedAnimation(
          parent: AlwaysStoppedAnimation(1.0),
          curve: Curves.easeOutBack,
        ),
        child: ScanResultDialog(
          value: scannedValue.value,
          type: scannedType.value,
          onScanAgain: () {
            Get.back<dynamic>();
            resetScanner();
          },
          onClose: () {
            Get.back<dynamic>();
            resetScanner();
          },
        ),
      ),
      barrierDismissible: false,
      barrierColor: Colors.black.withAlpha(179),
      transitionDuration: const Duration(milliseconds: 400),
      transitionCurve: Curves.easeOutQuart,
    ).then((_) => isDialogShowing.value = false);
  }
  void handleSmartZoom(List<Offset> corners) {
    final width = (corners[1].dx - corners[0].dx).abs();
    final height = (corners[3].dy - corners[0].dy).abs();
    final barcodeSize = (width + height) / 2;
    lastDetectedBarcodeSize.value = barcodeSize;

    final screenSize = Get.size;
    final screenDiagonal = sqrt(pow(screenSize.width, 2) + pow(screenSize.height, 2));

    Offset barcodeCenter = Offset.zero;
    for (final corner in corners) {
      barcodeCenter += corner;
    }
    barcodeCenter /= corners.length.toDouble();

    final normalizedSize = (barcodeSize / screenDiagonal).clamp(0.01, 0.99);

    double targetZoom = normalizedSize < 0.1 ? 0.9 : (normalizedSize < 0.3 ? 0.6 : 0.3);

    final centerOffset = Offset(
      (barcodeCenter.dx - screenSize.width / 2) / (screenSize.width / 2),
      (barcodeCenter.dy - screenSize.height / 2) / (screenSize.height / 2),
    );
    final centerDistance = sqrt(pow(centerOffset.dx, 2) + pow(centerOffset.dy, 2));

    if (centerDistance > 0.4) {
      targetZoom *= (1 - centerDistance * 0.5).clamp(0.3, 1.0);
    }

    zoomController.animateTo(targetZoom, duration: const Duration(milliseconds: 1500), curve: Curves.easeInOut).then((_) {
      startInitialZoom();
    });
  }

  void adjustZoomForNoDetection() {
    final currentValue = zoomController.value;
    final target = currentValue > 0.1 ? currentValue * 0.8 : 0.3;
    zoomController.animateTo(target, duration: const Duration(milliseconds: 3000), curve: Curves.easeInOut);
    noDetectionCount.value = 0;
  }

  Future<void> resetScanner() async {
    _zoomTimer?.cancel();
    _countdownTimer?.cancel();
    countdownSeconds.value = 10;
    showZoomOutButton.value = false;
    isZoomed.value = false;
    zoomController.stop();

    hasScanned.value = false;
    scannedValue.value = '';
    scannedType.value = null;
    shouldAdjustZoom.value = true;
    noDetectionCount.value = 0;
    currentZoom.value = 1.0;

    zoomController.value = 0.3;

    try {
      await cameraController.stop();
      await cameraController.start();
      startInitialZoom();
    } catch (e) {
      debugPrint('Error resetting camera: $e');
      await initializeCamera();
    }
  }

  Future<void> toggleTorch() async {
    isTorchOn.value = await _repository.toggleTorch(cameraController, isTorchOn.value);
  }

  @override
  void onClose() {
    _zoomTimer?.cancel();
    _countdownTimer?.cancel();
    zoomController.dispose();
    if (isControllerReady.value) {
      cameraController.dispose();
    }
    super.onClose();
  }
}
