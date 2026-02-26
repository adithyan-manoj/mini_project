import 'package:campusapp/models/comment_model.dart';
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
        id: 'id1',
        userName: "Vinayak D",
        text: "Huge congrats, Arjun! So happy for you. ❤️",
        subComments: [
          CommentModel(id: 'id2',userName: "Arjun", text: "Thanks man! Appreciate it."),
          CommentModel(
            id: 'id3',
            userName: "Arjun",
            text: "Thanks man! Appreciate it.",
            subComments: [
              CommentModel(
                id: 'id4',
                userName: "Arjun",
                text: "Thanks man! Appreciate it.",
                subComments: [
                  CommentModel(
                    id: 'id5',
                    userName: "Arjun",
                    text: "Thanks man! Appreciate it.",
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      CommentModel(id: 'id11',userName: "Adithyan S", text: "So proud of you buddy!",subComments: [
        CommentModel(id: 'id12',userName: "Arjun", text: "Thanks man! Appreciate it."),
      ]),
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
                PostCard(isDetails: true, post: widget.post),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Text(
                    "Comments",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
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

  // Widget buildCommentThread(CommentModel comment, {double indent = 0}) {
  //   return Padding(
  //     padding: EdgeInsets.only(left: 16 + indent, right: 16, top: 8, bottom: 4),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             const CircleAvatar(radius: 12),
  //             const SizedBox(width: 10),
  //             Expanded(
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     comment.userName,
  //                     style: const TextStyle(
  //                       fontWeight: FontWeight.bold,
  //                       color: Colors.white,
  //                       fontSize: 13,
  //                     ),
  //                   ),
  //                   const SizedBox(height: 2),
  //                   Text(
  //                     comment.text,
  //                     style: const TextStyle(color: Colors.white, fontSize: 13),
  //                   ),
  //                   const SizedBox(height: 4),
  //                   const Text(
  //                     "Reply",
  //                     style: TextStyle(color: Colors.white54, fontSize: 11),
  //                   ), // Figma Reply button
  //                 ],
  //               ),
  //             ),
  //             const Icon(Icons.more_vert, size: 16, color: Colors.white54),
  //           ],
  //         ),

  //         // If there are sub-comments, call THIS SAME function again
  //         if (comment.subComments.isNotEmpty)
  //           ...comment.subComments
  //               .map((sub) => buildCommentThread(sub, indent: indent + 20))
  //               .toList(),
  //       ],
  //     ),
  //   );
  // }

//   Widget buildCommentThread(CommentModel comment, {double indent = 0}) {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       // THE MAIN COMMENT
//       buildCommentItem(comment),

//       // THE REPLIES SECTION
//       if (comment.subComments.isNotEmpty)
//         IntrinsicHeight( // Crucial to make the vertical line match the content height
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // THE CONNECTING LINE
//               Padding(
//                 padding: const EdgeInsets.only(left: 12.0), // Align under the parent avatar
//                 child: Container(
//                   width: 1.5,
//                   color: Colors.white24, // Matches your black/grey theme
//                 ),
//               ),
              
//               // THE REPLIES LIST
//               Expanded(
//                 child: Column(
//                   children: comment.subComments
//                       .map((sub) => buildCommentThread(sub, indent: 10))
//                       .toList(),
//                 ),
//               ),
//             ],
//           ),
//         ),
//     ],
//   );
// }


// Widget buildCommentThread(CommentModel comment, {double indent = 0}) {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       _buildCommentItem(comment, indent),
//       if (comment.subComments.isNotEmpty)
//         Padding(
//           padding: EdgeInsets.only(left: 28 + indent), // Align with parent avatar
//           child: Column(
//             children: comment.subComments.map((sub) {
//               return Stack(
//                 children: [
//                   // THE YOUTUBE LINE
//                   Positioned(
//                     left: 0,
//                     top: 0,
//                     bottom: 0,
//                     child: Container(
//                       width: 1.5,
//                       color: Colors.white10,
//                     ),
//                   ),
//                   // THE HORIZONTAL "HOOK"
//                   Positioned(
//                     left: 0,
//                     top: 20, // Adjust to align with the middle of the child avatar
//                     child: Container(
//                       width: 15, // How long the "hook" is
//                       height: 1.5,
//                       color: Colors.white10,
//                     ),
//                   ),
//                   // THE ACTUAL CHILD CONTENT
//                   Padding(
//                     padding: const EdgeInsets.only(left: 15), 
//                     child: buildCommentThread(sub, indent: 0),
//                   ),
//                 ],
//               );
//             }).toList(),
//           ),
//         ),
//     ],
//   );
// }

Widget buildCommentThread(CommentModel comment, {double indent = 0}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildCommentItem(comment, indent),
      if (comment.subComments.isNotEmpty)
        Padding(
          padding: EdgeInsets.only(left: 28 + indent), 
          child: Column(
            children: comment.subComments.map((sub) {
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // THE CURVED CONNECTOR
                    SizedBox(
                      width: 20, // Distance the curve travels horizontally
                      child: Stack(
                        children: [
                          // Persistent vertical line for deeper nesting
                          Container(
                            width: 1.5,
                            color: Colors.white60,
                          ),
                          // The actual curve pointing to this specific reply
                          CustomPaint(
                            size: const Size(20, 40),
                            painter: ThreadCurvePainter(color: Colors.white60),
                          ),
                        ],
                      ),
                    ),
                    // THE CHILD CONTENT
                    Expanded(
                      child: buildCommentThread(sub, indent: 0),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
    ],
  );
}
// // Widget buildCommentThread(CommentModel comment, {double indent = 0}) {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       // 1. Draw the single comment UI
//       _buildCommentItem(comment, indent),

//       // 2. Draw the vertical line and sub-comments
//       if (comment.subComments.isNotEmpty)
//         IntrinsicHeight( // Ensures the line stretches to the bottom of the last reply
//           child: Row(
//             children: [
//               // THE CONNECTING LINE
//               Container(
//                 width: 1.5,
//                 margin: EdgeInsets.only(left: 28 + indent), // Aligns line under parent avatar
//                 color: Colors.white12, // Subtle grey line
//               ),
//               // THE NESTED REPLIES
//               Expanded(
//                 child: Column(
//                   children: comment.subComments
//                       .map((sub) => buildCommentThread(sub, indent: 8)) // Indent the next level
//                       .toList(),
//                 ),
//               ),
//             ],
//           ),
//         ),
//     ],
//   );
// }

Widget _buildCommentItem(CommentModel comment, double indent) {
  return Padding(
    padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(radius: 12, backgroundColor: Colors.grey),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                comment.userName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                comment.text,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
              const SizedBox(height: 4),
              const Text(
                "Reply",
                style: TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],
          ),
        ),
        const Icon(Icons.more_vert, size: 16, color: Colors.white54),
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
          border: Border.all(
            width: 1,
            color: Color.fromARGB(255, 152, 152, 152),
          ),
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

class ThreadCurvePainter extends CustomPainter {
  final Color color;
  ThreadCurvePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    // Start at the top left
    path.moveTo(0, 0);
    // Draw line down to the middle, then curve to the right
    path.lineTo(0, size.height * 0.4); 
    path.quadraticBezierTo(
      0, size.height * 0.7, // Control point (the "bend" of the curve)
      size.width, size.height * 0.7, // End point (pointing at the child avatar)
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}