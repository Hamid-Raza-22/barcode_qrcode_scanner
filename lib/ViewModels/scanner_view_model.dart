import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/animation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:camera/camera.dart';
import '../Models/scan_results.dart';
import '../Models/scanner_state.dart';
import '../Repositories/scanner_repository.dart';

class ScannerController extends GetxController with SingleGetTickerProviderMixin{
  final ScannerRepository _repository;

  ScannerController(this._repository);

  // Reactive state variables
  var mobileScannerController = Rxn<MobileScannerController>();
  var cameraController = Rxn<CameraController>();
  var flashEnabled = false.obs;
  var isZoomed = false.obs;
  var lastScanResult = Rxn<ScanResult>();
  var state = ScannerState.initializing.obs;
  late AnimationController _animationController;
  // Add these new properties
  var scanLinePosition = 0.0.obs;
  late Animation<double> _scanAnimation;
  var isScanPaused = false.obs;
  // Add these new variables
  var detectedBarcodeOffset = Offset.zero.obs;
  var detectedBarcodeSize = Size.zero.obs;
  var shouldCenterBarcode = false.obs;
  var targetRect = Rect.zero.obs;
  // In your ScannerController class
  final currentZoomLevel = 1.0.obs;  // Track zoom manually
  final _zoomDebounceTimer = Timer(Duration.zero, () {}).obs;
  final _scanDebouncer = Timer(Duration.zero, () {}).obs;
  // Change this:


// To this:
  @override

  void onInit() {
    super.onInit();
    initializeCamera();
    _setupAnimation();
  }
  void _setupAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scanAnimation = Tween<double>(begin: 0, end: 1).animate(_animationController)
      ..addListener(() {
        scanLinePosition.value = _scanAnimation.value;
      });

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _animationController.forward();
      }
    });

    if (!isScanPaused.value) {
      _animationController.repeat();
    }
  }

  Future<void> initializeCamera() async {
    try {
      state.value = ScannerState.initializing;

      final cameras = await _repository.getAvailableCameras();
      final backCamera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back,
      );

      mobileScannerController.value = await _repository.createScannerController(
        torchEnabled: flashEnabled.value,
        formats: [BarcodeFormat.all],
        autoStart: true,
      );

      // Reset zoom immediately after controller creation
      mobileScannerController.value?.setZoomScale(1.0);
      isZoomed.value = false;

      cameraController.value = await _repository.createCameraController(
        camera: backCamera,
        resolutionPreset: ResolutionPreset.high,
        enableAudio: false,
      );

      state.value = ScannerState.ready;
    } catch (e) {
      state.value = ScannerState.error;
      Get.snackbar('Error', 'Failed to initialize camera: $e');
    }
  }




  void onBarcodeDetected(BarcodeCapture capture) {
    _scanDebouncer.value.cancel();
    _scanDebouncer.value = Timer(Duration(milliseconds: 200), () {
      if (state.value != ScannerState.ready) return;
      // Reset zoom at start of detection
      resetZoom();
      final barcodes = capture.barcodes;
      if (barcodes.isNotEmpty) {
        final barcode = barcodes.first;

        // Store scan result
        lastScanResult.value = ScanResult(
          content: barcode.rawValue ?? 'No Content',
          type: _getBarcodeTypeString(barcode.type),
        );

        // Calculate barcode position and size
        if (barcode.corners != null && barcode.corners!.isNotEmpty) {
          final corners = barcode.corners!;

          // Calculate bounding box of detected barcode
          double minX = corners[0].dx;
          double maxX = corners[0].dx;
          double minY = corners[0].dy;
          double maxY = corners[0].dy;

          for (final corner in corners) {
            minX = min(minX, corner.dx);
            maxX = max(maxX, corner.dx);
            minY = min(minY, corner.dy);
            maxY = max(maxY, corner.dy);
          }

          detectedBarcodeSize.value = Size(maxX - minX, maxY - minY);
          detectedBarcodeOffset.value = Offset(minX, minY);

          // Calculate target position (center of the scanner box)
          final screenSize = Get.size;
          final scannerBoxWidth = screenSize.width * 0.7;
          final scannerBoxHeight = scannerBoxWidth;
          final scannerBoxTop = screenSize.height / 2 - scannerBoxHeight / 2;
          final scannerBoxLeft = screenSize.width / 2 - scannerBoxWidth / 2;

          targetRect.value = Rect.fromLTWH(
            scannerBoxLeft,
            scannerBoxTop,
            scannerBoxWidth,
            scannerBoxHeight,
          );

          // Calculate required translation to center the barcode
          final barcodeCenter = Offset(
            minX + detectedBarcodeSize.value.width / 2,
            minY + detectedBarcodeSize.value.height / 2,
          );

          final targetCenter = Offset(
            targetRect.value.center.dx,
            targetRect.value.center.dy,
          );

          final translationRequired = targetCenter - barcodeCenter;

          // Apply smooth translation
          shouldCenterBarcode.value = true;
          Future.delayed(Duration(milliseconds: 300), () {
            shouldCenterBarcode.value = false;
            _processScanResult();
          });

          // Adjust camera zoom/position based on barcode size
          _adjustCameraForBarcode(barcode);
        }
      }
    } );
  }
// Update the _adjustCameraForBarcode method with these changes
  void _adjustCameraForBarcode(Barcode barcode) {
    if (barcode.corners == null || barcode.corners!.isEmpty) return;
    if (isUserZoomed.value) return;

    final center = _calculateBarcodeCenter(barcode.corners!);
    final distanceFromCenter = _calculateDistanceFromCenter(center);
    final sizeFactor = _calculateBarcodeSizeFactor(barcode);

    final zoomLevel = _calculateOptimalZoom(distanceFromCenter, sizeFactor);
    _smoothZoomTo(zoomLevel);
  }
// Add these methods to your ScannerController class

  Offset _calculateBarcodeCenter(List<Offset> corners) {
    double sumX = 0;
    double sumY = 0;

    for (final corner in corners) {
      sumX += corner.dx;
      sumY += corner.dy;
    }

    return Offset(
      sumX / corners.length,
      sumY / corners.length,
    );
  }

  double _calculateDistanceFromCenter(Offset barcodeCenter) {
    final screenCenter = Offset(0.5, 0.5); // Normalized screen coordinates
    return sqrt(
      pow(barcodeCenter.dx - screenCenter.dx, 2) +
          pow(barcodeCenter.dy - screenCenter.dy, 2),
    );
  }

  double _calculateBarcodeSizeFactor(Barcode barcode) {
    if (barcode.corners == null || barcode.corners!.isEmpty) return 1.0;

    final corners = barcode.corners!;
    double minX = corners[0].dx;
    double maxX = corners[0].dx;
    double minY = corners[0].dy;
    double maxY = corners[0].dy;

    for (final corner in corners) {
      minX = min(minX, corner.dx);
      maxX = max(maxX, corner.dx);
      minY = min(minY, corner.dy);
      maxY = max(maxY, corner.dy);
    }

    final barcodeWidth = maxX - minX;
    final barcodeHeight = maxY - minY;
    final barcodeSize = min(barcodeWidth, barcodeHeight);

    // Target size is about 30% of screen width
    const targetSize = 0.3;
    return barcodeSize / targetSize;
  }

  double _calculateOptimalZoom(double distance, double sizeFactor) {
    const maxDistance = 0.35;
    const minZoom = 1.0;
    const maxZoom = 3.0;

    // Distance-based zoom (more important when far from center)
    final distanceZoom = minZoom + (distance / maxDistance).clamp(0, 1) * (maxZoom - minZoom);

    // Size-based zoom (more important when barcode is small)
    final sizeZoom = 1.0 + (1.0 - sizeFactor).clamp(0, 1) * (maxZoom - minZoom);

    // Weighted average favoring size factor more
    return (sizeZoom * 0.7 + distanceZoom * 0.3).clamp(minZoom, maxZoom);
  }



  void _smoothZoomTo(double targetZoom) {
    _zoomDebounceTimer.value.cancel();
    _animationController.stop(); // Pause scanning animation during zoom

    final animation = Tween<double>(
      begin: currentZoomLevel.value,
      end: targetZoom.clamp(1.0, 3.0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    animation.addListener(() {
      mobileScannerController.value?.setZoomScale(animation.value);
      currentZoomLevel.value = animation.value;
      isZoomed.value = animation.value > 1.1;
    });

    _animationController.forward(from: 0).then((_) {
      if (!isScanPaused.value) {
        _animationController.repeat(); // Resume scanning animation
      }
    });
  }
// Update the toggleZoom method to be less aggressive

  String _getBarcodeTypeString(BarcodeType type) {
    switch (type) {
      case BarcodeType.product:
        return 'QR Code';
      case BarcodeType.isbn:
        return 'EAN-13';
      // case BarcodeType.upca:
      //   return 'UPC-A';
    // Add other types as needed
      default:
        return type.toString().split('.').last;
    }
  }



  void _processScanResult() {
    state.value = ScannerState.paused;
    mobileScannerController.value?.stop(); // Updated API
  }

  void resumeScanning() {
    state.value = ScannerState.ready;
    resetZoom(); // Add this line
    mobileScannerController.value?.start();
    _animationController.repeat();
  }
  void toggleFlash() {
    flashEnabled.toggle();
    mobileScannerController.value?.toggleTorch();
  }

  var isUserZoomed = false.obs;
  var lastAutoZoom = 1.0.obs;

  Future<void> toggleZoom() async {
    await HapticFeedback.lightImpact();
    if (isUserZoomed.value) {
      _smoothZoomTo(lastAutoZoom.value); // Return to auto-zoom level
    } else {
      lastAutoZoom.value = currentZoomLevel.value;
      _smoothZoomTo(min(currentZoomLevel.value + 1.0, 3.0));
    }
    isUserZoomed.toggle();
  }

// Add pinch-to-zoom gesture support
  void handlePinchZoom(double scale) {
    final newZoom = (currentZoomLevel.value * scale).clamp(1.0, 3.0);
    _smoothZoomTo(newZoom);
  }

  void resetZoom() {
    _smoothZoomTo(1.0);
  }

  @override
  void onClose() {
    _zoomDebounceTimer.value.cancel();
    _animationController.dispose();
    _animationController.dispose();
    _repository.disposeControllers(
      scannerController: mobileScannerController.value,
      cameraController: cameraController.value,
    );
    super.onClose();
  }
}