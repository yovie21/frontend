import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class CameraScannerPage extends StatefulWidget {
  final String title;

  const CameraScannerPage({
    super.key,
    this.title = 'Scan Barcode Produk',
  });

  @override
  State<CameraScannerPage> createState() => _CameraScannerPageState();
}

class _CameraScannerPageState extends State<CameraScannerPage> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _isScanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isScanned) return;
    final barcode = capture.barcodes.firstOrNull;
    final code = barcode?.rawValue?.trim();

    if (code != null && code.isNotEmpty) {
      _isScanned = true;
      HapticFeedback.mediumImpact();
      Navigator.of(context).pop(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Camera Viewfinder
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error, child) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt_outlined, color: Colors.redAccent, size: 32),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Izin Kamera Diperlukan',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pastikan izin kamera sudah diberikan di pengaturan HP untuk memindai barcode.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => _controller.start(),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // 2. Viewfinder Overlay & Framing
          SafeArea(
            child: Column(
              children: [
                // Top Action Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black45,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      Row(
                        children: [
                          ValueListenableBuilder<MobileScannerState>(
                            valueListenable: _controller,
                            builder: (context, state, child) {
                              final isTorchOn = state.torchState == TorchState.on;
                              return IconButton(
                                style: IconButton.styleFrom(
                                  backgroundColor: isTorchOn ? const Color(0xFF10B981) : Colors.black45,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                icon: Icon(
                                  isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: () => _controller.toggleTorch(),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black45,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.cameraswitch_rounded, color: Colors.white, size: 20),
                            onPressed: () => _controller.switchCamera(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Center Reticle Box
                Center(
                  child: Container(
                    width: 280,
                    height: 180,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Stack(
                      children: [
                        // Emerald Corner Reticles
                        Positioned(
                          top: 0,
                          left: 0,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Color(0xFF10B981), width: 3.5),
                                left: BorderSide(color: Color(0xFF10B981), width: 3.5),
                              ),
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(18)),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Color(0xFF10B981), width: 3.5),
                                right: BorderSide(color: Color(0xFF10B981), width: 3.5),
                              ),
                              borderRadius: BorderRadius.only(topRight: Radius.circular(18)),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Color(0xFF10B981), width: 3.5),
                                left: BorderSide(color: Color(0xFF10B981), width: 3.5),
                              ),
                              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(18)),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Color(0xFF10B981), width: 3.5),
                                right: BorderSide(color: Color(0xFF10B981), width: 3.5),
                              ),
                              borderRadius: BorderRadius.only(bottomRight: Radius.circular(18)),
                            ),
                          ),
                        ),
                        // Center Red Laser Guide
                        Center(
                          child: Container(
                            height: 1.5,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.redAccent.withOpacity(0.1),
                                  Colors.redAccent,
                                  Colors.redAccent.withOpacity(0.1),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.redAccent.withOpacity(0.5),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Bottom Hint
                Container(
                  margin: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.65),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF10B981), size: 20),
                      SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          'Posisikan barcode di dalam kotak scanner',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
