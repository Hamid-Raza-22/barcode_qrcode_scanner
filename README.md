# 📷 QR Scanner App

This Flutter project implements a scanner screen that mimics the **Google Code Scanner UI** experience. It includes a **live camera preview**, a **stylized scanning box**, **dimmed background**, and a **smooth animated scanning line** to highlight active detection.

---

## 🚀 Features
## Clean MVVM architecture implementation

### ✅ Camera Scanner (To be integrated)
- Prepares for integration with live camera feed.
- Designed for seamless QR and Barcode scanning experience.

### ✅ Custom Overlay UI
- Central scanning box with a rounded green border.
- Dimmed background areas to focus the user's attention.
- Fully responsive layout based on screen size.

### ✅ Scanning Animation
- A moving green scanning line inside the scanner box.
- Smooth and continuous animation using Flutter's `AnimationController`.
- Mimics native Google scanning behavior.

---

## Project Structure 

```
lib/
├── Models/               # Data models and entities
│   └── scan_results.dart # Standard Results
│
├── Repositories/         # Data access layer
│   └── scanner_repository.dart # Logic for controlling scan states
│
├── ViewModels/           # Business logic layer
│   └──scanner_viewmodel.dart # Manages application state
│
├── Views/                # Presentation layer
│   ├── scanner_screen.dart  # Main chat interface
│   │
│   ├── Components/          # Reusable UI components
│   │   ├── scanner_overlay.dart # Overlay UI with dimming, animated scan line
│   │   ├── scanner_debug_info.dart # Debug info widget
│   │   └── scanner_app_bar.dart # App bar with camera toggle
│   │
│   └── Widgets/             # Reusable UI widgets  
│        └── sanner_result_dailog.dart # Animated dailog indicator
│
└── main.dart            # Application entry point
```