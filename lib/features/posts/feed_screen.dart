import 'package:flutter/material.dart';
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
      context.read<PostProvider>().fetchPage(1);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$month-$day-$year';
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
                          .fetchPage(postProvider.currentPage);
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
                                      final formattedDate =
                                          _formatDate(post.createdAt);

                                      return InkWell(
                                        onTap: () {
                                          context.go('/post/${post.id}');
                                        },
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: 160,
                                                width: double.infinity,
                                                child: post.imageUrls.isNotEmpty
                                                    ? Image.network(
                                                        post.imageUrls.first,
                                                        fit: BoxFit.cover,
                                                        errorBuilder:
                                                            (ctx, _, __) =>
                                                                Container(
                                                          color:
                                                              Colors.grey[200],
                                                          child: const Icon(
                                                              Icons
                                                                  .broken_image,
                                                              size: 40),
                                                        ),
                                                      )
                                                    : Container(
                                                        color: Colors.grey[200],
                                                        child: Icon(
                                                          Icons
                                                              .article_outlined,
                                                          size: 48,
                                                          color:
                                                              Colors.grey[400],
                                                        ),
                                                      ),
                                              ),
                                              // Card Contents
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      12.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      // Post Author
                                                      Text(
                                                        post.authorEmail
                                                            .toUpperCase(),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors
                                                                .grey[600],
                                                            letterSpacing: 0.8),
                                                      ),
                                                      const SizedBox(height: 6),
                                                      // Post Title
                                                      Text(
                                                        post.title,
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      // Post Content
                                                      Text(
                                                        post.content,
                                                        maxLines: 3,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            fontSize: 13,
                                                            color: Colors
                                                                .grey[700]),
                                                      ),
                                                      const Spacer(),
                                                      Text(
                                                        formattedDate,
                                                        style: TextStyle(
                                                            fontSize: 11,
                                                            color: Colors
                                                                .grey[500]),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
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
                                .fetchPage(postProvider.currentPage - 1)
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
                              onTap: () => postProvider.fetchPage(pageNum),
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
                                    .fetchPage(postProvider.currentPage + 1)
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
