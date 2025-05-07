# 📷 QR Scanner App

This Flutter project implements a scanner screen that mimics the **Google Code Scanner UI** experience. It includes a **live camera preview**, a **stylized scanning box**, **dimmed background**, and a **smooth animated scanning line** to highlight active detection.

---

## 🚀 Features
-  Clean MVVM architecture pattern
-  GetX for state management and dependency injection
-  Platform-specific barcode scanning via MethodChannel
-  Simple UI with scan results display
-  Error handling with user feedback
-  Bi-directional Flutter-Android communication

---
## 1: Architecture Overview
Flutter UI (Dart) → Platform Channel → Android (Kotlin) → ML Kit Barcode Scanner → Results
___

##  2:A  Flutter MVVM Project Structure 

```
lib/
├── Models/
│   └── scan_result.dart       # Data model
├── Repositories/
│   └── scanner_repository.dart # Data abstraction
├── Services/
│   └── google_code_scanner.dart # Platform-specific code
├── View_models/
│   └── scanner_view_model.dart # Business logic
├── Views/
│   └── scanner_screen.dart    # UI Layer
└── main.dart                  # App entry point
```
## 2:B Flutter Architecture Components

### Models
**File:** `lib/Models/scan_result.dart`
- Defines data structure for scan results
- Contains:
    - `rawValue`: Scanned data content
    - `format`: Barcode type (QR, EAN-13, etc.)
    - `timestamp`: When scan occurred
- Handles data serialization/deserialization

### Repositories
**File:** `lib/Repositories/scanner_repository.dart`
- Abstracts data operations
- Responsibilities:
    - Converts raw data to model objects
    - Centralizes error handling
    - Acts as single source of truth for scan data

### Services
**File:** `lib/Services/google_code_scanner.dart`
- Platform channel implementation
- Features:
    - Handles native method invocations
    - Manages cross-platform communication
    - Bridges Flutter and native Android code

### ViewModels
**File:** `lib/View_models/scanner_view_model.dart`
- Manages application state using GetX
- Functions:
    - Processes business logic
    - Mediates between View and Repository
    - Provides reactive state management
    - Handles scan lifecycle (loading/success/error)

### Views
**File:** `lib/Views/scanner_screen.dart`
- UI presentation layer
- Contains:
    - All widgets and visual elements
    - User interaction handlers
    - State observers (via GetX)
- Responsibilities:
    - Displays scan button and results
    - Shows loading states
    - Listens to ViewModel state changes  

---
## 3: Android Native Components
---
### MainActivity.kt
**Location:** `android/app/src/main/kotlin/<your-package>/MainActivity.kt`

#### 3.A: Initialization
- Configures ML Kit Barcode Scanner with:
    - **Supported Formats**:
      ```kotlin
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
      ```
    - **Features**:
        - Auto-zoom enabled (`enableAutoZoom()`)
        - Optional potential barcodes detection (`enableAllPotentialBarcodes()`)

#### 3.B: Method Channel Setup
- Registers handler for channel: `google_code_scanner`
- Implemented methods:
    - `startScan`: Main scanning interface

#### 3.C: Scan Process Flow
```mermaid

sequenceDiagram
  participant UI as ScannerScreen
  participant VM as ScannerViewModel
  participant Repo as ScannerRepository
  participant Service as GoogleCodeScanner
  participant Android as MainActivity
  participant MLKit as GmsBarcodeScanner
 
  UI->>VM: User taps "Start Scanning"
  VM->>Repo: startScan()
  Repo->>Service: scan()
  Service->>Android: invokeMethod("startScan")
  Android->>MLKit: startScan()
  MLKit-->>Android: Shows scanner UI


sequenceDiagram
  participant MLKit as GmsBarcodeScanner
  participant Android as MainActivity
  participant Service as GoogleCodeScanner
  participant Repo as ScannerRepository
  participant VM as ScannerViewModel
  participant UI as ScannerScreen
 
  MLKit->>Android: Returns Barcode object
  Android->>Service: Converts to Map{rawValue, format}
  Service->>Repo: Returns Map
  Repo->>VM: Creates ScanResult model
  VM->>UI: Updates Obx() widgets

Native Android (Kotlin):
Barcode Object → 
  Map<String,Object> → 
    Platform Channel → 
      Flutter (Dart): Map<String,dynamic> → 
        ScanResult Model


### Workflow
sequenceDiagram
    User->>UI: Tap Scan Button
    UI->>ViewModel: startScan()
    ViewModel->>Repository: scan()
    Repository->>Service: invokeMethod()
    Service->>Android: "startScan"
    Android->>MLKit: Launch Scanner
    MLKit-->>User: Show Camera UI
    User->>MLKit: Scan Barcode
    MLKit->>Android: Return Result
    Android->>Flutter: Send Data Map
    Flutter->>UI: Update Results
