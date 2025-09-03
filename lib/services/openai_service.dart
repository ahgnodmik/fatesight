import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ChatMessage {
  final String role; // 'user' or 'assistant'
  final String content;
  ChatMessage({required this.role, required this.content});
}

class ChatProvider extends ChangeNotifier {
  ChatProvider(this._service);

  final OpenAIService _service;
  final List<ChatMessage> _messages = <ChatMessage>[];
  bool _isLoading = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;

  Future<void> sendMessage(String content) async {
    _messages.add(ChatMessage(role: 'user', content: content));
    _isLoading = true;
    notifyListeners();

    try {
      final reply = await _service.createChatCompletion(_messages);
      _messages.add(ChatMessage(role: 'assistant', content: reply));
    } catch (e) {
      _messages.add(ChatMessage(role: 'assistant', content: '오류가 발생했습니다. 다시 시도해주세요.'));
      if (kDebugMode) {
        // ignore: avoid_print
        print('OpenAI error: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

class OpenAIService {
  static const String _chatUrl = 'https://api.openai.com/v1/chat/completions';

  Future<String> createChatCompletion(List<ChatMessage> history) async {
    final key = dotenv.env['OPENAI_API_KEY'];
    final system = dotenv.env['OPENAI_SYSTEM_PROMPT'] ?? 'You are a helpful assistant.';
    if (key == null || key.isEmpty) {
      throw Exception('OPENAI_API_KEY is not set');
    }

    final model = dotenv.env['OPENAI_MODEL'] ?? 'gpt-4o-mini';

    final messages = <Map<String, String>>[
      {'role': 'system', 'content': system},
      ...history.map((m) => {'role': m.role, 'content': m.content}),
    ];

    final response = await http.post(
      Uri.parse(_chatUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $key',
      },
      body: jsonEncode({
        'model': model,
        'messages': messages,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = data['choices'] as List<dynamic>;
      if (choices.isNotEmpty) {
        return choices.first['message']['content'] as String;
      }
      return '응답이 비어있습니다.';
    }

    throw Exception('OpenAI API error: ${response.statusCode} ${response.body}');
  }
}


