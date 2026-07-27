import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart';

class Comment {
  final String id;
  final String postId;
  final String userId;
  final String authorEmail;
  final String content;
  final List<String> imageUrls;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.authorEmail,
    required this.content,
    required this.imageUrls,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      authorEmail: json['author_email'] ?? 'Anonymous User',
      content: json['content'] ?? 'No Content',
      imageUrls: List<String>.from(json['image_urls'] ?? []),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}

class CommentProvider extends ChangeNotifier {
  // Maps Post to post comments
  final Map<String, List<Comment>> _comments = {};
  bool _isLoading = false;

  List<Comment> getCommentsForPost(String postId) {
    return _comments[postId] ?? [];
  }
  // Fetches comments under a post via post_id
  Future<void> getComments(String postId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await supabase
          .from('comments')
          .select()
          .eq('post_id', postId)
          .order('created_at', ascending: true);
      final fetched = (response as List).map((json) => Comment.fromJson(json)).toList();
      _comments[postId] = fetched;

    } catch (e) {
      debugPrint('Error fetching comments: $e');

    } finally {
      _isLoading = false;
      notifyListeners();

    }
  }

  // Upload Images in comments
  Future<List<String>> _uploadImages(List<XFile> images) async {
    List<String> uploadedUrls = [];
    for (var image in images) {
      final bytes = await image.readAsBytes();
      final fileExt = image.name.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
      final path = 'comments/$fileName';

      await supabase.storage.from('blog_images').uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(contentType: 'image/$fileExt'),
          );

      final publicUrl = supabase.storage.from('blog_images').getPublicUrl(path);
      uploadedUrls.add(publicUrl);
    }
    return uploadedUrls;
  }

  // Create Comment
  Future<bool> addComment({
    required String postId,
    required String content,
    required List<XFile> selectedImages,
  }) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return false;

      final imageUrls = await _uploadImages(selectedImages);

      // Parameterized insert()?
      await supabase.from('comments').insert({
        'post_id': postId,
        'user_id': user.id,
        'author_email': user.email ?? 'Anonymous',
        'content': content,
        'image_urls': imageUrls,
      });

      await getComments(postId);
      return true;
    } catch (e) {
      debugPrint('Error adding comment: $e');
      return false;
    }
  }

  // Update Post
  Future<bool> updateComment({
    required String commentId,
    required String postId,
    required String content,
    required List<String> existingImageUrls,
    required List<XFile> newImages,
  }) async {
    try {
      final newlyUploadedUrls = await _uploadImages(newImages);
      final finalImageUrls = [...existingImageUrls, ...newlyUploadedUrls];

      await supabase.from('comments').update({
        'content': content,
        'image_urls': finalImageUrls,
      }).eq('id', commentId);

      await getComments(postId);
      return true;
    } catch (e){
      debugPrint('Error updating comment: $e');
      return false;
    }
  }

  // Delete Comment
  Future<bool> deleteComment(String commentId, String postId) async {
    try {
      await supabase
        .from('comments')
        .delete()
        .eq('id', commentId);
      _comments[postId]?.removeWhere((c) => c.id == commentId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting comment: $e');
      return false;
    }
  }
}
