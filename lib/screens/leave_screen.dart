import 'package:flutter/material.dart';
import '../services/leave_service.dart';

class LeaveScreen extends StatefulWidget {
  @override
  _LeaveScreenState createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  final LeaveService _leaveService = LeaveService();
  final _reasonController = TextEditingController();

  String _selectedType = 'Sakit';
  DateTime? _selectedDate;
  bool _isLoading = false;

  final List<String> _leaveTypes = ['Sakit', 'Cuti Tahunan', 'Izin Penting'];

  // Fungsi memunculkan kalender
  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), // Tidak bisa pilih tanggal mundur
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submit() async {
    if (_selectedDate == null || _reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tanggal dan alasan harus diisi!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Ubah format tanggal jadi YYYY-MM-DD
    String formattedDate =
        "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";

    final result = await _leaveService.submitLeave(
      _selectedType,
      formattedDate,
      _reasonController.text,
    );

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message']),
        backgroundColor: result['success'] ? Colors.green : Colors.red,
      ),
    );

    // Jika sukses, kembali ke dashboard
    if (result['success']) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pengajuan Cuti / Izin")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Pilih Jenis Izin:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedType,
              items: _leaveTypes
                  .map(
                    (type) => DropdownMenuItem(value: type, child: Text(type)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selectedType = value!),
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            SizedBox(height: 20),

            Text(
              "Pilih Tanggal:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            InkWell(
              onTap: _pickDate,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDate == null
                          ? "Pilih Tanggal di Kalender"
                          : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                    ),
                    Icon(Icons.calendar_today, color: Colors.blue),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            Text(
              "Alasan / Keterangan:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _reasonController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                    "Contoh: Sakit demam berdarah (surat dokter menyusul)",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "KIRIM PENGAJUAN",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
