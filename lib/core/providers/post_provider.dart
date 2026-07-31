import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/post.dart';
import '../services/auth_service.dart';
import '../services/post_service.dart';

class PostProvider extends ChangeNotifier {
  final _authService = AuthService();
  final _postService = PostService();

  List<Post> _posts = [];
  bool _isLoading = false;
  int _currentPage = 1;
  int _totalPages = 1;
  final int _pageSize = 6;

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;

  Future<void> getPage(int page) async {
    _isLoading = true;
    _currentPage = page;
    notifyListeners();

    try {
      final result =
          await _postService.fetchPostsPage(page: page, pageSize: _pageSize);
      _posts = result['posts'] as List<Post>;
      _totalPages = result['totalPages'] as int;
    } catch (e) {
      debugPrint('Error fetching posts! $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create Post
  Future<bool> createPost({
    required String title,
    required String content,
    required List<XFile> selectedImages,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = _authService.currentUser;
      if (user == null) {
        return false;
      }

      final imageUrls = await _postService.uploadImages(selectedImages);

      await _postService.createPost(
          title: title,
          content: content,
          imageUrls: imageUrls,
          userId: user.id,
          authorEmail: user.email
      );

      await getPage(1);
      return true;
    } catch (e) {
      debugPrint('Error Creating Post: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch Post by Id
  Post? getPostById(String postId) {
    try {
      return _posts.firstWhere((post) => post.id == postId);
    } catch (_) {
      return null;
    }
  }

  // Update Post
  Future<bool> updatePost({
    required String postId,
    required String title,
    required String content,
    required List<String> existingImageUrls,
    required List<XFile> newImages,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final newlyUploadedUrls = await _postService.uploadImages(newImages);
      final finalImageUrls = [...existingImageUrls, ...newlyUploadedUrls];

      await _postService.updatePost(
          postId: postId,
          title: title,
          content: content,
          imageUrls: finalImageUrls
      );

      await getPage(_currentPage);
      return true;
    } catch (e) {
      debugPrint('Error updating Post: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete Post
  Future<bool> deletePost(String postId) async {
    try {
      await _postService.deletePost(postId);
      _posts.removeWhere((post) => post.id == postId);
      await getPage(_currentPage);
      return true;
    } catch (e) {
      debugPrint('Error Deleting Post: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
