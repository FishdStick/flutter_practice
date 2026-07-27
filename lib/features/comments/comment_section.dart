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
      context.read<CommentProvider>().getComments(widget.postId);
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

  // Edit Comment dialog box
  void _showEditCommentDialog(BuildContext context, Comment comment) {
    final editController = TextEditingController(text: comment.content);
    List<String> existingUrls = List<String>.from(comment.imageUrls);
    List<XFile> newImages = [];

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final allPreviewPaths = [
            ...existingUrls,
            ...newImages.map((e) => e.path),
          ];

          return AlertDialog(
            title: const Text('Edit Comment'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: editController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Comment',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await _picker.pickMultiImage();
                      if (picked.isNotEmpty) {
                        setModalState(() {
                          newImages.addAll(picked);
                        });
                      }
                    },
                    icon: const Icon(Icons.attach_file),
                    label: Text('Attach images ${newImages.length}'),
                  ),
                  if (allPreviewPaths.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ImagePreviewRow(
                      imageUrls: allPreviewPaths,
                      // What's idx and where does it come from? is it
                      // similar to ctx to how it refers to build context?
                      onDelete: (idx) {
                        setModalState(() {
                          if (idx < existingUrls.length) {
                            existingUrls.removeAt(idx);
                          } else {
                            newImages.removeAt(idx - existingUrls.length);
                          }
                        });
                      },
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final text = editController.text.trim();
                  if (text.isEmpty &&
                      existingUrls.isEmpty &&
                      newImages.isEmpty) {
                    return;
                  }
                  final success = await context
                      .read<CommentProvider>()
                      .updateComment(
                          commentId: comment.id,
                          postId: widget.postId,
                          content: text,
                          existingImageUrls: existingUrls,
                          newImages: newImages);

                  if (dialogCtx.mounted) {
                    Navigator.pop(dialogCtx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success
                            ? 'Comment updated.'
                            : 'Failed to update comment.'),
                        backgroundColor:
                            success ? Colors.green : Colors.redAccent,
                      ),
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _pickImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      // Why use set state here? Aren't we using provider for state management?
      // Answer: setState() is best used for managing local UI state. By doing
      // this, we make sure provider only manages global states.
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
                          // Triple Dot 'more'
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, size: 16),
                            onSelected: (value) async {
                              if (value == 'edit') {
                                _showEditCommentDialog(context, comment);
                              } else if (value == 'delete') {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Delete Comment'),
                                    content: const Text(
                                        'Are you sure you want to delete this comment?'),
                                    actions: [
                                      // Cancel button
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: const Text('Cancel'),
                                      ),
                                      // Delete button
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                        child: const Text('Delete',
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await commentProvider.deleteComment(
                                      comment.id, widget.postId);
                                }
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 16),
                                    SizedBox(width: 8),
                                    Text('Edit',
                                        style: TextStyle(fontSize: 13)),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 16),
                                    SizedBox(width: 8),
                                    Text('Delete',
                                        style: TextStyle(fontSize: 13, color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
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
