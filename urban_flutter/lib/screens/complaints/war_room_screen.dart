import 'package:flutter/material.dart';

class ComplaintsWarRoom extends StatelessWidget {
  const ComplaintsWarRoom({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Complaints Management")),
      body: const Center(
        child: Text("Live Complaints Data from Node.js will show here"),
      ),
    );
  }
}