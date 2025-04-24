import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../Models/scanner_state.dart';

class ScannerRepository {
  Future<List<CameraDescription>> getAvailableCameras() async {
    try {
      return await availableCameras();
    } catch (e) {
      if (e is CameraException) {
        throw ScannerError.initializationFailed;
      }
      rethrow;
    }
  }

  Future<MobileScannerController> createScannerController({
    required bool torchEnabled,
    required List<BarcodeFormat> formats,
    required bool autoStart,
  }) async {
    try {
      return MobileScannerController(
        torchEnabled: torchEnabled,
        formats: formats,
        autoStart: autoStart,
      );
    } catch (e) {
      throw ScannerError.initializationFailed;
    }
  }

  Future<CameraController> createCameraController({
    required CameraDescription camera,
    required ResolutionPreset resolutionPreset,
    required bool enableAudio,
  }) async {
    try {
      final controller = CameraController(
        camera,
        resolutionPreset,
        enableAudio: enableAudio,
      );
      await controller.initialize();
      return controller;
    } catch (e) {
      if (e is CameraException) {
        throw ScannerError.initializationFailed;
      }
      rethrow;
    }
  }

  Future<void> disposeControllers({
    required MobileScannerController? scannerController,
    required CameraController? cameraController,
  }) async {
    try {
      await scannerController?.dispose();
    } catch (e) {
      debugPrint('Error disposing scanner controller: $e');
    }

    try {
      await cameraController?.dispose();
    } catch (e) {
      debugPrint('Error disposing camera controller: $e');
    }
  }
}