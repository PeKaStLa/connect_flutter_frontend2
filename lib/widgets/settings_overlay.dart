import 'package:flutter/material.dart';
import 'package:connect_flutter/services/pocketbase.dart';

class SettingsOverlay extends StatefulWidget {
  final bool isLoggedIn;
  final void Function(bool) onLoginStateChanged;
  const SettingsOverlay({
    super.key,
    required this.isLoggedIn,
    required this.onLoginStateChanged,
  });

  @override
  State<SettingsOverlay> createState() => _SettingsOverlayState();
}

class _SettingsOverlayState extends State<SettingsOverlay> {
  bool showAccountPage = false;
  bool showLoginPage = false;
  bool showRegisterPage = false;
  bool showLogoutConfirmPage = false;

  late bool isLoggedIn;

  @override
  void initState() {
    super.initState();
    isLoggedIn = widget.isLoggedIn;
  }

  void _setLoginStatus(bool loggedIn) {
    setState(() {
      isLoggedIn = loggedIn;
    });
    widget.onLoginStateChanged(loggedIn); // <-- This updates main.dart
  }

  void _openAccountPage() {
    setState(() {
      showAccountPage = true;
      showLoginPage = false;
      showRegisterPage = false;
      showLogoutConfirmPage = false;
    });
  }

  void _closeAccountPage() {
    setState(() {
      showAccountPage = false;
      showLoginPage = false;
      showRegisterPage = false;
      showLogoutConfirmPage = false;
    });
  }

  void _openLoginPage() {
    setState(() {
      showLoginPage = true;
      showRegisterPage = false;
      showLogoutConfirmPage = false;
    });
  }

  void _closeLoginPage() {
    setState(() {
      showLoginPage = false;
    });
  }

  void _openRegisterPage() {
    setState(() {
      showRegisterPage = true;
      showLoginPage = false;
      showLogoutConfirmPage = false;
    });
  }

  void _closeRegisterPage() {
    setState(() {
      showRegisterPage = false;
    });
  }

  void _openLogoutConfirmPage() {
    setState(() {
      showLogoutConfirmPage = true;
      showLoginPage = false;
      showRegisterPage = false;
    });
  }

  void _closeLogoutConfirmPage() {
    setState(() {
      showLogoutConfirmPage = false;
    });
  }

  // Example for login:
  void _onLoginSuccess() {
    _setLoginStatus(true);
    setState(() {
      showLoginPage = false;
      showAccountPage = false;
    });
  }

  // Example for logout:
  void _onLogout() {
    logoutUser();
    _setLoginStatus(false);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final String statusText = isLoggedIn ? 'Logged in' : 'Guest';
    final IconData statusIcon = isLoggedIn ? Icons.verified_user : Icons.person_outline;
    final Color statusColor = isLoggedIn ? Colors.green : Colors.grey;

    return Align(
      alignment: const Alignment(0, -0.01),
      child: FractionallySizedBox(
        widthFactor: 0.85,
        heightFactor: 0.85,
        child: Material(
          elevation: 16,
          borderRadius: BorderRadius.circular(24),
          color: Theme.of(context).dialogBackgroundColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: Text(
                  showLogoutConfirmPage
                      ? 'Logout'
                      : showRegisterPage
                          ? 'Register'
                          : showLoginPage
                              ? 'Login'
                              : showAccountPage
                                  ? 'Account'
                                  : 'Settings',
                ),
                automaticallyImplyLeading: false,
                elevation: 0,
                backgroundColor: Colors.transparent,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                actions: [
                  if (showLogoutConfirmPage)
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _closeLogoutConfirmPage,
                    ),
                  if (!showLogoutConfirmPage && showRegisterPage)
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _closeRegisterPage,
                    ),
                  if (!showLogoutConfirmPage && !showRegisterPage && showLoginPage)
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _closeLoginPage,
                    ),
                  if (!showLogoutConfirmPage && !showRegisterPage && !showLoginPage && showAccountPage)
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _closeAccountPage,
                    ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 1),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: showLogoutConfirmPage
                      ? _LogoutConfirmPage(onConfirm: _onLogout)
                      : showRegisterPage
                          ? const _RegisterForm()
                          : showLoginPage
                              ? _LoginForm(onLogin: _onLoginSuccess)
                              : showAccountPage
                                  ? ListView(
                                      key: const ValueKey('accountPage'),
                                      children: [
                                        ListTile(
                                          leading: const Icon(Icons.app_registration),
                                          title: const Text('Register'),
                                          onTap: _openRegisterPage,
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.login),
                                          title: const Text('Login'),
                                          enabled: !isLoggedIn, // <-- This greys out the tile if already logged in
                                          onTap: !isLoggedIn ? _openLoginPage : null,
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.logout),
                                          title: const Text('Logout'),
                                          enabled: isLoggedIn, // <-- This greys out the tile if not logged in
                                          onTap: isLoggedIn ? _openLogoutConfirmPage : null,
                                        ),
                                      ],
                                    )
                                  : ListView(
                                      key: const ValueKey('settingsList'),
                                      children: [
                                        ListTile(
                                          leading: Icon(statusIcon, color: statusColor),
                                          title: Text(
                                            'Login Status: $statusText',
                                            style: TextStyle(
                                              color: statusColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.person),
                                          title: const Text('Account'),
                                          subtitle: const Text('Manage your account'),
                                          onTap: _openAccountPage,
                                        ),
                                        const ListTile(
                                          leading: Icon(Icons.palette),
                                          title: Text('Theme'),
                                          subtitle: Text('Choose app theme'),
                                        ),
                                        const ListTile(
                                          leading: Icon(Icons.info),
                                          title: Text('About'),
                                          subtitle: Text('App information'),
                                        ),
                                      ],
                                    ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  final VoidCallback onLogin;
  const _LoginForm({required this.onLogin});

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _error;
  String? _success;

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
      widget.onLogin(); // Update login status in parent
    } catch (e) {
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
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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

class _RegisterForm extends StatefulWidget {
  const _RegisterForm();

  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
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
      setState(() {
        _success = "Registration successful! You can now log in.";
      });
    } catch (e) {
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

class _LogoutConfirmPage extends StatelessWidget {
  final VoidCallback onConfirm;
  const _LogoutConfirmPage({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        key: const ValueKey('logoutConfirmPage'),
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Are you sure you want to logout?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Yes, I want to logout'),
            ),
          ],
        ),
      ),
    );
  }
}



