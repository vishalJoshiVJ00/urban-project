import 'package:flutter/material.dart';
import '../../core/api_service.dart'; // ✅ API Service import zaroori hai

class AdminView extends StatelessWidget {
  const AdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin War Room (Live Feed)"),
        backgroundColor: Colors.red,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => (context as Element).markNeedsBuild()),
        ],
      ),
      // ✅ Deepanshu ki API se live data fetch karne ka logic
      body: FutureBuilder<List<dynamic>>(
        future: ApiService.getAdminFeed(), // ✅ GET http://localhost:3000/api/v1/complaints/admin
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Bhai, abhi koi complaints nahi hain."));
          }

          final complaints = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              final item = complaints[index];
              return _buildComplaintCard(
                  context,
                  item['title'] ?? "No Title",
                  item['location'] ?? "Unknown",
                  item['citizenName'] ?? "Anonymous",
                  item['email'] ?? "N/A",
                  item['complaintCount'] ?? 0 // ✅ Red border ke liye count
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildComplaintCard(BuildContext context, String title, String loc, String name, String email, int count) {
    // 🔴 Deepanshu ka logic: Agar count 5 ya zyada hai toh Red Border
    bool isUrgent = count >= 5;

    return Card(
      elevation: 5,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        // ✅ "Red Border" Logic Implementation
        side: BorderSide(
            color: isUrgent ? Colors.red : Colors.transparent,
            width: 2.5
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
            backgroundColor: isUrgent ? Colors.red : Colors.orange,
            child: Text("$count", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("By: $name | Loc: $loc"),
        trailing: const Icon(Icons.open_in_new),
        onTap: () => _showFullDetails(context, title, name, loc, email),
      ),
    );
  }

  // ... _showFullDetails, _infoRow, aur _evidenceIcon wahi rahenge jo aapne diye hain ...
  // Bas Resolve/Fake buttons mein Navigator.pop ke baad API call add ki ja sakti hai

  void _showFullDetails(BuildContext context, String title, String name, String loc, String email) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (c) => Container(
        padding: const EdgeInsets.all(25),
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("COMPLAINT FILE: $title", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
            const Divider(),
            _infoRow(Icons.person, "Citizen:", name),
            _infoRow(Icons.email, "Contact:", email),
            _infoRow(Icons.location_on, "Location:", loc),
            const SizedBox(height: 20),
            const Text("Attachments:", style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _evidenceIcon(Icons.image, "Photo", Colors.blue),
                _evidenceIcon(Icons.mic, "Voice", Colors.green),
                _evidenceIcon(Icons.map, "GPS", Colors.orange),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () {
                      Navigator.pop(context);
                      _statusMsg(context, "Complaint Resolved! ✅");
                    },
                    child: const Text("RESOLVE", style: TextStyle(color: Colors.white))
                )),
                const SizedBox(width: 10),
                Expanded(child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _statusMsg(context, "Marked as Fake/Invalid. ⚠️");
                    },
                    child: const Text("MARK FAKE")
                )),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData i, String label, String val) => ListTile(
    leading: Icon(i, color: Colors.blue),
    title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
    subtitle: Text(val, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
  );

  Widget _evidenceIcon(IconData i, String t, Color c) => Column(children: [Icon(i, color: c, size: 40), Text(t)]);

  void _statusMsg(BuildContext context, String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
}