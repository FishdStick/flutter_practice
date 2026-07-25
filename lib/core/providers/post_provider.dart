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

  factory Post.fromJson(Map<String, dynamic> json){
    return Post(
      id: json['id'],
      userId: json['userId'],
      authorEmail: json['authorEmail'],
      title: json['title'],
      content: json['content'],
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class PostProvider extends ChangeNotifier {
  List<Post> _posts = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  final int _pageSize = 5;

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  // Fetches posts to be paginated
  Future<void> fetchPosts({bool refresh = false}) async {
    if (_isLoading) {
      return;
    }

    if(refresh) {
      _currentPage = 0;
      _hasMore = true;
      _posts = [];
    }

    if (!_hasMore) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final from = _currentPage * _pageSize;
      final to = (from + _pageSize) - 1;

      final response = await supabase
        .from('posts')
        .select()
        .order('created_at', ascending: false)
        .range(from, to);

      final fetchedPosts = (response as List).map((e) => Post.fromJson(e)).toList();

      // Pagination logic?
      if (fetchedPosts.length < _pageSize){
        _hasMore = false;
      }

      _posts.addAll(fetchedPosts);
      _currentPage++;
    } catch (e) {
      debugPrint('Error Fetching posts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Upload Images
  Future <List<String>> _uploadImages(List<XFile> images) async {
    List <String> uploadedUrls = [];
      for (var image in images) {
        final bytes = await image.readAsBytes();
        final fileExt = image.name.split('.').last;
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
        final path = 'posts/$fileName';

        await supabase.storage.from('blog_images').uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(contentType: 'image/$fileExt'),
        );

        final publicUrl =
            supabase.storage.from('blog_images').getPublicUrl(path);
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
        'author_email': user.email,
        'title': title,
        'content': content,
        'image_urls': imageUrls,
      });

      await fetchPosts(refresh: true);
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
      return true;
    } catch (e){
      debugPrint('Error Deleting Post: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}