import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AttendanceService {
  // Ingat: Gunakan '10.0.2.2' untuk Emulator Android, atau IP WiFi kamu untuk HP asli
  static const String baseUrl = 'http://192.168.1.6:3000/api/attendance';

  // Fungsi Check-In (Kirim Foto + GPS)
  Future<Map<String, dynamic>> checkIn(
    String lat,
    String long,
    String imagePath,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      // Karena kita kirim foto (file), kita harus pakai MultipartRequest
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/checkin'),
      );

      // Masukkan Token ke Header
      request.headers.addAll({'Authorization': 'Bearer $token'});

      // Masukkan teks lat & long
      request.fields['lat'] = lat;
      request.fields['long'] = long;

      // Masukkan file foto
      request.files.add(await http.MultipartFile.fromPath('photo', imagePath));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      var data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server!'};
    }
  }

  // Fungsi Check-Out (Hanya butuh Token)
  Future<Map<String, dynamic>> checkOut() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('$baseUrl/checkout'),
        headers: {'Authorization': 'Bearer $token'},
      );

      var data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server!'};
    }
  }

  // Fungsi Mengambil Riwayat Presensi
  Future<List<dynamic>> getHistory() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('$baseUrl/history'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return data['data']; // Mengembalikan List berisi data presensi
      } else {
        return [];
      }
    } catch (e) {
      print("Error fetching history: $e");
      return [];
    }
  }
}
