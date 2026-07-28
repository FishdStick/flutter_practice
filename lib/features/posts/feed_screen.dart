import 'package:flutter/material.dart';
import 'package:flutter_practice/features/widgets/post_card.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/post_provider.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  void initState() {
    super.initState();

    // Fetches post when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostProvider>().getPage(1);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final postProvider = context.watch<PostProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Feed'),
        actions: [
          if (authProvider.isLoggedIn) ...[
            TextButton.icon(
              onPressed: () => context.go('/create-post'),
              icon: const Icon(Icons.add, color: Colors.blue),
              label:
                  const Text('New Post', style: TextStyle(color: Colors.blue)),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () => context.read<AuthProvider>().logout(),
            ),
          ] else
            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text('Login',
                  style: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          // Limits the size of the feed
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await context
                          .read<PostProvider>()
                          .getPage(postProvider.currentPage);
                    },
                    child: postProvider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : postProvider.posts.isEmpty
                            ? const Center(
                                child: Text(
                                  'No posts yet.',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                ),
                              )
                            // Dynamic layout builder depending on feed width
                            : LayoutBuilder(
                                builder: (context, constraints) {
                                  int crossAxisCount = 3;
                                  if (constraints.maxWidth < 600) {
                                    crossAxisCount = 1;
                                  } else if (constraints.maxWidth < 900) {
                                    crossAxisCount = 2;
                                  }
                                  return GridView.builder(
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: crossAxisCount,
                                        crossAxisSpacing: 16,
                                        mainAxisSpacing: 16,
                                        childAspectRatio: 0.82,
                                      ),
                                      itemCount: postProvider.posts.length,
                                      itemBuilder: (context, index) {
                                        final post = postProvider.posts[index];
                                        return PostCard(
                                          post: post,
                                          onTap: () =>
                                              context.go('/post/${post.id}'),
                                        );

                                      });
                                },
                              ),
                  ),
                ),

                // Pagination Navigator
                if (postProvider.totalPages > 1) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: postProvider.currentPage > 1
                            ? () => postProvider
                                .getPage(postProvider.currentPage - 1)
                            : null,
                      ),
                      ...List.generate(
                        postProvider.totalPages,
                        (pageIdx) {
                          final pageNum = pageIdx + 1;
                          final isSelected =
                              pageNum == postProvider.currentPage;

                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: InkWell(
                              onTap: () => postProvider.getPage(pageNum),
                              borderRadius: BorderRadius.circular(4),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.blue
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '$pageNum',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed:
                            postProvider.currentPage < postProvider.totalPages
                                ? () => postProvider
                                    .getPage(postProvider.currentPage + 1)
                                : null,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
