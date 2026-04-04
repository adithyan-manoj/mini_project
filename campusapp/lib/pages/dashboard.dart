import 'package:campusapp/pages/backup_lost_found/backup_lost_found_list_page.dart';
import 'package:campusapp/pages/create_post.dart';
import 'package:campusapp/pages/create_event_page.dart';
import 'package:campusapp/pages/backup_lost_found/backup_post_item_page.dart';

import 'package:campusapp/pages/community_page.dart';
import 'package:campusapp/pages/events_page.dart';
import 'package:campusapp/pages/harassment/my_reports_page.dart';
import 'package:campusapp/pages/admin_panel_page.dart';
import 'package:campusapp/pages/harassment/harassment_monitor_page.dart'; 
import 'package:campusapp/pages/ai_chat_page.dart';
import 'package:campusapp/services/api_service.dart';
import 'package:campusapp/widgets/custom_nav_bar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _currentIndex = 0;
  bool _isRoleLoading = true;
  final GlobalKey<CommunityPageState> _communityKey = GlobalKey<CommunityPageState>();
  final GlobalKey<EventsPageState> _eventsKey = GlobalKey<EventsPageState>();
  final GlobalKey<BackupLostFoundListPageState> _lfKey = GlobalKey<BackupLostFoundListPageState>();

  @override
  void initState() {
    super.initState();
    _checkUserRole();
    _initFirebaseMessaging();
  }

  Future<void> _initFirebaseMessaging() async {
    try {
      final fcm = FirebaseMessaging.instance;
      
      // Get the token for this device
      String? token = await fcm.getToken();
      if (token != null) {
        await ApiService.registerFCMToken(token);
      }

      // Handle token refreshes
      fcm.onTokenRefresh.listen((newToken) {
        ApiService.registerFCMToken(newToken);
      });

      // Handle foreground notifications (optional alert)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print("Received Foreground Message: ${message.notification?.title}");
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               content: Text("${message.notification?.title}: ${message.notification?.body}"),
               backgroundColor: Colors.orangeAccent,
             ),
           );
        }
      });
    } catch (e) {
      print("FCM Init Error: $e");
    }
  }

  Future<void> _checkUserRole() async {
    try {
      await ApiService.fetchRole().timeout(
        const Duration(seconds: 6),
        onTimeout: () {
          print("DASHBOARD: fetchRole timed out, defaulting to 'student'");
          ApiService.currentUserRole ??= 'student';
        },
      );
    } catch (e) {
      print("DASHBOARD: fetchRole error: $e");
      ApiService.currentUserRole ??= 'student';
    } finally {
      if (mounted) {
        setState(() {
          _isRoleLoading = false;
        });
      }
    }
  }

  List<Widget> get _pages {
    final role = ApiService.currentUserRole;
    
    return [
      CommunityPage(key: _communityKey),
      EventsPage(key: _eventsKey),
      BackupLostFoundListPage(key: _lfKey),
      if (role == 'admin')
        const AdminPanelPage()
      else if (role == 'staff')
        const HarassmentMonitorPage()
      else
        const MyReportsPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_isRoleLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }
    
    // DEBUG: Confirm role in Dashboard build
    print("DASHBOARD BUILD: Current Role is ${ApiService.currentUserRole}");
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: CustomAiamtedNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Index 0: Community Page Buttons
          if (_currentIndex == 0) ...[
            FloatingActionButton(
              heroTag: 'add_post_fab',
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreatePost()),
                );
                if (result == true) {
                  _communityKey.currentState?.loadPosts();
                }
              },
              backgroundColor: Colors.white,
              mini: true,
              child: const Icon(Icons.add, color: Colors.black),
            ),
            const SizedBox(height: 12),
          ],

          // Index 1: Events Page Buttons (Admin/Club Rep only)
          if (_currentIndex == 1 && (ApiService.currentUserRole == 'admin' || ApiService.currentUserRole == 'club_rep')) ...[
            FloatingActionButton(
              heroTag: 'events_fab_tag',
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const CreateEvent()),
                );
                if (result == true) {
                  _eventsKey.currentState?.updateFilters("All", "");
                }
              },
              backgroundColor: Colors.white,
              mini: true,
              child: const Icon(Icons.my_library_add_sharp, color: Colors.black),
            ),
            const SizedBox(height: 12),
          ],

          // Index 2: Lost & Found Page Buttons
          if (_currentIndex == 2) ...[
            FloatingActionButton(
              heroTag: 'backup_lost_found_fab_tag',
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BackupPostItemPage()),
                );
                if (result == true) {
                  _lfKey.currentState?.loadItems();
                }
              },
              backgroundColor: Colors.white,
              mini: true,
              child: const Icon(Icons.add_location_alt_outlined, color: Colors.black),
            ),
            const SizedBox(height: 12),
          ],

          // The Global AI Chat Button (Always present)
          FloatingActionButton(
            heroTag: 'ai_chat_fab',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AiChatPage()),
              );
            },
            backgroundColor: Colors.orange,
            child: const Icon(Icons.psychology_outlined, color: Colors.black, size: 30),
          ),
        ],
      ),
    );
  }
}
