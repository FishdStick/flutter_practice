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
          ? DateTime.parse(json['created_at']).toLocal()
          : DateTime.now().toLocal(),
    );
  }

  // Post Json Package
  Map <String, dynamic> toJson(){
    return{
      'id': id,
      'user_id': userId,
      'author_email': authorEmail,
      'title': title,
      'content': content,
      'image_urls': imageUrls,
      'created_at': createdAt.toUtc().toIso8601String()
    };
  }
}