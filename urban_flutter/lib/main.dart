import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/app_provider.dart';
import 'screens/dashboard/admin_war_room.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppProvider(),
      child: const UrbanApp(),
    ),
  );
}

class UrbanApp extends StatelessWidget {
  const UrbanApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: provider.isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: const AdminWarRoom(),
    );
  }
}