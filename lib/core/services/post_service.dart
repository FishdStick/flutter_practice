import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart';
import '../models/post.dart';

class PostService {
  // Upload Images
  Future<List<String>> uploadImages(List<XFile> images) async {
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

  Future<Map<String, dynamic>> fetchPostsPage({
    required int page,
    required int pageSize,
  }) async {
    final from = (page - 1) * pageSize;
    final to = (from + pageSize) - 1;

    final response = await supabase
        .from('posts')
        .select('*')
        .order('created_at', ascending: false)
        .range(from, to)
        .count(CountOption.exact);

    final List<Post> posts =
        //Is this casting?
        (response.data as List).map((json) => Post.fromJson(json)).toList();

    final int totalCount = response.count;
    final int totalPages = (totalCount / pageSize).ceil();

    return {
      'posts': posts,
      'totalPages': totalPages == 0 ? 1 : totalPages,
    };
  }

  // Create Post
  Future<void> createPost({
    required String title,
    required String content,
    required List<String> imageUrls,
    required String userId,
    required String authorEmail,
  }) async {
    await supabase.from('posts').insert({
      'user_id': userId,
      'author_email': authorEmail,
      'title': title,
      'content': content,
      'image_urls': imageUrls,
    });
  }

  // Update Post
  Future<void> updatePost({
    required String postId,
    required String title,
    required String content,
    required List<String> imageUrls,
  }) async {
    await supabase.from('posts').update({
      'title': title,
      'content': content,
      'image_urls': imageUrls,
    }).eq('id', postId);
  }

  Future<void> deletePost(String postId) async {
    await supabase.from('posts').delete().eq('id', postId);
  }
}
