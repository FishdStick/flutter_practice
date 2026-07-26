import 'package:flutter/material.dart';

class CommentSection extends StatefulWidget {
  const CommentSection({super.key});

  @override
  // What's State<> generics?
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  // What is this class?
  final TextEditingController _commentController = TextEditingController();

  final List<String> _comments = [];

  void _addComment() {
    final text = _commentController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _comments.insert(0, text);
      });
      _commentController.clear();
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  hintText: 'Write a comment...',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _addComment,
              child: const Text('Post'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Comments (${_comments.length})',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        ..._comments.map((comment) => Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: const Icon(Icons.comment),
                title: Text(comment),
              ),
            )),
      ],
    );
  }
}
