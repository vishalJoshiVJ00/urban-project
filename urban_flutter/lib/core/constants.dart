class AppConstants {
  static const String friendIP = "192.168.1.25";
  static const String baseUrl = 'http://192.168.1.25:3000';

  // ✅ FIXED: Added missing quotes and fixed syntax
  static const String complaintsEndpoint = 'http://192.168.1.25:3000/api/v1/complaints';
  static const String aiEndpoint = "$baseUrl/api/v1/ai/citybrain";
}