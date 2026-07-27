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

  // Comment Json Package
  Map <String, dynamic> toJson(){
    return{
      'id': id,
      'post_id': postId,
      'userId': userId,
      'author_email': authorEmail,
      'content': content,
      'image_urls': imageUrls,
      'created_at': createdAt.toIso8601String(),
    };
  }
}