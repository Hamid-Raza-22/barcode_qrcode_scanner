
package com.example.barcode_qrcode_scanner

import android.app.Activity
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import com.google.mlkit.vision.codescanner.GmsBarcodeScanner
import com.google.mlkit.vision.codescanner.GmsBarcodeScanning
import com.google.mlkit.vision.barcode.common.Barcode
import com.google.mlkit.vision.codescanner.GmsBarcodeScannerOptions


class MainActivity: FlutterActivity() {
    private val CHANNEL = "google_code_scanner"
    private lateinit var scanner: GmsBarcodeScanner

    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Configure scanner with auto-zoom and all formats
        scanner = GmsBarcodeScanning.getClient(this,
            GmsBarcodeScannerOptions.Builder()
                .setBarcodeFormats(
                    Barcode.FORMAT_QR_CODE,
                    Barcode.FORMAT_AZTEC,
                    Barcode.FORMAT_DATA_MATRIX,
                    Barcode.FORMAT_UPC_A,
                    Barcode.FORMAT_UPC_E,
                    Barcode.FORMAT_EAN_8,
                    Barcode.FORMAT_EAN_13,
                    Barcode.FORMAT_CODE_39,
                    Barcode.FORMAT_CODE_93,
                    Barcode.FORMAT_CODE_128,
                    Barcode.FORMAT_CODABAR,
                    Barcode.FORMAT_ITF,
                    Barcode.FORMAT_PDF417
                )
                .enableAutoZoom()
//                .enableAllPotentialBarcodes() // Optional
                .build()
        )

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            when (call.method) {
                "startScan" -> {
                    scanner.startScan()
                        .addOnSuccessListener { barcode ->
                            result.success(mapOf(
                                "rawValue" to barcode.rawValue,
                                "format" to barcode.format,
                                "displayValue" to barcode.displayValue
                            ))
                        }
                        .addOnCanceledListener {
                            result.success(null) // User canceled
                        }
                        .addOnFailureListener { e ->
                            result.error("SCAN_FAILED", e.message, null)
                        }
                }
                else -> result.notImplemented()
            }
        }
    }
}
