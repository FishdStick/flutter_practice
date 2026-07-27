import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/comment.dart';
import '../services/auth_service.dart';
import '../services/comment_service.dart';

class CommentProvider extends ChangeNotifier {
  // Maps Post to post comments
  final CommentService _commentService = CommentService();
  final AuthService _authService = AuthService();

  final Map<String, List<Comment>> _comments = {};
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  List<Comment> getCommentsForPost(String postId) {
    return _comments[postId] ?? [];
  }

  // Fetches comments under a post via post_id
  Future<void> getComments(String postId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final fetched = await _commentService.fetchComments(postId);
      _comments[postId] = fetched;
    } catch (e) {
      debugPrint('Error fetching comments: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create Comment
  Future<bool> addComment({
    required String postId,
    required String content,
    required List<XFile> selectedImages,
  }) async {
    try {
      final user = _authService.currentUser;
      if (user == null) return false;

      final imageUrls = await _commentService.uploadImages(selectedImages);

      await _commentService.addComment(
          postId: postId,
          userId: user.id,
          authorEmail: user.email,
          content: content,
          imageUrls: imageUrls
      );

      await getComments(postId);
      return true;
    } catch (e) {
      debugPrint('Error adding comment: $e');
      return false;
    }
  }

  // Update Comment
  Future<bool> updateComment({
    required String commentId,
    required String postId,
    required String content,
    required List<String> existingImageUrls,
    required List<XFile> newImages,
  }) async {
    try {
      final newlyUploadedUrls = await _commentService.uploadImages(newImages);
      final finalImageUrls = [...existingImageUrls, ...newlyUploadedUrls];

      await _commentService.updateComment(
        commentId: commentId,
        content: content,
        imageUrls: finalImageUrls,
      );

      await getComments(postId);
      return true;
    } catch (e) {
      debugPrint('Error updating comment: $e');
      return false;
    }
  }

  // Delete Comment
  Future<bool> deleteComment(String commentId, String postId) async {
    try {
      await _commentService.deleteComment(commentId);
      // What's c? and why have ? before .removeWhere?
      _comments[postId]?.removeWhere((c) => c.id == commentId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting comment: $e');
      return false;
    }
  }
}
