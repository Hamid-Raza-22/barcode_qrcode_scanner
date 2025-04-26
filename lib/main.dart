import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:barcode_qrcode_scanner/ViewModels/scanner_view_model.dart';
import 'package:barcode_qrcode_scanner/views/scanner_screen.dart';

Future<void> main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Barcode Scanner',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialBinding: ScannerBinding(), // Use GetX binding for dependency injection
      home:  ScannerScreen(),
    );
  }
}

// Create a binding class to handle dependency injection
class ScannerBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ScannerViewModel(), permanent: true);
  }
}

// import 'package:flutter/material.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Barcode Scanner with Auto-Zoom',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const BarcodeScannerScreen(),
//     );
//   }
// }
//
// class BarcodeScannerScreen extends StatefulWidget {
//   const BarcodeScannerScreen({super.key});
//
//   @override
//   State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
// }
//
// class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
//   final MobileScannerController controller = MobileScannerController(
//     autoStart: true,
//     detectionSpeed: DetectionSpeed.noDuplicates, // Optimized for auto-zoom
//     detectionTimeoutMs: 1000,
//     returnImage: false,
//   );
//
//   String? lastScannedCode;
//   bool isScanning = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _setupScanner();
//   }
//
//   Future<void> _setupScanner() async {
//     // Optional: Set initial zoom level (0.0 to 1.0)
//     await controller.setZoomScale(0.3);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Barcode Scanner'),
//         actions: [
//           IconButton(
//             icon: Icon(isScanning ? Icons.stop : Icons.play_arrow),
//             onPressed: () {
//               setState(() {
//                 isScanning = !isScanning;
//                 if (isScanning) {
//                   controller.start();
//                 } else {
//                   controller.stop();
//                 }
//               });
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: Stack(
//               children: [
//                 MobileScanner(
//                   controller: controller,
//                   onDetect: (BarcodeCapture barcode) {
//                     final String? code = barcode.barcodes.firstOrNull?.rawValue;
//                     if (code != null && code != lastScannedCode) {
//                       setState(() {
//                         lastScannedCode = code;
//                       });
//                       _showScannedCode(context, code);
//                     }
//                   },
//                 ),
//                 // Scanner overlay
//                 CustomPaint(
//                   painter: ScannerOverlay(),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.all(16),
//             color: Colors.black.withOpacity(0.4),
//             child: Row(
//               children: [
//                 const Text(
//                   'Last scanned:',
//                   style: TextStyle(color: Colors.white, fontSize: 16),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     lastScannedCode ?? 'None',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       // floatingActionButton: FloatingActionButton(
//       //   onPressed: () {
//       //     // Toggle torch
//       //     controller.toggleTorch();
//       //   },
//       //   child: ValueListenableBuilder(
//       //     valueListenable: controller.torchState,
//       //     builder: (context, state, child) {
//       //       switch (state) {
//       //         case TorchState.off:
//       //           return const Icon(Icons.flash_off);
//       //         case TorchState.on:
//       //           return const Icon(Icons.flash_on);
//       //       }
//       //     },
//       //   ),
//       // ),
//     );
//   }
//
//   void _showScannedCode(BuildContext context, String code) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Scanned: $code'),
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }
// }
//
// // Custom scanner overlay
// class ScannerOverlay extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final width = size.width;
//     final height = size.height;
//     const cutoutSize = 200.0;
//
//     final backgroundPaint = Paint()
//       ..color = Colors.black.withOpacity(0.5);
//
//     final cutoutPaint = Paint()
//       ..color = Colors.transparent
//       ..blendMode = BlendMode.clear;
//
//     // Draw background
//     canvas.drawRect(
//       Rect.fromLTRB(0, 0, width, height),
//       backgroundPaint,
//     );
//
//     // Draw transparent cutout
//     final cutoutRect = Rect.fromCenter(
//       center: Offset(width / 2, height / 2),
//       width: cutoutSize,
//       height: cutoutSize,
//     );
//     canvas.drawRect(cutoutRect, cutoutPaint);
//
//     // Draw border around cutout
//     final borderPaint = Paint()
//       ..color = Colors.white
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 2.0;
//
//     canvas.drawRect(cutoutRect, borderPaint);
//
//     // Draw corner marks
//     const cornerLength = 20.0;
//     const cornerWidth = 4.0;
//
//     final cornerPaint = Paint()
//       ..color = Colors.green
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = cornerWidth;
//
//     // Top-left corner
//     canvas.drawPath(
//       Path()
//         ..moveTo(cutoutRect.left, cutoutRect.top + cornerLength)
//         ..lineTo(cutoutRect.left, cutoutRect.top)
//         ..lineTo(cutoutRect.left + cornerLength, cutoutRect.top),
//       cornerPaint,
//     );
//
//     // Top-right corner
//     canvas.drawPath(
//       Path()
//         ..moveTo(cutoutRect.right - cornerLength, cutoutRect.top)
//         ..lineTo(cutoutRect.right, cutoutRect.top)
//         ..lineTo(cutoutRect.right, cutoutRect.top + cornerLength),
//       cornerPaint,
//     );
//
//     // Bottom-left corner
//     canvas.drawPath(
//       Path()
//         ..moveTo(cutoutRect.left, cutoutRect.bottom - cornerLength)
//         ..lineTo(cutoutRect.left, cutoutRect.bottom)
//         ..lineTo(cutoutRect.left + cornerLength, cutoutRect.bottom),
//       cornerPaint,
//     );
//
//     // Bottom-right corner
//     canvas.drawPath(
//       Path()
//         ..moveTo(cutoutRect.right - cornerLength, cutoutRect.bottom)
//         ..lineTo(cutoutRect.right, cutoutRect.bottom)
//         ..lineTo(cutoutRect.right, cutoutRect.bottom - cornerLength),
//       cornerPaint,
//     );
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return false;
//   }
// }
//
//
//








// import 'dart:io';
// import 'dart:typed_data';
// import 'package:camera/camera.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   final cameras = await availableCameras();
//   runApp(MyApp(cameras: cameras));
// }
//
// class MyApp extends StatelessWidget {
//   final List<CameraDescription> cameras;
//   const MyApp({super.key, required this.cameras});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'QR Code Scanner',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: QRScannerPage(cameras: cameras),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }
//
// class QRScannerPage extends StatefulWidget {
//   final List<CameraDescription> cameras;
//   const QRScannerPage({super.key, required this.cameras});
//
//   @override
//   State<QRScannerPage> createState() => _QRScannerPageState();
// }
//
// class _QRScannerPageState extends State<QRScannerPage> {
//   late CameraController _cameraController;
//   late BarcodeScanner _barcodeScanner;
//   bool _isDetecting = false;
//   String? _barcodeValue;
//
//   @override
//   void initState() {
//     super.initState();
//     _initialize();
//   }
//
//   Future<void> _initialize() async {
//     await Permission.camera.request();
//
//     _barcodeScanner = BarcodeScanner();
//
//     _cameraController = CameraController(
//       widget.cameras.firstWhere(
//             (camera) => camera.lensDirection == CameraLensDirection.back,
//       ),
//       ResolutionPreset.medium,
//       enableAudio: false,
//     );
//
//     await _cameraController.initialize();
//     _startImageStream();
//     setState(() {});
//   }
//
//   void _startImageStream() {
//     _cameraController.startImageStream((CameraImage cameraImage) async {
//       if (_isDetecting) return;
//       _isDetecting = true;
//
//       try {
//         final WriteBuffer allBytes = WriteBuffer();
//         for (Plane plane in cameraImage.planes) {
//           allBytes.putUint8List(plane.bytes);
//         }
//         final bytes = allBytes.done().buffer.asUint8List();
//
//         final inputImage = InputImage.fromBytes(
//           bytes: bytes,
//           metadata: InputImageMetadata(
//             size: Size(
//               cameraImage.width.toDouble(),
//               cameraImage.height.toDouble(),
//             ),
//             rotation: InputImageRotation.rotation0deg,
//             format: Platform.isAndroid
//                 ? InputImageFormat.nv21
//                 : InputImageFormat.bgra8888,
//             bytesPerRow: Platform.isAndroid
//                 ? 0
//                 : cameraImage.planes.first.bytesPerRow,
//           ),
//         );
//
//         final List<Barcode> barcodes = await _barcodeScanner.processImage(inputImage);
//
//         if (barcodes.isNotEmpty) {
//           final value = barcodes.first.rawValue;
//
//           if (value != null && value != _barcodeValue) {
//             setState(() {
//               _barcodeValue = value;
//             });
//
//             // ✅ Show Dialog when QR is scanned
//             if (mounted) {
//               showDialog(
//                 context: context,
//                 builder: (context) => AlertDialog(
//                   title: const Text('QR Code Detected!'),
//                   content: Text(value),
//                   actions: [
//                     TextButton(
//                       onPressed: () => Navigator.pop(context),
//                       child: const Text('OK'),
//                     ),
//                   ],
//                 ),
//               );
//             }
//           }
//         }
//       } catch (e) {
//         print('Error during scanning: $e');
//       } finally {
//         _isDetecting = false;
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _cameraController.dispose();
//     _barcodeScanner.close();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (!_cameraController.value.isInitialized) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('QR Code Scanner'),
//       ),
//       body: Stack(
//         children: [
//           CameraPreview(_cameraController),
//           if (_barcodeValue != null)
//             Align(
//               alignment: Alignment.bottomCenter,
//               child: Container(
//                 color: Colors.black54,
//                 padding: const EdgeInsets.all(16),
//                 child: Text(
//                   'Scanned: $_barcodeValue',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 20,
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }



//
// class QRScannerScreen extends StatefulWidget {
//   const QRScannerScreen({super.key});
//
//   @override
//   State<QRScannerScreen> createState() => _QRScannerScreenState();
// }
//
// class _QRScannerScreenState extends State<QRScannerScreen> {
//   final MobileScannerController controller = MobileScannerController(
//     autoStart: true,
//     formats: [BarcodeFormat.qrCode],
//     detectionSpeed: DetectionSpeed.noDuplicates,
//     detectionTimeoutMs: 250,
//     returnImage: false,
//
//
//   );
//
//   bool _torchEnabled = false;
//   CameraFacing _cameraFacing = CameraFacing.back;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('QR Code Scanner'),
//       ),
//       body: Stack(
//         children: [
//           MobileScanner(
//             controller: controller,
//             onDetect: (capture) {
//               final List<Barcode> barcodes = capture.barcodes;
//               for (final barcode in barcodes) {
//                 debugPrint('Barcode found! ${barcode.rawValue}');
//                 // Handle the scanned QR code here
//               }
//             },
//           ),
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: Container(
//               alignment: Alignment.bottomCenter,
//               height: 100,
//               color: Colors.black.withOpacity(0.4),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   IconButton(
//                     color: Colors.white,
//                     icon: Icon(
//                         _torchEnabled ? Icons.flash_on : Icons.flash_off),
//                     iconSize: 32.0,
//                     onPressed: () {
//                       setState(() {
//                         _torchEnabled = !_torchEnabled;
//                       });
//                       controller.toggleTorch();
//                     },
//                   ),
//                   IconButton(
//                     color: Colors.white,
//                     icon: Icon(_cameraFacing == CameraFacing.back
//                         ? Icons.camera_rear
//                         : Icons.camera_front),
//                     iconSize: 32.0,
//                     onPressed: () {
//                       setState(() {
//                         _cameraFacing = _cameraFacing == CameraFacing.back
//                             ? CameraFacing.front
//                             : CameraFacing.back;
//                       });
//                       controller.switchCamera();
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }
// }