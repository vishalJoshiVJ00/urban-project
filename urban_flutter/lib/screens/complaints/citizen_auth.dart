import 'package:flutter/material.dart';
import '../../core/api_service.dart';

class CitizenAuth extends StatefulWidget {
  const CitizenAuth({super.key});
  @override
  State<CitizenAuth> createState() => _CitizenAuthState();
}

class _CitizenAuthState extends State<CitizenAuth> {
  int step = 1;
  String role = "Citizen";
  bool isSignupFlow = false;

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

  void _logicCheck() async {
    print("--- Logic Check Started ---");
    print("Current Step: $step");

    if (step == 2) { // Login Flow
      print("Attempting Login Check for: ${emailCont.text}");
      bool exists = await ApiService.checkEmail(emailCont.text);
      if (exists) {
        print("User exists, sending OTP...");
        bool otpSent = await ApiService.sendOtp(emailCont.text);
        if (otpSent) {
          print("OTP sent successfully to: ${emailCont.text}");
          setState(() { isSignupFlow = false; step = 4; });
        } else {
          print("Failed to send OTP");
          _msg("Error: OTP send nahi ho paya, please try again!");
        }
      } else {
        print("User does not exist in DB.");
        _msg("Error: Ye Gmail database mein nahi hai!");
      }
    }
    else if (step == 6) { // Signup Flow
      print("Checking Signup Validations...");
      if (nameCont.text.isEmpty || dobCont.text.isEmpty || emailCont.text.isEmpty) {
        print("Validation Failed: Empty fields");
        _msg("Bhai, Name, DOB aur Gmail bharna compulsory hai!");
        return;
      }

      print("Checking if email already exists...");
      bool exists = await ApiService.checkEmail(emailCont.text);
      if (exists) {
        print("Email already registered.");
        _msg("Error: Ye Gmail pehle se registered hai!");
      } else {
        print("Email clear! Requesting OTP from Backend...");
        bool otpSent = await ApiService.sendOtp(emailCont.text);
        if (otpSent) {
          print("OTP request function executed.");
          setState(() { isSignupFlow = true; step = 4; });
        } else {
          _msg("Error: OTP send nahi ho paya, please try again!");
        }
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
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // ✅ Tap karne par keyboard hide hoga
        child: SingleChildScrollView(padding: const EdgeInsets.all(25), child: _buildUI()),
      ),
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
          bool ok = await ApiService.verifyAndLogin(
            email: emailCont.text,
            otp: otpCont.text,
            name: nameCont.text,
            dob: dobCont.text,
            password: passCont.text,
          );
          if (ok) {
            _msg("Account Created Successfully!");
            Navigator.pop(context);
          } else {
            _msg("OTP galat hai!");
          }
        } else {
          // ✅ FIXED: Login with OTP verification
          bool ok = await ApiService.verifyAndLogin(
            email: emailCont.text,
            otp: otpCont.text,
          );
          if (ok) {
            _msg("Login Successful!");
            Navigator.pop(context);
          } else {
            _msg("OTP galat hai!");
          }
        }
      }),
    ]);
  }

  // ✅ FIXED: Complete Forgot Password UI
  Widget _forgotPassForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Forgot Password",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        const Text("Enter your email to reset password"),
        const SizedBox(height: 20),
        TextField(
          controller: emailCont,
          decoration: const InputDecoration(
            labelText: "Gmail",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email),
          ),
        ),
        const SizedBox(height: 20),
        _btn("SEND OTP", Colors.orange, () async {
          print("Forgot Password OTP requested for: ${emailCont.text}");

          // First check if email exists
          bool exists = await ApiService.checkEmail(emailCont.text);
          if (!exists) {
            _msg("Error: This email is not registered!");
            return;
          }

          // Send OTP for password reset
          bool otpSent = await ApiService.forgotPassword(emailCont.text);
          if (otpSent) {
            _msg("OTP sent to your email for password reset!");
            setState(() => step = 4); // Go to OTP screen
          } else {
            _msg("Failed to send OTP. Please try again.");
          }
        }),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () => setState(() => step = 2), // Back to login
            child: const Text("← Back to Login"),
          ),
        ),
      ],
    );
  }

  // ✅ FIXED: Complete New Password UI
  Widget _newPassScreen() {
    final newPassCont = TextEditingController();
    final confirmPassCont = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Set New Password",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: otpCont,
          decoration: const InputDecoration(
            labelText: "Enter OTP",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.lock),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: newPassCont,
          decoration: const InputDecoration(
            labelText: "New Password",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.lock_outline),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 10),
        TextField(
          controller: confirmPassCont,
          decoration: const InputDecoration(
            labelText: "Confirm New Password",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.lock_outline),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 20),
        _btn("RESET PASSWORD", Colors.purple, () async {
          if (newPassCont.text != confirmPassCont.text) {
            _msg("Passwords do not match!");
            return;
          }

          if (newPassCont.text.length < 6) {
            _msg("Password must be at least 6 characters!");
            return;
          }

          bool success = await ApiService.resetPassword(
            emailCont.text,
            otpCont.text,
            newPassCont.text,
          );

          if (success) {
            _msg("Password reset successful! Please login with new password.");
            setState(() => step = 2); // Go back to login
          } else {
            _msg("Failed to reset password. Please try again.");
          }
        }),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () => setState(() => step = 4), // Back to OTP
            child: const Text("← Back to OTP"),
          ),
        ),
      ],
    );
  }

  Widget _btn(String t, Color c, VoidCallback p) => ElevatedButton(
    style: ElevatedButton.styleFrom(backgroundColor: c, minimumSize: const Size(double.infinity, 50)),
    onPressed: p, child: Text(t, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
  );
}