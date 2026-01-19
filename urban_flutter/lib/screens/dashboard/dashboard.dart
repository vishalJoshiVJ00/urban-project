import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../complaints/citizen_auth.dart';
import '../complaints/complaint_form.dart'; // ✅ Form import kiya
import '../../core/api_service.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool isLoggedIn = false;
  String userName = "";

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  _checkAuth() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      // Deepanshu ki API 'name' save kar rahi hai, toh hum 'name' key use karenge
      userName = prefs.getString('name') ?? "User";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        title: const Text("Urban Super System"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: InkWell(
              onTap: () async {
                if (isLoggedIn) {
                  _showProfile();
                } else {
                  await Navigator.push(context, MaterialPageRoute(builder: (c) => const CitizenAuth()));
                  _checkAuth();
                }
              },
              child: Row(
                children: [
                  Text(isLoggedIn ? userName : "Login", style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 5),
                  Icon(isLoggedIn ? Icons.account_circle : Icons.login),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Welcome to Urban Dashboard", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 30),

            // ✅ Complaint Hub Button with Smart Logic
            _dashboardCard(
              title: "Complaint Hub",
              icon: Icons.report_problem,
              color: Colors.orange,
              onTap: () async {
                if (isLoggedIn) {
                  // ✅ Pehle se login hai toh seedha Form kholo
                  Navigator.push(context, MaterialPageRoute(builder: (c) => const ComplaintForm()));
                } else {
                  // ❌ Login nahi hai toh Login Screen par bhejo
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Bhai, shikayat ke liye login zaroori hai!"))
                  );
                  await Navigator.push(context, MaterialPageRoute(builder: (c) => const CitizenAuth()));
                  _checkAuth(); // Wapas aane par status refresh
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Dashboard Card Helper
  Widget _dashboardCard({required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 10),
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  void _showProfile() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (c) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.account_circle, size: 80, color: Colors.blue),
            const SizedBox(height: 10),
            Text(userName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout"),
              onTap: () async {
                await ApiService.logout();
                Navigator.pop(context);
                _checkAuth();
              },
            ),
          ],
        ),
      ),
    );
  }
}