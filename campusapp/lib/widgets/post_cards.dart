import 'package:campusapp/models/post_model.dart';
import 'package:campusapp/pages/post_details.dart';
import 'package:flutter/material.dart';

class PostCard extends StatefulWidget {
  final bool isDetails;
  final PostModel post;
  
  const PostCard({super.key, this.isDetails = false, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inDays > 0) return "${diff.inDays}d";
    if (diff.inHours > 0) return "${diff.inHours}h";
    return "${diff.inMinutes}m";
  }
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: widget.post.id,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.isDetails ? null : () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => PostDetailPage(post: widget.post),));
          },
        
          child: Container(
            padding: EdgeInsets.only(top: 5, bottom: 10, right: 8, left: 10),
            //height: MediaQuery.of(context).size.height * 0.15,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              //color: Colors.white,
              border: widget.isDetails? null : Border.symmetric(
                horizontal: BorderSide(
                  color: const Color.fromARGB(255, 110, 110, 110),
                  width: .5,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  if(!widget.isDetails) ...[ Row(
                  children: [
                    const CircleAvatar(
                      radius: 15,
                      // add image
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.post.userName,
                            style: const TextStyle(color: Colors.white, fontSize: 15),
                          ),
                          Text(
                            _formatTime(widget.post.postedTime),
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.more_vert, color: Colors.white, size: 25),
                    ),
                  ],
                ),],
                SizedBox(height: 2),
                Text(
                  widget.post.title,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
                SizedBox(height: 2),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  child: Text(widget.post.content,style: TextStyle(color: Colors.white, fontSize: 15)),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color.fromARGB(96, 255, 255, 255),
                      width: 0.5
                    ),
                    borderRadius: BorderRadius.circular(10)
                  ),
                ),
                SizedBox(height: 5,),
                Row(
                  children: [
                    _actionButton(
                      icon: widget.post.isLikedByMe ? Icons.thumb_up : Icons.thumb_up_outlined,
                      label: "${widget.post.likes}",
                      color: widget.post.isLikedByMe ? Colors.blue : Colors.white,
                      onTap: () => setState(() {
                        widget.post.isLikedByMe = !widget.post.isLikedByMe;
                        widget.post.isLikedByMe ? widget.post.likes++ : widget.post.likes--;
                      }),
                    ),
                    const SizedBox(width: 24),
                    _actionButton(
                      icon: Icons.comment_outlined,
                      label: "${widget.post.commentCount}",
                      color:Colors.white,
                      onTap: () {}, 
                    ),
                  ],
                ),
                  ],
                )
              
            ),
          ),
        ),
      );
    
  }
  Widget _actionButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color)),
        ],
      ),
    );
  }
Widget _interactionButton(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14,vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(
                color: const Color.fromARGB(96, 255, 255, 255),
                width: 0.5
              ),
              borderRadius: BorderRadius.circular(15)
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.white),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color:  Colors.white)),
          
        ],
      ),
    );
  }}


