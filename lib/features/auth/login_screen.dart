import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isSignUp = false;

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final authProvider = context.read<AuthProvider>();

    final bool success;
    if (_isSignUp) {
      success = await authProvider.signUp(email, password);
    } else {
      success = await authProvider.login(email, password);
    }

    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(_isSignUp
                ? 'Account created successfully! Logging in...'
                : 'Log in successful!'),
            backgroundColor: Colors.green),
      );
    } else if (authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(authProvider.errorMessage!),
        backgroundColor: Colors.redAccent,
      ));
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
          title: Text(_isSignUp ? 'Create Account' : 'Login')
      ),
      body: Center(
        child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      //Post Title Header
                      Text(
                        _isSignUp
                            ? 'Join our Community!'
                            : 'Awesome! Welcome Back!',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),

                      // Email Text Field
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        validator: (emailInput) {
                          if (emailInput == null || emailInput.isEmpty) {
                            return 'Please enter your email ';
                          }
                          final emailRegex =
                          RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!emailRegex.hasMatch(emailInput.trim())) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password Text Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        validator: (passwordInput) {
                          if (passwordInput == null || passwordInput.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (_isSignUp && passwordInput.length < 6) {
                            return 'Password must be at least 6 characters long';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Login/Register Button
                      ElevatedButton(
                        onPressed:
                            authProvider.isLoading ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16)),
                        child: authProvider.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _isSignUp ? 'Register' : 'Login',
                                style: const TextStyle(fontSize: 16),
                              ),
                      ),
                      const SizedBox(height: 16),

                      TextButton(
                          onPressed: authProvider.isLoading
                              ? null
                              : () {
                                  setState(() {
                                    _isSignUp = !_isSignUp;
                                    _formKey.currentState?.reset();
                                  });
                                },
                          child: Text(
                            _isSignUp
                                ? 'Already have an account? Log In'
                                : "Don't have an account? Sign up here",
                            style: const TextStyle(fontSize: 14),
                          )),
                    ],
                  ),
                ),
              ),
            )),
      ),
    );
  }
}
