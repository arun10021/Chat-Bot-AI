import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/message_model.dart';

class StorageService {
  static const String _messagesKey = 'chat_messages';

  Future<void> saveMessages(List<Message> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = messages.map((m) => m.toJson()).toList();
    await prefs.setString(_messagesKey, jsonEncode(jsonList));
  }

  Future<List<Message>> loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_messagesKey);

    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => Message.fromJson(json)).toList();
  }

  Future<void> clearMessages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_messagesKey);
  }
}