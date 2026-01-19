import 'package:flutter/material.dart';
import '../../core/api_service.dart'; // ✅ Backend connectivity ke liye

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Complaint Status"),
        backgroundColor: Colors.blue.shade800,
      ),
      // ✅ FutureBuilder se live status fetch ho raha hai
      body: FutureBuilder<List<dynamic>>(
        future: ApiService.getMyComplaints(), // Deepanshu ki API: GET /complaints/my
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("Bhai, aapne abhi tak koi complaint nahi ki hai."),
            );
          }

          final myComplaints = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: myComplaints.length,
            itemBuilder: (context, index) {
              final item = myComplaints[index];
              return _buildStatusCard(item);
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(Map<String, dynamic> data) {
    String status = data['status'] ?? 'Pending'; // Default status
    Color statusColor;

    // ✅ Logic: Admin ke action ke hisab se UI change
    switch (status) {
      case 'Working':
        statusColor = Colors.orange;
        break;
      case 'Solved':
        statusColor = Colors.green;
        break;
      case 'Fake':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  data['category'] ?? "General Issue",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                // ✅ Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(data['description'] ?? "No description provided."),
            const Divider(),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 5),
                Text(
                  "Submitted on: ${data['date'] ?? 'Today'}",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            // ✅ Agar Admin ne Fake mark kiya hai toh reason dikhao
            if (status == 'Fake')
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  "⚠️ This complaint was marked as invalid by Admin.",
                  style: TextStyle(color: Colors.red, fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ),
          ],
        ),
      ),
    );
  }
}