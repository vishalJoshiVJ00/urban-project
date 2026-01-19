import 'package:flutter/material.dart';
import 'dart:convert'; // ✅ Base64 photo dikhane ke liye
import '../../core/api_service.dart';

class AdminView extends StatefulWidget {
  const AdminView({super.key});
  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> {
  // ✅ 1. Status Update karne ka function
  void _updateStatus(String id, String newStatus) async {
    bool ok = await ApiService.updateStatus(id, newStatus);
    if (ok) {
      setState(() {}); // Screen refresh karein
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Status Updated!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin War Room (Feed)"), backgroundColor: Colors.red.shade900),
      body: FutureBuilder<List<dynamic>>(
        future: ApiService.getAdminFeed(), // ✅ Deepanshu ki sorted feed API
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Koi complaints nahi hain!"));

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var item = snapshot.data![index];
              int priority = item['priorityScore'] ?? 0;

              // ✅ 2. Priority Logic: Score 9-10 par Red Border
              bool isUrgent = priority >= 9;

              return Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: isUrgent ? Border.all(color: Colors.red, width: 3) : null,
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.5), blurRadius: 5)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ 3. Base64 Image Display
                    item['image'] != null
                        ? Image.memory(base64Decode(item['image']), height: 200, width: double.infinity, fit: BoxFit.cover)
                        : Container(height: 100, color: Colors.grey, child: const Center(child: Text("No Image"))),

                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(item['category'].toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              Chip(label: Text("Priority: $priority"), backgroundColor: isUrgent ? Colors.red : Colors.orange),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(item['description'] ?? "No description"),
                          const Divider(),
                          const Text("Update Status:", style: TextStyle(fontWeight: FontWeight.bold)),

                          // ✅ 4. Status Buttons (Deepanshu ne valid status "working", "solved", "fake" maange hain)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton(onPressed: () => _updateStatus(item['id'], "working"), style: ElevatedButton.styleFrom(backgroundColor: Colors.orange), child: const Text("WORKING")),
                              ElevatedButton(onPressed: () => _updateStatus(item['id'], "solved"), style: ElevatedButton.styleFrom(backgroundColor: Colors.green), child: const Text("SOLVED")),
                              ElevatedButton(onPressed: () => _updateStatus(item['id'], "fake"), style: ElevatedButton.styleFrom(backgroundColor: Colors.grey), child: const Text("FAKE")),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}