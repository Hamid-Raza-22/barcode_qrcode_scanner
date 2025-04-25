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