import 'package:campusapp/core/app_colors.dart';
import 'package:campusapp/models/event_model.dart';
import 'package:campusapp/models/post_model.dart';
import 'package:campusapp/pages/event_details_page.dart';
import 'package:campusapp/pages/post_details.dart';
import 'package:campusapp/services/ai_api_service.dart';
import 'package:campusapp/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'isUser': true, 'text': text});
      _isLoading = true;
      _messageController.clear();
    });

    _scrollToBottom();

    try {
      final response = await AiApiService.sendChatQuery(text);
      
      if (mounted) {
        setState(() {
          _messages.add({
            'isUser': false,
            'text': response['answer'],
            'links': response['links'],
          });
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({
            'isUser': false,
            'text': "Sorry, I'm having trouble connecting right now. Please try again later.",
          });
          _isLoading = false;
        });
      }
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Campus AI',
          style: GoogleFonts.oswald(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildChatBubble(message);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Center(child: CircularProgressIndicator(color: Colors.orange)),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(Map<String, dynamic> message) {
    final bool isUser = message['isUser'] ?? false;
    final List<dynamic>? links = message['links'];

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUser ? Colors.orange.withOpacity(0.9) : AppColors.cardGrey,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 16),
          ),
          border: Border.all(
            color: isUser ? Colors.orangeAccent : AppColors.accentBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MarkdownBody(
              data: message['text'] ?? '',
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(color: isUser ? Colors.black : Colors.white, fontSize: 15),
              ),
            ),
            if (links != null && links.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: links.map((link) {
                  return ActionChip(
                    backgroundColor: Colors.white10,
                    label: Text(
                      link['title'] ?? 'View Details',
                      style: const TextStyle(color: Colors.orange, fontSize: 12),
                    ),
                    onPressed: () async {
                      // Handled in Step 5: Navigation
                      final type = link['type'];
                      final id = link['id'].toString();

                      if (type == 'event') {
                        final event = await ApiService.fetchEventById(id);
                        if (event != null && mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => EventDetailsPage(event: event)),
                          );
                        }
                      } else if (type == 'post') {
                        final post = await ApiService.fetchPostById(id);
                        if (post != null && mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => PostDetailPage(post: post)),
                          );
                        }
                      }
                    },
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: AppColors.cardGrey,
        border: Border(top: BorderSide(color: AppColors.accentBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              onSubmitted: (_) => _sendMessage(),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Ask about events, posts...",
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.orange,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.black),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
