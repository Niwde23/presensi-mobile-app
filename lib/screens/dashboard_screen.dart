import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/attendance_service.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AttendanceService _attendanceService = AttendanceService();
  bool _isLoading = false;

  // Fungsi minta izin GPS dan ambil lokasi
  Future<Position?> _determinePosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }
    return await Geolocator.getCurrentPosition();
  }

  // Aksi Tombol Check-In
  void _handleCheckIn() async {
    setState(() {
      _isLoading = true;
    });

    // 1. Buka Kamera
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50, // Perkecil ukuran foto agar cepat dikirim
    );

    if (photo != null) {
      // 2. Ambil Lokasi GPS
      Position? position = await _determinePosition();

      if (position != null) {
        // 3. Kirim ke Server API
        final result = await _attendanceService.checkIn(
          position.latitude.toString(),
          position.longitude.toString(),
          photo.path,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: result['success'] ? Colors.green : Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Izin GPS ditolak!'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Aksi Tombol Check-Out
  void _handleCheckOut() async {
    setState(() {
      _isLoading = true;
    });
    final result = await _attendanceService.checkOut();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message']),
        backgroundColor: result['success'] ? Colors.green : Colors.red,
      ),
    );
    setState(() {
      _isLoading = false;
    });
  }

  // Aksi Logout
  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Hapus KTP Digital
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard Karyawan"),
        actions: [IconButton(icon: Icon(Icons.logout), onPressed: _logout)],
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, size: 80, color: Colors.blue),
                  SizedBox(height: 20),
                  Text(
                    "Siap Bekerja Hari Ini?",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 40),
                  ElevatedButton.icon(
                    onPressed: _handleCheckIn,
                    icon: Icon(Icons.camera_alt),
                    label: Text("CHECK IN (Masuk)"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _handleCheckOut,
                    icon: Icon(Icons.exit_to_app),
                    label: Text("CHECK OUT (Pulang)"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
