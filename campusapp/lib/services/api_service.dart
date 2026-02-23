import 'dart:convert';
import 'package:campusapp/models/event_model.dart';
import 'package:http/http.dart' as http;

class ApiService {
  //static const String baseUrl = "http://192.168.29.71:8000";
  static const String baseUrl = "http://10.207.195.152:8000";

  static Future<List<EventModel>> fetchEvents({String? search, String? date, int page = 1,int limit = 5}) async {
    // Logic: Construct a dynamic URL with query parameters
    String urlStr = "$baseUrl/events?page=$page&limit=$limit&";
    if (search != null) urlStr += "search=$search&";
    if (date != null) urlStr += "date=$date";

    try {
      final response = await http.get(Uri.parse(urlStr));
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body)['events'];
        return data.map((json) => EventModel(
          id: json['id'],
          title: json['title'],
          description: json['description'],
          imageUrl: json['image_url'],
          date: DateTime.parse(json['date']), // Standard ISO format
          venue: json['venue'],
        )).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
  static Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse("$baseUrl/login");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      ).timeout(const Duration(seconds: 10));

      return {
        "statusCode": response.statusCode,
        "body": jsonDecode(response.body),
      };
    } catch (e) {
      return {
        "statusCode": 500, 
        "body": {"detail": "ETLAB proxy error: Check your wifi or server"}
      };
    }
  }

  static Future<List<dynamic>> fetchLogs() async {
  final url = Uri.parse("$baseUrl/admin/logs");
  
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['logs'];
    }
    return [];
  } catch (e) {
    return [];
  }
}
}

