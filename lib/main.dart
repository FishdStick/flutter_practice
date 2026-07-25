import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_practice/core/providers/post_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_practice/core/providers/auth_provider.dart';
import 'package:flutter_practice/core/router/app_router.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env.local");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    publishableKey: dotenv.env['SUPABASE_PUBLISHABLE_KEY']!,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context){
    final router = createRouter(context);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Blog Posting App',
      routerConfig: router,
    );
  }
}

