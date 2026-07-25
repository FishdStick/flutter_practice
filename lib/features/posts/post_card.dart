import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final String postTitle;
  final String postAuthor;
  final String postPreviewContent;
  final int postCommentCount;

  // Constructor that requires the following NAMED PARAMETERS to be passed
  const PostCard({
    super.key,
    required this.postTitle,
    required this.postAuthor,
    required this.postPreviewContent,
    required this.postCommentCount
  });

  /*
  From what I learned, I assume we are doing an override here because the
  StatelessWidget class has an abstract Widget build method that needs to be
  overridden
  */
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                Icons.account_circle,
                    size: 28,
                    color: Colors.grey
                ),
                const SizedBox(width: 8),
                Text(
                  postAuthor,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            // Add Spacing
            const SizedBox(height: 12),

            // Post Title and Content
            Text(
              postTitle,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              postPreviewContent,
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),

            // Add Spacing
            const SizedBox(height: 16),

            Row (
              children: [
                const Icon(Icons.chat_bubble_outline,size: 18, color: Colors.blue),
                const SizedBox(width: 6),
                Text(
                  "$postCommentCount",
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}