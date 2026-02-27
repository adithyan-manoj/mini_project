import 'dart:convert';
import 'dart:io';
import 'package:campusapp/models/event_model.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';


class ApiService {
  //static const String baseUrl = "http://192.168.29.71:8000";
  //static const String baseUrl = "http://10.207.195.152:8000";
  static const String baseUrl = "http://192.168.1.76:8000";

  static final supabase = Supabase.instance.client;

  static Future<List<EventModel>> fetchEvents({String? search, String? date, int page = 1,int limit = 5}) async {
    // Logic: Construct a dynamic URL with query parameters
    String urlStr = "$baseUrl/events?page=$page&limit=$limit&";
    if (search != null) urlStr += "search=$search&";
    if (date != null) urlStr += "date=$date";

    try {
      final response = await http.get(Uri.parse(urlStr));
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body)['event'];
        return data.map((json) => EventModel(
          id: json['id'],
          title: json['title'],
          description: json['description'],
          image_url: json['image_url'],
          event_date: DateTime.parse(json['event_date']), // Standard ISO format
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

// adding new event image into supabase db......

static Future<bool> createEvent({
  required String title,
  required String description,
  required String venue,
  required DateTime date,
  required File imageFile,
}) async {
  try {
    final fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
    print("Step 1: Uploading to Supabase...");
    await supabase.storage.from('event_images').upload(fileName, imageFile);
    print("Step 2: Getting Public URL...");
    final imageUrl = supabase.storage.from('event_images').getPublicUrl(fileName);
    print("Image URL: $imageUrl");
    print("Step 3: Sending to FastAPI...");
    final response = await http.post(
      Uri.parse("$baseUrl/events"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "title": title,
        "description": description,
        "venue": venue,
        "event_date": date.toIso8601String(),
        "image_url": imageUrl,
      }),
    );
    print("FastAPI Response: ${response.statusCode} - ${response.body}");

    return response.statusCode == 200;
  }catch (e) {
    print("Upload Error: $e");
    print("CATCH ERROR in createEvent: $e");
    return false;
  }
}

}

