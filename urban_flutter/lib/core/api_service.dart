import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // ✅ Deepanshu ke phone/laptop ka IP yahan set hai
  static const String baseUrl = 'http://192.168.1.4:3000/api/v1';

  // 1️⃣ Email Check
  static Future<bool> checkEmail(String email) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/check-email'), // ✅ Localhost hata kar $baseUrl kar diya
      body: jsonEncode({'email': email}),
      headers: {'Content-Type': 'application/json'},
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['exists'] ?? false;
    }
    return false;
  }

  // 2️⃣ OTP Flow
  static Future<bool> sendOtp(String email) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/send-otp'), // ✅ $baseUrl fixed
      body: jsonEncode({'email': email}),
      headers: {'Content-Type': 'application/json'},
    );
    return res.statusCode == 200;
  }

  // 3️⃣ Verify OTP & Login (Named Parameters)
  static Future<bool> verifyAndLogin({
    required String email,
    required String otp,
    String? name,
    String? dob,
    String? password,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/verify-otp'), // ✅ $baseUrl fixed
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'otp': otp,
        'name': name,
        'dob': dob,
        'password': password,
      }),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      await prefs.setString('email', data['user']['email']);
      await prefs.setString('name', data['user']['name']);
      await prefs.setString('role', data['user']['role']);
      await prefs.setBool('isLoggedIn', true);
      return true;
    }
    return false;
  }

  // 4️⃣ Reset Password
  static Future<bool> resetPassword(String email, String otp, String newPass) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/reset-password'), // ✅ Fixed
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'otp': otp,
        'newPassword': newPass,
      }),
    );
    return res.statusCode == 200;
  }

  // 5️⃣ Complaint Submission
  static Future<bool> submitComplaint(Map<String, dynamic> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final res = await http.post(
      Uri.parse('$baseUrl/complaints'), // ✅ Fixed
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    return res.statusCode == 201 || res.statusCode == 200;
  }

  // 6️⃣ Get My Complaints
  static Future<List<dynamic>> getMyComplaints() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final res = await http.get(
        Uri.parse('$baseUrl/complaints/my'), // ✅ Fixed
        headers: {'Authorization': 'Bearer $token'},
      );
      return res.statusCode == 200 ? jsonDecode(res.body) : [];
    } catch (e) {
      return [];
    }
  }

  // 7️⃣ Admin Feed
  static Future<List<dynamic>> getAdminFeed() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final res = await http.get(
        Uri.parse('$baseUrl/complaints/admin'), // ✅ Fixed
        headers: {'Authorization': 'Bearer $token'},
      );
      return res.statusCode == 200 ? jsonDecode(res.body) : [];
    } catch (e) {
      return [];
    }
  }

  // 8️⃣ Admin Status Update
  static Future<bool> updateStatus(String id, String status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final res = await http.patch(
      Uri.parse('$baseUrl/complaints/$id'), // ✅ Fixed
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'status': status}),
    );
    return res.statusCode == 200;
  }

  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}