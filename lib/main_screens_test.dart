import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_practice/core/providers/auth_provider.dart';
import 'package:flutter_practice/core/router/app_router.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context){
    final router = createRouter(context);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Forum App',
      routerConfig: router,
    );
  }
}

