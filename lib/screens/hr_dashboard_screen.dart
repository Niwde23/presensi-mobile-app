import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/leave_service.dart';
import 'login_screen.dart';

class HRDashboardScreen extends StatefulWidget {
  @override
  _HRDashboardScreenState createState() => _HRDashboardScreenState();
}

class _HRDashboardScreenState extends State<HRDashboardScreen> {
  final LeaveService _leaveService = LeaveService();
  List<dynamic> _leaveRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLeaves();
  }

  void _fetchLeaves() async {
    final data = await _leaveService.getAllLeaves();
    setState(() {
      _leaveRequests = data;
      _isLoading = false;
    });
  }

  void _processLeave(String id, String status) async {
    bool success = await _leaveService.updateStatus(id, status);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status berhasil diubah!'),
          backgroundColor: Colors.green,
        ),
      );
      _fetchLeaves(); // Refresh data
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengubah status!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('role');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard HR"),
        backgroundColor: Colors.deepPurple,
        actions: [IconButton(icon: Icon(Icons.logout), onPressed: _logout)],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _leaveRequests.isEmpty
          ? Center(child: Text("Belum ada pengajuan cuti/izin."))
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _leaveRequests.length,
              itemBuilder: (context, index) {
                final item = _leaveRequests[index];
                final String status = item['status'];
                final String date = item['date'].toString().substring(0, 10);

                // Tentukan warna badge status
                Color statusColor = Colors.orange;
                if (status == 'approved') statusColor = Colors.green;
                if (status == 'rejected') statusColor = Colors.red;

                return Card(
                  elevation: 3,
                  margin: EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item['employee_name'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Chip(
                              label: Text(
                                status.toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              backgroundColor: statusColor,
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Text("Jenis: ${item['type']}  |  Tanggal: $date"),
                        SizedBox(height: 5),
                        Text(
                          "Alasan: ${item['reason']}",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        SizedBox(height: 10),

                        // Tampilkan tombol hanya jika statusnya masih pending
                        if (status == 'pending')
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => _processLeave(
                                  item['id'].toString(),
                                  'rejected',
                                ),
                                child: Text(
                                  "TOLAK",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                              SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () => _processLeave(
                                  item['id'].toString(),
                                  'approved',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                child: Text(
                                  "SETUJUI",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
