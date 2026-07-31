import 'package:flutter/material.dart';
import 'package:flutter_practice/core/utils/snackbar_utils.dart';
import 'package:flutter_practice/features/posts/image_preview_row.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/post.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/post_provider.dart';
import '../../core/utils/image_picker_utils.dart';
import '../comments/comment_section.dart';
import '../../core/utils/format_date_utils.dart';
import '../../core/utils/image_preview_utils.dart';
import '../../core/utils/dialog_utils.dart';
import '../widgets/owner_action_menu.dart';
import '../widgets/resizeable_text_field.dart';

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

  void _showEditPostDialog(BuildContext context, Post post) {
    final formKey = GlobalKey<FormState>();
    final editPostTitleController = TextEditingController(text: post.title);
    final editPostBodyController = TextEditingController(text: post.content);
    List<String> existingImageUrls = List<String>.from(post.imageUrls);

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(builder: (ctx, setModalState) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Edit Post',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                              onPressed: () => Navigator.pop(dialogCtx),
                              icon: const Icon(Icons.close)),
                        ],
                      ),
                      TextFormField(
                        controller: editPostTitleController,
                        decoration: const InputDecoration(
                          labelText: 'Post Title',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                                ? 'Please enter a title'
                                : null,
                      ),
                      const SizedBox(height: 16),
                      ResizeableTextArea(
                          textFieldController: editPostBodyController,
                          labelText: 'Post body',
                          initialHeight: 120.0,
                          minHeight: 120.0,
                          maxHeight: 450.0),
                      const SizedBox(height: 16),
                      if (existingImageUrls.isNotEmpty) ...[
                        ImagePreviewRow(
                          imageUrls: existingImageUrls,
                          onDelete: (index) {
                            setModalState(() {
                              existingImageUrls.removeAt(index);
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                      // Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                              onPressed: () => Navigator.pop(dialogCtx),
                              child: const Text('Cancel')),
                          const SizedBox(width: 8),
                          ElevatedButton(
                              onPressed: () async {
                                if (!formKey.currentState!.validate()) return;

                                final success = await context
                                    .read<PostProvider>()
                                    .updatePost(
                                  postId: post.id,
                                  title: editPostTitleController.text.trim(),
                                  content: editPostBodyController.text.trim(),
                                  existingImageUrls: existingImageUrls,
                                  newImages: [], //will this remove images when i edit a post?
                                );

                                if (dialogCtx.mounted) {
                                  Navigator.pop(dialogCtx);
                                  if (success) {
                                    SnackBarUtils.showSuccess(
                                        context, 'Post updated.');
                                  } else {
                                    SnackBarUtils.showError(
                                        context, 'Failed to update post.');
                                  }
                                }
                              },
                              child: const Text('Save Changes'))
                        ],
                      )
                    ],
                  )),
            ),
          ),
        );
      }),
    );
  }

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
            OwnerActionMenu(
              onEdit: () {
                _showEditPostDialog(context, post);
                // context.push('/edit-post/${post.id}');
              },
              onDelete: () async {
                final confirm = await DialogUtils.showConfirmDialog(
                    context: context,
                    title: 'Delete Post',
                    content: 'Are you sure you want to delete this post?',
                    confirmText: 'Delete');
                if (confirm) {
                  final deleted = await postProvider.deletePost(post.id);
                  if (context.mounted && deleted) {
                    context.go('/');
                  }
                }
              },
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
                            return GestureDetector(
                              onTap: () =>
                                  ImagePreviewUtils.expandPreviewImageGallery(
                                      context, post.imageUrls, index),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12)),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    post.imageUrls[index],
                                    fit: BoxFit.contain,
                                    width: double.infinity,
                                    errorBuilder: (ctx, _, __) => Container(
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.broken_image,
                                          size: 60, color: Colors.grey),
                                    ),
                                  ),
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
