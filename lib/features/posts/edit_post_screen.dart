import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/post_provider.dart';
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
  late TextEditingController _contentController;

  // final ImagePicker _picker = ImagePicker();
  List<String> _existingImageUrls = [];
  final List<XFile> _newImages = [];

  @override
  void initState() {
    super.initState();
    final postProvider = context.read<PostProvider>();
    final post = postProvider.getPostById(widget.postId);

    _titleController = TextEditingController(text: post?.title ?? '');
    _contentController = TextEditingController(text: post?.content ?? '');
    _existingImageUrls = List<String>.from(post?.imageUrls ?? []);
  }

  // Future<void> _pickImages() async {
  //   final List<XFile> pickedFiles = await _picker.pickMultiImage();
  //   if (pickedFiles.isNotEmpty) {
  //     setState(() {
  //       _newImages.addAll(pickedFiles);
  //     });
  //   }
  // }

  void _submitUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    final postProvider = context.read<PostProvider>();

    final success = await postProvider.updatePost(
        postId: widget.postId,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        existingImageUrls: _existingImageUrls,
        newImages: _newImages);

    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Post updated'), backgroundColor: Colors.green),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to update post'),
            backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
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
      appBar: AppBar(title: const Text('Edit Post')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title Text Field
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Post Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Please enter a title'
                      : null,
                ),
                const SizedBox(height: 16),
                // Content Text Field
                TextFormField(
                  controller: _contentController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Write post content',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Please enter post content'
                      : null,
                ),
                const SizedBox(height: 12),

                // Images
                if (allPreviewPaths.isNotEmpty)
                  ImagePreviewRow(
                    imageUrls: allPreviewPaths,
                    onDelete: (index) {
                      setState(() {
                        if (index < _existingImageUrls.length) {
                          _existingImageUrls.removeAt(index);
                        } else {
                          _newImages
                              .removeAt(index - _existingImageUrls.length);
                        }
                      });
                    },
                  ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: postProvider.isLoading ? null : _submitUpdate,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: postProvider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save Changes',
                          style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
