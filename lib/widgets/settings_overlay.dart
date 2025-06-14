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

  void _openAccountPage() {
    setState(() {
      showAccountPage = true;
      showLoginPage = false;
    });
  }

  void _closeAccountPage() {
    setState(() {
      showAccountPage = false;
      showLoginPage = false;
    });
  }

  void _openLoginPage() {
    setState(() {
      showLoginPage = true;
    });
  }

  void _closeLoginPage() {
    setState(() {
      showLoginPage = false;
    });
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
                  showLoginPage
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
                  if (showLoginPage)
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _closeLoginPage,
                    ),
                  if (!showLoginPage && showAccountPage)
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
                  child: showLoginPage
                      ? const _LoginForm()
                      : showAccountPage
                          ? ListView(
                              key: const ValueKey('accountPage'),
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.app_registration),
                                  title: const Text('Register'),
                                  onTap: () {
                                    // TODO: Implement register logic
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.login),
                                  title: const Text('Login'),
                                  onTap: _openLoginPage,
                                ),
                                ListTile(
                                  leading: const Icon(Icons.logout),
                                  title: const Text('Logout'),
                                  onTap: () {
                                    // TODO: Implement logout logic
                                  },
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

