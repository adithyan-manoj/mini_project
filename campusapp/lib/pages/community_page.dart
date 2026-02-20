import 'package:campusapp/widgets/post_cards.dart';
import 'package:flutter/material.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
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
        itemBuilder: (context, index) => PostCard(postId: 'id1',),),
    );
  }
}