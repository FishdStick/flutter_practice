import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/post_provider.dart';
import '../../core/utils/snackbar_utils.dart';
import 'image_preview_row.dart';

class EditPostScreen extends StatefulWidget {
  final String postId;

  const EditPostScreen({super.key, required this.postId});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _postBodyController;

  List<String> _existingImageUrls = [];
  final List<XFile> _newImages = [];
  double _postBodyTextFieldHeight = 140.0;

  @override
  void initState() {
    super.initState();
    final postProvider = context.read<PostProvider>();
    final post = postProvider.getPostById(widget.postId);

    _titleController = TextEditingController(text: post?.title ?? '');
    _postBodyController = TextEditingController(text: post?.content ?? '');
    _existingImageUrls = List<String>.from(post?.imageUrls ?? []);
  }

  void _submitUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    final postProvider = context.read<PostProvider>();

    final success = await postProvider.updatePost(
        postId: widget.postId,
        title: _titleController.text.trim(),
        content: _postBodyController.text.trim(),
        existingImageUrls: _existingImageUrls,
        newImages: _newImages);

    if (!mounted) {
      return;
    }

    if (success) {
      SnackBarUtils.showSuccess(context, 'Post updated');
      context.pop();
    } else {
      SnackBarUtils.showError(context, 'Failed to update post');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _postBodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = context.watch<PostProvider>();

    final allPreviewPaths = [
      ..._existingImageUrls,
      ..._newImages.map((e) => e.path)
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Post'),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => context.pop()),
      ),
      // Create a centralized Widget for this along with the one in create_post_screen.dart
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Post Title Text Field
                      TextFormField(
                        controller: _titleController,
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

                      // Post Body Text Field
                      SizedBox(
                        height: _postBodyTextFieldHeight,
                        child: Stack(
                          children: [
                            TextFormField(
                              controller: _postBodyController,
                              maxLines: null,
                              expands: true,
                              keyboardType: TextInputType.multiline,
                              textAlignVertical: TextAlignVertical.top,
                              decoration: const InputDecoration(
                                labelText: 'Post body',
                                border: OutlineInputBorder(),
                                alignLabelWithHint: true,
                                contentPadding:
                                    EdgeInsets.fromLTRB(12, 16, 28, 16),
                              ),
                              validator: (value) =>
                                  (value == null || value.trim().isEmpty)
                                      ? 'Please enter post body'
                                      : null,
                            ),
                            Positioned(
                              right: 2,
                              bottom: 2,
                              child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onVerticalDragUpdate: (details) {
                                  setState(() {
                                    _postBodyTextFieldHeight =
                                        (_postBodyTextFieldHeight +
                                                details.delta.dy)
                                            .clamp(120.0, 500.0);
                                  });
                                },
                                child: const MouseRegion(
                                  cursor: SystemMouseCursors.resizeUpDown,
                                  child: Padding(
                                    padding: EdgeInsets.all(6.0),
                                    child: Icon(Icons.drag_indicator,
                                        size: 16, color: Colors.grey),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Images
                      if (allPreviewPaths.isNotEmpty)
                        ImagePreviewRow(
                          imageUrls: allPreviewPaths,
                          onDelete: (index) {
                            setState(() {
                              if (index < _existingImageUrls.length) {
                                _existingImageUrls.removeAt(index);
                              } else {
                                _newImages.removeAt(
                                    index - _existingImageUrls.length);
                              }
                            });
                          },
                        ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed:
                            postProvider.isLoading ? null : _submitUpdate,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: postProvider.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Save Changes',
                                style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
