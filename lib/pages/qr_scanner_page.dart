import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  // MobileScannerController কে এরর-মুক্ত ভার্সনে ইনিশিয়ালাইজ করা হলো
  final MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    // cameraFacing প্যারামিটারটি এখানে বাদ দেওয়া হয়েছে। ডিফল্টভাবে ব্যাক ক্যামেরা ব্যবহার হবে।
  );

  // স্ক্যান করা URL-এর বেস লিংক
  static const String baseUrl = 'https://pgphs-reunion.com/verify/';

  // Reg ID এক্সট্র্যাক্ট করার ফাংশন
  String? _extractRegId(String url) {
    if (url.startsWith(baseUrl)) {
      // URL এর শেষ অংশটিই হলো Reg ID
      return url.substring(baseUrl.length).toUpperCase();
    }
    return null;
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? scannedUrl = barcodes.first.rawValue;

      if (scannedUrl != null) {
        final regId = _extractRegId(scannedUrl);

        if (regId != null) {
          // স্ক্যান সফল হলে ক্যামেরা বন্ধ করে রেজাল্ট ফেরত পাঠানো হবে
          cameraController.stop();
          if (Navigator.of(context).canPop()) {
            Navigator.pop(context, regId);
          }
        }
      }
    }
  }

  @override
  void dispose() {
    // ক্যামেরা কন্ট্রোলার ডিসপোজ করা জরুরি
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: MobileScanner(
        controller: cameraController,
        onDetect: _onDetect,

        // Overlay UI - স্ক্যানিং এরিয়া
        overlay: Center(
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                'Point camera at QR code',
                style: TextStyle(color: Colors.white, fontSize: 16, decoration: TextDecoration.none),
              ),
            ),
          ),
        ),
      ),
    );
  }
}