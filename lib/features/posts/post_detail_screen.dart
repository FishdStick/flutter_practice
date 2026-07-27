import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/post_provider.dart';
import '../comments/comment_section.dart';
import '../../core/utils/format_date_utils.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final PageController _pageController = PageController();
  final DateFormattingUtils formatDateUtil = DateFormattingUtils();
  int _currentImageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final postProvider = context.watch<PostProvider>();
    final post = postProvider.getPostById(widget.postId);

    final isOwner =
        authProvider.isLoggedIn && authProvider.currentUser?.id == post?.userId;

    if (post == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Post Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Post does not exist'),
              const SizedBox(height: 16),
              ElevatedButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Back to Main Feed')),
            ],
          ),
        ),
      );
    }
    final formattedDate = formatDateUtil.formatDate(post.createdAt);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.go('/'),
        ),
        actions: [
          if (isOwner)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) async {
                if (value == 'edit') {
                  context.push('/edit-post/${post.id}');
                } else if (value == 'delete') {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Post'),
                      content: const Text(
                          'Are you sure you want to delete this post?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel')),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Delete',
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    final deleted = await postProvider.deletePost(post.id);
                    if (context.mounted && deleted) {
                      context.go('/');
                    }
                  }
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Edit Post'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete Post', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Browsing (Carousel)
                if (post.imageUrls.isNotEmpty) ...[
                  SizedBox(
                    height: 350,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          itemCount: post.imageUrls.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentImageIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                post.imageUrls[index],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (ctx, _, __) => Container(
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.broken_image,
                                      size: 60, color: Colors.grey),
                                ),
                              ),
                            );
                          },
                        ),
                        if (_currentImageIndex > 0)
                          Positioned(
                              left: 8,
                              child: CircleAvatar(
                                  backgroundColor: Colors.black54,
                                  child: IconButton(
                                      icon: const Icon(Icons.chevron_left,
                                          color: Colors.white),
                                      onPressed: () {
                                        _pageController.previousPage(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            curve: Curves.easeInOut);
                                      }))),
                        if (_currentImageIndex < post.imageUrls.length - 1)
                          Positioned(
                              right: 8,
                              child: CircleAvatar(
                                  backgroundColor: Colors.black54,
                                  child: IconButton(
                                      icon: const Icon(Icons.chevron_right,
                                          color: Colors.white),
                                      onPressed: () {
                                        _pageController.nextPage(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            curve: Curves.easeInOut);
                                      }))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Dots
                  if (post.imageUrls.length > 1)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                          post.imageUrls.length,
                          (idx) => Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                width: _currentImageIndex == idx ? 10 : 6,
                                height: _currentImageIndex == idx ? 10 : 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentImageIndex == idx
                                      ? Colors.blue
                                      : Colors.grey,
                                ),
                              )),
                    ),
                  const SizedBox(height: 20),
                ],

                // Author and Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Author
                    Text(
                      'BY ${post.authorEmail.toUpperCase()}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                        letterSpacing: 1.0,
                      ),
                    ),
                    // Date
                    Text(
                      formattedDate,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Post Title
                Text(
                  post.title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),

                // Post Content
                Text(
                  post.content,
                  style: const TextStyle(
                      fontSize: 16, height: 1.6, color: Colors.black87),
                ),
                const SizedBox(height: 32),

                CommentSection(postId: post.id),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
