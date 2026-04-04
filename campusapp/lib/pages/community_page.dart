import 'package:campusapp/models/post_model.dart';
import 'package:campusapp/pages/create_post.dart';
import 'package:campusapp/pages/profile_page.dart';
import 'package:campusapp/services/api_service.dart';
import 'package:campusapp/widgets/post_cards.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => CommunityPageState();
}

class CommunityPageState extends State<CommunityPage> {
  List<PostModel> _posts = [];
  bool _isLoading = true;
  Map<String, dynamic>? _userProfile;

  @override
  void initState() {
    super.initState();
    loadPosts();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final userId = ApiService.supabase.auth.currentUser?.id;
    if (userId != null) {
      final profile = await ApiService.fetchUserProfile(userId);
      if (mounted) {
        setState(() => _userProfile = profile);
      }
    }
  }

  Future<void> loadPosts() async {
    setState(() => _isLoading = true);
    final posts = await ApiService.fetchPosts();
    if (mounted) {
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Campus App',
          style: GoogleFonts.oswald(textStyle: const TextStyle(fontSize: 28)),
        ),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: Colors.white),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white10,
              backgroundImage: NetworkImage(
                _userProfile?['profile_pic_url'] ?? 
                'https://api.dicebear.com/7.x/avataaars/png?seed=${ApiService.supabase.auth.currentUser?.id ?? "anon"}',
              ),
            ),
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _posts.isEmpty
              ? Center(
                  child: Text(
                    'No posts yet.\nBe the first to post!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadPosts,
                  color: Colors.white,
                  backgroundColor: Colors.grey[900],
                  child: ListView.builder(
                    itemCount: _posts.length,
                    itemBuilder: (context, index) {
                      return PostCard(post: _posts[index]);
                    },
                  ),
                ),
    );
  }
}
