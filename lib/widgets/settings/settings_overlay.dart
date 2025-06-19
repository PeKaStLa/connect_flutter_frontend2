import 'package:flutter/material.dart';
import 'package:connect_flutter/widgets/settings/account_page.dart';
import 'package:connect_flutter/widgets/settings/login_form.dart';
import 'package:connect_flutter/widgets/settings/register_form.dart';
import 'package:connect_flutter/widgets/settings/logout_confirm_page.dart';

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

  String? _confirmationMessage; // Add this field

  @override
  void initState() {
    super.initState();
    isLoggedIn = widget.isLoggedIn;
  }

  void _setLoginStatus(bool loggedIn) {
    setState(() {
      isLoggedIn = loggedIn;
    });
    widget.onLoginStateChanged(loggedIn);
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
      showAccountPage = false;
    });
  }

  void _closeLoginPage() {
    setState(() {
      showLoginPage = false;
      showAccountPage = true; // Go back to account page
    });
  }

  void _openRegisterPage() {
    setState(() {
      showRegisterPage = true;
      showLoginPage = false;
      showLogoutConfirmPage = false;
      showAccountPage = false;
    });
  }

  void _closeRegisterPage() {
    setState(() {
      showRegisterPage = false;
      showAccountPage = true; // Go back to account page
    });
  }

  void _openLogoutConfirmPage() {
    setState(() {
      showLogoutConfirmPage = true;
      showLoginPage = false;
      showRegisterPage = false;
      showAccountPage = false;
    });
  }

  void _closeLogoutConfirmPage() {
    setState(() {
      showLogoutConfirmPage = false;
      showAccountPage = true; // Go back to account page
    });
  }

  void _showConfirmation(String message) {
    setState(() {
      _confirmationMessage = message;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _confirmationMessage = null;
        });
      }
    });
  }

  void _onLogin(bool loggedIn) {
    if (loggedIn) {
      _setLoginStatus(true);
      _showConfirmation("Login successful!");
      _closeLoginPage(); // Only on success
    }
    // Do nothing on failure
  }

  void _onRegisterSuccess() {
    _closeRegisterPage();
    _showConfirmation("Registration successful!");
    // Only on success
  }

  void _onLogout() {
    _setLoginStatus(false);
    _closeLogoutConfirmPage();
    _showConfirmation("Logout successful!");
    // Only on success
  }

  @override
  Widget build(BuildContext context) {
    
    return Align(
      alignment: const Alignment(0, -0.9),
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
                      ? LogoutConfirmPage(
                          onConfirm: _onLogout,
                        )
                      : showRegisterPage
                          ? RegisterForm(
                              onRegisterSuccess: _onRegisterSuccess,
                            )
                          : showLoginPage
                              ? LoginForm(
                                  onLogin: _onLogin,
                                )
                              : showAccountPage
                                  ? AccountPage(
                                      isLoggedIn: isLoggedIn,
                                      onRegister: _openRegisterPage,
                                      onLogin: _openLoginPage,
                                      onLogout: _openLogoutConfirmPage,
                                      confirmationMessage: _confirmationMessage,
                                    )
                                  : ListView(
                                      key: const ValueKey('settingsList'),
                                      children: [
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



