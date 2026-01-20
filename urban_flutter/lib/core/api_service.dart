import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // ✅ Deepanshu ke phone/laptop ka IP yahan set hai
  static const String baseUrl = 'http://192.168.1.4:3000/api/v1';

  // 1️⃣ Email Check
  static Future<bool> checkEmail(String email) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/check-email'),
      body: jsonEncode({'email': email}),
      headers: {'Content-Type': 'application/json'},
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['exists'] ?? false;
    }
    return false;
  }

  // 2️⃣ Send OTP for Signup (FIXED)
  static Future<bool> sendOtp(String email) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      body: jsonEncode({
        'email': email,
        'name': 'User',
        'password': 'Temp@123'
      }),
      headers: {'Content-Type': 'application/json'},
    );
    return res.statusCode == 200;
  }

  // 3️⃣ Verify OTP & Login (Fixed parameters)
  static Future<bool> verifyAndLogin({
    required String email,
    required String otp,
    String? name,
    String? dob,
    String? password,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/verify-otp'),
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

  // 4️⃣ Direct Login (Added missing method)
  static Future<bool> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
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

  // 5️⃣ Forgot Password (Added missing method)
  static Future<bool> forgotPassword(String email) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    return res.statusCode == 200;
  }

  // 6️⃣ Reset Password
  static Future<bool> resetPassword(String email, String otp, String newPass) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'otp': otp,
        'newPassword': newPass,
      }),
    );
    return res.statusCode == 200;
  }

  // 7️⃣ Complaint Submission
  static Future<bool> submitComplaint(Map<String, dynamic> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final res = await http.post(
      Uri.parse('$baseUrl/complaints'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    return res.statusCode == 201 || res.statusCode == 200;
  }

  // 8️⃣ Get My Complaints
  static Future<List<dynamic>> getMyComplaints() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final res = await http.get(
        Uri.parse('$baseUrl/complaints/my'),
        headers: {'Authorization': 'Bearer $token'},
      );
      return res.statusCode == 200 ? jsonDecode(res.body) : [];
    } catch (e) {
      return [];
    }
  }

  // 9️⃣ Admin Feed
  static Future<List<dynamic>> getAdminFeed() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final res = await http.get(
        Uri.parse('$baseUrl/complaints/admin'),
        headers: {'Authorization': 'Bearer $token'},
      );
      return res.statusCode == 200 ? jsonDecode(res.body) : [];
    } catch (e) {
      return [];
    }
  }

  // 1️⃣0️⃣ Admin Status Update
  static Future<bool> updateStatus(String id, String status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final res = await http.patch(
      Uri.parse('$baseUrl/complaints/$id'),
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