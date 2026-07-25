import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/auth_provider.dart';

class FeedScreen extends StatelessWidget{
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context){
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Feed'),
        actions: [
          if (authProvider.isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () {
                context.read<AuthProvider>().logout();
              },
            )
          else
            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text('Login', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (authProvider.isLoggedIn)
              Text(
                'Logged in as ${authProvider.userEmail}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              )
            else
              const Text(
                'Viewing as Guest (public mode)',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/create-post'),
              child: const Text('Go to Create Post'),
            )
          ],
        ),
      ),
    );
  }
}

