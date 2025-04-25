import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerRepository {
  Future<bool> toggleTorch(
      MobileScannerController controller,
      bool currentState,
      ) async {
    await controller.toggleTorch();
    return !currentState;
  }

  Future<void> setZoom(
      MobileScannerController controller,
      double zoom,
      ) async {
    try {
      await controller.setZoomScale(zoom);
    } catch (e) {
      throw Exception('Failed to set zoom: $e');
    }
  }

  Future<void> restartCamera(MobileScannerController controller) async {
    try {
      await controller.stop();
      await controller.start();
    } catch (e) {
      throw Exception('Failed to restart camera: $e');
    }
  }
}
