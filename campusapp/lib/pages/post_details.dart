import 'package:campusapp/models/comment_model.dart';
import 'package:campusapp/models/post_model.dart';
import 'package:campusapp/services/api_service.dart';
import 'package:campusapp/widgets/post_cards.dart';
import 'package:flutter/material.dart';

class PostDetailPage extends StatefulWidget {
  final PostModel post;
  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  List<CommentModel> _comments = [];
  bool _isLoading = true;
  bool _isSending = false;

  // Reply state
  String? _replyingToId;       // parent comment id being replied to
  String? _replyingToName;     // display name for "Replying to @..." banner

  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() => _isLoading = true);
    final comments = await ApiService.fetchComments(widget.post.id);
    if (mounted) setState(() { _comments = comments; _isLoading = false; });
  }

  void _startReply(CommentModel comment) {
    setState(() {
      _replyingToId = comment.id;
      _replyingToName = comment.userName;
    });
    _inputFocus.requestFocus();
  }

  void _cancelReply() {
    setState(() { _replyingToId = null; _replyingToName = null; });
  }

  Future<void> _submitComment() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);
    final success = await ApiService.createComment(
      postId: widget.post.id,
      content: text,
      parentCommentId: _replyingToId,
    );

    if (!mounted) return;
    setState(() => _isSending = false);

    if (success) {
      _inputController.clear();
      _cancelReply();
      await _loadComments();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to post comment. Please try again.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
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
          // ── Post + comments ──────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : ListView(
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
                      if (_comments.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(
                            child: Text(
                              'No comments yet. Be the first!',
                              style: TextStyle(color: Colors.white38, fontSize: 14),
                            ),
                          ),
                        )
                      else
                        ..._comments.map((c) => buildCommentThread(c)).toList(),
                    ],
                  ),
          ),

          // ── Replying-to banner ───────────────────────────────────────────
          if (_replyingToName != null)
            Container(
              color: const Color(0xFF1A1A1A),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.reply, size: 14, color: Colors.white54),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Replying to @$_replyingToName',
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ),
                  GestureDetector(
                    onTap: _cancelReply,
                    child: const Icon(Icons.close, size: 14, color: Colors.white54),
                  ),
                ],
              ),
            ),

          // ── Comment input ────────────────────────────────────────────────
          _buildCommentInput(),
        ],
      ),
    );
  }

  // ── Recursive comment thread renderer ─────────────────────────────────────
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
                      SizedBox(
                        width: 20,
                        child: Stack(
                          children: [
                            Container(width: 1.5, color: Colors.white24),
                            CustomPaint(
                              size: const Size(20, 40),
                              painter: ThreadCurvePainter(color: Colors.white24),
                            ),
                          ],
                        ),
                      ),
                      Expanded(child: buildCommentThread(sub, indent: 0)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildCommentItem(CommentModel comment, double indent) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.grey[700],
            backgroundImage: comment.profilePic.isNotEmpty
                ? NetworkImage(comment.profilePic)
                : null,
          ),
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
                GestureDetector(
                  onTap: () => _startReply(comment),
                  child: const Text(
                    "Reply",
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.more_vert, size: 16, color: Colors.white54),
        ],
      ),
    );
  }

  // ── Comment input bar ──────────────────────────────────────────────────────
  Widget _buildCommentInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.black,
          border: Border.all(
            width: 1,
            color: const Color.fromARGB(255, 152, 152, 152),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.comment_outlined, color: Colors.white54),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _inputController,
                focusNode: _inputFocus,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: _replyingToName != null
                      ? 'Reply to @$_replyingToName...'
                      : 'Add a comment...',
                  border: InputBorder.none,
                  hintStyle: const TextStyle(color: Colors.white60),
                ),
                onSubmitted: (_) => _submitComment(),
              ),
            ),
            _isSending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : GestureDetector(
                    onTap: _submitComment,
                    child: const Icon(Icons.arrow_upward, color: Colors.white),
                  ),
          ],
        ),
      ),
    );
  }
}

// ── Thread connector painter ──────────────────────────────────────────────────
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
    path.moveTo(0, 0);
    path.lineTo(0, size.height * 0.4);
    path.quadraticBezierTo(
      0, size.height * 0.7,
      size.width, size.height * 0.7,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}