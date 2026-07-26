import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

// Pages for later
import '../../features/auth/login_screen.dart';
import '../../features/posts/feed_screen.dart';
import '../../features/posts/create_post_screen.dart';
import '../../features/posts/post_detail_screen.dart';

GoRouter createRouter(BuildContext context){
  return GoRouter(
    initialLocation: '/',
    refreshListenable: context.read<AuthProvider>(),
    // List of Routes
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const FeedScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/create-post',
        builder: (context, state) => const CreatePostScreen(),
      ),
      GoRoute(
        path: '/post/:id',
        builder: (context, state) {
          final postId = state.pathParameters['id']!;
          return PostDetailScreen(postId: postId);
        }
      )
    ],

    // Route Guarding
    // Prevents logged out users from accessing pages/routes that required a
    // user to be logged in i.e. create post

    redirect: (context, state) {
      final authProvider = context.read<AuthProvider>();
      final isLoggedIn = authProvider.isLoggedIn;
      final isGoingToCreatePost = state.matchedLocation == '/create-post';

      if (isGoingToCreatePost && !isLoggedIn){
        return '/login';
      }

      if (isLoggedIn && state.matchedLocation == '/login'){
        return '/';
      }

      return null;
    },
  );
}