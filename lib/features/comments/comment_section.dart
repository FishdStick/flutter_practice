import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/comment_provider.dart';
import '../posts/image_preview_row.dart';

class CommentSection extends StatefulWidget {
  final String postId;

  const CommentSection({super.key, required this.postId});

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

// Im guessing this creates parameterized Generics that only accepts CommentSection
// Why do classes that are subclasses of State, require the build method?
class _CommentSectionState extends State<CommentSection> {
  final _commentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  // compared to create_post, why is this not final?
  List<XFile> _selectedImages = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommentProvider>().fetchComments(widget.postId);
    });
  }

  // Makes comment-level images clickable and loads their full size
  void _showImagePreview(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      // what's ctx?
      // ctx apparently refers to the to the BuildContext
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: const Icon(Icons.broken_image, size: 60),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(ctx)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      // Why use set state here? Aren't we using provider for state management?
      // setState() is best used for managing local UI state. By doing this,
      // we make sure provider only manages global states.
      setState(() {
        _selectedImages.addAll(pickedFiles);
      });
    }
  }

  void _postComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty && _selectedImages.isEmpty) return;

    setState(() => _isSubmitting = true);
    final commentProvider = context.read<CommentProvider>();

    final success = await commentProvider.addComment(
      // how can widget provide the postId? Where is widget.postId coming from?
      postId: widget.postId,
      content: text,
      selectedImages: _selectedImages,
    );

    if (!mounted) {
      return;
    }
    setState(() => _isSubmitting = false);
    if (success) {
      _commentController.clear();
      setState(() {
        _selectedImages = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comment posted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to post comment!'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final commentProvider = context.watch<CommentProvider>();
    final comments = commentProvider.getCommentsForPost(widget.postId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Comment Section
        const Divider(
          height: 24,
        ),
        const Text('Comments',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),

        // Loads comments if they exist
        if (comments.isEmpty)
          const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text('Be the first to comment!',
                  style: TextStyle(color: Colors.grey)))
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: comments.length,
            itemBuilder: (context, index) {
              final comment = comments[index];
              final isOwner = authProvider.isLoggedIn &&
                  authProvider.currentUser?.id == comment.userId;
              return Container(
                margin: const EdgeInsets.only(bottom: 8.0),
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Author and Delete Icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          comment.authorEmail,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        if (isOwner)
                          InkWell(
                            onTap: () => commentProvider.deleteComment(
                              comment.id,
                              widget.postId,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.red,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(comment.content, style: const TextStyle(fontSize: 13)),

                    // Preview of Images in comment
                    // Displays images if they exist for the comment under the
                    // post it is in
                    if (comment.imageUrls.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 60,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: comment.imageUrls.length,
                          itemBuilder: (ctx, i) => Padding(
                            padding: const EdgeInsets.only(right: 6.0),

                            // Clickable comment images
                            child: InkWell(
                              onTap: () => _showImagePreview(
                                context, comment.imageUrls[i]),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.network(
                                  comment.imageUrls[i],
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        if (authProvider.isLoggedIn) ...[
          const SizedBox(height: 12),
          if (_selectedImages.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ImagePreviewRow(
                imageUrls: _selectedImages.map((e) => e.path).toList(),
                onDelete: (index) {
                  setState(() {
                    _selectedImages.removeAt(index);
                  });
                },
              ),
            ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.attach_file),
                onPressed: _pickImages,
                tooltip: 'Attach Images:',
              ),
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: 'Write a comment...',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send, color: Colors.blue),
                  onPressed: _isSubmitting ? null : _postComment),
            ],
          ),
        ] else
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              'Log in to join the conversation',
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          ),
      ],
    );
  }
}
