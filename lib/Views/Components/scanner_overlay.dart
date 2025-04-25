import 'package:flutter/material.dart';

class ScannerOverlay extends StatefulWidget {
  const ScannerOverlay({super.key});

  @override
  State<ScannerOverlay> createState() => _ScannerOverlayState();
}

class _ScannerOverlayState extends State<ScannerOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(); // repeat forever

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final boxSize = screenWidth * 0.8;
    final top = (screenHeight - boxSize) / 2;
    final left = (screenWidth - boxSize) / 2;

    return Stack(
      children: [
        // Dimmed Areas
        Positioned(top: 0, left: 0, right: 0, height: top, child: _dim()),
        Positioned(top: top, left: 0, width: left, height: boxSize, child: _dim()),
        Positioned(top: top, right: 0, width: left, height: boxSize, child: _dim()),
        Positioned(bottom: 0, left: 0, right: 0, height: top, child: _dim()),

        // Scanner Box with green border
        Positioned(
          top: top,
          left: left,
          width: boxSize,
          height: boxSize,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.indigo, width: 3),
              // borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),

        // Scanning line animation
        Positioned(
          top: top,
          left: left,
          width: boxSize,
          height: boxSize,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    top: _animation.value * boxSize,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 2,
                      color: Colors.indigo,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _dim() => Container(color: Colors.black.withOpacity(0.5));
}
