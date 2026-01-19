import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'citizen_auth.dart';
import 'complaint_form.dart';
import 'status_screen.dart';

class ComplaintsMain extends StatefulWidget {
  const ComplaintsMain({super.key});
  @override
  State<ComplaintsMain> createState() => _ComplaintsMainState();
}

class _ComplaintsMainState extends State<ComplaintsMain> {
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  _checkStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() => isLoggedIn = prefs.getBool('isLoggedIn') ?? false);
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      return const CitizenAuth(); // Pehle login as Citizen/Admin dikhao
    }
    // Agar Dashboard se pehle hi login hai, toh seedha ye options:
    return Scaffold(
      appBar: AppBar(title: const Text("Complaint Hub")),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          _hubBtn("New Complaint Form", Icons.edit_note, () => Navigator.push(context, MaterialPageRoute(builder: (c) => const ComplaintForm()))),
          const SizedBox(height: 20),
          _hubBtn("Check Problem Status", Icons.track_changes, () => Navigator.push(context, MaterialPageRoute(builder: (c) => const StatusScreen()))),
        ]),
      ),
    );
  }

  Widget _hubBtn(String t, IconData i, VoidCallback p) => ElevatedButton.icon(
    style: ElevatedButton.styleFrom(minimumSize: const Size(280, 60)),
    onPressed: p, icon: Icon(i), label: Text(t),
  );
}