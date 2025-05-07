# Flutter
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.** { *; }

# ML Kit Barcode Scanning
-keep class com.google.mlkit.** { *; }
-keep interface com.google.mlkit.** { *; }

# Google Play Services
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Prevent stripping Kotlin metadata
-keep class kotlin.Metadata { *; }

# Keep Barcode class and other scanner internals
-keep class com.google.mlkit.vision.barcode.common.Barcode { *; }
-keep class com.google.mlkit.vision.codescanner.** { *; }

# Optional: CameraX if you ever use it
-keep class androidx.camera.** { *; }
-dontwarn androidx.camera.**
# Play Core split install (used by Flutter deferred components or PlayStoreSplitApplication)
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }

# Keep FlutterPlayStoreSplitApplication (prevent R8 from removing it)
-keep class io.flutter.embedding.android.FlutterPlayStoreSplitApplication { *; }
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }

-keep class com.google.android.play.** { *; }
-dontwarn com.google.android.play.**
