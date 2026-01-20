import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart'; // ✅ Permissions ke liye
import 'package:shared_preferences/shared_preferences.dart'; // ✅ Storage ke liye

// --- Core Imports ---
import 'core/app_provider.dart';

// --- Screen Imports ---
import 'screens/dashboard/admin_war_room.dart'; // ✅ Dashboard/Home
import 'screens/complaints/citizen_auth.dart';

void main() async {
  // ✅ Compulsory for async initialization
  WidgetsFlutterBinding.ensureInitialized();
  // ✅ App start hote hi Permissions maangega (Storage, Camera, Location)
  await _requestInitialPermissions();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: const UrbanApp(),
    ),
  );
}

// 🛠️ 1. Global Permission Handler
Future<void> _requestInitialPermissions() async {
  await [
    Permission.location,
    Permission.camera,
    Permission.microphone,
    Permission.storage,
  ].request();
}

class UrbanApp extends StatelessWidget {
  const UrbanApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppProvider>(context);

    return MaterialApp(
      title: 'Urban Super System',
      debugShowCheckedModeBanner: false,
      theme: appState.isDarkMode
          ? ThemeData.dark().copyWith(
        primaryColor: Colors.blueAccent,
        scaffoldBackgroundColor: const Color(0xFF121212),
      )
          : ThemeData.light().copyWith(
        primaryColor: Colors.blue,
      ),
      // ✅ FIXED: Now opens login/signup screen for OTP
      home: const CitizenAuth(), // ✅ Changed from AdminWarRoom
    );
  }
}