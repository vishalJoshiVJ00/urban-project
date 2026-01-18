import 'package:flutter/material.dart';
import '../../widgets/kpi_card.dart';
import '../chat_bot_screen.dart'; // AI Bot ke liye
import '../complaints/war_room_screen.dart'; // Complaints ke liye

class AdminWarRoom extends StatelessWidget {
  const AdminWarRoom({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("URBAN COMMAND CENTER")),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(15),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                // 1. AI CityBrain Card
                KpiCard(
                  title: "AI CityBrain",
                  icon: Icons.psychology,
                  color: Colors.blue,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) =>  CityBrainBot())),
                ),
                // 2. Complaints Card
                KpiCard(
                  title: "Complaints",
                  icon: Icons.report,
                  color: Colors.red,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const ComplaintsWarRoom())),
                ),
                // 3. Property Dashboard (Placeholder)
                KpiCard(
                  title: "Property Tax",
                  icon: Icons.money,
                  color: Colors.green,
                  onTap: () => print("Property Tapped"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search 200+ features...",
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ),
    );
  }
}