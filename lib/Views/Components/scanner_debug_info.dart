import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../ViewModels/scanner_view_model.dart';

class ScannerDebugInfo extends StatelessWidget {
  final ScannerViewModel viewModel;

  const ScannerDebugInfo({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 32,
      left: 16,
      right: 16,
      child: Obx(() => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (viewModel.showZoomOutButton.value)
            ElevatedButton.icon(
              onPressed: viewModel.resetScanner,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.indigo,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.zoom_out,color: Colors.white,),
              label: const Text('Zoom Out'),
            ),
          const SizedBox(height: 8),
          // Text(
          //   'Zoom: ${viewModel.currentZoom.value.toStringAsFixed(2)}x',
          //   style: GoogleFonts.montserrat(
          //     color: Colors.white,
          //     fontSize: 14,
          //   ),
          // ),
          // const SizedBox(height: 8),

          // const SizedBox(height: 4),
          Text(
            'Auto Zoom In: ${viewModel.countdownSeconds.value}s',
            style: GoogleFonts.montserrat(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      )),
    );
  }
}
