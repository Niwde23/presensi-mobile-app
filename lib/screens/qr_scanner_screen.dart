import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/attendance_service.dart';

class QRScannerScreen extends StatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final AttendanceService _attendanceService = AttendanceService();
  bool _isProcessing = false;

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return; // Mencegah scan berkali-kali dalam 1 detik

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;
      if (code != null) {
        setState(() {
          _isProcessing = true;
        });

        // Tampilkan loading di layar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Memproses QR Code...'),
            duration: Duration(seconds: 1),
          ),
        );

        // Kirim data QR ke backend
        final result = await _attendanceService.checkInQR(code);

        // Tutup halaman scanner dan kembali ke dashboard sambil membawa pesan
        if (mounted) {
          Navigator.pop(context, result);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scan QR Code Kantor')),
      body: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(onDetect: _onDetect),
          // Bikin kotak target ala-ala scanner
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.greenAccent, width: 4),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          Positioned(
            bottom: 50,
            child: Text(
              "Arahkan kamera ke QR Code Kantor",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                backgroundColor: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
