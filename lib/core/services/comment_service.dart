import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart';
import '../models/comment.dart';


class CommentService {
// Upload Images in comments
  Future<List<String>> uploadImages(List<XFile> images) async {
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

  Future<List<Comment>> fetchComments(String postId) async {
    final response = await supabase
        .from('comments')
        .select()
        .eq('post_id', postId)
        .order('created_at', ascending: true);

    return (response as List).map((json) => Comment.fromJson(json)).toList();
  }

// Create Comment
  Future<void> addComment(
      {required String postId,
      required String userId,
      required String authorEmail,
      required String content,
      required List<String> imageUrls}) async {
    await supabase.from('comments').insert({
      'post_id': postId,
      'user_id': userId,
      'author_email': authorEmail,
      'content': content,
      'image_urls': imageUrls,
    });
  }

// Update Post
  Future<void> updateComment({
    required String commentId,
    required String content,
    required List<String> imageUrls,
  }) async {
    await supabase.from('comments').update({
      'content': content,
      'image_urls': imageUrls,
    }).eq('id', commentId);
  }

// Delete Comment
  Future<void> deleteComment(String commentId) async {
    await supabase.from('comments').delete().eq('id', commentId);
  }
}