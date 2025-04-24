enum ScannerState {
  initializing,
  ready,
  scanning,
  paused,
  error,
}
enum ScannerError {
  noCameraAvailable,
  initializationFailed,
  permissionDenied;

  String get message {
    switch (this) {
      case ScannerError.noCameraAvailable:
        return 'No camera available on this device';
      case ScannerError.initializationFailed:
        return 'Failed to initialize camera';
      case ScannerError.permissionDenied:
        return 'Camera permission denied';
    }
  }
}