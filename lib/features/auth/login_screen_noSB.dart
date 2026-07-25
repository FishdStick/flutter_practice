import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>{
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _handleLogin(){
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isNotEmpty && password.isNotEmpty){
      context.read<AuthProvider>().login(email, password);
    }
  }

  @override
  void dispose(){
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty){
                      return 'Please enter an email';
                    }
                    // Email Regex
                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value)){
                      return 'Please Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                // Password Text Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                  ),
                ),
              const SizedBox(height: 16),
              // Login Button
              ElevatedButton(
                onPressed: () {
                  if(_formKey.currentState!.validate()){
                    _handleLogin();
                  }
                },
                child: const Text('Login'),
              ),
              const SizedBox(height: 20),
              // Create New Account Button
              ElevatedButton(
                onPressed: /*_handleCreateNewAcccount*/ () {
                  // Add 'Create New Account' functionality here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  'Create New Account',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              ],
            ),
          ),
        ),
      )
    );
  }
}