import 'package:campusapp/core/commant_model.dart';
import 'package:campusapp/models/post_model.dart';
import 'package:campusapp/widgets/post_cards.dart';
import 'package:flutter/material.dart';

class PostDetailPage extends StatefulWidget {
  final PostModel post;

  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  @override
  Widget build(BuildContext context) {
    List<CommentModel> dummyComments = [
      CommentModel(
        userName: "Vinayak D",
        text: "Huge congrats, Arjun! So happy for you. ❤️",
        subComments: [
          CommentModel(userName: "Arjun", text: "Thanks man! Appreciate it."),
        ],
      ),
      CommentModel(userName: "Adithyan S", text: "So proud of you buddy!"),
    ];
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true, // Centers the profile
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(radius: 14, backgroundColor: Colors.orange),
            const SizedBox(width: 8),
            Text(
              widget.post.userName,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                PostCard(isDetails: true, post: widget.post ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Text("Comments", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
                ),
                ...dummyComments.map((c) => buildCommentThread(c)).toList(),
                //const Divider(color: Colors.white, thickness: 0.5,)
              ],
            ),
          ),
          _buildCommentInput(),
        ],
      ),
      
    );
    
  }

  Widget buildCommentThread(CommentModel comment, {double indent = 0}) {
    return Padding(
      padding: EdgeInsets.only(left: 16 + indent, right: 16, top: 8, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(radius: 12),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(comment.userName, style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(comment.text, style: const TextStyle(color: Colors.white, fontSize: 13)),
                    const SizedBox(height: 4),
                    const Text("Reply", style: TextStyle(color: Colors.white54, fontSize: 11)), // Figma Reply button
                  ],
                ),
              ),
              const Icon(Icons.more_vert, size: 16, color: Colors.white54),
            ],
          ),
          // If there are sub-comments, call THIS SAME function again
          if (comment.subComments.isNotEmpty)
            ...comment.subComments.map((sub) => buildCommentThread(sub, indent: indent + 20)).toList(),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 38.0, horizontal: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.black,
          border: Border.all(width: 1,color:  Color.fromARGB(255, 152, 152, 152),), 
        ),
        child: Row(
          children: [
            const Icon(Icons.comment_outlined, color: Colors.white),
            const SizedBox(width: 12),
            const Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: "add comments",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const Icon(Icons.arrow_upward, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
