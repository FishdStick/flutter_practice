import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/post_provider.dart';
import 'image_preview_row.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedImages = [];

  Future<void> _pickImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(pickedFiles);
      });
    }
  }

  void _submitPost() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final postProvider = context.read<PostProvider>();
    final text = _contentController.text.trim();

    final success = await postProvider.createPost(
      title: _titleController.text.trim(),
      content: text,
      selectedImages: _selectedImages,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post published successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to publish post!'),
          backgroundColor: Colors.redAccent,
        ),
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

    return Scaffold(
      appBar: AppBar(title: const Text('Create new post')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Post Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  (value == null || value
                      .trim()
                      .isEmpty)
                      ? 'Please enter a title' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: 'Write post content',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  (value == null || value
                      .trim()
                      .isEmpty)
                      ? 'Please enter post content' : null,
                ),
                const SizedBox(height: 16),

                OutlinedButton.icon(
                  onPressed: _pickImages,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: Text('Attach images (${_selectedImages.length})'),
                ),
                const SizedBox(height: 12),

                if (_selectedImages.isNotEmpty)
                  ImagePreviewRow(
                    imageUrls: _selectedImages.map((e) => e.path).toList(),
                    onDelete: (index) {
                      setState(() {
                        _selectedImages.removeAt(index);
                      });
                    },
                  ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: postProvider.isLoading ? null : _submitPost,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: postProvider.isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text(
                      'Publish Post',
                      style: TextStyle(fontSize: 16)
                  ),
                ),
              ],
            )
          )
        ),
      ),
    );
  }
}