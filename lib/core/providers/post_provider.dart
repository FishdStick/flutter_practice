import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart';

class Post {
  final String id;
  final String userId;
  final String authorEmail;
  final String title;
  final String content;
  final List<String> imageUrls;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.userId,
    required this.authorEmail,
    required this.title,
    required this.content,
    required this.imageUrls,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      authorEmail: json['author_email'] ?? 'Anonymous User',
      title: json['title'] ?? 'No Title',
      content: json['content'] ?? 'No Content',
      imageUrls: List<String>.from(json['image_urls'] ?? []),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}

class PostProvider extends ChangeNotifier {
  List<Post> _posts = [];
  bool _isLoading = false;
  int _currentPage = 1;
  int _totalPages = 1;
  final int _pageSize = 6;

  // Apparently these are getters ig they use =>
  List<Post> get posts => _posts;

  bool get isLoading => _isLoading;

  int get currentPage => _currentPage;

  int get totalPages => _totalPages;

  // Fetches posts to be paginated
  Future<void> fetchPage(int page) async {
    _isLoading = true;
    _currentPage = page;
    notifyListeners();

    try {
      final countResponse = await supabase.from('posts').select('*');
      final totalCount = (countResponse as List).length;
      // Upper limit of pages
      _totalPages = (totalCount / _pageSize).ceil();
      if (_totalPages < 1) _totalPages = 1;
      final from = (page - 1) * _pageSize;
      final to = (from + _pageSize) - 1;

      final response = await supabase
          .from('posts')
          .select()
          .order('created_at', ascending: false)
          .range(from, to);
      _posts = (response as List).map((e) => Post.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error fetching posts! $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Upload Images
  Future<List<String>> _uploadImages(List<XFile> images) async {
    List<String> uploadedUrls = [];
    for (var image in images) {
      final bytes = await image.readAsBytes();
      final fileExt = image.name.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
      final path = 'posts/$fileName';

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

  // Create Post
  Future<bool> createPost({
    required String title,
    required String content,
    required List<XFile> selectedImages,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        return false;
      }

      final imageUrls = await _uploadImages(selectedImages);

      await supabase.from('posts').insert({
        'user_id': user.id,
        'author_email': user.email ?? 'Unknown User',
        'title': title,
        'content': content,
        'image_urls': imageUrls,
      });

      await fetchPage(1);
      return true;
    } catch (e) {
      debugPrint('Error Creating Post: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete Post
  Future<bool> deletePost(String postId) async {
    try {
      await supabase.from('posts').delete().eq('id', postId);
      _posts.removeWhere((post) => post.id == postId);
      await fetchPage(_currentPage);
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
