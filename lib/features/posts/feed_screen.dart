import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/post_provider.dart';
import '../comments/comment_section.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Fetches post when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostProvider>().fetchPosts(refresh: true);
    });

    _scrollController.addListener(_onScroll);
  }

  // Fetch more posts when user has scrolled near the bottom
  // I could paginate via actual pages instead of infinite scrolling.
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<PostProvider>().fetchPosts();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final postProvider = context.watch<PostProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog Feed'),
        actions: [
          if (authProvider.isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () => context.read<AuthProvider>().logout(),
            )
          else
            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text('Login',
                  style: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      floatingActionButton: authProvider.isLoggedIn
          ? FloatingActionButton.extended(
              label: const Text('New Post'),
              onPressed: () => context.go('/create-post'),
              icon: const Icon(Icons.add),
            )
          : null,
      body: Center(
          child: ConstrainedBox(
        // Limits the size of the feed
        constraints: const BoxConstraints(maxWidth: 800),
        child: RefreshIndicator(
          onRefresh: () async {
            await context.read<PostProvider>().fetchPosts(refresh: true);
          },
          // TODO: Facebook style feed
          child: postProvider.posts.isEmpty && postProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : postProvider.posts.isEmpty
                  ? const Center(
                      child: Text(
                        'No posts yet.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: postProvider.posts.length +
                          (postProvider.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == postProvider.posts.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final post = postProvider.posts[index];
                        final isOwner = authProvider.isLoggedIn &&
                            authProvider.currentUser?.id == post.userId;

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header for Author
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.account_circle,
                                            size: 28, color: Colors.grey),
                                        const SizedBox(width: 8),
                                        Text(
                                          post.authorEmail,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    if (isOwner)
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.redAccent,
                                        ),
                                        onPressed: () async {
                                          final confirm =
                                              await showDialog<bool>(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: const Text('Delete Post'),
                                              content: const Text(
                                                  'Are you sure you want to delete this post?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(ctx, false),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(ctx, true),
                                                  child: const Text('Delete',
                                                      style: TextStyle(
                                                          color: Colors.red)),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            await postProvider
                                                .deletePost(post.id);
                                          }
                                        },
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Post Title
                                Text(
                                  post.title,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),

                                const SizedBox(height: 6),

                                // Post Content
                                Text(
                                  post.content,
                                  style: const TextStyle(fontSize: 14),
                                ),

                                const SizedBox(height: 12),

                                // Post Image
                                if (post.imageUrls.isNotEmpty)
                                  SizedBox(
                                    height: 120,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: post.imageUrls.length,
                                      itemBuilder: (context, imgIndex) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8.0),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Image.network(
                                              post.imageUrls[imgIndex],
                                              width: 120,
                                              height: 120,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  const Icon(Icons.broken_image,
                                                      size: 50),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                const SizedBox(height: 12),
                                CommentSection(postId: post.id),
                              ],
                            ),
                          ),
                        );
                      }),
        ),
      )),
    );
  }
}
