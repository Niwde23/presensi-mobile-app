import 'package:flutter/material.dart';
import '../services/attendance_service.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final AttendanceService _attendanceService = AttendanceService();
  List<dynamic> _historyData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  void _fetchHistory() async {
    final data = await _attendanceService.getHistory();
    setState(() {
      _historyData = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Riwayat Presensi")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _historyData.isEmpty
          ? Center(
              child: Text(
                "Belum ada data presensi.",
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _historyData.length,
              itemBuilder: (context, index) {
                final item = _historyData[index];

                // Memotong format waktu dari database agar lebih rapi (YYYY-MM-DD HH:MM)
                final checkInTime = item['check_in'] != null
                    ? item['check_in']
                          .toString()
                          .substring(0, 16)
                          .replaceFirst('T', ' ')
                    : '-';
                final checkOutTime = item['check_out'] != null
                    ? item['check_out']
                          .toString()
                          .substring(0, 16)
                          .replaceFirst('T', ' ')
                    : 'Belum Pulang';

                return Card(
                  elevation: 2,
                  margin: EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue[100],
                      child: Icon(Icons.history, color: Colors.blue),
                    ),
                    title: Text(
                      "Masuk: $checkInTime",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("Pulang: $checkOutTime"),
                    trailing: item['check_out'] == null
                        ? Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange,
                          )
                        : Icon(Icons.check_circle, color: Colors.green),
                  ),
                );
              },
            ),
    );
  }
}
