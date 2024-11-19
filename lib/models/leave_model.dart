import 'package:flutter/material.dart';

class LeaveFormPage extends StatefulWidget {
  @override
  _LeaveFormPageState createState() => _LeaveFormPageState();
}

class _LeaveFormPageState extends State<LeaveFormPage> {
  final TextEditingController reasonController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Form Pengajuan Ijin'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Alasan Ijin'),
              items: ['Cuti', 'Sakit', 'Lainnya'].map((String reason) {
                return DropdownMenuItem<String>(
                  value: reason,
                  child: Text(reason),
                );
              }).toList(),
              onChanged: (value) {},
            ),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(labelText: 'Penjelasan Detail'),
            ),
            // Add more fields as needed
            ElevatedButton(
              onPressed: () {
                // Submit form
              },
              child: Text('Kirim'),
            ),
          ],
        ),
      ),
    );
  }
}
