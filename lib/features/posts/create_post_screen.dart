import 'package:flutter/material.dart';
import 'package:flutter_practice/core/utils/snackbar_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/post_provider.dart';
import '../../core/utils/image_picker_utils.dart';
import 'image_preview_row.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _postBodyController = TextEditingController();
  final List<XFile> _selectedImages = [];
  double _postBodyTextFieldHeight = 160.0;

  void _uploadPost() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final postProvider = context.read<PostProvider>();
    final text = _postBodyController.text.trim();

    final success = await postProvider.createPost(
      title: _titleController.text.trim(),
      content: text,
      selectedImages: _selectedImages,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      SnackBarUtils.showSuccess(context, 'Post published.');
      context.go('/');
    } else {
      SnackBarUtils.showError(context, 'Failed to publish post.');
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create new post'),
        leading: IconButton(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.arrow_back_ios),
            tooltip: 'Back to Main Feed'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 3,
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
                            prefixIcon: Icon(Icons.title)),
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
                                          size: 16, color: Colors.grey)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Attachment Button
                      OutlinedButton.icon(
                        onPressed: () async {
                          if (await ImagePickerUtils.attachImagesTo(
                              _selectedImages)) {
                            setState(() {});
                          }
                        },
                        icon: const Icon(Icons.add_photo_alternate),
                        label:
                            Text('Attach images (${_selectedImages.length})'),
                        style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14)),
                      ),
                      const SizedBox(height: 12),

                      if (_selectedImages.isNotEmpty)
                        ImagePreviewRow(
                          imageUrls:
                              _selectedImages.map((e) => e.path).toList(),
                          onDelete: (index) {
                            setState(() {
                              _selectedImages.removeAt(index);
                            });
                          },
                        ),
                      const SizedBox(height: 24),

                      ElevatedButton(
                        onPressed: postProvider.isLoading ? null : _uploadPost,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: postProvider.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Publish Post',
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
