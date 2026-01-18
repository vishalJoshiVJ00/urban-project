import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000/api/v1'; // Emulator ke liye

  // 1️⃣ Send OTP
  static Future<bool> sendOtp(String contact) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/send-otp'),
      body: jsonEncode({'contact': contact}),
      headers: {'Content-Type': 'application/json'},
    );
    return response.statusCode == 200;
  }

  // 2️⃣ Verify OTP & Save Token
  static Future<String?> verifyOtp(String contact, String otp) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/verify-otp'),
      body: jsonEncode({'contact': contact, 'otp': otp}),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Token aur Login status save karna zaroori hai
      await prefs.setString('token', data['token']);
      await prefs.setBool('isLoggedIn', true);

      // Deepanshu agar user details bhej raha hai toh wo bhi yahan save karein
      if (data['user'] != null) {
        await prefs.setString('firstName', data['user']['firstName'] ?? "");
        await prefs.setString('surname', data['user']['surname'] ?? "");
        await prefs.setString('contact', contact);
      }

      return data['token'];
    }
    return null;
  }

  // 3️⃣ Get Admin Feed (Deepanshu's Header Logic)
  static Future<List<dynamic>> getAdminFeed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$baseUrl/complaints/admin'),
      headers: {
        'Authorization': 'Bearer $token', // Header authentication
      },
    );
    return response.statusCode == 200 ? jsonDecode(response.body) : [];
  }

  // 🚪 4️⃣ LOGOUT LOGIC (Error Fix for Line 67)
  // Dashboard isi static function ko dhund raha tha
  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Logic: Memory se saara login data saaf kar do
    await prefs.clear();

    // Debugging ke liye:
    print("User session cleared successfully.");
  }
}