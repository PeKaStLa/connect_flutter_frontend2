import 'package:flutter/material.dart';

class SettingsOverlay extends StatefulWidget {
  final bool isLoggedIn;
  const SettingsOverlay({super.key, this.isLoggedIn = false});

  @override
  State<SettingsOverlay> createState() => _SettingsOverlayState();
}

class _SettingsOverlayState extends State<SettingsOverlay> {
  bool showAccountPage = false;
  bool showLoginPage = false;
  bool showRegisterPage = false;
  bool showLogoutConfirmPage = false;

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

  void _logout() {
    // TODO: Implement actual logout logic
    Navigator.of(context).pop(); // Close the overlay after logout
  }

  @override
  Widget build(BuildContext context) {
    final String statusText = widget.isLoggedIn ? 'Logged in' : 'Guest';
    final IconData statusIcon = widget.isLoggedIn ? Icons.verified_user : Icons.person_outline;
    final Color statusColor = widget.isLoggedIn ? Colors.green : Colors.grey;

    return Center(
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
                      ? _LogoutConfirmPage(onConfirm: _logout)
                      : showRegisterPage
                          ? const _RegisterForm()
                          : showLoginPage
                              ? const _LoginForm()
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
                                          onTap: _openLoginPage,
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.logout),
                                          title: const Text('Logout'),
                                          onTap: _openLogoutConfirmPage,
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

class _LoginForm extends StatelessWidget {
  const _LoginForm();

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('loginForm'),
      padding: const EdgeInsets.all(24.0),
      children: [
          const TextField(
          decoration: InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // TODO: Add login logic
              },
              child: const Text('Login'),
            ),
      ],
    );
  }
}

class _RegisterForm extends StatelessWidget {
  const _RegisterForm();

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('registerForm'),
      padding: const EdgeInsets.all(24.0),
      children: [
        const TextField(
          decoration: InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Username',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 16),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Confirm Password',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () {
                // TODO: Add register logic
              },
              child: const Text('Register'),
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
      alignment: const Alignment(0, -0.99), // Move to about 1/3 from top
      key: const ValueKey('logoutConfirmPage'),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Are you sure you want to logout?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
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

