import 'package:flutter/material.dart';
import 'package:connect_flutter/services/pocketbase.dart';

class LoginForm extends StatefulWidget {
  final void Function(bool) onLogin;
  const LoginForm({required this.onLogin, super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _error;
  String? _success;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _success = null;
    });
    try {
      await loginUser(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      setState(() {
        _success = "Login successful!";
      });
      widget.onLogin(true); // Notify parent of login
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      widget.onLogin(false); // Notify parent of failed login
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('loginForm'),
      padding: const EdgeInsets.all(24.0),
      children: [
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          decoration: const InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 24),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        if (_success != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              _success!,
              style: const TextStyle(color: Colors.green),
              textAlign: TextAlign.center,
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _login,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Login'),
            ),
          ),
        ),
      ],
    );
  }
}