import 'package:flutter/material.dart';
import '../../core/api_service.dart';

class CitizenAuth extends StatefulWidget {
  const CitizenAuth({super.key});
  @override
  State<CitizenAuth> createState() => _CitizenAuthState();
}

class _CitizenAuthState extends State<CitizenAuth> {
  // 1: Role, 2: Login, 3: Forgot, 4: OTP, 5: NewPass, 6: Signup
  int step = 1;
  String role = "Citizen";
  bool isSignupFlow = false; // ✅ Track karne ke liye ki login hai ya signup

  final emailCont = TextEditingController();
  final passCont = TextEditingController();
  final otpCont = TextEditingController();
  final nameCont = TextEditingController();
  final dobCont = TextEditingController();

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => dobCont.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}");
    }
  }

  bool _isPasswordStrong(String p) {
    bool hasCapital = p.contains(RegExp(r'[A-Z]'));
    bool hasSpecial = p.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    return p.length >= 6 && hasCapital && hasSpecial;
  }

  void _logicCheck() async {
    if (step == 2) { // Login Flow
      bool exists = await ApiService.checkEmail(emailCont.text);
      if (exists) {
        await ApiService.sendOtp(emailCont.text);
        setState(() { isSignupFlow = false; step = 4; });
      } else {
        _msg("Error: Ye Gmail database mein nahi hai!");
      }
    } else if (step == 6) { // Signup Flow
      if (nameCont.text.isEmpty || dobCont.text.isEmpty || emailCont.text.isEmpty) {
        _msg("Bhai, Name, DOB aur Gmail bharna compulsory hai!");
        return;
      }
      bool exists = await ApiService.checkEmail(emailCont.text);
      if (exists) {
        _msg("Error: Ye Gmail pehle se registered hai!");
      } else {
        await ApiService.sendOtp(emailCont.text);
        setState(() { isSignupFlow = true; step = 4; });
      }
    }
  }

  void _msg(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$role Portal"),
        leading: step > 1 ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => step = 1)) : null,
      ),
      body: SingleChildScrollView(padding: const EdgeInsets.all(25), child: _buildUI()),
    );
  }

  Widget _buildUI() {
    if (step == 1) return _roleSelection();
    if (step == 2) return _loginForm();
    if (step == 3) return _forgotPassForm();
    if (step == 4) return _otpScreen();
    if (step == 5) return _newPassScreen();
    if (step == 6) return _signupForm();
    return const SizedBox();
  }

  Widget _roleSelection() {
    return Column(children: [
      _btn("Login as Citizen", Colors.blue, () => setState(() { role = "Citizen"; step = 2; })),
      const SizedBox(height: 20),
      _btn("Login as Admin", Colors.red, () => setState(() { role = "Admin"; step = 2; })),
    ]);
  }

  Widget _loginForm() {
    return Column(children: [
      TextField(controller: emailCont, decoration: const InputDecoration(labelText: "Gmail / Number")),
      TextField(controller: passCont, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
      Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => setState(() => step = 3), child: const Text("Forgot Password?"))),
      _btn("LOGIN", Colors.green, _logicCheck),
      if (role == "Citizen") Padding(padding: const EdgeInsets.only(top: 15), child: TextButton(onPressed: () => setState(() => step = 6), child: const Text("New User? Create Account"))),
    ]);
  }

  Widget _forgotPassForm() {
    return Column(children: [
      const Text("Enter your registered Gmail to receive OTP"),
      TextField(controller: emailCont, decoration: const InputDecoration(labelText: "Gmail")),
      const SizedBox(height: 20),
      _btn("SEND OTP", Colors.orange, () async {
        bool exists = await ApiService.checkEmail(emailCont.text);
        if (exists) { await ApiService.sendOtp(emailCont.text); setState(() { isSignupFlow = false; step = 4; }); }
        else { _msg("Ye Email database mein nahi hai!"); }
      }),
    ]);
  }

  Widget _signupForm() {
    return Column(children: [
      TextField(controller: nameCont, decoration: const InputDecoration(labelText: "Full Name *")),
      const SizedBox(height: 10),
      TextField(controller: dobCont, readOnly: true, onTap: _selectDate, decoration: const InputDecoration(labelText: "Date of Birth *", suffixIcon: Icon(Icons.calendar_today))),
      const SizedBox(height: 10),
      TextField(controller: emailCont, decoration: const InputDecoration(labelText: "Gmail *")),
      const SizedBox(height: 10),
      TextField(controller: passCont, decoration: const InputDecoration(labelText: "Password *"), obscureText: true),
      const SizedBox(height: 20),
      _btn("VERIFY & REGISTER", Colors.blue, _logicCheck),
    ]);
  }

  Widget _otpScreen() {
    return Column(children: [
      Text("OTP has been sent to ${emailCont.text}"),
      const SizedBox(height: 10),
      TextField(controller: otpCont, decoration: const InputDecoration(labelText: "Enter OTP")),
      const SizedBox(height: 20),
      _btn("VERIFY", Colors.blue, () async {
        if (isSignupFlow) {
          // ✅ Signup case: Sare data bhejo
          bool ok = await ApiService.verifyAndLogin(
            email: emailCont.text,
            otp: otpCont.text,
            name: nameCont.text,
            dob: dobCont.text,
            password: passCont.text,
          );
          if (ok) { _msg("Account Created!"); Navigator.pop(context); }
          else { _msg("OTP galat hai!"); }
        } else {
          // ✅ Login/Forgot case: Step 5 par bhejo ya seedha login
          setState(() => step = 5);
        }
      }),
    ]);
  }

  Widget _newPassScreen() {
    return Column(children: [
      const Text("Set Strong Password"),
      TextField(controller: passCont, decoration: const InputDecoration(labelText: "New Password *"), obscureText: true),
      const SizedBox(height: 20),
      _btn("SAVE PASSWORD", Colors.green, () async {
        if (_isPasswordStrong(passCont.text)) {
          // ✅ Deepanshu ki API ke hisab se otp bhi bhejna hai
          bool ok = await ApiService.resetPassword(emailCont.text, otpCont.text, passCont.text);
          if (ok) { _msg("Password changed! Login karein."); setState(() => step = 2); }
        } else {
          _msg("Password weak hai!");
        }
      }),
    ]);
  }

  Widget _btn(String t, Color c, VoidCallback p) => ElevatedButton(
    style: ElevatedButton.styleFrom(backgroundColor: c, minimumSize: const Size(double.infinity, 50)),
    onPressed: p, child: Text(t, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
  );
}