import 'package:flutter/material.dart';
import 'package:flutter_practice/core/utils/dialog_utils.dart';
import 'package:flutter_practice/core/utils/image_picker_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/comment_provider.dart';
import '../../core/utils/image_preview_utils.dart';
import '../../core/utils/snackbar_utils.dart';
import '../posts/image_preview_row.dart';
import '../../core/models/comment.dart';

class CommentSection extends StatefulWidget {
  final String postId;

  const CommentSection({super.key, required this.postId});

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final _commentController = TextEditingController();

  List<XFile> _selectedImages = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommentProvider>().getComments(widget.postId);
    });
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
                      if (await ImagePickerUtils.attachImagesTo(newImages)) {
                        setModalState(() {});
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
                    if (success) {
                      SnackBarUtils.showSuccess(context, 'Comment updated.');
                    } else {
                      SnackBarUtils.showError(
                          context, 'Failed to update comment');
                    }
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
      SnackBarUtils.showSuccess(context, 'Comment posted');
    } else {
      SnackBarUtils.showError(context, 'Failed to post comment');
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
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, size: 16),
                            onSelected: (value) async {
                              if (value == 'edit') {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  if (context.mounted) {
                                    _showEditCommentDialog(context, comment);
                                  }
                                });
                              } else if (value == 'delete') {
                                final confirm = await DialogUtils.showConfirmDialog(
                                    context: context,
                                    title: 'Delete Comment',
                                    content:
                                        'Are you sure you want to delete this comment?',
                                    confirmText: 'Delete');
                                if (confirm) {
                                  await commentProvider.deleteComment(
                                      comment.id, widget.postId);
                                }
                              }
                            },
                            // More button option items
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
                                    Icon(Icons.delete,
                                        size: 16, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Delete',
                                        style: TextStyle(
                                            fontSize: 13, color: Colors.red)),
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
                              onTap: () =>
                                  ImagePreviewUtils.expandSinglePreviewImage(
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
                onPressed: () async {
                  if (await ImagePickerUtils.attachImagesTo(_selectedImages)) {
                    setState(() {});
                  }
                },
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
