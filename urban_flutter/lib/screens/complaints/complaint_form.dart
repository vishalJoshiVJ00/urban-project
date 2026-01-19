import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert'; // ✅ Base64 ke liye
import 'dart:io';      // ✅ File handle karne ke liye
import '../../core/api_service.dart';

class ComplaintForm extends StatefulWidget {
  const ComplaintForm({super.key});
  @override
  State<ComplaintForm> createState() => _ComplaintFormState();
}

class _ComplaintFormState extends State<ComplaintForm> {
  final descCont = TextEditingController();
  String? category;
  stt.SpeechToText _speech = stt.SpeechToText();
  File? _image; // ✅ Photo store karne ke liye

  // 📸 Camera se photo click aur Base64 mein convert karna
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 50);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  void _submit() async {
    // ✅ Validation: Check karo sab bhara hai ya nahi
    if (category == null || descCont.text.isEmpty || _image == null) {
      _msg("Bhai, Category, Photo aur Description teeno zaroori hain!");
      return;
    }

    try {
      _msg("Location fetch kar raha hoon...");
      Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      // ✅ Image ko Base64 String mein convert karna (Deepanshu ki requirement)
      List<int> imageBytes = await _image!.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      final body = {
        'category': category!.toLowerCase(), // Deepanshu ne lowercase maanga hai
        'description': descCont.text,
        'lat': pos.latitude,  // Automatic double jayega
        'long': pos.longitude, // Automatic double jayega
        'image': base64Image,  // ✅ Pure Base64 String
      };

      bool ok = await ApiService.submitComplaint(body);
      if (ok) {
        _msg("Shikayat darj ho gayi!");
        Navigator.pop(context);
      } else {
        _msg("Server error! Deepanshu ka IP check karo.");
      }
    } catch (e) {
      _msg("Location error: $e");
    }
  }

  void _msg(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Report Issue"), backgroundColor: Colors.blue.shade900),
      body: SingleChildScrollView( // ✅ Keyboard aane par scroll ho sake
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          DropdownButtonFormField(
            items: ["Water", "Electricity", "Garbage", "Roads"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => category = v as String,
            decoration: const InputDecoration(labelText: "Problem Category *"),
          ),
          const SizedBox(height: 20),

          TextField(
              controller: descCont,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Dikat batao ya Mic dabao...",
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                    icon: const Icon(Icons.mic, color: Colors.blue),
                    onPressed: () async {
                      bool available = await _speech.initialize();
                      if (available) {
                        _speech.listen(onResult: (val) => setState(() => descCont.text = val.recognizedWords));
                      }
                    }
                ),
              )
          ),

          const SizedBox(height: 20),

          // 🖼️ Photo Preview Area
          InkWell(
            onTap: _pickImage,
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(10)),
              child: _image == null
                  ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.camera_alt, size: 50), Text("Click Evidence Photo *")])
                  : Image.file(_image!, fit: BoxFit.cover),
            ),
          ),

          const SizedBox(height: 30),

          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 50)
              ),
              onPressed: _submit,
              child: const Text("SUBMIT COMPLAINT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
          ),
        ]),
      ),
    );
  }
}