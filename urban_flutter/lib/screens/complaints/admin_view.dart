import 'package:flutter/material.dart';

class AdminView extends StatelessWidget {
  const AdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin War Room"), backgroundColor: Colors.red),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          // Ye cards wahi data dikhayenge jo citizen ne form me bhara tha
          _buildComplaintCard(context, "Garbage Issue", "Ward 12", "Rahul Kumar", "rahul@test.com", 7),
          _buildComplaintCard(context, "Water Leakage", "Main Chauraha", "Amit Ji", "amit@test.com", 3),
        ],
      ),
    );
  }

  Widget _buildComplaintCard(BuildContext context, String title, String loc, String name, String email, int count) {
    bool isHigh = count >= 5;
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(side: BorderSide(color: isHigh ? Colors.red : Colors.transparent), borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: isHigh ? Colors.red : Colors.orange, child: Text("$count")),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("By: $name | Loc: $loc"),
        trailing: const Icon(Icons.open_in_new),
        onTap: () => _showFullDetails(context, title, name, loc, email),
      ),
    );
  }

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
                      _statusMsg(context, "Complaint Resolved! Citizen notified. ✅");
                    },
                    child: const Text("RESOLVE")
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