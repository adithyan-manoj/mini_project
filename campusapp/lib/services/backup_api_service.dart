import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class BackupApiService {
  static String get baseUrl => dotenv.env['backend_url'] ?? "http://10.141.4.152:8000";

  // ─── Backup Lost & Found (via FastAPI backend) ────────────────────────

  static Future<List<dynamic>> getBackupItems({
    String? type,
    String? status,
    String? sortBy,
    String? q,
  }) async {
    String url = '$baseUrl/backup-lost-found';
    List<String> params = [];
    if (type != null && type != 'all') params.add('type=$type');
    if (status != null) params.add('status=$status');
    if (sortBy != null) params.add('sort_by=$sortBy');
    if (q != null && q.isNotEmpty) params.add('q=$q');

    if (params.isNotEmpty) url += '?${params.join('&')}';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['items'];
      }
      throw Exception('Failed to load backup items');
    } catch (e) {
      print('❌ GET BACKUP ITEMS ERROR: $e');
      throw Exception(e);
    }
  }

  static Future<void> createBackupItem(Map<String, dynamic> item) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/backup-lost-found'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(item),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to post item: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ CREATE BACKUP ITEM ERROR: $e');
      throw Exception(e);
    }
  }

  static Future<void> closeBackupItem(String itemId) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/backup-lost-found/$itemId/close'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode != 200) throw Exception('Failed to close item');
    } catch (e) {
      print('❌ CLOSE BACKUP ITEM ERROR: $e');
      throw Exception(e);
    }
  }
}
