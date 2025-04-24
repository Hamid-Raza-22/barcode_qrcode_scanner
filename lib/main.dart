import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:barcode_qrcode_scanner/Repositories/scanner_repository.dart';
import 'package:barcode_qrcode_scanner/views/scanner_screen.dart';

void main() {
  // Initialize dependencies before running the app
  Get.put(ScannerRepository()); // Add this line

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
        primarySwatch: Colors.blue,
      ),
      home:  ScannerScreen(),
    );
  }
}