import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LeaveService {
  // GANTI IP INI SESUAI IP LAPTOP KAMU SEPERTI SEBELUMNYA!
  static const String baseUrl = 'http://192.168.1.6:3000/api/leave';

  Future<Map<String, dynamic>> submitLeave(
    String type,
    String date,
    String reason,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('$baseUrl/request'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'type': type, 'date': date, 'reason': reason}),
      );

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
}
