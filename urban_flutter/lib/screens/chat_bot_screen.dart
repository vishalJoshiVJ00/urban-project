import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/constants.dart';

class CityBrainBot extends StatefulWidget {
  @override
  _CityBrainBotState createState() => _CityBrainBotState();
}

class _CityBrainBotState extends State<CityBrainBot> {
  final TextEditingController _ctrl = TextEditingController();
  List<Map<String, String>> messages = [];

  void sendMessage() async {
    if (_ctrl.text.isEmpty) return;
    String userMsg = _ctrl.text;
    setState(() => messages.add({"sender": "user", "text": userMsg}));
    _ctrl.clear();

    try {
      final res = await http.post(
        Uri.parse(AppConstants.aiEndpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"question": userMsg}),
      );
      final data = jsonDecode(res.body);
      setState(() => messages.add({"sender": "bot", "text": data['answer']}));
    } catch (e) {
      setState(() => messages.add({"sender": "bot", "text": "❌ Connection Lost!"}));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("CityBrain AI")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, i) => ListTile(
                title: Text(messages[i]['text']!),
                subtitle: Text(messages[i]['sender']!),
              ),
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(child: TextField(controller: _ctrl, decoration: InputDecoration(hintText: "Ask AI..."))),
          IconButton(icon: Icon(Icons.send), onPressed: sendMessage),
        ],
      ),
    );
  }
}