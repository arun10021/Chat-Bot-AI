import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  final String apiKey = 'AIzaSyDi4cmH7JrRpkL_AHn3YF0ejjR0JfVKpwM';

  Future<String> sendMessage(String message, List<Map<String, String>> conversationHistory) async {
    if (apiKey.isEmpty || apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      throw Exception('Please add your Gemini API key in gemini_service.dart');
    }

    try {
      List<Map<String, dynamic>> contents = [];

      // Add conversation history
      for (var msg in conversationHistory) {
        contents.add({
          'role': msg['role'] == 'user' ? 'user' : 'model',
          'parts': [
            {'text': msg['content']}
          ]
        });
      }

      // Add current message
      contents.add({
        'role': 'user',
        'parts': [
          {'text': message}
        ]
      });

      final url = 'https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent?key=$apiKey';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': contents,
          'generationConfig': {
            'temperature': 0.9,
            'maxOutputTokens': 1000,
            'topP': 1,
            'topK': 1,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        return text.trim();
      } else {
        final error = jsonDecode(response.body);
        throw Exception('Error: ${error['error']['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }
}