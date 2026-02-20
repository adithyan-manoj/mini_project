import 'package:campusapp/models/post_model.dart';
import 'package:campusapp/widgets/post_cards.dart';
import 'package:flutter/material.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  @override
  Widget build(BuildContext context) {

    final List<PostModel> posts = [
      PostModel(
        id: "post_001",
        userName: "Aashwin Suresh",
        userProfilePic: "https://api.dicebear.com/7.x/avataaars/png?seed=Aashwin",
        postedTime: DateTime.now().subtract(const Duration(days: 4)),
        title: "Arjun as got pregnant",
        content: "CAN'T BELIEVE I'M FINALLY SHARING THIS NEWS! IT'S BEEN A WILD JOURNEY SO FAR...",
        likes: 69,
        commentCount: 100,
      ),
      PostModel(
        id: "post_002",
        userName: "Vinayak D",
        userProfilePic: "https://api.dicebear.com/7.x/avataaars/png?seed=Vinayak",
        postedTime: DateTime.now().subtract(const Duration(hours: 2)),
        title: "Mini Project Update",
        content: "Smart Campus Forum is coming along great! Backend in FastAPI is almost done.",
        likes: 42,
        commentCount: 12,
      ),
    ];
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Campus App', style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white
        ),),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        actions: [
          IconButton(onPressed: () {
            
          }, icon: const Icon(Icons.search,color: Colors.white,),
          
          ),
          const CircleAvatar(radius: 18,backgroundColor: Colors.white,),
          const SizedBox(width: 15,)
        ],
      ),
      body: 
      ListView.builder(
        itemCount: 1,
        itemBuilder:(context, index) {
          return PostCard(post: posts[index]);
        },),
    );
  }
}