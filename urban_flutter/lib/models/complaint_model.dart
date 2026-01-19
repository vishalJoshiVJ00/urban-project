import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt; // Mic ke liye
import 'package:image_picker/image_picker.dart'; // Camera ke liye
import 'dart:io';
import '../../core/api_service.dart';

class ComplaintForm extends StatefulWidget {
  const ComplaintForm({super.key});
  @override
  State<ComplaintForm> createState() => _ComplaintFormState();
}

class _ComplaintFormState extends State<ComplaintForm> {
  final _descCont = TextEditingController();
  String? _selectedCategory;
  File? _image;

  // Speech to Text logic
  late stt.SpeechToText _speech;
  bool _isListening = false;

  final List<String> _categories = ['Water Supply', 'Electricity', 'Waste Management', 'Road/Potholes', 'Other'];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  // ✅ 1. Mic Logic (Bol kar shikayat likhein)
  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (val) {
          setState(() => _descCont.text = val.recognizedWords);
        });
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  // ✅ 2. Camera Logic (Photo click karein)
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  // ✅ 3. Submit Logic with Compulsory Validation
  void _submit() async {
    if (_selectedCategory == null || _descCont.text.isEmpty || _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bhai, Category, Description aur Photo teeno compulsory hain!")),
      );
      return;
    }

    _msg("Submitting your complaint...");

    Map<String, dynamic> data = {
      "category": _selectedCategory,
      "description": _descCont.text,
      "imagePath": _image!.path,
      "status": "Pending",
      "date": DateTime.now().toString(),
    };

    bool success = await ApiService.submitComplaint(data); // Backend connection
    if (success) {
      _msg("Shikayat darj ho gayi hai!");
      Navigator.pop(context);
    }
  }

  void _msg(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Complaint"), backgroundColor: Colors.blue.shade900),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Dropdown
            DropdownButtonFormField(
              decoration: const InputDecoration(labelText: "Select Category *"),
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val as String?),
            ),
            const SizedBox(height: 20),

            // Description with Mic Icon
            TextField(
              controller: _descCont,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: "Description *",
                hintText: "Dikat bataein ya Mic icon dabakar bolein...",
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: _isListening ? Colors.red : Colors.blue),
                  onPressed: _listen,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Camera Section
            const Text("Upload Evidence (Photo) *", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            InkWell(
              onTap: _pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(10)),
                child: _image == null
                    ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.camera_alt, size: 50), Text("Click Photo")])
                    : Image.file(_image!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 30),

            // Submit Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: _submit,
              child: const Text("SUBMIT COMPLAINT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}