import 'dart:convert';
import 'dart:io';
import 'package:campusapp/models/comment_model.dart';
import 'package:campusapp/models/event_model.dart';
import 'package:campusapp/models/post_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiService {
  static String get baseUrl => dotenv.env['backend_url'] ?? "http://10.141.4.152:8000";

  static final supabase = Supabase.instance.client;
  static String? currentUserRole; // Store role globally for UI checks

  static Future<List<EventModel>> fetchEvents({
    String? search,
    String? date,
    int page = 1,
    int limit = 5,
  }) async {
    String urlStr = "$baseUrl/events?page=$page&limit=$limit&";
    if (search != null) urlStr += "search=$search&";
    if (date != null) urlStr += "date=$date";

    try {
      final response = await http.get(Uri.parse(urlStr));
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body)['event'];
        return data
            .map(
              (json) => EventModel(
                id: json['id'],
                title: json['title'],
                description: json['description'],
                image_url: json['image_url'],
                event_date: DateTime.parse(json['event_date']),
                venue: json['venue'],
              ),
            )
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<EventModel?> fetchEventById(String id) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/events"));
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body)['event'];
        final json = data.firstWhere((e) => e['id'].toString() == id, orElse: () => null);
        if (json != null) {
          return EventModel(
            id: json['id'].toString(),
            title: json['title'],
            description: json['description'],
            image_url: json['image_url'],
            event_date: DateTime.parse(json['event_date']),
            venue: json['venue'],
          );
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  // static Future<Map<String, dynamic>> login(String username, String password) async {
  //   final url = Uri.parse("$baseUrl/login");

  //   try {
  //     final response = await http.post(
  //       url,
  //       headers: {"Content-Type": "application/json"},
  //       body: jsonEncode({"username": username, "password": password}),
  //     ).timeout(const Duration(seconds: 10));

  //     return {
  //       "statusCode": response.statusCode,
  //       "body": jsonDecode(response.body),
  //     };
  //   } catch (e) {
  //     return {
  //       "statusCode": 500,
  //       "body": {"detail": "ETLAB proxy error: Check your wifi or server"}
  //     };
  //   }
  // }

  // static Future<Map<String, dynamic>> login(String username, String password) async {
  //   final url = Uri.parse("$baseUrl/login");

  //   try {
  //     final response = await http.post(
  //       url,
  //       headers: {"Content-Type": "application/json"},
  //       body: jsonEncode({"username": username, "password": password}),
  //     ).timeout(const Duration(seconds: 30)); // Increased timeout for scraping
  //     print("DEBUG: Raw Backend Response: ${response.body}");

  //     final responseData = jsonDecode(response.body);

  //     if (response.statusCode == 200) {
  //       // Inject the session into Supabase
  //       await supabase.auth.setSession(responseData['session']['access_token']);
  //       return {"statusCode": 200, "body": responseData};
  //     }

  //     return {"statusCode": response.statusCode, "body": responseData};

  //   } catch (e) {
  //     print("Login Error: $e");
  //     return {
  //       "statusCode": 500,
  //       "body": {"detail": "Connection error: Check your server or network"}
  //     };
  //   }
  // }
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    final url = Uri.parse("$baseUrl/login");

    try {
      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"username": username, "password": password}),
          )
          .timeout(const Duration(seconds: 60));

      print("DEBUG Status: ${response.statusCode}");
      print("DEBUG Body: ${response.body}");

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final sessionData = responseData['session'];

        // --- PHASE 1: CORRECT SESSION INJECTION ---
        // Supabase Flutter requires the refresh token to set a session manually,
        // or a full serialized JSON session object if using recoverSession.
        await supabase.auth.setSession(sessionData['refresh_token']);

        // --- PHASE 2: STORE ROLE ---
        final rawRole = responseData['user']['role'] ?? 'student';
        currentUserRole = rawRole.toString().toLowerCase();

        print("DEBUG FRONTEND LOGIN: User role received logic: $rawRole -> $currentUserRole");
        return {"statusCode": 200, "body": responseData};
      }

      return {"statusCode": response.statusCode, "body": responseData};
    } catch (e) {
      print("Flutter Login Error: $e");
      return {
        "statusCode": 500,
        "body": {"detail": "Connection error: ${e.toString()}"},
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
      final imageUrl = supabase.storage
          .from('event_images')
          .getPublicUrl(fileName);
      print("Image URL: $imageUrl");
      print("Step 3: Sending to FastAPI...");
      final response = await http.post(
        Uri.parse("$baseUrl/events_post"),
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
    } catch (e) {
      print("Upload Error: $e");
      print("CATCH ERROR in createEvent: $e");
      return false;
    }
  }

  // ─── Community Posts (via FastAPI backend) ────────────────────────────────

  /// Fetches all community posts from the FastAPI backend.
  static Future<List<PostModel>> fetchPosts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/community/posts'));
      if (response.statusCode == 200) {
        final List posts = jsonDecode(response.body)['posts'];
        return posts.map((row) {
          final author = row['author'];
          final authorId = row['author_id'] as String? ?? 'anonymous';
          final authorName = author != null ? author['full_name'] as String : 'Campus User';
          final authorPic = (author != null && author['profile_pic_url'] != null)
              ? author['profile_pic_url'] as String
              : 'https://api.dicebear.com/7.x/avataaars/png?seed=$authorId';

          return PostModel(
            id: row['id'] as String,
            userName: authorName,
            userProfilePic: authorPic,
            postedTime: DateTime.parse(row['created_at'] as String),
            title: row['title'] as String? ?? '',
            content: row['content'] as String? ?? '',
            likes: (row['likes_count'] as int?) ?? 0,
          );
        }).toList();
      }
      return [];
    } catch (e) {
      print('fetchPosts error: $e');
      return [];
    }
  }

  static Future<PostModel?> fetchPostById(String id) async {
    try {
      final posts = await fetchPosts(); // Reusing the existing list fetch for simplicity
      return posts.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Sends a new post to the FastAPI backend which saves it to Supabase.
  /// Returns true on success, false on failure.
  static Future<bool> createPost({
    required String title,
    required String content,
  }) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      final body = <String, dynamic>{
        'title': title,
        'content': content,
        if (userId != null) 'author_id': userId,
      };
      final response = await http.post(
        Uri.parse('$baseUrl/community/posts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('createPost error: $e');
      return false;
    }
  }

  // ─── Comments (via FastAPI backend) ───────────────────────────────────────

  /// Fetches all comments for a post and assembles them into a tree.
  static Future<List<CommentModel>> fetchComments(String postId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/community/posts/$postId/comments'),
      );
      if (response.statusCode == 200) {
        final List raw = jsonDecode(response.body)['comments'];
        final flat = raw.map<CommentModel>((row) {
          final author = row['author'];
          final authorId = row['author_id'] as String? ?? 'anonymous';
          final authorName = author != null ? author['full_name'] as String : 'Campus User';
          final authorPic = (author != null && author['profile_pic_url'] != null)
              ? author['profile_pic_url'] as String
              : 'https://api.dicebear.com/7.x/avataaars/png?seed=$authorId';

          return CommentModel(
            id: row['id'] as String,
            postId: row['post_id'] as String,
            parentId: row['parent_comment_id'] as String?,
            authorId: authorId,
            userName: authorName,
            profilePic: authorPic,
            text: row['content'] as String? ?? '',
            createdAt: DateTime.parse(row['created_at'] as String),
          );
        }).toList();
        return CommentModel.buildTree(flat);
      }
      return [];
    } catch (e) {
      print('fetchComments error: $e');
      return [];
    }
  }

  /// Posts a new comment (or reply) to the FastAPI backend.
  /// [parentCommentId] is null for top-level comments, a UUID for replies.
  static Future<bool> createComment({
    required String postId,
    required String content,
    String? parentCommentId,
  }) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      final body = <String, dynamic>{
        'content': content,
        if (userId != null) 'author_id': userId,
        if (parentCommentId != null) 'parent_comment_id': parentCommentId,
      };
      final response = await http.post(
        Uri.parse('$baseUrl/community/posts/$postId/comments'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('createComment error: $e');
      return false;
    }
  }

  // ─── Likes (via FastAPI backend) ───────────────────────────────────────

  /// Toggles the like status of a post.
  static Future<int?> toggleLike(String postId, bool isLiking) async {
    try {
      final endpoint = isLiking ? 'like' : 'unlike';
      final response = await http.post(
        Uri.parse('$baseUrl/community/posts/$postId/$endpoint'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['likes_count'] as int?;
      }
      return null;
    } catch (e) {
      print('toggleLike error: $e');
      return null;
    }
  }

  //suraa

  static Future<List<dynamic>> getItems({String? type, String? status}) async {
    String url = '$baseUrl/lost-found';
    List<String> params = [];
    if (type != null) params.add('type=$type');
    if (status != null) params.add('status=$status');
    if (params.isNotEmpty) url += '?${params.join('&')}';

    print(' GET ITEMS URL: $url'); // ← ADD
    try {
      final response = await http.get(Uri.parse(url));
      print(' GET ITEMS STATUS: ${response.statusCode}'); // ← ADD
      print(' GET ITEMS BODY: ${response.body}'); // ← ADD
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['items'];
      }
      throw Exception('Failed to load items');
    } catch (e) {
      print(' GET ITEMS ERROR: $e'); // ← ADD
      throw Exception(e);
    }
  }

  static Future<void> createItem(Map<String, dynamic> item) async {
    print(' CREATE ITEM PAYLOAD: $item'); // ← ADD
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/lost-found'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(item),
      );
      print(' CREATE STATUS: ${response.statusCode}'); // ← ADD
      print(' CREATE BODY: ${response.body}'); // ← ADD
      if (response.statusCode != 200) throw Exception('Failed to post item');
    } catch (e) {
      print(' CREATE ITEM ERROR: $e'); // ← ADD
      throw Exception(e);
    }
  }

  static Future<void> markResolved(String itemId) async {
    print(' MARKING RESOLVED: $itemId'); // ← ADD
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/lost-found/$itemId/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': 'resolved'}),
      );
      print(' RESOLVE STATUS: ${response.statusCode}'); // ← ADD
    } catch (e) {
      print(' RESOLVE ERROR: $e'); // ← ADD
    }
  }

  static Future<List<dynamic>> searchItems(String query) async {
    print(' SEARCHING: $query'); // ← ADD
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/lost-found-search?q=$query'),
      );
      print(' SEARCH STATUS: ${response.statusCode}'); // ← ADD
      print(' SEARCH BODY: ${response.body}'); // ← ADD
      return jsonDecode(response.body)['items'];
    } catch (e) {
      print(' SEARCH ERROR: $e'); // ← ADD
      return [];
    }
  }



  static Future<Map<String, dynamic>?> fetchUserProfile(String userId) async {
    try {
      final response = await http
          .get(Uri.parse("$baseUrl/user/profile/$userId"))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final profile = jsonDecode(response.body)['user'];
        final rawRole = profile['role'] ?? 'student';
        currentUserRole = rawRole.toString().toLowerCase();
        print("DEBUG FRONTEND FETCH ROLE: Current user role synced: $rawRole -> $currentUserRole");
        return profile;
      }
      return null;
    } catch (e) {
      print("Fetch Profile Error (using default role 'student'): $e");
      currentUserRole ??= 'student'; // fallback so app doesn't get stuck
      return null;
    }
  }

  static Future<void> fetchRole() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId != null) {
      await fetchUserProfile(userId);
    }
  }

  static Future<void> registerFCMToken(String token) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await http.post(
        Uri.parse("$baseUrl/user/update-fcm"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "fcm_token": token,
        }),
      );

      if (response.statusCode == 200) {
        print("SUCCESS: FCM Token registered for $userId");
      }
    } catch (e) {
      print("FCM Registration Error: $e");
    }
  }

  static Future<void> logout() async {
    try {
      await supabase.auth.signOut();
      currentUserRole = null;
    } catch (e) {
      print("Logout Error: $e");
    }
  }

  // ─── Admin Operations ──────────────────────────────────────────────────────

  static Future<bool> adminCreateUser({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/admin/create-user"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
          "full_name": fullName,
          "role": role,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Admin Create User Error: $e");
      return false;
    }
  }
}
