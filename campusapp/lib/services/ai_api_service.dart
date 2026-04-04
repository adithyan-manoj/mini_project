import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiApiService {
  static final String baseUrl = dotenv.env['backend_url'] ?? 'http://10.141.4.152:8000';

  static Future<Map<String, dynamic>> sendChatQuery(String query, {String? userId}) async {
    final url = Uri.parse('$baseUrl/ai/chat');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'query': query,
          'user_id': userId,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get AI response: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ AiApiService Error: $e');
      rethrow;
    }
  }
}
