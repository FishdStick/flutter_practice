import 'package:flutter/material.dart';
import '../../../core/models/post.dart';
import '../../../core/utils/format_date_utils.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;

  const PostCard({super.key, required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final DateFormattingUtils formatDateUtil = DateFormattingUtils();
    final formattedDate = formatDateUtil.formatDate(post.createdAt);

    return InkWell(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 160,
              width: double.infinity,
              child: post.imageUrls.isNotEmpty
                  ? Container(
                      color: Colors.grey[100],
                      child: Image.network(
                        post.imageUrls.first,
                        fit: BoxFit.contain,
                        errorBuilder: (ctx, _, __) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image, size: 40),
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.article_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                    ),
            ),
            // Card Contents
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Post Author
                    Text(
                      post.authorEmail.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                          letterSpacing: 0.8),
                    ),
                    const SizedBox(height: 6),
                    // Post Title
                    Text(
                      post.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Post Content
                    Text(
                      post.content,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                    const Spacer(),
                    Text(
                      formattedDate,
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
