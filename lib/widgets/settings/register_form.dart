import 'package:flutter/material.dart';
import 'package:connect_flutter/services/pocketbase.dart';
import 'package:connect_flutter/utils/map_utils.dart';

class RegisterForm extends StatefulWidget {
  final VoidCallback? onRegisterSuccess;
  const RegisterForm({super.key, this.onRegisterSuccess});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  bool _isLoading = false;
  String? _error;
  String? _success;

  bool get _isPasswordValid => _passwordController.text.length >= 8;
  bool get _isEmailValid {
    final email = _emailController.text.trim();
    final emailRegex = RegExp(r"^[\w\.-]+@[\w\.-]+\.\w+$");
    return emailRegex.hasMatch(email);
  }

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onPasswordChanged);
    _emailController.addListener(_onEmailChanged);
  }

  void _onPasswordChanged() {
    setState(() {});
  }

  void _onEmailChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _emailController.removeListener(_onEmailChanged);
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.removeListener(_onPasswordChanged);
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _success = null;
    });
    try {
      await createUser(
        email: _emailController.text.trim(),
        userName: _usernameController.text.trim(),
        password: _passwordController.text,
        passwordConfirm: _passwordConfirmController.text,
      );
      if (!mounted) return;
      setState(() {
        _success = "Registration successful! You can now log in.";
      });
      snackbar(context, "Registration successful! You can now log in.");
      if (widget.onRegisterSuccess != null) {
        widget.onRegisterSuccess!();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
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
    final showPasswordError = _passwordController.text.isNotEmpty && !_isPasswordValid;
    final showEmailError = _emailController.text.isNotEmpty && !_isEmailValid;

    return ListView(
      key: const ValueKey('registerForm'),
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
        if (showEmailError)
          const Padding(
            padding: EdgeInsets.only(top: 8.0, left: 4.0),
            child: Text(
              'Please enter a valid email address.',
              style: TextStyle(color: Colors.red, fontSize: 13),
            ),
          ),
        const SizedBox(height: 16),
        TextField(
          controller: _usernameController,
          decoration: const InputDecoration(
            labelText: 'Username',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          decoration: const InputDecoration(
            labelText: 'Password (min. 8 chars)',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        if (showPasswordError)
          const Padding(
            padding: EdgeInsets.only(top: 8.0, left: 4.0),
            child: Text(
              'Password must be at least 8 characters long.',
              style: TextStyle(color: Colors.red, fontSize: 13),
            ),
          ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordConfirmController,
          decoration: const InputDecoration(
            labelText: 'Confirm Password',
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
              onPressed: (_isLoading || !_isPasswordValid || !_isEmailValid)
                  ? null
                  : _register,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Register'),
            ),
          ),
        ),
      ],
    );
  }
}