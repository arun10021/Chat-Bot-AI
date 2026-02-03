import 'package:flutter/material.dart';
import '../model/message_model.dart';
import '../service/open_AI_service.dart';
import '../service/storage_service.dart';

class ChatProvider extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  final StorageService _storageService = StorageService();

  List<Message> _messages = [];
  bool _isLoading = false;
  bool _isDarkMode = false;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _isDarkMode;

  ChatProvider() {
    loadMessages();
  }

  Future<void> loadMessages() async {
    _messages = await _storageService.loadMessages();
    notifyListeners();
  }

  Future<void> saveMessages() async {
    await _storageService.saveMessages(_messages);
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    final userMessage = Message(
      content: content.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    _messages.add(userMessage);
    _isLoading = true;
    notifyListeners();

    try {
      final conversationHistory = _messages.map((msg) {
        return {
          'role': msg.isUser ? 'user' : 'assistant',
          'content': msg.content,
        };
      }).toList();

      final response = await _geminiService.sendMessage(
        userMessage.content,
        conversationHistory,
      );

      final aiMessage = Message(
        content: response,
        isUser: false,
        timestamp: DateTime.now(),
      );

      _messages.add(aiMessage);
      await saveMessages();
    } catch (e) {
      final errorMessage = Message(
        content: 'Sorry, I encountered an error: ${e.toString()}',
        isUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearChat() async {
    _messages.clear();
    await _storageService.clearMessages();
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}