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

  // When FORTUNE_PROXY_URL is set, all requests go through the server-side
  // proxy (supabase/functions/fortune) so no OpenAI key ships with the app.
  // Direct OpenAI calls with OPENAI_API_KEY remain only as a dev fallback.
  Future<String> _complete(
    List<Map<String, String>> messages, {
    required double temperature,
    int? maxTokens,
  }) async {
    final proxyUrl = dotenv.env['FORTUNE_PROXY_URL'];
    final model = dotenv.env['OPENAI_MODEL'] ?? 'gpt-4o-mini';

    final Uri uri;
    final String? bearer;
    if (proxyUrl != null && proxyUrl.isNotEmpty) {
      uri = Uri.parse(proxyUrl);
      bearer = dotenv.env['AUTH_SECRET_TOKEN'];
    } else {
      final key = dotenv.env['OPENAI_API_KEY'];
      if (key == null || key.isEmpty) {
        throw Exception('Neither FORTUNE_PROXY_URL nor OPENAI_API_KEY is set');
      }
      uri = Uri.parse(_chatUrl);
      bearer = key;
    }

    final response = await http
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            if (bearer != null && bearer.isNotEmpty)
              'Authorization': 'Bearer $bearer',
          },
          body: jsonEncode({
            'model': model,
            'messages': messages,
            'temperature': temperature,
            if (maxTokens != null) 'max_tokens': maxTokens,
          }),
        )
        .timeout(const Duration(seconds: 60));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = data['choices'] as List<dynamic>;
      if (choices.isNotEmpty) {
        return choices.first['message']['content'] as String;
      }
      return '응답이 비어있습니다.';
    }

    throw Exception('Completion API error: ${response.statusCode}');
  }

  Future<String> createChatCompletion(List<ChatMessage> history) async {
    final system = dotenv.env['OPENAI_SYSTEM_PROMPT'] ?? 'You are a helpful assistant.';

    final messages = <Map<String, String>>[
      {'role': 'system', 'content': system},
      ...history.map((m) => {'role': m.role, 'content': m.content}),
    ];

    return _complete(messages, temperature: 0.7);
  }

  // 사주 기반 스토리 생성 메서드
  Future<String> generateFortuneStory({
    required String name,
    required DateTime birthDateTime,
    required String question,
    required String language,
  }) async {
    // 언어에 따른 시스템 프롬프트 설정
    final systemPrompt = language == 'ko'
        ? _getKoreanSystemPrompt()
        : _getEnglishSystemPrompt();

    // 생년월일시 정보를 포함한 프롬프트 생성
    final userPrompt = language == 'ko'
        ? _getKoreanUserPrompt(name, birthDateTime, question)
        : _getEnglishUserPrompt(name, birthDateTime, question);

    final messages = <Map<String, String>>[
      {'role': 'system', 'content': systemPrompt},
      {'role': 'user', 'content': userPrompt},
    ];

    // 창의적인 스토리를 위해 높은 온도 설정
    return _complete(messages, temperature: 0.8, maxTokens: 1000);
  }

  String _getKoreanSystemPrompt() {
    return '''
당신은 전문적인 사주명리학자이자 스토리텔러입니다. 
사용자의 생년월일시를 바탕으로 사주를 분석하고, 궁금한 점에 대해 아름다운 운명의 이야기로 답변해주세요.

답변 형식:
1. 사용자의 이름과 생년월일시를 언급
2. 사주 분석을 바탕으로 한 운명 해석
3. 궁금한 점에 대한 구체적이고 긍정적인 조언
4. 앞으로의 운세와 조언
5. 희망적이고 아름다운 마무리

답변은 따뜻하고 친근한 톤으로, 이모지를 적절히 사용하여 아름답게 작성해주세요.
한국어로만 답변해주세요.
''';
  }

  String _getEnglishSystemPrompt() {
    return '''
You are a professional fortune teller and storyteller specializing in Korean astrology (Saju).
Based on the user's birth date and time, analyze their fortune and provide beautiful destiny stories in response to their questions.

Response format:
1. Mention the user's name and birth date/time
2. Fortune interpretation based on astrological analysis
3. Specific and positive advice regarding their question
4. Future fortune and guidance
5. Hopeful and beautiful conclusion

Please respond in a warm and friendly tone, using appropriate emojis to make it beautiful.
Respond only in English.
''';
  }

  String _getKoreanUserPrompt(String name, DateTime birthDateTime, String question) {
    final year = birthDateTime.year;
    final month = birthDateTime.month;
    final day = birthDateTime.day;
    final hour = birthDateTime.hour;
    final minute = birthDateTime.minute;
    
    return '''
이름: $name
생년월일시: ${year}년 ${month}월 ${day}일 ${hour}시 ${minute}분
궁금한 점: $question

위 정보를 바탕으로 사주를 분석하고 운명의 이야기를 들려주세요.
''';
  }

  String _getEnglishUserPrompt(String name, DateTime birthDateTime, String question) {
    final year = birthDateTime.year;
    final month = birthDateTime.month;
    final day = birthDateTime.day;
    final hour = birthDateTime.hour;
    final minute = birthDateTime.minute;
    
    return '''
Name: $name
Birth Date and Time: ${month}/${day}/${year} at ${hour}:${minute.toString().padLeft(2, '0')}
Question: $question

Please analyze the fortune based on the above information and tell me a destiny story.
''';
  }
}





